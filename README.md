# Setup

### Project
1. Create a project to contain resources used in this demo, or re-use one
   that you've used previously.

### LMS setup
1. Open GCP Cloud Shell with SDK pointed at demo project
1. Run the following to ensure key services are enabled

   ```bash
   export PROJECT_ID=$(gcloud config get-value project)
   gcloud services enable sqladmin.googleapis.com --quiet
   gcloud services enable pubsub.googleapis.com --quiet
   gcloud services enable compute.googleapis.com --quiet
   gcloud services enable cloudresourcemanager.googleapis.com --quiet
   sleep 60
   ```

   This will take 5-8 minutes to complete. The `sleep` at the end is meant
   to avoid timing problems where the APIs won't respond immediately after
   being enabled.

1. Run the following get get the current version of demo into home directory

   ```bash
   cd ~
   rm -rf ce-demo-lms
   git clone https://github.com/jwdavis/ce-demo-lms.git
   cd ~/ce-demo-lms/terraform
   ```

1. Run the following to populated some Terraform variables. Make sure to replace
   the placeholders (including the <>) with real values:

   ```bash
   export TF_VAR_SUP_PASS=<sup_pass>
   export TF_VAR_SQL_PASS=<sql_pass>
   export TF_VAR_SQL_SUFFIX=$(date +%Y%m%d%H%M%S)
   export TF_VAR_project=$PROJECT_ID
   ```

2. Run the following to do the Terraform build:
   
   ```bash
   terraform init
   terraform apply -auto-approve
   ```

3. Installation with take about 20 minutes to complete (Cloud SQL takes a
   long time to create a primary and 2 read replicas). Also, after TF shows
   it's down, it may still take 5+ minutes for the load balancer to settle down
4. Open browser pointed at load balancer IP (this is shown after the setup has
   completed) and validate app is running

# Demo instructions

### Stage 1 - Show app
1. show home page
1. show modules
1. show a module module with video playing
2. show create module

### Stage 2 - Show architecture
![Architecture diagram](./arch.png)
1. walk them through diagram
   1. Note that MIGs are autoscaling 1-10
   2. NGINX servers scale based on LB load
   3. Transcoding servers scale based on CPU load
   4. Primary Cloud SQL instance is HA
   5. There are Cloud SQL read replicas in other regions
   6. App is written to read from local replica, write to primary
   7. When video is uploaded, app sends pubsub message to topic
   8. Transcoding app reads messages about uploads and processes them
   9. Server speak to Cloud SQL using Cloud SQL Auth Proxy
2. Optionally, you can call out additional details
   1. Custom subnet network is created for solution
   2. Firewall rules only allow HTTP traffic from google LBs and HC
   3. Cloud SQL Admin API is enabled during setup
   4. What might you do differently?

### Stage 3 - Show load balancer
1. global ip
1. backend service page (note cdn)
1. backend bucket page (note cdn)
1. url map page

### Stage 4 - Show managed instance groups
1. show the three web and one transcode
1. show autoscaling setup

### Stage 5 - Show traffic distribution
1. sSSHsh into test machines in us, europe, asia
2. generate load from three regions (the command customized for your lb IP is
   shown in cloud shell)
3. show them what's happening using the LB monitoring page.
   1. it takes a while for the page to update
   2. hopefully, it shows traffic from each source going to different backends
4. Google Cloud Monitoring dashboard for load balancing can also be fun
5. Google Cloud Monitoring dashboard for Cloud SQL can be fun

### Stage 6 - Show videos serving out of CDN
1. on each test VM, generate load of video (the command customized for your lb
   IP is shown in cloud shell)
2. show each vm having similar performance (though videos are in us)
4. show the cdn monitoring page to see increase in cdn use
   1. it takes a while for the page to update
5. show lms backend service has no traffic
   1. the videos are being served by bucket and CDN
6. click on backend bucket in lb monitoring page to show requests there
8. you may note that CDN only caches objects <10MB (mantas video is)
9.  there's a beta for large object caching

### Stage 7 - Show autoscaling web app
1. on each test VM, generate high rps load from each test machine
   (the command customized for your lb IP is shown in cloud shell)
2. show instance groups changing size
3. in LB monitoring page, click on backend service to show backend details
4. watch the test machines to see if ab errors out
5. The river chart will be totally messed up now, with all traffic showing
   as flowing through the /videos path which is wrong. This is an error
   in the chart.

### Optional - Show autoscaling transcoding servers
1. show raw media bucket
1. show transcoded media bucket
1. create module with video
1. backend takes 30-60 seconds to kickoff
1. show new server spinning up
1. show cpu utilization in instance group
   1. this takes a while to update

### Optional - IaC demo
1. The entire build is handled via Terraform
1. Can be fun to start deployment, then show students some of how it works

# Cleanup

1. Run the following in Cloud Shell

   ```bash
   # Workaround https://github.com/hashicorp/terraform-provider-google/issues/6782
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 net.ipv6.conf.default.disable_ipv6=1 net.ipv6.conf.lo.disable_ipv6=1 > /dev/null
    export APIS="googleapis.com www.googleapis.com storage.googleapis.com iam.googleapis.com cloudresourcemanager.googleapis.com sqladmin.googleapis.com pubsub.googleapis.com compute.googleapis.com"
    for name in $APIS
    do
      ipv4=$(getent ahostsv4 "$name" | head -n 1 | awk '{ print $1 }')
      grep -q "$name" /etc/hosts || ([ -n "$ipv4" ] && sudo sh -c "echo '$ipv4 $name' >> /etc/hosts")
    done
   # Workaround end
   ```

   ```bash
   cd ~/ce-demo-lms/terraform 
   terraform destroy -auto-approve && \
      cd ~ && \
      rm -rf ~/ce-demo-lms && \
      export PROJECT_ID=$(gcloud config get-value project) && \
   ```

2. If you receive an error that looks similar to this

   ```
   terraform dial tcp [2607:f8b0:400c:c15::80]:443: connect: cannot assign requested address
   ```

   Just rerun the command; eventually it'll all work. This is a bug in TF and Cloud Shell.