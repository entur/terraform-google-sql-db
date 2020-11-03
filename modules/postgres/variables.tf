#
# Variables that needs a value
#
variable "gcp_project" {
  type = string
  description = "The GCP project id"
}

variable "region" {
  description = "GCP default region"
}

variable "zoneLetter" {
  description = "GCP default zone"
}

variable "labels" {
  description = "Labels used in all resources"
  type        = map(string)
  #default = {
  #  team    = "TEAM"
  #  app     = "SERVICE"
  #}
}

variable "kubernetes_namespace" {
  description = "Your kubernetes namespace"
}

variable "db_name" {
  description = "The name of the default database to create"
  type        = string
  default     = "default-db-name"
}

variable "db_user" {
  description = "Default user for postgres db"
  type        = string
  default     = "default-db-user"
}

#
# Variables with default value
#
variable "prevent_destroy" {
  description = "Prevent the destruction of this postgres database"
  type        = bool
  default     = false
}

variable "postgresql_version" {
  description = "Which POSTGRES version to use. Check availability before declaring any version."
  default     = "POSTGRES_9_6"
}

variable "db_instance_custom_name" {
  description = "Database instance name override (empty string = use standard convention)"
  default     = ""
}

variable "account_id" {
  description = "Database service account id override (empty string = use standard convention)"
  default     = ""
}

variable "account_id_use_existing" {
  description = "Set this to true if you want to use an existing service account, otherwise a new one will be created (account_id must also be provided if set to true)"
  default     = false
}

variable "db_instance_backup_enabled" {
  description = "Enable database backup"
  default     = true
}

variable "db_instance_backup_time" {
  description = "When the backup should be scheduled"
  default     = "04:00"
}

variable "db_instance_tier" {
  description = "DB default tier"
  default     = "db-custom-1-3840"
}

variable "db_instance_disk_size" {
  description = "DB disc size"
  default     = "10"
}

# New
variable "service_account_email" {
  description= "Email to the service account that we want the bucket to be attached to"
  default = ""
}

variable "tier" {
  description = "The tier for the master instance."
  type        = string
  default     = "db-f1-micro"
}

variable "activation_policy" {
  description = "The activation policy for the master instance.Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  type        = string
  default     = "ALWAYS"
}

variable "availability_type" {
  description = "The availability type for the master instance.This is only used to set up high availability for the PostgreSQL instance. Can be either `ZONAL` or `REGIONAL`."
  type        = string
  default     = "ZONAL"
}

variable "authorized_gae_applications" {
  description = "The authorized gae applications for the Cloud SQL instances"
  type        = list(string)
  default     = []
}

variable "backup_configuration" {
  description = "The backup_configuration settings subblock for the database setings"
  type = object({
    binary_log_enabled = bool
    enabled            = bool
    start_time         = string
  })
  default = {
    binary_log_enabled = false
    enabled            = true
    start_time         = "04:00"
  }
}

variable "ip_configuration" {
  description = "The ip configuration for the master instances."
  type = object({
    authorized_networks = list(map(string))
    ipv4_enabled        = bool
    private_network     = string
    require_ssl         = bool
  })
  default = {
    authorized_networks = []
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = true
  }
}

variable "disk_autoresize" {
  description = "Configuration to increase storage size."
  type        = bool
  default     = true
}

variable "disk_size" {
  description = "The disk size for the master instance."
  default     = 10
}

variable "disk_type" {
  description = "The disk type for the master instance."
  type        = string
  default     = "PD_SSD"
}

variable "pricing_plan" {
  description = "The pricing plan for the master instance."
  type        = string
  default     = "PER_USE"
}

variable "database_flags" {
  description = "The database flags for the master instance. See [more details](https://cloud.google.com/sql/docs/mysql/flags)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "user_labels" {
  description = "The key/value labels for the master instances."
  type        = map(string)
  default     = {}
}

variable "peering_completed" {
  description = "Optional. This is used to ensure that resources are created in the proper order when using private IPs and service network peering."
  type        = string
  default     = ""
}

variable "maintenance_window_day" {
  description = "The day of week (1-7) for the master instance maintenance."
  type        = number
  default     = 1
}

variable "maintenance_window_hour" {
  description = "The hour of day (0-23) maintenance window for the master instance maintenance."
  type        = number
  default     = 23
}

variable "maintenance_window_update_track" {
  description = "The update track of maintenance window for the master instance maintenance.Can be either `canary` or `stable`."
  type        = string
  default     = "canary"
}

variable "create_timeout" {
  description = "The optional timout that is applied to limit long database creates."
  type        = string
  default     = "10m"
}

variable "update_timeout" {
  description = "The optional timout that is applied to limit long database updates."
  type        = string
  default     = "10m"
}

variable "delete_timeout" {
  description = "The optional timout that is applied to limit long database deletes."
  type        = string
  default     = "10m"
}

variable "db_charset" {
  description = "The charset for the default database"
  type        = string
  default     = ""
}

variable "db_collation" {
  description = "The collation for the default database. Example: 'en_US.UTF8'"
  type        = string
  default     = ""
}

variable "additional_databases" {
  description = "A list of databases to be created in your cluster"
  type = list(object({
    project   = string
    name      = string
    charset   = string
    collation = string
    instance  = string
  }))
  default = []
}

variable "user_password" {
  description = "The password for the default user. If not set, a random one will be generated and available in the generated_user_password output variable."
  type        = string
  default     = ""
}

variable "additional_users" {
  description = "A list of users to be created in your cluster"
  type = list(object({
    project  = string
    name     = string
    password = string
    host     = string
    instance = string
  }))
  default = []
}

variable "database_version" {
  description = "The database version to use"
  type        = string
}