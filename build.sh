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

# Create or clear the output log file
LOG_FILE="output.log"
> $LOG_FILE

# Create a directory for query results
RESULTS_DIR="query_results"
mkdir -p $RESULTS_DIR

# Function to run a query and save the result
run_query() {
    local query_file=$1
    local result_file=$2
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f "$query_file" > "$result_file" 2>&1
}

# Run the SQL files and redirect output to the log file and individual result files
{
    echo "Running SQL files..."
    run_query "select-code1.sql" "$RESULTS_DIR/select-code1-result.log"
    run_query "select-code2.sql" "$RESULTS_DIR/select-code2-result.log"
    run_query "select-code4.sql" "$RESULTS_DIR/select-code4-result.log"
    run_query "select-code5.sql" "$RESULTS_DIR/select-code5-result.log"
    run_query "select-code7.sql" "$RESULTS_DIR/select-code7-result.log"
    run_query "select-code8.sql" "$RESULTS_DIR/select-code8-result.log"
} 2>&1 | tee -a $LOG_FILE

echo "Select query execution time: $SECONDS seconds" | tee -a $LOG_FILE

# Check if the SQL files executed successfully
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "SQL files executed successfully. Check output.log for details." | tee -a $LOG_FILE
else
    echo "Error executing SQL files. Check output.log for details." | tee -a $LOG_FILE
    exit 1
fi

# Compare new query results with view content
echo "Comparing new query results with view content..."
mismatch_found=false

# Define an array of queries and corresponding views
declare -A queries_views=(
    ["select-code1.sql"]="demo.view_select_code_1"
    ["select-code2.sql"]="demo.view_select_code_2"
    ["select-code4.sql"]="demo.view_select_code_4"
    ["select-code5.sql"]="demo.view_select_code_5"
    ["select-code7.sql"]="demo.view_select_code_7"
    ["select-code8.sql"]="demo.view_select_code_8"
)

for query_file in "${!queries_views[@]}"; do
    view_name="${queries_views[$query_file]}"
    result_file="$RESULTS_DIR/${query_file%.sql}-result.log"

    # Query the view and save the output
    view_result_file="$RESULTS_DIR/${view_name}-result.log"
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "SELECT * FROM $view_name;" > "$view_result_file" 2>&1

    # Compare the two files
    if diff -q "$result_file" "$view_result_file" > /dev/null; then
        echo "$view_name: Results match." | tee -a $LOG_FILE
    else
        echo "$view_name: Results do not match!" | tee -a $LOG_FILE
        mismatch_found=true
    fi
done

# Exit with an error if any mismatches were found
if $mismatch_found; then
    echo "One or more results did not match. Exiting with error." | tee -a $LOG_FILE
    exit 1
fi

# Print total execution time
echo "Total execution time: $SECONDS seconds" | tee -a $LOG_FILE

# Delete the results directory if no mismatches were found
echo "Cleaning up: Deleting the results directory."
rm -rf "$RESULTS_DIR"