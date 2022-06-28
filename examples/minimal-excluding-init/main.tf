resource "random_integer" "random_database_generation" {
  min = 1
  max = 999
}

module "terraform-gcp-postgres" {
  source     = "../../modules/terraform-gcp-postgres"
  init       = var.init
  generation = random_integer.random_database_generation.result
}
