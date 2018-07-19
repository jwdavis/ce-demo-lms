 #!/bin/bash

gsutil -m rm -rf gs://bdev2_raw_media_$DEVSHELL_PROJECT_ID/*
gsutil -m rm -rf gs://bdev2_media_$DEVSHELL_PROJECT_ID/*
gcloud deployment-manager deployments delete lms --quiet
