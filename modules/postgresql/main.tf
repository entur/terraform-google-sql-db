locals {
  user_name             = var.user_name != null ? var.user_name : var.init.app.id
  retained_backups      = var.retained_backups != null ? var.retained_backups : var.init.is_production ? 30 : 7
  deletion_protection   = var.deletion_protection != null ? var.deletion_protection : var.init.is_production ? true : false
  offsite_backup_label  = var.disable_offsite_backup == true && var.init.is_production ? { label_backup_offsite = false } : {} # Add the label for opt-out of offsite backup in prod environments when disable_offsite_backup is true
  labels                = merge(var.init.labels, local.offsite_backup_label)
  generation            = format("%03d", var.generation)
  disk_autoresize_limit = var.disk_autoresize_limit != null ? var.disk_autoresize_limit : var.init.is_production ? 500 : 50
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "main" {
  name             = "sql-${var.init.app.id}-${var.init.environment}-${local.generation}"
  project          = var.init.app.project_id
  database_version = var.database_version
  region           = var.region

  settings {
    user_labels           = local.labels
    availability_type     = var.availability_type
    disk_size             = var.disk_autoresize ? null : var.disk_size # must be null if disk_autoresize is true to avoid instance recreation when the disk expands
    disk_autoresize       = var.disk_autoresize
    disk_autoresize_limit = local.disk_autoresize_limit
    tier                  = "db-custom-${var.machine_size.cpu}-${var.machine_size.memory}"
    backup_configuration {
      enabled                        = var.enable_backup
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = var.transaction_log_retention_days
      start_time                     = var.backup_start_time
      backup_retention_settings {
        retained_backups = local.retained_backups
      }
    }
    ip_configuration {
      require_ssl = true
    }
    maintenance_window {
      day          = var.maintenance_window.day
      hour         = var.maintenance_window.hour
      update_track = "stable"
    }
  }

  deletion_protection = local.deletion_protection
}

resource "google_sql_database" "main" {
  name     = var.init.app.name
  project  = var.init.app.project_id
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "main" {
  name     = local.user_name
  project  = var.init.app.project_id
  instance = google_sql_database_instance.main.name
  password = random_password.password.result
}

resource "kubernetes_config_map" "main_psql_connection" {
  depends_on = [
    google_sql_database_instance.main
  ]
  metadata {
    name      = "${var.init.app.name}-psql-connection"
    namespace = var.init.app.name
    labels    = var.init.labels
  }

  data = {
    INSTANCES = "${google_sql_database_instance.main.connection_name}=tcp:5432"
  }
}
resource "random_integer" "password_length" {
  min = 32
  max = 64
}
resource "random_password" "password" {
  length           = random_integer.password_length.result
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "main_database_credentials" {
  depends_on = [
    google_sql_database_instance.main
  ]
  metadata {
    name      = "${var.init.app.name}-psql-credentials"
    namespace = var.init.app.name
    labels    = var.init.labels
  }
  data = {
    PGHOST     = "localhost"
    PGPORT     = 5432
    PGUSER     = google_sql_user.main.name
    PGPASSWORD = random_password.password.result
  }
}
