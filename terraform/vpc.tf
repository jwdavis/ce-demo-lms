# create a set of networks
# take a list of configuration object as input
# sets only the minimual set of arguments
# can expand later on
resource "google_compute_network" "networks" {
  count                   = length(var.networks)
  project                 = var.project
  name                    = var.networks[count.index]["name"]
  auto_create_subnetworks = var.networks[count.index]["auto"]
}

# create a set of subnetworks
# takes a list of config objects as input
# looks up the network id based on provided network name
# sets small set of argument - can be expanded
resource "google_compute_subnetwork" "subnets" {
  count                    = length(var.subnets)
  name                     = var.subnets[count.index]["name"]
  region                   = var.subnets[count.index]["region"]
  ip_cidr_range            = var.subnets[count.index]["range"]
  network                  = local.net_ids[var.subnets[count.index]["network"]]
  private_ip_google_access = var.subnets[count.index]["private"]
}

# create a set of firewalls
# takes a list of config objects as input
# looks up the network id based on provided network name
# only handles allow rules; doesn't set priorities; can be expanded
# need to add filter by tag
resource "google_compute_firewall" "firewalls" {
  count     = length(var.firewalls)
  network   = local.net_ids[var.firewalls[count.index]["network"]]
  name      = var.firewalls[count.index]["name"]
  direction = var.firewalls[count.index]["direction"]
  allow {
    protocol = var.firewalls[count.index]["allow"]["protocol"]
    ports    = var.firewalls[count.index]["allow"]["ports"]
  }
  source_ranges = var.firewalls[count.index]["source_ranges"]
  target_tags   = var.firewalls[count.index]["target_tags"]
}
