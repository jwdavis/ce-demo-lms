
module "project-services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "10.1.1"
  project_id                  = var.project
  activate_apis               = var.apis
  disable_services_on_destroy = false
}
