#!/bin/bash

# Exit on any error
set -e

# Function to print usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -v, --verbose   Enable verbose output"
    echo "  -f, --file FILE Specify input file"
    exit 1
}

# Default values
VERBOSE=false
INPUT_FILE=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--file)
            if [[ -n "$2" ]]; then
                INPUT_FILE="$2"
                shift 2
            else
                echo "Error: --file requires an argument." >&2
                usage
            fi
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            usage
            ;;
        *)
            echo "Error: Unknown argument $1" >&2
            usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "$INPUT_FILE" ]]; then
    echo "Error: --file is required." >&2
    usage
fi

# Check if file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: File '$INPUT_FILE' does not exist." >&2
    exit 1
fi

# Main script logic
if [[ "$VERBOSE" == true ]]; then
    echo "Processing file: $INPUT_FILE"
fi

# Example: Read file and process
while IFS= read -r line; do
    echo "$line"
done < "$INPUT_FILE"

# Success message
echo "Script completed successfully."

