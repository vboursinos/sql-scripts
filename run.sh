
Copy
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

# Run the SQL files and redirect output to the log file
{
    echo "Running SQL files..."
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code1.sql
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code2.sql
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code4.sql
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code5.sql
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code7.sql
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -f select-code8.sql
} 2>&1 | tee -a $LOG_FILE

# Check if the SQL files executed successfully
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "SQL files executed successfully. Check output.log for details." | tee -a $LOG_FILE
else
    echo "Error executing SQL files. Check output.log for details." | tee -a $LOG_FILE
    exit 1
fi

# Print total execution time
echo "Total execution time: $SECONDS seconds" | tee -a $LOG_FILE
