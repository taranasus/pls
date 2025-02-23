#!/bin/bash

# Read the token from token.txt
token=$(cat "$(dirname "$0")/token.txt")

# Initialize variables for model, label, color, cost, and modes
model="gpt-4o-mini"
label="\033[0;32m[GPT]" # green color for GPT-4o-mini
color="\033[0;32m" # green by default
input_cost_per_million=0.150
output_cost_per_million=0.600
debug_mode=false
query_mode=false

# Parse command line arguments
while [[ "$1" == -* ]]; do
  case "$1" in
    -a)
      model="gpt-4o"
      label="\033[0;35m[GPT ADVANCED]" # purple color for GPT-4o
      color="\033[0;35m" # change color to purple for GPT-4o
      input_cost_per_million=5.00
      output_cost_per_million=15.00
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

# Disable globbing, to prevent OpenAI's command from being prematurely expanded
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

# Function to directly print out the stream with labels and colors, and save it to a variable
stream_response() {
  echo -ne "$label " # Print the label with color before starting the stream
  response=""
  
  # Write curl output to a temporary file
  temp_file=$(mktemp)
  curl -N -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d "$request" > "$temp_file"
  
  # Now read from the temporary file
  while IFS= read -r line; do
    if [[ "$line" == *"[DONE]"* ]]; then
      break
    fi
    content=$(echo "$line" | sed 's/^data: //g' | jq -r '.choices[0].delta.content // empty')
    if [ -n "$content" ]; then
      echo -ne "$color$content"
      response+="$content"
    fi
  done < "$temp_file"
  
  rm "$temp_file" # Clean up the temporary file
  
  echo -e "\033[0m" # Reset color after stream ends

  # If query mode is not enabled, execute the command
  if [ "$query_mode" = false ]; then
    echo -e -n "\033[0;34m" # set color to blue
    # After collecting the full response    
    eval "$response"
   
  fi

  # Calculate and display costs
  prompt_tokens=$(echo "$response" | wc -c)
  completion_tokens=$(echo "$response" | wc -c)
  input_cost=$(echo "scale=6; ($prompt_tokens / 1000000) * $input_cost_per_million" | bc)
  output_cost=$(echo "scale=6; ($completion_tokens / 1000000) * $output_cost_per_million" | bc)
  total_cost=$(echo "scale=6; $input_cost + $output_cost" | bc)
  total_cost=$(printf "%.6f" "$total_cost" | sed 's/0*$//;s/\.$//')
  
  echo -e "\033[0m[Total Cost: \$${total_cost}]"
}

# Start streaming the response
stream_response

# Re-enable globbing
set +f