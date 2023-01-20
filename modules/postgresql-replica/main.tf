locals {
  deletion_protection = var.deletion_protection != null ? var.deletion_protection : var.init.is_production ? true : false
  machine_size        = var.machine_size_override != null ? try(var.machine_size_override.tier, "db-custom-${var.machine_size_override.cpu}-${var.machine_size_override.memory}") : data.google_sql_database_instance.main.settings[0].tier
  labels              = merge(data.google_sql_database_instance.main.settings[0].user_labels, { label_backup_offsite = false })
  replica_number      = format("%03d", var.replica_number)
}

data "google_sql_database_instance" "main" {
  name    = var.master_instance_name
  project = var.init.app.project_id
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "replica" {
  name             = "${data.google_sql_database_instance.main.name}-repl-${local.replica_number}"
  project          = data.google_sql_database_instance.main.project
  region           = data.google_sql_database_instance.main.region
  database_version = data.google_sql_database_instance.main.database_version

  # replica specific settings
  master_instance_name = data.google_sql_database_instance.main.name
  replica_configuration {
    failover_target = false
  }

  settings {
    user_labels                 = local.labels
    availability_type           = var.availability_type
    deletion_protection_enabled = local.deletion_protection
    disk_size                   = null # must be null if disk_autoresize is true to avoid instance recreation when the disk expands
    disk_autoresize             = true
    disk_autoresize_limit       = 0 # no-limit for read-replicas, limit should be controlled by master
    tier                        = local.machine_size
    ip_configuration {
      require_ssl = data.google_sql_database_instance.main.settings[0].ip_configuration[0].require_ssl
    }
    # maintenance_window not set for read-replicas
    insights_config {
      query_insights_enabled  = data.google_sql_database_instance.main.settings[0].insights_config[0].query_insights_enabled
      query_string_length     = data.google_sql_database_instance.main.settings[0].insights_config[0].query_string_length
      record_client_address   = data.google_sql_database_instance.main.settings[0].insights_config[0].record_client_address
      record_application_tags = data.google_sql_database_instance.main.settings[0].insights_config[0].record_application_tags
    }
    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }
  }

  deletion_protection = local.deletion_protection
}

