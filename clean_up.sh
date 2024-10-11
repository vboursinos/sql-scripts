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

# Function to drop views
drop_views() {
    echo "Dropping views..." | tee -a $LOG_FILE

    # Drop each view
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "
    DROP VIEW IF EXISTS demo.view_select_code_1;
    DROP VIEW IF EXISTS demo.view_select_code_2;
    DROP VIEW IF EXISTS demo.view_select_code_4;
    DROP VIEW IF EXISTS demo.view_select_code_5;
    DROP VIEW IF EXISTS demo.view_select_code_7;
    DROP VIEW IF EXISTS demo.view_select_code_8;" | tee -a $LOG_FILE
}

# Run the function to drop views
{
    drop_views
} 2>&1 | tee -a $LOG_FILE

# Check if the view deletion was successful
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Views dropped successfully. Check output.log for details." | tee -a $LOG_FILE
else
    echo "Error dropping views. Check output.log for details." | tee -a $LOG_FILE
    exit 1
fi

# Print total execution time
echo "Total execution time: $SECONDS seconds" | tee -a $LOG_FILE