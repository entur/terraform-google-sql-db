variable "init" {
  default = {
    app = {
      id         = "posgrsmdul"
      name       = "tf-mod-gcp-postgres"
      owner      = "team-plattform"
      project_id = "ent-posgrsmdul-dev"
    }
    #app_name = "terraform-gcp-postgres" # After rename of the module, this name will be used.
    environment = "dev"
    labels = {
      app    = "terraform-gcp-postgres"
      app_id = "posgrsmdul"
      env    = "dev"
      team   = "team-plattform"
      owner  = "team-plattform"
    }
    is_production = false
  }
}

variable "generation" {
  default = 1
}
