# Postgres Terraform Module #

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=4.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >=4.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_sql_database_instance.replica](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_database_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/sql_database_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_init"></a> [init](#input\_init) | Entur init module output. https://github.com/entur/terraform-google-init. Used to determine application name, application project, labels, and resource names. | <pre>object({<br>    app = object({<br>      id         = string<br>      name       = string<br>      owner      = string<br>      project_id = string<br>    })<br>    environment   = string<br>    labels        = map(string)<br>    is_production = bool<br>  })</pre> | n/a | yes |
| <a name="input_master_instance_name"></a> [master\_instance\_name](#input\_master\_instance\_name) | The name of the master instance to create a read-replica for. | `string` | n/a | yes |
| <a name="input_availability_type"></a> [availability\_type](#input\_availability\_type) | Whether to enable high availability with automatic failover to another read-replica. 'REGIONAL' for HA, 'ZONAL' for single zone. | `string` | `null` | no |
| <a name="input_database_flags"></a> [database\_flags](#input\_database\_flags) | Override default CloudSQL configuration by specifying database-flags. | <pre>map(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `{}` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether or not to allow Terraform to destroy the instance. | `bool` | `null` | no |
| <a name="input_machine_size_override"></a> [machine\_size\_override](#input\_machine\_size\_override) | By default, machine\_size will be the same as the master. Set this variable to override. Keep in mind that replica must have equal or higher machine\_size. See README.md for examples. | `map` | `null` | no |
| <a name="input_query_insights_config"></a> [query\_insights\_config](#input\_query\_insights\_config) | Advanced config for Query Insights. | <pre>object({<br>    query_string_length     = number<br>    record_application_tags = bool<br>    record_client_address   = bool<br>  })</pre> | <pre>{<br>  "query_string_length": 1024,<br>  "record_application_tags": false,<br>  "record_client_address": false<br>}</pre> | no |
| <a name="input_query_insights_enabled"></a> [query\_insights\_enabled](#input\_query\_insights\_enabled) | Whether to enable query insights (7 day retention). | `bool` | `false` | no |
| <a name="input_replica_number"></a> [replica\_number](#input\_replica\_number) | The replica-number of the instance in the case of many. Starts at 1, ends at 999. Will be padded with leading zeros. Used as suffix for the instance-name | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_init"></a> [init](#output\_init) | The output of the consumed init module. |
| <a name="output_instance"></a> [instance](#output\_instance) | The database instance output, as described in https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance. |
<!-- END_TF_DOCS -->