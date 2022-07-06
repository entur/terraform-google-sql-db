# Postgres Terraform Module #

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=4.26.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >=4.26.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0.3 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_sql_database.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [kubernetes_config_map.main_psql_connection](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_secret.main_database_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_integer.password_length](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_init"></a> [init](#input\_init) | Entur init module output. https://github.com/entur/terraform-google-init. Used to determine application name, application project, labels, and resource names. | <pre>object({<br>    app = object({<br>      id         = string<br>      name       = string<br>      owner      = string<br>      project_id = string<br>    })<br>    environment   = string<br>    labels        = map(string)<br>    is_production = bool<br>  })</pre> | n/a | yes |
| <a name="input_availability_type"></a> [availability\_type](#input\_availability\_type) | REGIONAL or ZONAL database. | `string` | `"REGIONAL"` | no |
| <a name="input_backup_start_time"></a> [backup\_start\_time](#input\_backup\_start\_time) | Start time in UTC for daily backup job in the format HH:MM. This is the start time of a 4 hour time window. | `string` | `"00:00"` | no |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | The postgres database version. | `string` | `"POSTGRES_13"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable backup for database. | `bool` | `null` | no |
| <a name="input_disable_offsite_backup"></a> [disable\_offsite\_backup](#input\_disable\_offsite\_backup) | Disable offsite backup for this database. Offsite backup is only applied to prd. | `bool` | `false` | no |
| <a name="input_disk_autoresize"></a> [disk\_autoresize](#input\_disk\_autoresize) | Enable disk auto resize. | `bool` | `true` | no |
| <a name="input_disk_autoresize_limit"></a> [disk\_autoresize\_limit](#input\_disk\_autoresize\_limit) | Maximum size of auto resized disk. Default 500 for production, and 50 for non-prod. | `number` | `null` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | The disk size of this database. Default is 10 (GB). Only takes effect if disk\_autoresize is false. | `number` | `10` | no |
| <a name="input_enable_backup"></a> [enable\_backup](#input\_enable\_backup) | Enable daily backup of the database. | `bool` | `true` | no |
| <a name="input_generation"></a> [generation](#input\_generation) | Generation of database. Starts at 1, ends at 999. Will be padded with leading zeros. | `number` | `1` | no |
| <a name="input_machine_size"></a> [machine\_size](#input\_machine\_size) | Map of the database instance CPU count (cpu) and memory sizes in MB (memory). | <pre>object({<br>    cpu    = number<br>    memory = number<br>  })</pre> | <pre>{<br>  "cpu": 1,<br>  "memory": 3840<br>}</pre> | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | The day of the week (1-7), and hour of the day (0-24) in UTC to perform database instance maintenance. This is the start time of the one hour maintinance window. | <pre>object({<br>    day  = number<br>    hour = number<br>  })</pre> | <pre>{<br>  "day": 2,<br>  "hour": 0<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The region of this database | `string` | `"europe-west1"` | no |
| <a name="input_retained_backups"></a> [retained\_backups](#input\_retained\_backups) | The number of backups to retain. 30 for prod, 7 for non prod. | `number` | `null` | no |
| <a name="input_transaction_log_retention_days"></a> [transaction\_log\_retention\_days](#input\_transaction\_log\_retention\_days) | How long the transaction logs is stored (1-7). | `number` | `7` | no |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | The username of the database. Defaults to init.app.name. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Name of the default database in the database instance. |
| <a name="output_init"></a> [init](#output\_init) | The init module used in the module. |
| <a name="output_instance"></a> [instance](#output\_instance) | The database instance output, as described in https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance. |
| <a name="output_kubernetes_namespace"></a> [kubernetes\_namespace](#output\_kubernetes\_namespace) | Name of the kubernetes namespace where the connection details configmap and secret are deployed. |
| <a name="output_user"></a> [user](#output\_user) | Map containing the username and password of the default application user. |
<!-- END_TF_DOCS -->