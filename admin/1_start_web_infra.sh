 #!/bin/bash

# enable apis
gcloud service-management enable compute-component.googleapis.com
gcloud service-management enable sqladmin.googleapis.com
gcloud service-management enable pubsub.googleapis.com 

# make buckets
gsutil mb -l US gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID
gsutil mb -l US gs://"bdev2_media_"$DEVSHELL_PROJECT_ID

# set defacl on buckets
gsutil defacl ch -u AllUsers:R gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID
gsutil defacl ch -u AllUsers:R gs://"bdev2_media_"$DEVSHELL_PROJECT_ID

# copy initial files from source bucket
gsutil cp gs://bdev2_raw_media/ch1.mp4 gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID/ch1.mp4
gsutil cp gs://bdev2_raw_media/ch2.mp4 gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID/ch2.mp4
gsutil cp gs://bdev2_raw_media/ch3.mp4 gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID/ch3.mp4
gsutil cp gs://bdev2_raw_media/mantas.mp4 gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID/mantas.mp4

# make pubsub topic/sub
gcloud beta pubsub topics create video_to_transcode
gcloud beta pubsub subscriptions create file_ready \
--topic video_to_transcode \
--ack-deadline=30

# create cloud sql instance
gcloud sql instances create lms-sql \
--activation-policy=ALWAYS \
--database-version="MYSQL_5_6" \
--gce-zone=us-central1-a \
--tier=db-n1-standard-1 \
--quiet

# set the root user password
gcloud beta sql users set-password root % \
--instance=lms-sql \
--password=$1

# create lms database
gcloud sql databases create lms \
--instance=lms-sql

# setup cloud sql proxy in cloud shell
if [ ! -d "`eval echo ~/proxy/`" ]; then
	wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
	mkdir ~/proxy
	mkdir ~/proxy/cloud_sql
	mv cloud_sql_proxy.linux.amd64 ~/proxy/cloud_sql_proxy
	chmod +x ~/proxy/cloud_sql_proxy
fi

# launch the proxy and run in background
kill $(lsof -t -i:3306)
~/proxy/cloud_sql_proxy -instances=$DEVSHELL_PROJECT_ID:us-central1:lms-sql=tcp:3306 &

# create base vm for app server
gcloud compute instances create clean-start-web \
--zone us-central1-a \
--machine-type n1-standard-1 \
--no-boot-disk-auto-delete \
--scopes=\
https://www.googleapis.com/auth/cloud.useraccounts.readonly,\
https://www.googleapis.com/auth/devstorage.read_write,\
https://www.googleapis.com/auth/logging.write,\
https://www.googleapis.com/auth/monitoring.write,\
https://www.googleapis.com/auth/service.management.readonly,\
https://www.googleapis.com/auth/servicecontrol,\
https://www.googleapis.com/auth/pubsub,\
sql-admin \
--tags=webapp

for i in 'us-west1-a' 'europe-west1-b' 'asia-east1-a'
do 
	gcloud compute instances create test-$i \
	--zone $i \
	--machine-type n1-standard-1 \
	--metadata startup-script="sudo apt-get update; sudo apt-get install apache2-utils -y" \
	--tags=test
done


# create the tables
mysql -uroot -p$1 --host 127.0.0.1 -e "CREATE TABLE lms.users (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, email TINYTEXT, name TINYTEXT, title TINYTEXT);"
mysql -uroot -p$1 --host 127.0.0.1 -e "CREATE TABLE lms.paths (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, name TINYTEXT, description VARCHAR(500));"
mysql -uroot -p$1 --host 127.0.0.1 -e "CREATE TABLE lms.modules (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, name TINYTEXT, description VARCHAR(500), content LONGTEXT, media TINYTEXT);"

# create the initial module rowscd 
mysql -uroot -p$1 --host 127.0.0.1 -e 'INSERT INTO lms.modules (name, description, content, media) VALUES ("CPO200: Chapter 1","Chapter 1 video for v1.3 revision","https://googl.gl/t1z4f","ch1.mp4")'
mysql -uroot -p$1 --host 127.0.0.1 -e 'INSERT INTO lms.modules (name, description, content, media) VALUES ("CPO200: Chapter 2","Chapter 2 video for v1.3 revision","https://googl.gl/t1z4f","ch2.mp4")'
mysql -uroot -p$1 --host 127.0.0.1 -e 'INSERT INTO lms.modules (name, description, content, media) VALUES ("CPO200: Chapter 3","Chapter 3 video for v1.3 revision","https://googl.gl/t1z4f","ch3.mp4")'

# create the initial path rows
mysql -uroot -p$1 --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Cloud Master","Modules for mastering clouds")'
mysql -uroot -p$1 --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Time Master","Modules for mastering Times")'
mysql -uroot -p$1 --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Key Master","Modules for mastering Keys")'
mysql -uroot -p$1 --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Master and Commander","Modules for mastering sailing")'
mysql -uroot -p$1 --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Path not taken","Modules for getting lost")'
mysql -uroot -p$1 --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Off the beaten path","Modules for being alone")'