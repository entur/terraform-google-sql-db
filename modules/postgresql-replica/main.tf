locals {
  deletion_protection = var.deletion_protection != null ? var.deletion_protection : var.init.is_production ? true : false
  machine_size        = var.machine_size_override != null ? try(var.machine_size_override.tier, "db-custom-${var.machine_size_override.cpu}-${var.machine_size_override.memory}") : data.google_sql_database_instance.main.settings[0].tier
  labels              = merge(var.init.labels, { label_backup_offsite = false })
  replica_number      = format("%03d", var.replica_number)
}

data "google_sql_database_instance" "main" {
  name    = var.master_instance_name
  project = var.init.app.project_id
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "replica" {
  name             = "${data.google_sql_database_instance.main.name}-repl-${local.replica_number}"
  project          = var.init.app.project_id
  region           = data.google_sql_database_instance.main.region
  database_version = data.google_sql_database_instance.main.database_version

  master_instance_name = data.google_sql_database_instance.main.name
  replica_configuration {
    failover_target = false
  }

  settings {
    user_labels           = local.labels
    availability_type     = var.availability_type
    disk_size             = null # must be null if disk_autoresize is true to avoid instance recreation when the disk expands
    disk_autoresize       = true
    disk_autoresize_limit = 0 # no-limit for read-replicas, limit should be controlled by master
    tier                  = local.machine_size
    ip_configuration {
      require_ssl = true
    }
    # maintenance_window not set for read-replicas
    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = var.query_insights_config.query_string_length
      record_client_address   = var.query_insights_config.record_client_address
      record_application_tags = var.query_insights_config.record_application_tags
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

