resource "random_integer" "random_database_generation" {
  min = 1
  max = 999
}

module "init" {
  source      = "github.com/entur/terraform-google-init//modules/init?ref=v0.1.0"
  app_id      = "posgrsmdul"
  environment = "dev"
}

module "postgresql" {
  source     = "../../modules/postgresql"
  init       = module.init
  generation = random_integer.random_database_generation.result
}
