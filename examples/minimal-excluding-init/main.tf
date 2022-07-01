resource "random_integer" "random_database_generation" {
  min = 1
  max = 999
}

module "postgresql" {
  source     = "../../modules/postgresql"
  init       = var.init
  generation = random_integer.random_database_generation.result
}
