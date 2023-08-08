variable "init" {
  default = {
    app = {
      id         = "tfmodules"
      name       = "tf-mod-google-postgresql"
      owner      = "team-plattform"
      project_id = "ent-tfmodules-dev"
    }
    environment = "dev"
    labels = {
      app    = "tf-mod-google-postgresql"
      app_id = "tfmodules"
      env    = "dev"
      team   = "team-plattform"
      owner  = "team-plattform"
    }
    is_production = false
  }
}
