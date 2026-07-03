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
    service_accounts = object({
      default = object({
        email = string
        id    = string
      })
    })
  })
}

variable "master_instance" {
  type        = any # can we do any more advanced typing here?
  description = "The master instance to create a read-replica for. Must be a 'google_sql_database_instance' from either the master resource or data."
}

variable "machine_size_override" {
  description = "By default, machine_size will be the same as the master. Set this variable to override. Keep in mind that replica must have equal or higher machine_size. See README.md for examples."
  # type = object({
  #   tier   = optional(string) # Optional attributes not supported until Terraform 1.3
  #   cpu    = number
  #   memory = number
  # })
  type = map(any)
  #default = {
  #tier   = "db-f1-micro"
  #cpu    = 1
  #memory = 3840
  #}
  default = null
  validation {
    condition     = var.machine_size_override != null ? try(var.machine_size_override.cpu, 1) >= 1 && try(var.machine_size_override.cpu, 1) <= 96 : true
    error_message = "CPU must be a whole number between 1 and 96."
  }
  validation {
    condition     = var.machine_size_override != null ? try(var.machine_size_override.memory, 256) % 256 == 0 && try(var.machine_size_override.memory, 3840) >= 3840 && try(var.machine_size_override.memory, 3840) <= 13312 : true
    error_message = "Memory must be divisable by 256, and between 3840 and 13312."
  }
  validation {
    condition     = var.machine_size_override != null ? (try(var.machine_size_override.tier, null) != null) && (try(var.machine_size_override.cpu, null) == null || try(var.machine_size_override.memory, null) == null) || (try(var.machine_size_override.tier, null) == null) && (try(var.machine_size_override.cpu, null) != null && try(var.machine_size_override.memory, null) != null) : true
    error_message = "Either supply desired resource limits for cpu and memory (recommended), or specify a tier."
  }
}

variable "replica_number" {
  description = "The replica-number of the instance in the case of many. Starts at 1, ends at 999. Will be padded with leading zeros. Used as suffix for the instance-name"
  type        = number
  default     = 1

  validation {
    condition     = var.replica_number < 1000 && var.replica_number > 0
    error_message = "Replica-number must be between [1,999]."
  }
}

variable "availability_type" {
  description = "Whether to enable high availability with automatic failover to another read-replica. 'REGIONAL' for HA, 'ZONAL' for single zone."
  type        = string
  default     = null
}

variable "database_flags" {
  description = "Override default CloudSQL configuration by specifying database-flags."
  type = map(object({
    name  = string
    value = string
  }))
  default = {}
}

variable "enable_iam_auth" {
  description = "Enables IAM auth for the replica instance. If add_replica_secret_manager_credentials is true, the default application IAM username is stored in Secret Manager. The primary instance must also have IAM auth enabled."
  type        = bool
  default     = false
}

variable "iam_auth_default_application_user" {
  description = "Adds IAM auth credentials for the default application user. If enabled, the application service account username is stored in Secret Manager."
  type = object({
    enabled = bool
  })
  default = {
    enabled = true
  }
}

variable "secret_key_prefix" {
  description = "Key prefix for replica secrets. Ex. {secret_key_prefix: REPLICA_PG} creates REPLICA_PGINSTANCES and REPLICA_PGIAMUSER."
  type        = string
  default     = "PG_REPLICA"
}

variable "add_replica_secret_manager_credentials" {
  description = "Set to false to not store replica connection and IAM credentials in Secret Manager."
  type        = bool
  default     = true
}

variable "instance_edition" {
  type        = string
  default     = "ENTERPRISE"
  description = "Override the default instance edition (`ENTERPRISE` or `ENTERPRISE_PLUS`)."
}
