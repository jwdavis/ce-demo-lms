 #!/bin/bash

gcloud compute forwarding-rules delete lms-global-forwarding-rule --global --quiet
gcloud compute target-http-proxies delete lms-http-proxy --quiet
gcloud compute url-maps delete lms-http-lb --quiet
gcloud compute backend-services delete lms-backend-service --global --quiet
gcloud compute instance-groups managed delete lms-web-asia --zone asia-east1-a --quiet
gcloud compute instance-groups managed delete lms-web-eu --zone europe-west1-b --quiet
gcloud compute instance-groups managed delete lms-web-us --zone us-central1-a --quiet
gcloud compute health-checks delete lms-lb-health-check --quiet
gcloud compute http-health-checks delete lms-web-health-check --quiet
gcloud compute instance-templates delete lms-web-template --quiet
gcloud compute images delete lms-web-image --quiet
gcloud compute disks delete clean-start-web --zone us-central1-a --quiet
# gcloud sql instances patch lms-sql \
# --activation-policy=NEVER \
--quiet