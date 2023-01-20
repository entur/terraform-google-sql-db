output "init" {
  description = "The output of the consumed init module."
  value       = var.init
}

output "instance" {
  description = "The database instance output, as described in https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance."
  value       = google_sql_database_instance.replica
}
