terraform {
  required_version = ">= 0.12"
}

module "gcp-init" {
  #source               = "../../modules/init"
  source               = "github.com/entur/terraform-gcp-init/modules/init"
  labels               = var.labels
  project_id           = var.gcp_project
  kubernetes_namespace = var.kubernetes_namespace
}

module "postgres" {
  #source = "github.com/entur/terraform//modules/postgres"
  source                = "/mnt/c/Users/E180047/Documents/GitHub/terraform-gcp-postgresql/modules/postgres"
  gcp_project           = var.gcp_project
  labels                = var.labels
  kubernetes_namespace  = var.kubernetes_namespace
  db_name               = var.db_name
  db_user               = var.db_user
  region                = var.region
  zoneLetter            = var.zone_letter
  prevent_destroy       = var.prevent_destroy
  service_account_email = module.gcp-init.service_account_email
  database_version      = var.database_version
}
