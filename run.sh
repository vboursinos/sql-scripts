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

# Run the SQL files and redirect output to the log file and individual result files
{
    echo "Running SQL files..."
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code1.sql > "$RESULTS_DIR/select-code1-result.log" 2>&1
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code2.sql > "$RESULTS_DIR/select-code2-result.log" 2>&1
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code4.sql > "$RESULTS_DIR/select-code4-result.log" 2>&1
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code5.sql > "$RESULTS_DIR/select-code5-result.log" 2>&1
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code7.sql > "$RESULTS_DIR/select-code7-result.log" 2>&1
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code8.sql > "$RESULTS_DIR/select-code8-result.log" 2>&1
} 2>&1 | tee -a $LOG_FILE

# Check if the SQL files executed successfully
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "SQL files executed successfully. Check output.log for details." | tee -a $LOG_FILE
else
    echo "Error executing SQL files. Check output.log for details." | tee -a $LOG_FILE
    exit 1
fi

# Compare new query results with actual query results
echo "Comparing new query results with actual query results..."
for file in "$RESULTS_DIR"/*; do
    # Extract the base filename (without path)
    base_file=$(basename "$file")

    # Define the corresponding actual result file
    actual_file="actual_query_results/$base_file"

    # Check if the actual result file exists
    if [[ -f "$actual_file" ]]; then
        # Compare the two files
        if diff -q "$file" "$actual_file" > /dev/null; then
            echo "$base_file: Results match." | tee -a $LOG_FILE
        else
            echo "$base_file: Results do not match!" | tee -a $LOG_FILE
        fi
    else
        echo "$base_file: Actual result file not found!" | tee -a $LOG_FILE
    fi
done

# Print total execution time
echo "Total execution time: $SECONDS seconds" | tee -a $LOG_FILE