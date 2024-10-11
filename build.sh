#!/bin/bash

# Reset the SECONDS variable to track execution time
SECONDS=0

# Load environment variables from .env file
export $(grep -v '^#' .env | xargs)

# Check if required variables are set
if [[ -z "$POSTGRES_HOST" || -z "$POSTGRES_USER" || -z "$POSTGRES_PASSWORD" || -z "$POSTGRES_PORT" || -z "$POSTGRES_DB" ]]; then
    echo "Error: One or more environment variables are not set."
    exit 1
fi

# Set the PGPASSWORD environment variable to avoid password prompts
export PGPASSWORD=$POSTGRES_PASSWORD

# Function to run a query and return the result
run_query() {
    local query_file=$1
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f "$query_file" -t -A
}

# Function to query a view and return the result
run_view_query() {
    local view_name=$1
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "SELECT * FROM $view_name;" -t -A
}

# Define an array of queries and corresponding views
declare -A queries_views=(
    ["select-code1.sql"]="demo.view_select_code_1"
    ["select-code2.sql"]="demo.view_select_code_2"
    ["select-code4.sql"]="demo.view_select_code_4"
    ["select-code5.sql"]="demo.view_select_code_5"
    ["select-code7.sql"]="demo.view_select_code_7"
    ["select-code8.sql"]="demo.view_select_code_8"
)

# Initialize mismatch flag
mismatch_found=false

# Loop through each query and view pair
for query_file in "${!queries_views[@]}"; do
    view_name="${queries_views[$query_file]}"

    # Get the query result
    query_result=$(run_query "$query_file")

    # Get the view result
    view_result=$(run_view_query "$view_name")

    # Compare the results
    if diff <(echo "$query_result") <(echo "$view_result") > /dev/null; then
        echo "$view_name: Results match."
    else
        echo "$view_name: Results do not match!"
        mismatch_found=true
    fi
done

# Check if any mismatches were found
if $mismatch_found; then
    echo "One or more results did not match. Exiting with error."
    exit 1
else
    echo "All results match."
fi

echo "Select query execution time: $SECONDS seconds"