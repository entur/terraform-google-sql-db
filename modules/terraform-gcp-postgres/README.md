# Postgres Terraform Module #

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=4.26 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >=4.26 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_projects.app_projects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |
| [google_projects.kubernetes_projects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |
| [google_projects.network_projects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |
| [google_service_account.application_default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Application ID, yolo structure | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment descriptor (i.e. 'dev', 'tst', 'prd'). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app"></a> [app](#output\_app) | A map containing essentials about the application (id', 'name', 'project\_id', 'owner'). |
| <a name="output_environment"></a> [environment](#output\_environment) | Environment descriptor (i.e. 'dev', 'tst', 'prd'). |
| <a name="output_is_production"></a> [is\_production](#output\_is\_production) | Describes whether the environment in use is a production environment. |
| <a name="output_kubernetes"></a> [kubernetes](#output\_kubernetes) | A map containing essentials about available Kubernetes cluster(s) ('project\_id'). |
| <a name="output_labels"></a> [labels](#output\_labels) | Labels for use on managed resources (i.e. Kubernetes resources). |
| <a name="output_networks"></a> [networks](#output\_networks) | A map containing essentials about available network(s) ('project\_id'). |
| <a name="output_service_accounts"></a> [service\_accounts](#output\_service\_accounts) | A map containing essentials about application service account(s). |
<!-- END_TF_DOCS -->
