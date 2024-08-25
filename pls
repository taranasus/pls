#!/bin/bash

# Read the token from token.txt
# The file should contain the token, on one line, in the format sk-xxxxxxxxxxxxxxxxxxxxxxxx
token=$(cat "$(dirname "$0")/token.txt")

# Initialize variables for model and debug mode
model="gpt-4o-mini"
label="\033[0;32m[GPT]" # default green color for GPT
input_cost_per_million=0.150
output_cost_per_million=0.600
debug_mode=false

# Parse command line arguments
while [[ "$1" == -* ]]; do
  case "$1" in
    -a)
      model="gpt-4o"
      label="\033[0;35m[GPT ADVANCED]" # purple color for GPT ADVANCED
      input_cost_per_million=5.00
      output_cost_per_million=15.00
      ;;
    -d)
      debug_mode=true
      ;;
    *)
      echo -e -n "\033[0;31m" # set color to red
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

# Get user CLI arguments as a string
args=$*

# If no arguments are given, prompt the user for input
if [ -z "$args" ]; then
  echo -e "\033[0;33m" # set color to yellow for the prompt
  read -p "SUP? : " args
fi

# Save the current working directory to a variable
cwd=$(pwd)

# Save OS name to a variable
os=$(system_profiler SPSoftwareDataType | grep 'System Version:' | sed 's/System Version: //g' | sed 's/;//g')

# Disable globbing, to prevent OpenAI's command from being prematurely expanded
set -f

# Build the JSON request using jq
request=$(jq -n \
  --arg model "$model" \
  --arg shell "$SHELL" \
  --arg cwd "$cwd" \
  --arg os "$os" \
  --arg args "$args" \
  '{
    model: $model,
    messages: [
      {role: "system", content: "You are a helpful assistant. You will generate \($shell) commands based on user input. Your response should contain ONLY the command and NO explanation. Do NOT ever use newlines to separate commands, instead use ; or &&. The operating system is \($os).The current working directory is \($cwd)."},
      {role: "user", content: $args}
    ],
    temperature: 0.0
  }')

# Use echo to pass the request JSON to curl via stdin
response=$(echo $request | curl -s https://api.openai.com/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer '$token'' \
  -d @-)

# If OpenAI reported an error, tell the user, then exit the script
error=$(echo $response | jq -r '.error.message')
if [ "$error" != "null" ]
then
    echo -e -n "\033[0;31m" # set color to red
    echo "Error from OpenAI API:"
    echo $error
    echo "Aborted."
    exit 1
fi

# If debug mode is enabled, print the full JSON response and exit
if [ "$debug_mode" = true ]; then
  echo -e "\033[0;33m" # set color to yellow for debugging output
  echo "$response"
  exit 0
fi

# Parse the 'content', 'prompt_tokens', and 'completion_tokens' fields from the response which is in JSON format
command=$(echo $response | jq -r '.choices[0].message.content')
prompt_tokens=$(echo $response | jq -r '.usage.prompt_tokens')
completion_tokens=$(echo $response | jq -r '.usage.completion_tokens')

# Calculate the costs
input_cost=$(echo "scale=6; ($prompt_tokens / 1000000) * $input_cost_per_million" | bc)
output_cost=$(echo "scale=6; ($completion_tokens / 1000000) * $output_cost_per_million" | bc)
total_cost=$(echo "scale=6; $input_cost + $output_cost" | bc)

total_cost=$(printf "%.6f" "$total_cost" | sed 's/0*$//;s/\.$//')

# Echo the command with appropriate label and total cost
echo -e "$label [\$${total_cost}] $command"

# Re-enable globbing
set +f

# Execute the command
echo -e -n "\033[0;34m" # set color to blue
eval "$command"