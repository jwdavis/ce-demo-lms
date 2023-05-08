# create a set of instance templates
# takes a list of config objects as input
# looks up the new and subnet id based on provided values
# handles minimal settings; can be expanded
resource "google_compute_instance_template" "instance_templates" {
  count        = length(var.instance_templates)
  name         = var.instance_templates[count.index]["name"]
  tags         = var.instance_templates[count.index]["tags"]
  machine_type = var.instance_templates[count.index]["machine_type"]
  metadata = merge(
    var.instance_templates[count.index]["metadata"],
    {
      "SUP_PASS" : contains(var.instance_templates[count.index]["tags"], "webapp") ? var.SUP_PASS : null,
      "SQL_PASS" : contains(var.instance_templates[count.index]["tags"], "webapp") ? var.SQL_PASS : null,
      "SQL_MAIN" : contains(var.instance_templates[count.index]["tags"], "webapp") ? local.all_sql_instances[var.instance_templates[count.index]["sql_write_base"]] : null,
      "SQL_REPLICA" : contains(var.instance_templates[count.index]["tags"], "webapp") ? local.all_sql_instances[var.instance_templates[count.index]["sql_read_base"]] : null,
      "PROJECT_ID" : var.project,
      "startup-script" : local.startup_scripts[var.instance_templates[count.index]["name"]]
    },
  )

  service_account {
    scopes = var.instance_templates[count.index]["scopes"]
  }

  disk {
    source_image = var.instance_templates[count.index]["image"]
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = local.net_ids[var.instance_templates[count.index]["network"]]
    subnetwork = local.subnet_ids[var.instance_templates[count.index]["subnet"]]
    dynamic "access_config" {
      for_each = var.instance_templates[count.index]["public_ip"] ? [1] : []
      content {
        network_tier = "PREMIUM"
      }
    }
  }
}

# create a set of instance groups
# takes a list of config objects as input
# looks up the template based on provided values
# handles minimal settings; can be expanded
resource "google_compute_instance_group_manager" "instance_groups" {
  count              = length(var.instance_groups)
  name               = var.instance_groups[count.index]["name"]
  zone               = var.instance_groups[count.index]["zone"]
  base_instance_name = var.instance_groups[count.index]["base"]
  wait_for_instances = var.instance_groups[count.index]["wait"]
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = local.template_ids[var.instance_groups[count.index]["template"]]
  }
}

# create a set of autoscalers
# takes a list of config objects as input
# looks up the target based on provided values
# handles minimal settings; can be expanded
# need to change scaling triggers...
resource "google_compute_autoscaler" "autoscalers" {
  count  = length(var.autoscalers)
  name   = var.autoscalers[count.index]["name"]
  zone   = var.autoscalers[count.index]["zone"]
  target = local.mig_ids[var.autoscalers[count.index]["target"]]

  autoscaling_policy {
    min_replicas = var.autoscalers[count.index]["min"]
    max_replicas = var.autoscalers[count.index]["max"]
    dynamic "load_balancing_utilization" {
      for_each = var.autoscalers[count.index]["lb"] ? [1] : []
      content {
        target = var.autoscalers[count.index]["percent"]
      }
    }
    dynamic "cpu_utilization" {
      for_each = var.autoscalers[count.index]["lb"] ? [] : [1]
      content {
        target = var.autoscalers[count.index]["percent"]
      }
    }
  }

}
