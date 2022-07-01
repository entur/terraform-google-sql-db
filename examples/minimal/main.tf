module "init" {
  # This is an example only; if you're adding this block to a live configuration,
  # make sure to use the latest release of the init module, found here:
  # https://github.com/entur/terraform-google-init/releases
  source      = "github.com/entur/terraform-google-init//modules/init?ref=v0.1.0"
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
}
