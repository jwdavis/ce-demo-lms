 #!/bin/bash

# delete updated vm while saving boot disk
gcloud compute instances delete clean-start-web \
--zone us-central1-a \
--quiet

# create image from boot disk
gcloud compute images create lms-web-image \
--source-disk clean-start-web \
--source-disk-zone us-central1-a \
--quiet

# create instance template from image
gcloud compute instance-templates create lms-web-template  \
--machine-type=n1-standard-1 \
--image=lms-web-image \
--scopes=\
https://www.googleapis.com/auth/cloud.useraccounts.readonly,\
https://www.googleapis.com/auth/devstorage.read_write,\
https://www.googleapis.com/auth/logging.write,\
https://www.googleapis.com/auth/monitoring.write,\
https://www.googleapis.com/auth/service.management.readonly,\
https://www.googleapis.com/auth/servicecontrol,\
https://www.googleapis.com/auth/pubsub,\
sql-admin \
--tags=webapp \
--quiet

# create na managed instance group using template
gcloud compute instance-groups managed create lms-web-us \
--template=lms-web-template \
--size=1 \
--base-instance-name=lms-web-us \
--zone=us-central1-a

# create emea managed instance group using template
gcloud compute instance-groups managed create lms-web-eu \
--template=lms-web-template \
--size=1 \
--base-instance-name=lms-web-eu \
--zone=europe-west1-b

# create apac managed instance group using template
gcloud compute instance-groups managed create lms-web-asia \
--template=lms-web-template \
--size=1 \
--base-instance-name=lms-web-asia \
--zone=asia-east1-a

# create ip address for web app
gcloud compute addresses create bdev2 --global

# create firewall rule allowing incoming http from load balancer
gcloud compute firewall-rules create webapp-allow \
--allow=tcp:80,tcp:443,tcp:9001 \
--source-ranges=0.0.0.0/0 \
--target-tags=webapp

# create firewall rule allowing incoming supervisor traffic to transcoding
gcloud compute firewall-rules create transcode-allow \
--allow=tcp:9001 \
--source-ranges=0.0.0.0 \
--target-tags=transcode

# create health check for use in load-balancer
gcloud compute health-checks create http lms-lb-health-check \
	--port 80 \
    --check-interval 30s \
    --healthy-threshold 1 \
    --timeout 10s \
    --unhealthy-threshold 3

# create health check for use in managed-instance-group
gcloud compute http-health-checks create lms-web-health-check \
	--port 80 \
    --check-interval 30s \
    --healthy-threshold 1 \
    --timeout 10s \
    --unhealthy-threshold 3

# set named ports of na mig
gcloud compute instance-groups managed set-named-ports lms-web-us \
--named-ports http:80 \
--zone us-central1-a

# set named ports of emea mig
gcloud compute instance-groups managed set-named-ports lms-web-eu \
--named-ports http:80 \
--zone europe-west1-b

# set named ports of apac mig
gcloud compute instance-groups managed set-named-ports lms-web-asia \
--named-ports http:80 \
--zone asia-east1-a

# create backend service for the load balancer
gcloud compute backend-services create lms-backend-service \
--protocol HTTP \
--health-checks lms-lb-health-check \
--global

# add na backend
gcloud compute backend-services add-backend lms-backend-service \
--balancing-mode UTILIZATION \
--max-utilization 0.8 \
--capacity-scaler 1 \
--instance-group lms-web-us \
--instance-group-zone us-central1-a \
--max-rate-per-instance=30 \
--global

# add emea backend
gcloud compute backend-services add-backend lms-backend-service \
--balancing-mode UTILIZATION \
--max-utilization 0.8 \
--capacity-scaler 1 \
--instance-group lms-web-eu \
--instance-group-zone europe-west1-b \
--max-rate-per-instance=30 \
--global

# add apac backend
gcloud compute backend-services add-backend lms-backend-service \
--balancing-mode UTILIZATION \
--max-utilization 0.8 \
--capacity-scaler 1 \
--instance-group lms-web-asia \
--instance-group-zone asia-east1-a \
--max-rate-per-instance=30 \
--global

# create url map for load balancer
gcloud compute url-maps create lms-http-lb \
--default-service lms-backend-service

# create the target proxy for the load balancer
gcloud compute target-http-proxies create lms-http-proxy \
--url-map=lms-http-lb

# create the global forwarding rule for the load balancer
gcloud compute forwarding-rules create lms-global-forwarding-rule \
--address bdev2 --global \
--target-http-proxy lms-http-proxy \
--ports 80

# set autoscaling for na mig
gcloud compute instance-groups managed set-autoscaling lms-web-us \
--max-num-replicas=5 \
--cool-down-period=180 \
--min-num-replicas=1 \
--scale-based-on-load-balancing \
--target-load-balancing-utilization=0.8 \
--zone us-central1-a

# set autohealing for na mig
gcloud beta compute instance-groups managed set-autohealing lms-web-us \
--http-health-check=lms-web-health-check \
--initial-delay=180 \
--zone us-central1-a

# set autoscaling for emea mig
gcloud compute instance-groups managed set-autoscaling lms-web-eu \
--max-num-replicas=5 \
--cool-down-period=180 \
--min-num-replicas=1 \
--scale-based-on-load-balancing \
--target-load-balancing-utilization=0.8 \
--zone europe-west1-b

# set autohealing for emea mig
gcloud beta compute instance-groups managed set-autohealing lms-web-eu \
--http-health-check=lms-web-health-check \
--initial-delay=180 \
--zone europe-west1-b

# set autoscaling for apac mig
gcloud compute instance-groups managed set-autoscaling lms-web-asia \
--max-num-replicas=5 \
--cool-down-period=180 \
--min-num-replicas=1 \
--scale-based-on-load-balancing \
--target-load-balancing-utilization=0.8 \
--zone asia-east1-a

# set autohealing for apac mig
gcloud beta compute instance-groups managed set-autohealing lms-web-asia \
--http-health-check=lms-web-health-check \
--initial-delay=180 \
--zone asia-east1-a