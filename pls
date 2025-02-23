#!/bin/bash

# Read the token from token.txt
token=$(cat "$(dirname "$0")/token.txt")

# Initialize variables for model, label, color, and modes
model="meta-llama/llama-3.2-1b-instruct:free"
label="\033[0;32m[LLAMA]" # green color for Llama
color="\033[0;32m" # green by default
debug_mode=false
query_mode=false

# Parse command line arguments
while [[ "$1" == -* ]]; do
  case "$1" in
    -a)
      model="google/gemini-2.0-flash-001"
      label="\033[0;35m[GEMINI]" # purple color for Gemini
      color="\033[0;35m" # change color to purple for Gemini
      ;;
    -d)
      debug_mode=true
      ;;
    -q)
      query_mode=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

# Get user input as a string
args=$*

# If no arguments, prompt the user
if [ -z "$args" ]; then
  echo -e "\033[0;33m" # yellow for prompt
  read -p "SUP? : " args
fi

# Save the current working directory to a variable
cwd=$(pwd)

# Save OS name to a variable
os=$(uname -s)

# Disable globbing, to prevent command from being prematurely expanded
set -f

# Build the system message
system_message="You are a helpful assistant."
if [ "$query_mode" = false ]; then
  system_message+=" You will generate \($SHELL) commands based on user input. Your response should contain ONLY the command and NO explanation. Do NOT ever use newlines to separate commands, instead use ; or &&. The operating system is $os. The current working directory is $cwd."
fi

# Create the JSON payload
request=$(jq -n \
  --arg model "$model" \
  --arg args "$args" \
  --arg system_message "$system_message" \
  '{
    model: $model,
    messages: [
      {role: "system", content: $system_message},
      {role: "user", content: $args}
    ],
    temperature: 0.0,
    stream: true
  }')

# Function to get generation stats with fixed delay retries
get_generation_stats() {
  local generation_id=$1
  local max_retries=5
  local retry_delay=0.2  # 200ms between retries
  local attempt=0

  # Initial wait to allow for processing
  sleep 0.1  # 100ms initial wait

  while [ $attempt -lt $max_retries ]; do
    local temp_file=$(mktemp)
    local error_file=$(mktemp)

    # Add verbose output if debug mode is enabled
    local debug_flags=""
    if [ "$debug_mode" = true ]; then
      debug_flags="-v"
    fi

    local stats_response=$(curl $debug_flags -w "%{http_code}" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $token" \
      -H "HTTP-Referer: https://github.com/justinpopa/pls" \
      -H "X-Title: pls CLI Tool" \
      "https://openrouter.ai/api/v1/generation?id=$generation_id" -o "$temp_file" 2>"$error_file")
    
    local curl_exit_code=$?

    # Handle curl errors (connection issues, etc.)
    if [ $curl_exit_code -ne 0 ]; then
      echo -e "\033[0;31mCURL Error ($curl_exit_code): $(cat "$error_file")\033[0m" >&2
      rm "$temp_file" "$error_file"
      return 1
    fi

    # Print raw response in debug mode
    if [ "$debug_mode" = true ]; then
      echo -e "\033[0;33mDebug: Stats Raw Response:\033[0m" >&2
      cat "$temp_file" >&2
      echo -e "\033[0;33mDebug: Stats Response Code: $stats_response\033[0m" >&2
    fi
    
    if [ "$stats_response" = "200" ]; then
      # Try to parse the response as JSON and extract total_cost
      if jq -e '.data.total_cost' "$temp_file" >/dev/null 2>&1; then
        local total_cost=$(cat "$temp_file" | jq -r '.data.total_cost // "0"')
        rm "$temp_file" "$error_file"
        if [ "$total_cost" != "null" ] && [ "$total_cost" != "0" ]; then
          echo "$total_cost"
          return 0
        fi
      else
        if [ "$debug_mode" = true ]; then
          echo -e "\033[0;33mDebug: Invalid JSON in stats response\033[0m" >&2
        fi
        rm "$temp_file" "$error_file"
      fi
    else
      if [ "$debug_mode" = true ]; then
        echo -e "\033[0;33mDebug: Stats Error Response Body:\033[0m" >&2
        cat "$temp_file" >&2
      fi
      rm "$temp_file" "$error_file"
    fi

    sleep $retry_delay
    attempt=$((attempt + 1))
  done

  # If we've exhausted all retries, return 0
  echo "0"
}

# Function to directly print out the stream with labels and colors, and save it to a variable
stream_response() {
  echo -ne "$label " # Print the label with color before starting the stream
  response=""
  generation_id=""
  
  # Write curl output to a temporary file and get response code
  temp_file=$(mktemp)
  error_file=$(mktemp)

  # Add verbose output if debug mode is enabled
  debug_flags=""
  if [ "$debug_mode" = true ]; then
    debug_flags="-v"
  fi

  # Make the API call
  response_code=$(curl -N $debug_flags -w "%{http_code}" https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -H "HTTP-Referer: https://github.com/justinpopa/pls" \
    -H "X-Title: pls CLI Tool" \
    -d "$request" -o "$temp_file" 2>"$error_file")
  
  curl_exit_code=$?

  # Handle curl errors (connection issues, etc.)
  if [ $curl_exit_code -ne 0 ]; then
    echo -e "\033[0;31mCURL Error ($curl_exit_code): $(cat "$error_file")\033[0m"
    rm "$temp_file" "$error_file"
    return 1
  fi

  # Print raw response in debug mode
  if [ "$debug_mode" = true ]; then
    echo -e "\033[0;33mDebug: Raw Response:\033[0m"
    cat "$temp_file"
    echo -e "\033[0;33mDebug: Response Code: $response_code\033[0m"
  fi

  # Check response code
  if [ "$response_code" != "200" ]; then
    error_message=$(cat "$temp_file" | jq -r '.error.message // .error // "Unknown error"')
    echo -e "\033[0;31mError ($response_code): $error_message\033[0m"
    if [ "$debug_mode" = true ]; then
      echo -e "\033[0;33mDebug: Error Response Body:\033[0m"
      cat "$temp_file"
    fi
    rm "$temp_file" "$error_file"
    return 1
  fi

  rm "$error_file"

  # Process successful response
  while IFS= read -r line; do
    # Skip empty lines and processing status lines
    if [[ -z "$line" ]] || [[ "$line" == ": "* ]]; then
      continue
    fi

    if [[ "$line" == *"[DONE]"* ]]; then
      break
    fi
    
    # Only process lines that start with "data: "
    if [[ "$line" == "data: "* ]]; then
      # Extract the JSON part
      json_data=$(echo "$line" | sed 's/^data: //g')
      
      # Extract generation ID if not already set
      if [[ -z "$generation_id" ]]; then
        generation_id=$(echo "$json_data" | jq -r '.id // empty' 2>/dev/null)
      fi
      
      # Extract content if present
      content=$(echo "$json_data" | jq -r '.choices[0].delta.content // empty' 2>/dev/null)
      if [ -n "$content" ]; then
        echo -ne "$color$content"
        response+="$content"
      fi
    fi
  done < "$temp_file"
  
  rm "$temp_file" # Clean up the temporary file
  
  echo -e "\033[0m" # Reset color after stream ends

  # If query mode is not enabled, execute the command
  if [ "$query_mode" = false ]; then
    echo -e -n "\033[0;34m" # set color to blue
    eval "$response"
  fi

  # Get and display the actual cost from OpenRouter
  if [ -n "$generation_id" ]; then
    total_cost=$(get_generation_stats "$generation_id")
    if [ -n "$total_cost" ] && [ "$total_cost" != "0" ]; then
      echo -e "\033[0m[Total Cost: \$$total_cost]"
    fi
  fi
}

# Start streaming the response
stream_response

# Re-enable globbing
set +f
