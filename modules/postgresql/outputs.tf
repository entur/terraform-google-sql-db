output "init" {
  description = "The output of the consumed init module."
  value       = var.init
}

output "basic_auth_user" {
  description = "Map containing the username and password of the default application user."
  sensitive   = true
  value = var.enable_basic_auth ? {
    username = google_sql_user.main[0].name
    password = random_password.password[0].result
  } : {}
}

output "additional_users" {
  description = "Map containing the username and password for any additional users."
  sensitive   = true
  value = var.enable_basic_auth ? {
    for key in keys(local.additional_users) : key => {
      username = google_sql_user.additional_users[key].name
      password = random_password.additional_users_password[key].result
    }
  } : {}
}

output "instance" {
  description = "The database instance output, as described in https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance."
  value       = google_sql_database_instance.main
}

output "databases" {
  description = "Databases created on this instance."
  value       = var.databases
}
