# Utility functions
get_log_date () {
    date +[%Y-%m-%d\ %H:%M:%S]
}
get_file_date () {
    date +%Y%m%d%H%M%S
}

# Validate needed ENV vars
if [ -z "$MONGO_HOST" ]; then
    echo "$(get_log_date) MONGO_HOST is unset or set to the empty string"
    exit 1
fi
if [ -z "$MONGO_USER" ]; then
    echo "$(get_log_date) MONGO_USER is unset or set to the empty string"
    exit 1
fi
if [ -z "$MONGO_PASS" ]; then
    echo "$(get_log_date) MONGO_PASS is unset or set to the empty string"
    exit 1
fi
if [ -z "$BUCKET_NAME" ]; then
    echo "$(get_log_date) BUCKET_NAME is unset or set to the empty string"
    exit 1
fi

# Path in which to create the backup (will get cleaned later)
BACKUP_PATH="/tmp/"

# START
echo "$(get_log_date) Mongo backup started"

# Activate google cloud service account
echo "$(get_log_date) Activating service account"
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

# Backup filename
BACKUP_FILENAME="$(get_file_date).gz"

# Create the backup
echo "$(get_log_date) [Step 1/3] Running mongodump from $MONGO_HOST to $BACKUP_PATH"
#mongodump --uri $MONGO_URI -o $BACKUP_PATH --quiet
mongodump --host $MONGO_HOST --port 27017 -u $MONGO_USER -p $MONGO_PASS --gzip --archive="$BACKUP_PATH$BACKUP_FILENAME"
echo $BACKUP_PATH$BACKUP_FILENAME
# Compress
# echo "$(get_log_date) [Step 2/3] Creating tar file"
# tar -czf $BACKUP_PATH$BACKUP_FILENAME $BACKUP_PATH*

# Copy to Google Cloud Storage
echo "$(get_log_date) [Step 3/3] Uploading archive to Google Cloud Storage"
echo "Copying $BACKUP_PATH$BACKUP_FILENAME to gs://$BUCKET_NAME/$BACKUP_FILENAME"
gsutil cp $BACKUP_PATH$BACKUP_FILENAME gs://$BUCKET_NAME/$BACKUP_FILENAME 2>&1

# Clean
echo "Removing backup data"
rm -rf $BACKUP_PATH*

# FINISH
echo "$(get_log_date) Copying finished"
