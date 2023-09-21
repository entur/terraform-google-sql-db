locals {
  # If updated, reflect changes in README.md
  default_tiers = {
    prod     = "db-custom-1-3840"
    non-prod = "db-f1-micro"
  }

  user_name                      = var.user_name != null ? var.user_name : var.init.app.id
  retained_backups               = var.retained_backups != null ? var.retained_backups : var.init.is_production ? 30 : 7
  deletion_protection            = var.deletion_protection != null ? var.deletion_protection : var.init.is_production ? true : false
  availability_type              = var.availability_type != null ? var.availability_type : var.init.is_production ? "REGIONAL" : "ZONAL"
  machine_size                   = var.machine_size != null ? try(var.machine_size.tier, "db-custom-${var.machine_size.cpu}-${var.machine_size.memory}") : var.init.is_production ? local.default_tiers.prod : local.default_tiers.non-prod
  offsite_backup_label           = var.disable_offsite_backup == true && var.init.is_production ? { offsite_enabled = false } : {} # Add the label for opt-out of offsite backup in prod environments when disable_offsite_backup is true
  labels                         = merge(var.init.labels, local.offsite_backup_label)
  generation                     = format("%03d", var.generation)
  disk_autoresize_limit          = var.disk_autoresize_limit != null ? var.disk_autoresize_limit : var.init.is_production ? 500 : 50
  additional_users               = { for key, value in var.additional_users : key => value if value.username != local.user_name }
  additional_user_credentials    = ! var.create_kubernetes_resources ? {} : { for key, value in local.additional_users : key => value if value.create_kubernetes_secret }
  additional_sm_user_credentials = ! var.add_additional_secret_manager_credentials ? {} : { for key, value in local.additional_users : key => value if var.add_additional_secret_manager_credentials }
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
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days
      start_time                     = var.backup_start_time
      backup_retention_settings {
        retained_backups = local.retained_backups
      }
    }
    ip_configuration {
      require_ssl = true
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        iterator = authnet
        content {
          name  = authnet.value.name
          value = authnet.value.value
        }

      }
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
  count = var.create_kubernetes_resources ? 1 : 0
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
  count = var.create_kubernetes_resources ? 1 : 0
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
  name     = each.value.username
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

resource "kubernetes_secret" "additional_database_credentials" {
  for_each = local.additional_user_credentials
  depends_on = [
    google_sql_database_instance.main
  ]
  metadata {
    name      = "${var.init.app.name}-${each.value.username}-psql-credentials"
    namespace = var.init.app.name
    labels    = var.init.labels
  }
  data = {
    PGHOST     = "localhost"
    PGPORT     = 5432
    PGUSER     = google_sql_user.additional_users[each.key].name
    PGPASSWORD = random_password.additional_users_password[each.key].result
  }
}

locals {
  credentials = {
    HOST      = "localhost",
    PORT      = 5432,
    USER      = google_sql_user.main.name,
    PASSWORD  = random_password.password.result,
    INSTANCES = google_sql_database_instance.main.connection_name
  }

}

resource "google_secret_manager_secret" "db_secret" {
  for_each  = var.add_main_secret_manager_credentials ? local.credentials : {}
  secret_id = "${var.secret_key_prefix}${each.key}"
  labels    = var.init.labels
  project   = var.init.app.project_id
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_secret_version_main_database_credentials" {
  for_each    = var.add_main_secret_manager_credentials ? local.credentials : {}
  secret      = google_secret_manager_secret.db_secret[each.key].id
  secret_data = each.value
  depends_on = [
    google_sql_database_instance.main
  ]
}

locals {
  users = flatten([
    for user_key, data in local.additional_sm_user_credentials : [
      for cred_key, cred in local.credentials : {
        id_prefix = "projects/${var.init.app.project_id}/secrets"
        secret_id = "${upper(user_key)}_${var.secret_key_prefix}${cred_key}"
        user_key  = user_key
        cred_key  = cred_key
        cred_data = cred
      }
    ]
  ])
}

resource "google_secret_manager_secret" "db_secret_additional" {
  for_each = {
    for cred in local.users : "${cred.user_key}.${cred.cred_key}" => cred
  }
  secret_id = each.value.secret_id
  labels    = var.init.labels
  project   = var.init.app.project_id
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}


resource "google_secret_manager_secret_version" "db_secret_version_additional_database_credentials" {
  for_each = {
    for cred in local.users : "${cred.user_key}.${cred.cred_key}" => cred
  }
  secret = "${each.value.secret_prefix}/${each.value.secret_id}"
  secret_data = (
    each.value.cred_key == "USER" ?
    google_sql_user.additional_users[each.value.user_key].name :
    each.value.cred_key == "PASSWORD" ?
    random_password.additional_users_password[each.value.user_key].result :
    each.value.cred_key == "INSTANCES" ?
    google_sql_database_instance.main.connection_name :
    each.value.cred_data
  )
  depends_on = [
    google_sql_database_instance.main
  ]
}
