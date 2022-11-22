variable "init" {
  description = "Entur init module output. https://github.com/entur/terraform-google-init. Used to determine application name, application project, labels, and resource names."
  type = object({
    app = object({
      id         = string
      name       = string
      owner      = string
      project_id = string
    })
    environment   = string
    labels        = map(string)
    is_production = bool
  })
}

variable "region" {
  description = "The region the instance will sit in."
  type        = string
  default     = "europe-west1"
}

variable "machine_size" {
  description = "Map of the database instance CPU count (cpu) and memory sizes in MB (memory). Optionally, set a tier override (tier). See README.md for examples."
  # type = object({
  #   tier   = optional(string) # Optional attributes not supported until Terraform 1.3
  #   cpu    = number
  #   memory = number
  # })
  type = map
  #default = {
  #tier   = "db-f1-micro"
  #cpu    = 1
  #memory = 3840
  #}
  default = null
  validation {
    condition     = var.machine_size != null ? try(var.machine_size.cpu, 1) >= 1 && try(var.machine_size.cpu, 1) <= 96 : true
    error_message = "CPU must be a whole number between 1 and 96."
  }
  validation {
    condition     = var.machine_size != null ? try(var.machine_size.memory, 256) % 256 == 0 && try(var.machine_size.memory, 3840) >= 3840 && try(var.machine_size.memory, 3840) <= 13312 : true
    error_message = "Memory must be divisable by 256, and between 3840 and 13312."
  }
  validation {
    condition     = var.machine_size != null ? (try(var.machine_size.tier, null) != null) && (try(var.machine_size.cpu, null) == null || try(var.machine_size.memory, null) == null) || (try(var.machine_size.tier, null) == null) && (try(var.machine_size.cpu, null) != null && try(var.machine_size.memory, null) != null) : true
    error_message = "Either supply desired resource limits for cpu and memory (recommended), or specify a tier."
  }
}

variable "generation" {
  description = "The generation (aka serial no.) of the instance. Starts at 1, ends at 999. Will be padded with leading zeros."
  type        = number
  default     = 1

  validation {
    condition     = var.generation < 1000 && var.generation > 0
    error_message = "Generation must be bewteen [1,999]."
  }
}

variable "databases" {
  description = "Names of databases to create."
  type        = list(string)
}

variable "database_version" {
  description = "The PostgreSQL version (see https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version)."
  type        = string
  default     = "POSTGRES_14"

  validation {
    condition     = can(regex("^POSTGRES_[1-9][0-9]$", var.database_version))
    error_message = "Supports PostgreSQL version 10 or higher."
  }
}

variable "user_name" {
  description = "The username of the default application user. Defaults to the app ID."
  type        = string
  default     = null
}

variable "additional_users" {
  description = "A list of user-names in addition to the main user that should be created."
  type        = list(string)
  validation {
    condition = length([
      for user in var.additional_users : true if can(regex("^[0-9a-z-]+$", user))
    ]) == length(var.additional_users)
    error_message = "Username must match regex '[0-9a-z-]'."
  }
}

variable "retained_backups" {
  description = "The number of backups to retain. Default is 30 for production, 7 for non-production."
  type        = number
  default     = null
}

variable "disk_size" {
  description = "The storage disk size of the instance. Default is 10 (GB). Only takes effect if disk_autoresize is set to 'false'."
  type        = number
  default     = 10
}

variable "disk_autoresize" {
  description = "Whether to enable auto-resizing of the storage disk."
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "The maximum size an auto-resized disk can reach. Default is 500 for production, 50 for non-production."
  type        = number
  default     = null
}

variable "enable_backup" {
  description = "Whether to enable daily backup of databases."
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "Start time in UTC for daily backup job in the format HH:MM. This is the start time of a 4 hour time window."
  type        = string
  default     = "00:00"
  validation {
    condition     = can(regex("^[0-2][0-9]:[0-6][0-9]", var.backup_start_time))
    error_message = "Start time must be in the format HH:MM."
  }
}

variable "maintenance_window" {
  description = "The day of the week (1-7), and hour of the day (0-24) in UTC to perform database instance maintenance. This is the start time of the one hour maintinance window."
  type = object({
    day  = number
    hour = number
  })
  default = {
    day  = 2
    hour = 0
  }
  validation {
    condition     = var.maintenance_window.day >= 1 && var.maintenance_window.day <= 7 && var.maintenance_window.hour >= 0 && var.maintenance_window.hour <= 23
    error_message = "Day of the week must be from 1 to 7, and hour must be from 0 to 23."
  }
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance."
  type        = bool
  default     = null
}

variable "transaction_log_retention_days" {
  description = "How long transaction logs are stored (1-7)."
  type        = number
  default     = 7
}

variable "availability_type" {
  description = "Whether to enable high availability with automatic failover over multiple zones ('REGIONAL') vs. single zone ('ZONAL')."
  type        = string
  default     = null
}

variable "disable_offsite_backup" {
  description = "Disable offsite backup for this instance. Offsite backup is only applied to production environments."
  type        = bool
  default     = false
}

variable "query_insights_enabled" {
  description = "Whether to enable query insights (7 day retention)."
  type        = bool
  default     = false // Default false for non-breaking change
}

variable "query_insights_config" {
  description = "Advanced config for Query Insights."
  type = object({
    query_string_length     = number
    record_application_tags = bool
    record_client_address   = bool
  })
  default = {
    query_string_length     = 1024
    record_application_tags = false
    record_client_address   = false
  }
}
