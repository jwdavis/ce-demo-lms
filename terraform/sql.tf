resource "google_sql_database_instance" "sql_instances" {
  count = length(var.sql_instances)
  name = (
    join("-",
      [
        var.sql_instances[count.index]["name"],
        var.SQL_SUFFIX
      ]
    )
  )
  database_version    = var.sql_instances[count.index]["database_version"]
  region              = var.sql_instances[count.index]["region"]
  deletion_protection = false

  settings {
    tier              = var.sql_instances[count.index]["tier"]
    activation_policy = var.sql_instances[count.index]["activation_policy"]
    availability_type = var.sql_instances[count.index]["availability_type"]
    backup_configuration {
      binary_log_enabled             = true
      enabled                        = true
      start_time                     = null
      location                       = null
      transaction_log_retention_days = null
      backup_retention_settings {
        retained_backups = 5
        retention_unit   = "COUNT"
      }
    }
  }
  # depends_on = [project-services]
}

resource "google_sql_user" "sql_users" {
  count    = length(var.sql_users)
  name     = var.sql_users[count.index]["name"]
  instance = local.sql_instances[var.sql_users[count.index]["instance"]]
  password = var.SQL_PASS
}

resource "google_sql_database" "sql_databases" {
  count    = length(var.sql_databases)
  name     = var.sql_databases[count.index]["name"]
  instance = local.sql_instances[var.sql_users[count.index]["instance"]]
}

# this currently runs the same script against any instance
# listed in the tfvars file; should add a way
# to have per instance script contents
resource "null_resource" "sql_init" {
  count = length(var.sql_init_scripts)
  provisioner "local-exec" {
    command = <<-EOT
      # kill the proxy if it's already running
      uname -a | grep 'Darwin' &> /dev/null
      if [ $? == 0 ]; then
        kill $(lsof -t -i:3306)
        os="mac"
      else
        fuser -k 3306/tcp
        os="other"
      fi

      ~/proxy/cloud_sql_proxy -instances=${var.project}:${var.sql_init_scripts[count.index]["region"]}:${local.sql_instances[var.sql_init_scripts[count.index]["instance"]]}=tcp:3306 &
      sleep 10

      # create the tables
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e "CREATE TABLE lms.users (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, email TINYTEXT, name TINYTEXT, title TINYTEXT);"
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e "CREATE TABLE lms.paths (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, name TINYTEXT, description VARCHAR(500));"
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e "CREATE TABLE lms.modules (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, name TINYTEXT, description VARCHAR(500), content LONGTEXT, media TINYTEXT);"

      # create the initial module rowscd
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e 'INSERT INTO lms.modules (name, description, content, media) VALUES ("CPO200: Chapter 1","Chapter 1 video for v1.3 revision","https://googl.gl/t1z4f","ch1.mp4")'
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e 'INSERT INTO lms.modules (name, description, content, media) VALUES ("CPO200: Chapter 2","Chapter 2 video for v1.3 revision","https://googl.gl/t1z4f","ch2.mp4")'
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e 'INSERT INTO lms.modules (name, description, content, media) VALUES ("CPO200: Chapter 3","Chapter 3 video for v1.3 revision","https://googl.gl/t1z4f","ch3.mp4")'

      # create the initial path rows
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Cloud Master","Modules for mastering clouds")'
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Time Master","Modules for mastering Times")'
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Key Master","Modules for mastering Keys")'
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Master and Commander","Modules for mastering sailing")'
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Path not taken","Modules for getting lost")'
      mysql -ulms-app -p${var.SQL_PASS} --host 127.0.0.1 -e 'INSERT INTO lms.paths (name, description) VALUES ("Off the beaten path","Modules for being alone")'

      # kill the proxy
      if [ $os == "mac" ]; then
        kill $(lsof -t -i:3306)
      else
        fuser -k 3306/tcp
      fi
    EOT
  }
  depends_on = [null_resource.install_cloud_sql_proxy, google_sql_database.sql_databases]
}

resource "google_sql_database_instance" "sql_replicas" {
  count = length(var.sql_replicas)
  name = (
    join("-",
      [
        var.sql_replicas[count.index]["name"],
        var.SQL_SUFFIX
      ]
    )
  )
  master_instance_name = local.sql_instances[var.sql_replicas[count.index]["master_instance_name"]]

  database_version = var.sql_replicas[count.index]["database_version"]
  region           = var.sql_replicas[count.index]["region"]
  settings {
    tier              = var.sql_replicas[count.index]["tier"]
    activation_policy = var.sql_replicas[count.index]["activation_policy"]
  }
  deletion_protection = false
}

