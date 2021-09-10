resource "null_resource" "seed_files" {
  provisioner "local-exec" {
    command = "gsutil cp gs://bdev2_raw_media/* $BUCKET/videos/"
    environment = {
      BUCKET = format("%s_%s", "gs://bdev2_raw_media", var.project)
    }
  }
  depends_on = [time_sleep.wait_for_buckets]
}

resource "null_resource" "install_cloud_sql_proxy" {
  provisioner "local-exec" {
    command = <<EOT
      uname -a | grep 'Darwin' &> /dev/null
      if [ $? == 0 ]; then
        if [ ! -d "`eval echo ~/proxy/`" ]; then
          mkdir ~/proxy
          curl -o ~/proxy/cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.darwin.amd64
          chmod +x ~/proxy/cloud_sql_proxy
        fi
      else
        if [ ! -d "`eval echo ~/proxy/`" ]; then
          mkdir ~/proxy
          wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
          mv cloud_sql_proxy.linux.amd64 ~/proxy/cloud_sql_proxy
          chmod +x ~/proxy/cloud_sql_proxy
        fi
      fi
    EOT
  }
  depends_on = [google_sql_database_instance.sql_instances]
}
