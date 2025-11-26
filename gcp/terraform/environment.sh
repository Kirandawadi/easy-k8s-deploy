#!/usr/bin/env bash
set -eo pipefail

# Read the service account JSON file created by start.sh
credentials_file="${GOOGLE_APPLICATION_CREDENTIALS}"
project_id="${GOOGLE_PROJECT_ID}"

# Read the credentials file content and escape it for JSON
if [ -f "$credentials_file" ]; then
    # Read file content and escape for JSON (remove newlines, escape quotes)
    credentials_content=$(cat "$credentials_file" | jq -c .)
else
    echo "Error: Credentials file not found at $credentials_file" >&2
    exit 1
fi

# Output JSON for Terraform external data source
# Note: credentials is the entire JSON as a string
cat <<EOF
{
    "project_id": "$project_id",
    "credentials": $(echo "$credentials_content" | jq -R .)
}
EOF
