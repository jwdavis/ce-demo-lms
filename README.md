# Setup

### Project
1. Create a project to contain resources used in this demo

### LMS setup
1. Open GCP Cloud Shell with SDK pointed at demo project
1. In Cloud Shell, run the deployment, providing preferred passwords for SQL and Supervisor
```
cd ~
git clone https://github.com/jwdavis/ce-demo-lms.git
cd ~/ce-demo-lms/deploy
. ./start_deployment.sh <sql_pass> <supervisor_pass> <billing_account_id> <sql_instance_name>
```
For example...
```
git clone https://github.com/jwdavis/ce-demo-lms.git
cd ~/ce-demo-lms/deploy
. ./start_deployment.sh sql.pass sup.pass 001153-165B33-99FB93 my-sql-instance
```
1. Wait a couple minutes for the load balancer to come online. Overall, it'll take 10+ minutes for the entire solution to be demoable.
1. Open browser pointed at load balancer IP and validate app is running

# Demo instructions

### Stage 1 - Show app
1. show home page
1. show modules
1. show module
1. show create module - don't actually create module

### Stage 2 - Show architecture
![Architecture diagram](./arch.png)
1. walk them through diagram
1. point out pub/sub is there if you want

### Stage 3 - Show load balancer
1. global ip
1. backend service page (note cdn)
1. backend bucket page (note cdn)
1. url map page

### Stage 4 - Show managed instance groups
1. show the three web and one transcode
1. show autoscaling setup

### Stage 5 - show traffic distribution
1. ssh into test machines in us, europe, asia
1. generate load from three regions
```watch -n 1 curl -o /dev/null http://<ip>/```
1. backend takes 30-60 seconds to refresh; stall
1. show traffic from origins going to correct backends

### Stage 6 - show videos serving out of CDN
1. generate load of video
```ab -n 2500 -c 1 http://<ip>/videos/mantas.mp4```
1. show each vm having similar performance (though videos in us)
1. show no increase in load on backend service (served from bucket)
1. You may note that CDN only caches objects <10MB (mantas video is)
1. There's a beta for large object caching

### Stage 6 - show autoscaling web app
1. generate high rps load from each test machine
```ab -n 100000 -c 3 -r -l http://<ip>/```
1. show instance groups changing size
1. show backend page update
1. watch the test machines to see if ab errors out

### Optional - show autoscaling transcoding servers
1. show raw media bucket
1. show transcoded media bucket
1. create module with video
1. backend takes 30-60 seconds to kickoff
1. show new server spinning up
1. show cpu utilization in instance group

### Optional - Deployment manager demo
1. The entire build is handled via DM
1. Can be fun to start deployment, then show students
1. The details page for the deployment shows all the dependencies in action
1. The template and python files gives a good idea of how DM works.

