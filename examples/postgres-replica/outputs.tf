/*output "instance_name" {
  description = "The database instance name."
  value       = module.postgresql.instance.name
  sensitive   = true
}*/

output "project_id" {
  description = "Project ID"
  value       = module.init.app.project_id
}

output "app_id" {
  description = "Application ID"
  value       = module.init.app.id
}
