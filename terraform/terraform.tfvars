credentials_file = "~/Desktop/Dev/terraform.json"
project          = "jwd-gcp-demos"

networks = [
  { "name" : "lms-network", "auto" : false }
]

subnets = [
  { "name" : "us-subnet", "region" : "us-central1", "range" : "192.168.1.0/24", "network" : "lms-network", "private" : true },
  { "name" : "eu-subnet", "region" : "europe-west1", "range" : "192.168.2.0/24", "network" : "lms-network", "private" : true },
  { "name" : "asia-subnet", "region" : "asia-east1", "range" : "192.168.3.0/24", "network" : "lms-network", "private" : true },
]

global_addresses = [
]

firewalls = [
  {
    "name" : "lms-network-ssh",
    "direction" : "INGRESS",
    "allow" : {
      "protocol" : "tcp",
      "ports" : ["22"]
    },
    "source_ranges" : ["0.0.0.0/0"],
    "target_tags" : null,
    "network" : "lms-network"
  },
  {
    "name" : "lms-network-http",
    "direction" : "INGRESS",
    "allow" : {
      "protocol" : "tcp",
      "ports" : ["80"]
    },
    "source_ranges" : ["130.211.0.0/22", "35.191.0.0/16"],
    "target_tags" : ["webapp"],
    "network" : "lms-network"
  },
  {
    "name" : "lms-from-home",
    "direction" : "INGRESS",
    "allow" : {
      "protocol" : "TCP",
      "ports" : null
    },
    "source_ranges" : ["69.181.203.96"],
    "target_tags" : null,
    "network" : "lms-network"
  },
  # {
  #   "name" : "lms-network-test-80",
  #   "direction" : "INGRESS",
  #   "allow" : {
  #     "protocol" : "tcp",
  #     "ports" : ["80"]
  #   },
  #   "source_ranges" : ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"],
  #   "target_tags" : ["webapp"],
  #   "network" : "lms-network"
  # },
  # {
  #   "name" : "lms-network-test-icmp",
  #   "direction" : "INGRESS",
  #   "allow" : {
  #     "protocol" : "icmp",
  #     "ports" : null
  #   },
  #   "source_ranges" : ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"],
  #   "target_tags" : null,
  #   "network" : "lms-network"
  # }
]

buckets = [
  {
    "name" : "bdev2_media",
    "location" : "US",
    "class" : "MULTI_REGIONAL",
    "uniform" : true,
  },
  {
    "name" : "bdev2_raw_media",
    "location" : "US",
    "class" : "MULTI_REGIONAL",
    "uniform" : true
  }
]

bucket_bindings = [
  {
    "bucket" : "bdev2_media",
    "member" : "allUsers",
    "role" : "roles/storage.objectViewer"
  },

  {
    "bucket" : "bdev2_raw_media",
    "member" : "allUsers",
    "role" : "roles/storage.objectViewer"
  }
]

topics = [
  { "name" : "videos" }
]

subscriptions = [
  {
    "name" : "videos",
    "topic" : "videos",
    "ack_deadline_seconds" : 30
  }
]

test_vms = [
  {
    "name" : "test-us",
    "machine_type" = "e2-medium",
    "zone" : "us-central1-a",
    "metadata_startup_script" = "sudo apt-get update; sudo apt-get install apache2-utils -y"
    "subnet" : "us-subnet"
  },
  {
    "name" : "test-eu",
    "machine_type" = "e2-medium",
    "zone" : "europe-west1-b",
    "metadata_startup_script" = "sudo apt-get update; sudo apt-get install apache2-utils -y"
    "subnet" : "eu-subnet"
  },
  {
    "name" : "test-asia",
    "machine_type" = "e2-medium",
    "zone" : "asia-east1-a",
    "metadata_startup_script" = "sudo apt-get update; sudo apt-get install apache2-utils -y"
    "subnet" : "asia-subnet"
  }
]

startup_scripts = [
  {
    "target" : "us-lms-web-template",
    "source" : "./startup.sh"
  },
  {
    "target" : "eu-lms-web-template",
    "source" : "./startup.sh"
  },
  {
    "target" : "asia-lms-web-template",
    "source" : "./startup.sh"
  },
  {
    "target" : "transcode-template",
    "source" : "./t-startup.sh"
  }
]

instance_templates = [
  {
    "name" : "us-lms-web-template",
    "tags" : ["webapp"],
    "machine_type" : "n1-standard-1",
    "network" : "lms-network",
    "subnet" : "us-subnet",
    "zone" : "us-central1-a",
    "image" : "projects/jwd-gcp-demos/global/images/lms-server",
    "scopes" = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/sqlservice.admin"
    ],
    "metadata" : {
      "SQL_WRITE_REGION" : "us-central1",
      "SQL_READ_REGION" : "us-central1",
      "SQL_READ_REGION_1" : "us-central1",
    },
    "sql_write_base" : "lms-sql-us-main",
    "sql_read_base" : "lms-sql-us-main",
    "public_ip" : true,
  },
  {
    "name" : "eu-lms-web-template",
    "tags" : ["webapp"],
    "machine_type" : "n1-standard-1",
    "network" : "lms-network",
    "subnet" : "eu-subnet",
    "zone" : "europe-west1-b",
    "image" : "projects/jwd-gcp-demos/global/images/lms-server",
    "scopes" = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/sqlservice.admin"
    ],
    "metadata" : {
      "SQL_WRITE_REGION" : "us-central1",
      "SQL_READ_REGION" : "europe-west1",
    },
    "sql_write_base" : "lms-sql-us-main",
    "sql_read_base" : "lms-sql-europe-replica",
    "public_ip" : true,
  },
  {
    "name" : "asia-lms-web-template",
    "tags" : ["webapp"],
    "machine_type" : "n1-standard-1",
    "network" : "lms-network",
    "subnet" : "asia-subnet",
    "zone" : "asia-east1-a",
    "image" : "projects/jwd-gcp-demos/global/images/lms-server",
    "scopes" = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/sqlservice.admin"
    ],
    "metadata" : {
      "SQL_WRITE_REGION" : "us-central1",
      "SQL_READ_REGION" : "asia-east1",
    },
    "sql_write_base" : "lms-sql-us-main",
    "sql_read_base" : "lms-sql-asia-replica",
    "public_ip" : true,
  },
  {
    "name" : "transcode-template",
    "tags" : ["transcode"],
    "machine_type" : "n2d-standard-2",
    "network" : "lms-network",
    "image" : "projects/jwd-gcp-demos/global/images/transcode-server",
    "subnet" : "us-subnet",
    scopes = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/pubsub"
    ],
    "metadata" : {},
    "public_ip" : false,
  }
]

instance_groups = [
  {
    "name" : "us-lms-web-group",
    "zone" : "us-central1-a",
    "base" : "us-lms-web",
    "template" : "us-lms-web-template",
    "network" : "lms-network",
    "subnet" : "us-subnet",
    "wait" : true
  },
  {
    "name" : "eu-lms-web-group",
    "zone" : "europe-west1-b",
    "base" : "eu-lms-web",
    "network" : "lms-network",
    "subnet" : "eu-subnet",
    "template" : "eu-lms-web-template",
    "wait" : true
  },
  {
    "name" : "asia-lms-web-group",
    "zone" : "asia-east1-a",
    "base" : "asia-lms-web",
    "network" : "lms-network",
    "subnet" : "asia-subnet",
    "template" : "asia-lms-web-template",
    "wait" : true
  },
  {
    "name" : "us-transcode-group",
    "zone" : "us-central1-a",
    "base" : "us-transcode",
    "network" : "lms-network",
    "subnet" : "us-subnet",
    "template" : "transcode-template",
    "wait" : true
  }
]

autoscalers = [
  {
    "name" : "us-lms-web-autoscaler",
    "zone" : "us-central1-a",
    "target" : "us-lms-web-group",
    "min" : 1,
    "max" : 10,
    "lb" : true,
    "percent" : 0.7
  },
  {
    "name" : "eu-lms-web-autoscaler",
    "zone" : "europe-west1-b",
    "target" : "eu-lms-web-group",
    "min" : 1,
    "max" : 10,
    "lb" : true,
    "percent" : 0.7
  },
  {
    "name" : "asia-lms-web-autoscaler",
    "zone" : "asia-east1-a",
    "target" : "asia-lms-web-group",
    "min" : 1,
    "max" : 10,
    "lb" : true,
    "percent" : 0.7
  },
  {
    "name" : "us-transcode-autoscaler",
    "zone" : "us-central1-a",
    "target" : "us-transcode-group",
    "min" : 1,
    "max" : 5,
    "lb" : false,
    "percent" : 0.7
  }
]

health_check = {
  "name" : "lms-hc",
  "check_interval_sec" : 1,
  "timeout_sec" : 1,
  "request_path" : "/",
  "port" : 80,
  "healthy_threshold" : 2,
  "unhealthy_threshold" : 2,
  "host" : null,
  "logging" : null
}

backend_buckets = [
  {
    "name" : "videos",
    "bucket_name" : "bdev2_raw_media",
    "enable_cdn" : true,
  }
]


url_maps = {
  "name" : "lms-http-lb",
}

http_lb = {
  "name" : "lms-http-lb",
  "tags" : ["webapp"],
  "bes_network" : "lms-network",
  "url_map" : "lms-web-url-map",
  "static_address" : "lms-demo-ip"
}

sql_instances = [
  {
    "name" : "lms-sql-us-main",
    "database_version" : "MYSQL_8_0",
    "region" : "us-central1",
    "tier" : "db-n1-standard-1",
    "activation_policy" : "ALWAYS",
    "availability_type" : "REGIONAL",
    "backup_configuration" : {
      "enabled" : true,
      "binary_log_enabled" : true
    }
  }
]

sql_users = [
  {
    "name" : "lms-app",
    "instance" : "lms-sql-us-main",
    "region" : "us-central1"
  }
]

sql_replicas = [
  {
    "name" : "lms-sql-europe-replica",
    "database_version" : "MYSQL_8_0",
    "region" : "europe-west1",
    "tier" : "db-n1-standard-1",
    "activation_policy" : "ALWAYS",
    "master_instance_name" : "lms-sql-us-main"
  },
  {
    "name" : "lms-sql-asia-replica",
    "database_version" : "MYSQL_8_0",
    "region" : "asia-east1",
    "tier" : "db-n1-standard-1",
    "activation_policy" : "ALWAYS",
    "master_instance_name" : "lms-sql-us-main"
  }
]

sql_databases = [
  {
    "name" : "lms",
    "instance" : "lms-sql-us-main"
  }
]

sql_init_scripts = [
  {
    "instance" : "lms-sql-us-main",
    "region" : "us-central1"
  }
]

apis = [
  "sqladmin.googleapis.com",
]
