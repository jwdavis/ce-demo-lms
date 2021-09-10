# create a set of VMs
# takes a list of config objects as input
# looks up the subnet id based on provided subnet name
# handles minimal settings; can be expanded
resource "google_compute_instance" "test-vms" {
  count                   = length(var.test_vms)
  name                    = var.test_vms[count.index]["name"]
  machine_type            = var.test_vms[count.index]["machine_type"]
  zone                    = var.test_vms[count.index]["zone"]
  metadata_startup_script = var.test_vms[count.index]["metadata_startup_script"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = local.subnet_ids[var.test_vms[count.index]["subnet"]]
    access_config {
      // Ephemeral public IP
    }
  }
}
