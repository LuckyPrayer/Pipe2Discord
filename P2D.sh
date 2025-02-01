#!/bin/bash

# Path to the config file
CONFIG_FILE="P2D.cfg"

# Read the webhook URL and other config values from the config file
source "$CONFIG_FILE"

# Track the last time we sent a request (in milliseconds)
LAST_REQUEST_TIME=0

# Default rate limiting settings
MAX_REQUESTS_PER_SECOND=5
REQUEST_INTERVAL=200  # Interval in milliseconds (1000ms / 5 requests = 200ms)

# Function to apply rate limit based on response header
rate_limit() {
  # Get the current time in seconds and nanoseconds
  current_time_sec=$(date +%s)
  current_time_ns=$(date +%N)

  # Remove leading zeros from nanoseconds
  current_time_ns=$(echo $current_time_ns | sed 's/^0*//')

  # Convert current time to milliseconds
  current_time=$((current_time_sec * 1000 + current_time_ns / 1000000))

  # Calculate the time difference in milliseconds
  time_diff=$((current_time - LAST_REQUEST_TIME))

  # If we haven't waited long enough, sleep
  if [ $time_diff -lt $REQUEST_INTERVAL ]; then
    sleep_time=$(( (REQUEST_INTERVAL - time_diff) / 1000 ))  # Convert to seconds for sleep
    sleep $sleep_time
  fi

  # Update the last request time
  LAST_REQUEST_TIME=$current_time
}

# Function to send the message to Discord and handle rate limiting dynamically
send_to_discord() {
  local line=$1

  # Send the request and capture the response headers and body
  response=$(curl -s -w "%{http_code}" -o response_body.txt -X POST -H "Content-Type: application/json" \
      -d "{\"content\":\"$line\"}" \
      "$WEBHOOK_URL")

  # Check if the status code is 429 (rate-limited)
  if [[ "$response" == "429" ]]; then
    # Extract the Retry-After header (in seconds) from the response
    retry_after=$(grep -i "Retry-After" response_body.txt | awk '{print $2}')

    # If Retry-After is not empty, sleep for the given time
    if [ ! -z "$retry_after" ]; then
      echo "Rate limited. Retrying after $retry_after seconds..."
      sleep $retry_after
    fi
  fi
}

# Continuously read input and send to Discord
while IFS= read -r line || [ -n "$line" ]; do
  # Apply rate limit before sending
  rate_limit
  echo "$line"  # Print the line to the terminal  
  # Send the message to Discord and handle possible rate limiting dynamically
  send_to_discord "$line"
done