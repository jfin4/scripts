#!/bin/bash

# Check if the correct number of arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 filepath process_id"
    exit 1
fi

# Assign the arguments to variables
FILEPATH=$1
PROCESS_ID=$2

# Check if the file exists
if [ ! -f "$FILEPATH" ]; then
    echo "File does not exist: $FILEPATH"
    exit 1
fi

# Iterate through each line in the file and send it to the process
while IFS= read -r line; do
    # Example of sending the line to the process. This command might vary based on the target.
    # This example uses `gdb` to send commands to a process by its PID. Adjust as needed.
    echo "$line" | gdb -p "$PROCESS_ID" -x -
done < "$FILEPATH"

# Clean up if necessary
echo "All lines sent successfully."

