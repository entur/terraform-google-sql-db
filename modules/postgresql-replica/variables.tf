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

variable "master_instance_name" {
  type        = string
  description = "The name of the master instance to create a read-replica for."
}

variable "machine_size_override" {
  description = "By default, machine_size will be the same as the master. Set this variable to override. Keep in mind that replica must have equal or higher machine_size. See README.md for examples."
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

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance."
  type        = bool
  default     = null
}

variable "availability_type" {
  description = "Whether to enable high availability with automatic failover to another read-replica. 'REGIONAL' for HA, 'ZONAL' for single zone."
  type        = string
  default     = null
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

variable "database_flags" {
  description = "Override default CloudSQL configuration by specifying database-flags."
  type = map(object({
    name  = string
    value = string
  }))
  default = {}
}