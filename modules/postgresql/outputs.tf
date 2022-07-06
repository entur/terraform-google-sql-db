output "init" {
  value       = var.init
  description = "The init module used in the module."
}

output "user" {
  value = {
    username = google_sql_user.main.name
    password = random_password.password.result
  }
  description = "Map containing the username and password of the default application user."
  sensitive   = true
}

output "instance" {
  description = "The database instance output, as described in https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance."
  value       = google_sql_database_instance.main
}

output "databases" {
  description = "Databases created on this instance."
  value       = var.databases
}

output "kubernetes_namespace" {
  description = "Name of the kubernetes namespace where the connection details configmap and secret are deployed."
  value       = kubernetes_secret.main_database_credentials.metadata[0].namespace
}
