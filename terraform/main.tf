locals {
  # we create maps of ids for generated resources
  # to use for lookup tables when creating dependent resource
  net_ids = {
    for net in google_compute_network.networks : "${net.name}" => net.id
  }

  subnet_ids = {
    for subnet in google_compute_subnetwork.subnets : "${subnet.name}" => subnet.id
  }

  bucket_ids = {
    for bucket in google_storage_bucket.buckets : "${bucket.name}" => bucket.id
  }

  topics_ids = {
    for topic in google_pubsub_topic.topics : "${topic.name}" => topic.id
  }

  startup_scripts = {
    for script in var.startup_scripts : "${script.target}" => file(script.source)
  }

  template_ids = {
    for template in google_compute_instance_template.instance_templates : "${template.name}" => template.id
  }

  mig_ids = {
    for mig in google_compute_instance_group_manager.instance_groups : "${mig.name}" => mig.id
  }

  backend_buckets = {
    for bucket in google_compute_backend_bucket.backend_buckets : "${bucket.name}" => bucket.id
  }

  sql_instances = {
    for instance in google_sql_database_instance.sql_instances : regex("^(.*)[-]", instance.id)[0] => instance.id
  }

  sql_replicas = {
    for instance in google_sql_database_instance.sql_replicas : regex("^(.*)[-]", instance.id)[0] => instance.id
  }

  all_sql_instances = merge(local.sql_instances, local.sql_replicas)
}
