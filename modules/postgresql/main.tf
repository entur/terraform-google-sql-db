locals {
  # If updated, reflect changes in README.md
  default_tiers = {
    prod     = "db-custom-1-3840"
    non-prod = "db-f1-micro"
  }

  user_name             = var.user_name != null ? var.user_name : var.init.app.id
  retained_backups      = var.retained_backups != null ? var.retained_backups : var.init.is_production ? 30 : 7
  deletion_protection   = var.deletion_protection != null ? var.deletion_protection : var.init.is_production ? true : false
  availability_type     = var.availability_type != null ? var.availability_type : var.init.is_production ? "REGIONAL" : "ZONAL"
  machine_size          = var.machine_size != null ? try(var.machine_size.tier, "db-custom-${var.machine_size.cpu}-${var.machine_size.memory}") : var.init.is_production ? local.default_tiers.prod : local.default_tiers.non-prod
  offsite_backup_label  = var.disable_offsite_backup == true && var.init.is_production ? { label_backup_offsite = false } : {} # Add the label for opt-out of offsite backup in prod environments when disable_offsite_backup is true
  labels                = merge(var.init.labels, local.offsite_backup_label)
  generation            = format("%03d", var.generation)
  disk_autoresize_limit = var.disk_autoresize_limit != null ? var.disk_autoresize_limit : var.init.is_production ? 500 : 50
  # TODO: optionally filter out user_name if also present in additional_users
  additional_users = { for user in var.additional_users : user.name => user }
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "main" {
  name             = "sql-${var.init.app.id}-${var.init.environment}-${local.generation}"
  project          = var.init.app.project_id
  database_version = var.database_version
  region           = var.region

  settings {
    user_labels           = local.labels
    availability_type     = local.availability_type
    disk_size             = var.disk_autoresize ? null : var.disk_size # must be null if disk_autoresize is true to avoid instance recreation when the disk expands
    disk_autoresize       = var.disk_autoresize
    disk_autoresize_limit = local.disk_autoresize_limit
    tier                  = local.machine_size
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
    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = var.query_insights_config.query_string_length
      record_client_address   = var.query_insights_config.record_client_address
      record_application_tags = var.query_insights_config.record_application_tags
    }
  }

  deletion_protection = local.deletion_protection
}

resource "google_sql_database" "main" {
  for_each = toset(var.databases)
  name     = each.key
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

resource "google_sql_user" "additional_users" {
  for_each = local.additional_users
  name     = each.value.name
  project  = var.init.app.project_id
  instance = google_sql_database_instance.main.name
  password = random_password.additional_users_password[each.key].result
}

resource "random_integer" "additional_users_password_length" {
  for_each = local.additional_users
  min      = 32
  max      = 64
}

resource "random_password" "additional_users_password" {
  for_each         = local.additional_users
  length           = random_integer.additional_users_password_length[each.key].result
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
