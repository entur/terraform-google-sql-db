output "init" {
  description = "The output of the consumed init module."
  value       = var.init
}

output "user" {
  description = "Map containing the username and password of the default application user."
  sensitive   = true
  value = {
    username = google_sql_user.main.name
    password = random_password.password.result
  }
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
  description = "Name of the Kubernetes namespace where config maps and secrets are deployed."
  value       = var.create_kubernetes_resources ? kubernetes_secret.main_database_credentials[0].metadata[0].namespace : null
}
