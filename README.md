# Setup

* Create a project to contain resources used in this demo

### LMS setup
* Open GCP Cloud Shell with SDK pointed at demo project
* In Cloud Shell, set up the first part of the infrastructure
```
cd ~
git clone https://github.com/jwdavis/ce-demo-lms.git
cd ~/ce-demo-lms/admin
sh 1_start_web_infra.sh <sql_pass>
``` 
-- substitute preferred sql password)
* In text editor, modify `2_begin_web_setup.txt`, substituting preferred supervisor and sql password
* SSH into the `clean-start-web` instance to create the base webapp server image. In SSH window...
	* Copy/paste commands from `2_begin_web_setup.txt` into SSH window
	* Close SSH window
* In Cloud Shell, complete the infrastructure by running script
```sh 4_finish_web_infra.sh```
* Wait 60-90 seconds for load balancer to come online
* Open browser pointed at load balancer IP and validate app is running

### Transcoding setup

* See instruction in ce-demo-vtc repo

# Demo instructions

### Stage 1 - Show app
* show home page
* show modules
* show module
* show create module - don't actually create module

### Stage 2 - Show architecture
* use diagram in the presenation
* walk them through
* point out pub/sub is there if you want

### Stage 3 - Show load balancer
* global ip
* backend service page

### Stage 4 - Show managed instance groups
* show the three web and one transcode
* show autoscaling setup

### Stage 5 - show traffic distribution
* start up test machines (if they have been stopped)
* ssh into test machines in na,eu,asia
* generate load from three regions
```ab -n 1500 -c 1 http://<your ip>/gcs/mantas.mp4```
* backend takes 30-60 seconds to refresh; stall
* show traffic from origins going to correct backends

### Stage 6 - show autoscaling web app
* generate high rps load from each test machine
```ab -n 150000 -c 16 http://<your ip>/```
* show instance groups changing size
* show backend page update

### Stage 7 - show autoscaling transcoding servers
* show raw media bucket
* show transcoded media bucket
* create module with video
* backend takes 30-60 seconds to kickoff
* show new server spinning up
* show cpu utilization in instance group
