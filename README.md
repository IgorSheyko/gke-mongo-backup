# GKE mongo backup
Scripts and config to backup mongodb to Google Cloud Storage in GKE

## Contains:
- kubernetes cronJob to execute our docker image with the necesari script and dependencies
- Dockerfile of the image used by de cronJob
- Script with the necesary steps to backup database and upload to GCS

## Steps
- Create bucket in Google Cloud Storage to upload backups

- Create Google cloud service account with credentials and access permisions for GCS (Storage Object Creator, Storage Object Viewer): 
https://cloud.google.com/kubernetes-engine/docs/tutorials/authenticating-to-cloud-platform?hl=es

- Create kubernetes secret in your kubernetes cluster to store Service Account Credentials:
```
 kubectl create secret generic gcs-key --from-file=key.json
```
 
- Build and push docker image to your registry

- Apply cron.yaml to your kubernetes cluster:

  ```
   kubectl apply -f cron.yaml
   ```

## Local test:
- Need to save your Google cloud service account credentials json in same path 
- Run:
    ```
    docker run -ti -v .:/var/mongobackup \
    -e GOOGLE_APPLICATION_CREDENTIALS='/var/mongobackup/key.json' \
    -e MONGO_HOST='<MONGO_HOST>' -e MONGO_USER='<MONGO_USER>' \
    -e MONGO_PASS='<MONGO_PASS>' \
    -e BUCKET_NAME='<BUCKET_NAME>' \
    mongobackup
    ``
    
## Backup means restore ^^
* full restore
```
mongorestore  --drop --gzip \
--host <MONGO_HOST> \
-u <MONGO_USER> -p <MONGO_PASS> \
--archive=<PATH_TO_ARCHIVE>.gz
```
* restore one db only
```
mongorestore  --nsInclude 'MY_DB_NAME.*' --drop --gzip \
--host <MONGO_HOST> \
-u <MONGO_USER> -p <MONGO_PASS> \
--archive=<PATH_TO_ARCHIVE>.gz
```