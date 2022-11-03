module "init" {
  # This is an example only; if you're adding this block to a live configuration,
  # make sure to use the latest release of the init module, found here:
  # https://github.com/entur/terraform-google-init/releases
  source      = "github.com/entur/terraform-google-init//modules/init?ref=v0.1.0"
  app_id      = "tfmodules"
  environment = "dev"
}

# ci: x-release-please-start-version
module "postgresql" {
  source    = "github.com/entur/terraform-google-sql-db//modules/postgresql?ref=v1.0.0"
  init      = module.init
  databases = ["my-database"]

  # machine_size = {
  #   cpu    = 1
  #   memory = 3840
  # }
}
# ci: x-release-please-end
