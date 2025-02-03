#!/bin/bash

# Define the directory to process (can be the current directory by default)
directory="."

# Find all files matching the pattern
find "$directory" -type f -name "*_*.xml" | while read file; do
    # Extract the base filename without the directory
    base_filename=$(basename "$file")
    
    # Extract the day, month, and year using pattern matching
    day=$(echo "$base_filename" | cut -d'_' -f1)
    month=$(echo "$base_filename" | cut -d'_' -f2)
    year=$(echo "$base_filename" | cut -d'_' -f3 | cut -d'.' -f1)

    # Reformat the filename to YYYY_MM_DD
    new_filename="${year}_${month}_${day}.xml"

    # Create the year folder if it doesn't exist
    if [ ! -d "$directory/$year" ]; then
        mkdir "$directory/$year"
    fi

    # Move the file into the year folder with the new name
    mv "$file" "$directory/$year/$new_filename"
done





