#!/usr/bin/env bash

# Define the timestamp
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Define the backup filename
BACKUP_FILENAME="/home/ubuntu/backup/openclaw-backup-$TIMESTAMP.zip"

# Define the paths to backup
PATHS_TO_BACKUP=(
    "/home/ubuntu/.npm-packages/lib/node_modules/openclaw"
    "/home/ubuntu/.openclaw"
    "/home/ubuntu/.config/opencode"
)

# Run 7z to create the zip file
# 'a' adds files to the archive
# '-xr!node_modules' excludes all node_modules directories
7z a "$BACKUP_FILENAME" "${PATHS_TO_BACKUP[@]}" -xr!node_modules

echo "Backup created: $BACKUP_FILENAME"

# Cleanup: Delete backups older than 3 days based on filename timestamp
BACKUP_DIR=$(dirname "$BACKUP_FILENAME")
CUTOFF=$(date -d "3 days ago" +%s)

echo "Cleaning up backups older than 3 days in $BACKUP_DIR..."

for file in "$BACKUP_DIR"/openclaw-backup-*.zip; do
    [ -e "$file" ] || continue
    
    # Extract timestamp YYYYMMDD-HHMMSS from filename
    filename=$(basename "$file")
    ts_str=$(echo "$filename" | grep -oP '\d{8}-\d{6}')
    
    if [ -n "$ts_str" ]; then
        formatted_ts="${ts_str:0:4}-${ts_str:4:2}-${ts_str:6:2} ${ts_str:9:2}:${ts_str:11:2}:${ts_str:13:2}"
        file_ts=$(date -d "$formatted_ts" +%s 2>/dev/null)
        
        if [ -n "$file_ts" ] && [ "$file_ts" -lt "$CUTOFF" ]; then
            echo "Deleting old backup: $filename"
            rm "$file"
        fi
    fi
done
