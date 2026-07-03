# Postgres Terraform Module #

> [!IMPORTANT]
> The primary instance must still have IAM auth enabled too, because IAM users and groups are managed there. For Helm, the replica instance should use the matching prefix, for example `secretKeyPrefix: PG_REPLICA`, so it reads `PG_REPLICAINSTANCES` and `PG_REPLICAIAMUSER`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >=5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_secret_manager_secret.replica_db_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.replica_db_secret_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_sql_database_instance.replica](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_init"></a> [init](#input\_init) | Entur init module output. https://github.com/entur/terraform-google-init. Used to determine application name, application project, labels, and resource names. | <pre>object({<br/>    app = object({<br/>      id         = string<br/>      name       = string<br/>      owner      = string<br/>      project_id = string<br/>    })<br/>    environment   = string<br/>    labels        = map(string)<br/>    is_production = bool<br/>    service_accounts = object({<br/>      default = object({<br/>        email = string<br/>        id    = string<br/>      })<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_master_instance"></a> [master\_instance](#input\_master\_instance) | The master instance to create a read-replica for. Must be a 'google\_sql\_database\_instance' from either the master resource or data. | `any` | n/a | yes |
| <a name="input_add_replica_secret_manager_credentials"></a> [add\_replica\_secret\_manager\_credentials](#input\_add\_replica\_secret\_manager\_credentials) | Set to false to not store replica connection and IAM credentials in Secret Manager. | `bool` | `true` | no |
| <a name="input_availability_type"></a> [availability\_type](#input\_availability\_type) | Whether to enable high availability with automatic failover to another read-replica. 'REGIONAL' for HA, 'ZONAL' for single zone. | `string` | `null` | no |
| <a name="input_database_flags"></a> [database\_flags](#input\_database\_flags) | Override default CloudSQL configuration by specifying database-flags. | <pre>map(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_iam_auth"></a> [enable\_iam\_auth](#input\_enable\_iam\_auth) | Enables IAM database authentication for the replica instance. IAM users and groups must be managed on the primary instance. | `bool` | `false` | no |
| <a name="input_instance_edition"></a> [instance\_edition](#input\_instance\_edition) | Override the default instance edition (`ENTERPRISE` or `ENTERPRISE_PLUS`). | `string` | `"ENTERPRISE"` | no |
| <a name="input_machine_size_override"></a> [machine\_size\_override](#input\_machine\_size\_override) | By default, machine\_size will be the same as the master. Set this variable to override. Keep in mind that replica must have equal or higher machine\_size. See README.md for examples. | `map(any)` | `null` | no |
| <a name="input_replica_number"></a> [replica\_number](#input\_replica\_number) | The replica-number of the instance in the case of many. Starts at 1, ends at 999. Will be padded with leading zeros. Used as suffix for the instance-name | `number` | `1` | no |
| <a name="input_secret_key_prefix"></a> [secret\_key\_prefix](#input\_secret\_key\_prefix) | Key prefix for replica secrets. Ex. {secret\_key\_prefix: REPLICA\_PG} creates REPLICA\_PGINSTANCES and REPLICA\_PGIAMUSER. | `string` | `"PG_REPLICA"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_init"></a> [init](#output\_init) | The output of the consumed init module. |
| <a name="output_instance"></a> [instance](#output\_instance) | The database instance output, as described in https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance. |
<!-- END_TF_DOCS -->