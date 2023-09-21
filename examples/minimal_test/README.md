<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_init"></a> [init](#module\_init) | github.com/entur/terraform-google-init//modules/init | v0.3.0 |
| <a name="module_postgresql"></a> [postgresql](#module\_postgresql) | ../../modules/postgresql | n/a |

## Resources

| Name | Type |
|------|------|
| [random_integer.random_database_generation](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_init"></a> [init](#input\_init) | n/a | `map` | <pre>{<br>  "app": {<br>    "id": "tfmodules",<br>    "name": "tf-mod-google-postgresql",<br>    "owner": "team-plattform",<br>    "project_id": "ent-tfmodules-dev"<br>  },<br>  "environment": "dev",<br>  "is_production": false,<br>  "labels": {<br>    "app": "tf-mod-google-postgresql",<br>    "app_id": "tfmodules",<br>    "env": "dev",<br>    "owner": "team-plattform",<br>    "team": "team-plattform"<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | Application ID |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | The database instance name. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | Project ID |
<!-- END_TF_DOCS -->