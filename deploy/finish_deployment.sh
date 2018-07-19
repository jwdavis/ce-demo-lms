 #!/bin/bash

# copy initial files from source bucket
gsutil cp gs://bdev2_raw_media/ch1.mp4 gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID/videos/ch1.mp4
gsutil cp gs://bdev2_raw_media/ch2.mp4 gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID/videos/ch2.mp4
gsutil cp gs://bdev2_raw_media/ch3.mp4 gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID/videos/ch3.mp4
gsutil cp gs://bdev2_raw_media/mantas.mp4 gs://"bdev2_raw_media_"$DEVSHELL_PROJECT_ID/videos/mantas.mp4

# setup cloud sql proxy in cloud shell
uname -a | grep 'Darwin' &> /dev/null
if [ $? == 0 ]; then
    kill $(lsof -t -i:3306)
    mkdir ~/proxy
    curl -o ~/proxy/cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.darwin.amd64
    chmod +x ~/proxy/cloud_sql_proxy
else
  fuser -k 3306/tcp
  if [ ! -d "`eval echo ~/proxy/`" ]; then
    wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
    mkdir ~/proxy
    mv cloud_sql_proxy.linux.amd64 ~/proxy/cloud_sql_proxy
    chmod +x ~/proxy/cloud_sql_proxy
  fi
fi

# launch the proxy and run in background
~/proxy/cloud_sql_proxy -instances=$DEVSHELL_PROJECT_ID:us-central1:<sql_name>=tcp:3306 &

gcloud beta sql users set-password root % \
--instance=<sql_name> \
--password=$1

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
