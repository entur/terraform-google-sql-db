terraform {
  required_version = ">= 0.12"
}

locals {
  //is not used yet?
  env = split("-", terraform.workspace)[0]

  ip_configuration_enabled = length(keys(var.ip_configuration)) > 0 ? true : false

  ip_configurations = {
    enabled  = var.ip_configuration
    disabled = {}
  }

  peering_completed_enabled = var.peering_completed != "" ? true : false

  labels_including_tf_dependency = {
    enabled  = merge(map("tf_dependency", var.peering_completed), var.labels)
    disabled = var.labels
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.region
  zone    = "${var.region}-${var.zoneLetter}"
}

provider "google-beta" {
  project = var.gcp_project
  region  = var.region
  zone    = "${var.region}-${var.zoneLetter}"
}

//Make connection between init module(service account) and this module
resource "google_project_iam_member" "project" {
  // count = var.account_id_use_existing == true ? 0 : 1
  project = var.gcp_project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_sql_database_instance" "default" {
  project          = var.gcp_project
  name             = length(var.db_instance_custom_name) > 0 ? var.db_instance_custom_name : "${var.labels.app}-${var.kubernetes_namespace}-${random_id.suffix.hex}"
  database_version = var.postgresql_version
  region           = var.region
  //Might be better to have this as true, or remove it so that it is true by default. If we remove it and need to erase it we add 'deletion_protection = false', then apply, and then terraform delete. Troublesome, but secure.
  deletion_protection = false

  settings {
    tier                        = var.tier
    activation_policy           = var.activation_policy
    availability_type           = var.availability_type
    authorized_gae_applications = var.authorized_gae_applications
    dynamic "backup_configuration" {
      for_each = [var.backup_configuration]
      content {
        binary_log_enabled = lookup(backup_configuration.value, "binary_log_enabled", null)
        enabled            = lookup(backup_configuration.value, "enabled", null)
        start_time         = lookup(backup_configuration.value, "start_time", null)
      }
    }
    dynamic "ip_configuration" {
      for_each = [local.ip_configurations[local.ip_configuration_enabled ? "enabled" : "disabled"]]
      content {
        ipv4_enabled    = lookup(ip_configuration.value, "ipv4_enabled", null)
        private_network = lookup(ip_configuration.value, "private_network", null)
        require_ssl     = lookup(ip_configuration.value, "require_ssl", null)

        dynamic "authorized_networks" {
          for_each = lookup(ip_configuration.value, "authorized_networks", [])
          content {
            expiration_time = lookup(authorized_networks.value, "expiration_time", null)
            name            = lookup(authorized_networks.value, "name", null)
            value           = lookup(authorized_networks.value, "value", null)
          }
        }
      }
    }

    disk_autoresize = var.disk_autoresize
    disk_size       = var.disk_size
    disk_type       = var.disk_type
    pricing_plan    = var.pricing_plan
    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = lookup(database_flags.value, "name", null)
        value = lookup(database_flags.value, "value", null)
      }
    }

    // Define a label to force a dependency to the creation of the network peering.
    // Substitute this with a module dependency once the module is migrated to
    // Terraform 0.12
    user_labels = local.labels_including_tf_dependency[local.peering_completed_enabled ? "enabled" : "disabled"]

    location_preference {
      zone = "${var.region}-${var.zoneLetter}"
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }
  }

  lifecycle {
    ignore_changes = [
      settings[0].disk_size
    ]
  }

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }
}

resource "google_sql_database" "default" {
  name       = var.db_name
  project    = var.gcp_project
  instance   = google_sql_database_instance.default.name
  charset    = var.db_charset
  collation  = var.db_collation
  depends_on = [google_sql_database_instance.default]
}

resource "google_sql_database" "additional_databases" {
  count      = length(var.additional_databases)
  project    = var.gcp_project
  name       = var.additional_databases[count.index]["name"]
  charset    = lookup(var.additional_databases[count.index], "charset", "")
  collation  = lookup(var.additional_databases[count.index], "collation", "")
  instance   = google_sql_database_instance.default.name
  depends_on = [google_sql_database_instance.default]
}

resource "random_id" "user-password" {
  keepers = {
    name = google_sql_database_instance.default.name
  }

  byte_length = 8
  depends_on  = [google_sql_database_instance.default]
}

resource "google_sql_user" "default" {
  name       = var.db_user
  project    = var.gcp_project
  instance   = google_sql_database_instance.default.name
  password   = var.user_password == "" ? random_id.user-password.hex : var.user_password
  depends_on = [google_sql_database_instance.default]
}

resource "google_sql_user" "additional_users" {
  count   = length(var.additional_users)
  project = var.gcp_project
  name    = var.additional_users[count.index]["name"]
  password = lookup(
    var.additional_users[count.index],
    "password",
    random_id.user-password.hex,
  )
  instance   = google_sql_database_instance.default.name
  depends_on = [google_sql_database_instance.default]
}

resource "random_id" "protector" {
  count       = var.prevent_destroy ? 1 : 0
  byte_length = 8
  keepers = {
    protector = google_sql_database_instance.default.name
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "random_id" "suffix" {
  byte_length = 2
}

//fresh kubernetes_secret merging two
resource "kubernetes_secret" "team-db-credentials" {
  metadata {
    name      = "${var.labels.app}-db-credentials"
    namespace = var.kubernetes_namespace
    labels    = var.labels
  }
  data = {
    username  = var.db_user
    password  = random_id.user-password.hex
    INSTANCES = "${google_sql_database_instance.default.connection_name}=tcp:5432"
  }
}


