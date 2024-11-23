#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install it first." >&2
    exit 1
fi

# Parse arguments
while getopts d: flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
    esac
done

# Check if domain argument is provided
if [ -z "$domain" ]; then
    echo "Usage: $0 -d domain.com" >&2
    exit 1
fi

# Retry logic for crt.sh requests
max_retries=3
retry_count=0
success=false

while [[ $retry_count -lt $max_retries && $success == false ]]; do
    echo "Fetching subdomains for $domain from crt.sh..." >&2
    response=$(curl -s "https://crt.sh/?q=%25.$domain&output=json")

    # Check if crt.sh returned an HTML response (error or rate-limiting)
    if echo "$response" | grep -q "<html>"; then
        echo "Error: crt.sh returned an HTML response (rate-limited or error). Retrying..." >&2
        ((retry_count++))
        sleep 5  # Wait 5 seconds before retrying
    else
        success=true
    fi
done

# If the request failed after retries, exit
if [ "$success" = false ]; then
    echo "Error: Failed to retrieve valid response after $max_retries attempts." >&2
    exit 1
fi

# Check if the response is valid JSON
if echo "$response" | jq . > /dev/null 2>&1; then
    echo "$response" | jq '.[].name_value' | sed 's/\\n/\n/g' | sort -u | sed 's/"//g' | sed 's/\*\.//g' >> all-subs.txt
else
    echo "Error: crt.sh returned an invalid or empty response." >&2
    exit 1
fi
