#!/usr/bin/env bash
set -euo pipefail

# Usage check
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <target_path> <filename>"
    exit 1
fi

TARGET_DIR="$1"
FILENAME="$2"

# Absolute path to the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Full path to the source file
SOURCE_FILE="$SCRIPT_DIR/$FILENAME"

# Check if the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: source file '$SOURCE_FILE' does not exist."
    exit 1
fi

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: target directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Go to the target directory
cd "$TARGET_DIR"

# Create relative symlink
ln -sf "$(realpath --relative-to="$(pwd)" "$SOURCE_FILE")" "$FILENAME"

echo "Created symlink '$TARGET_DIR/$FILENAME' -> '$SOURCE_FILE'"