# create a set of backend buckets
# takes a list of config objects as input
# looks up the bucket id based on provided bucket name
# handles minimal settings; can be expanded
resource "google_compute_backend_bucket" "backend_buckets" {
  count       = length(var.backend_buckets)
  name        = var.backend_buckets[count.index]["name"]
  bucket_name = local.bucket_ids[format("%s_%s", var.backend_buckets[count.index]["bucket_name"], var.project)]
  enable_cdn  = var.backend_buckets[count.index]["enable_cdn"]
}

module "gce-lb-https" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 5.1"
  name              = var.http_lb.name
  project           = var.project
  target_tags       = var.http_lb.tags
  firewall_networks = [local.net_ids[var.http_lb["bes_network"]]]
  url_map           = google_compute_url_map.url_map.self_link
  create_url_map    = false
  ssl               = false

  backends = {
    lms-web = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = var.health_check
      log_config = {
        enable      = true
        sample_rate = 1.0
      }
      groups = [
        {
          group                        = google_compute_instance_group_manager.instance_groups[0].instance_group
          balancing_mode               = "RATE"
          capacity_scaler              = 0.8
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = 30
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
        {
          group                        = google_compute_instance_group_manager.instance_groups[1].instance_group
          balancing_mode               = "RATE"
          capacity_scaler              = 0.8
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = 30
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
        {
          group                        = google_compute_instance_group_manager.instance_groups[2].instance_group
          balancing_mode               = "RATE"
          capacity_scaler              = 0.8
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = 30
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}

resource "google_compute_url_map" "url_map" {
  name            = var.url_maps["name"]
  default_service = module.gce-lb-https.backend_services["lms-web"].self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "lms"
  }

  path_matcher {
    name            = "lms"
    default_service = module.gce-lb-https.backend_services["lms-web"].self_link

    path_rule {
      paths = [
        "/videos/*"
      ]
      service = local.backend_buckets["videos"]
    }
  }
}
