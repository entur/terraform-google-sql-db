resource "random_integer" "random_database_generation" {
  min = 1
  max = 999
}

module "postgresql" {
  # This is for local reference only; if you're using this module as a published
  # module from GitHub, the 'source' parameter must refer to it's public location.
  # See README.md for instructions.
  # source     = "github.com/entur/terraform-google-sql-db//modules/postgresql?ref=vVERSION"
  source     = "../../modules/postgresql"
  init       = var.init
  generation = random_integer.random_database_generation.result
}