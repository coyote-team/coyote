#!/bin/bash

# Set the current date
current_date=$(date +%m_%d_%Y)

# Set the file name pattern
file_name="coyote_db_${current_date}.sql"

# Docker container name
container_name="coyote_db_1"

# Directory on the host where backups will be stored
backup_dir=/root/db_backups

# 1. Create Postgres Dump inside the Docker Container
docker exec -it $container_name bash -c "pg_dump -U postgres -d coyote > /$file_name"

# 2. Copy the Dump from the Docker Container to the Host
# Make sure the backup directory exists
mkdir -p $backup_dir

# Copy the file from the container to the host
docker cp $container_name:/$file_name $backup_dir

# 3. Compress the dump file using `gzip`
xz $backup_dir/$file_name

# 4. Remove the dump file from the container
docker exec -it $container_name bash -c "rm /$file_name"

# 5. Remove backup files older than 30 days
find $backup_dir -type f -name "coyote_db_*.sql" -mtime +30 -exec rm {} \;
