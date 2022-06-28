resource "random_integer" "random_database_generation" {
  min = 1
  max = 999
}

module "init" {
  source      = "github.com/entur/terraform-gcp-init//modules/init?ref=v0.1.0"
  app_id      = "posgrsmdul"
  environment = "dev"
}

module "terraform-gcp-postgres" {
  source     = "../../modules/terraform-gcp-postgres"
  init       = module.init
  generation = random_integer.random_database_generation.result
}
