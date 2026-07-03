locals {
  machine_size   = var.machine_size_override != null ? try(var.machine_size_override.tier, "db-custom-${var.machine_size_override.cpu}-${var.machine_size_override.memory}") : var.master_instance.settings[0].tier
  labels         = merge(var.master_instance.settings[0].user_labels, { offsite_enabled = false })
  replica_number = format("%03d", var.replica_number)

  iam_auth_database_flag = var.enable_iam_auth ? {
    "enable_iam_auth" = {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  } : {}

  database_flags = merge(var.database_flags, local.iam_auth_database_flag)

  iam_auth_default_application_user = var.enable_iam_auth && var.iam_auth_default_application_user.enabled ? {
    "main" = {
      name = trimsuffix(var.init.service_accounts.default.email, ".gserviceaccount.com")
  } } : {}

  credentials = merge(
    length(local.iam_auth_default_application_user) > 0 ? {
      IAMUSER = local.iam_auth_default_application_user.main.name,
    } : {},
    { INSTANCES = google_sql_database_instance.replica.connection_name }
  )
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "replica" {
  name             = "${var.master_instance.name}-repl-${local.replica_number}"
  project          = var.master_instance.project
  region           = var.master_instance.region
  database_version = var.master_instance.database_version

  # replica specific settings
  master_instance_name = var.master_instance.name
  replica_configuration {
    failover_target = false
  }

  settings {
    user_labels                 = local.labels
    availability_type           = var.availability_type
    deletion_protection_enabled = var.master_instance.settings[0].deletion_protection_enabled
    # disk_size properties is inherited from the master, adding to ignore_changes
    # maintenance_window is inherited from the master, adding to ignore_changes
    tier    = local.machine_size
    edition = var.instance_edition
    ip_configuration {
      ssl_mode = var.master_instance.settings[0].ip_configuration[0].ssl_mode
    }
    insights_config {
      query_insights_enabled  = var.master_instance.settings[0].insights_config[0].query_insights_enabled
      query_string_length     = var.master_instance.settings[0].insights_config[0].query_string_length
      record_client_address   = var.master_instance.settings[0].insights_config[0].record_client_address
      record_application_tags = var.master_instance.settings[0].insights_config[0].record_application_tags
    }
    dynamic "database_flags" {
      for_each = local.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }
  }

  deletion_protection = var.master_instance.deletion_protection

  # Inspired by https://github.com/terraform-google-modules/terraform-google-sql-db/blob/master/modules/postgresql/read_replica.tf#L108
  lifecycle {
    ignore_changes = [
      settings[0].disk_size,
      settings[0].disk_autoresize,
      settings[0].disk_autoresize_limit,
      settings[0].maintenance_window,
    ]
  }
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "google_secret_manager_secret" "replica_db_secret" {
  for_each  = var.add_replica_secret_manager_credentials ? local.credentials : {}
  secret_id = "${var.secret_key_prefix}${each.key}"
  labels    = var.init.labels
  project   = var.init.app.project_id
  replication {
    user_managed {
      replicas {
        location = var.master_instance.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "replica_db_secret_version" {
  for_each    = var.add_replica_secret_manager_credentials ? local.credentials : {}
  secret      = google_secret_manager_secret.replica_db_secret[each.key].id
  secret_data = each.value
  depends_on = [
    google_sql_database_instance.replica
  ]
}

