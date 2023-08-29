resource "random_integer" "random_database_generation" {
  # This resource block is used to randomize instance names for testing; 
  # do not include this in a live configuration.
  min = 1
  max = 999
}

module "init" {
  # This is an example only; if you're adding this block to a live configuration,
  # make sure to use the latest release of the init module, found here:
  # https://github.com/entur/terraform-google-init/releases
  source      = "github.com/entur/terraform-google-init//modules/init?ref=v0.3.0"
  app_id      = "tfmodules"
  environment = "dev"
}

module "postgresql" {
  # This is for local reference only; if you're using this module as a published
  # module from GitHub, the 'source' parameter must refer to it's public location.
  # See README.md for instructions.
  # source     = "github.com/entur/terraform-google-sql-db//modules/postgresql?ref=vVERSION"
  source     = "../../modules/postgresql"
  init       = module.init
  generation = random_integer.random_database_generation.result
  databases  = ["database-1"]
  additional_users = { user1 = { username = "user1", create_kubernetes_secret = false },
  user2 = { username = "user2", create_kubernetes_secret = false } }

}
