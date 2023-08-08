output "instance_name" {
  description = "The database instance name."
  value       = module.postgresql.instance.name
}

output "project_id" {
  description = "Project ID"
  value       = module.init.app.project_id
}
