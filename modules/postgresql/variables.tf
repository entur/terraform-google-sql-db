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
  description = "The region of this database"
  type        = string
  default     = "europe-west1"
}

variable "machine_size" {
  description = "Map of the database instance CPU count (cpu) and memory sizes in MB (memory)."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 1
    memory = 3840
  }
  validation {
    condition     = var.machine_size.cpu >= 1 && var.machine_size.cpu <= 96 && var.machine_size.memory % 256 == 0 && var.machine_size.memory >= 3840 && var.machine_size.memory <= 13312
    error_message = "CPU must be a whole number between 1 and 96. Memory must be devisable by 256, and between 3840 and 13312."
  }
}

variable "generation" {
  description = "Generation of database. Starts at 1, ends at 999. Will be padded with leading zeros."
  type        = number
  default     = 1

  validation {
    condition     = var.generation < 1000 && var.generation > 0
    error_message = "Generation must be bewteen [1,999]."
  }
}

variable "database_version" {
  description = "The postgres database version."
  type        = string
  default     = "POSTGRES_13"

  validation {
    condition     = can(regex("^POSTGRES_[1-9][0-9]$", var.database_version))
    error_message = "Supports postgres version 10 or higher."
  }
}

variable "user_name" {
  description = "The username of the database. Defaults to init.app.name."
  type        = string
  default     = null
}

variable "retained_backups" {
  description = "The number of backups to retain. 30 for prod, 7 for non prod."
  type        = number
  default     = null
}

variable "disk_size" {
  description = "The disk size of this database. Default is 10 (GB). Only takes effect if disk_autoresize is false."
  type        = number
  default     = 10
}

variable "disk_autoresize" {
  description = "Enable disk auto resize."
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "Maximum size of auto resized disk. Default 500 for production, and 50 for non-prod."
  type        = number
  default     = null
}

variable "enable_backup" {
  description = "Enable daily backup of the database."
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
  description = "Enable backup for database."
  type        = bool
  default     = null
}

variable "transaction_log_retention_days" {
  description = "How long the transaction logs is stored (1-7)."
  type        = number
  default     = 7
}

variable "availability_type" {
  description = "REGIONAL or ZONAL database."
  type        = string
  default     = "REGIONAL"
}

variable "disable_offsite_backup" {
  description = "Disable offsite backup for this database. Offsite backup is only applied to prd."
  type        = bool
  default     = false
}
