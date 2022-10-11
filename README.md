# Terraform module(s) for creating Google Cloud SQL instances following Entur's conventions

Modules for provisioning Cloud SQL instances on Google Cloud Platform.

## PostgreSQL module

A PostgreSQL module that uses the [init module](https://github.com/entur/terraform-google-init) as minimum input, while allowing overrides and additional configuration.

[Module](modules/postgresql)

[Examples](examples)

## Getting started

<!-- ci: x-release-please-start-version -->
### Example using the latest release
```
module "postgresql" {
  source = "github.com/entur/terraform-google-sql-db//modules/postgresql?ref=v0.2.0"
  ...
}
```
<!-- ci: x-release-please-end -->

See the `README.md` under each module's subfolder for a list of supported inputs and outputs. For examples showing how they're implemented, check the [examples](examples) subfolder.

### Version constraints
You can control the version of a module dependency by adding `?ref=TAG` at the end of the source argument, as shown in the example above. This is highly recommended. You can find a list of available versions [here](https://github.com/entur/terraform-google-sql-db/releases).

Dependency automation tools such as Renovate Bot will be able to discover new releases and suggest updates automatically.

## Machine sizes and availability
If a desired machine size and/or availability type is not explicitly set, defaults will be used:

| Environment    | Type           | CPU  | Memory  | Highly available |
|----------------|----------------|------|---------|------------------|
| non-production | Shared vCPU    | <1   | 600 MB  | No               |
| production     | Dedicated vCPU | 1    | 3840 MB | Yes              |

### Sizing
To specify the size of a database instance, supply the `cpu` and `memory` attributes in `var.machine_size` (recommended):

```
module "postgresql" {
  ...
  machine_size = {
    cpu    = 1
    memory = 3840
  }
}
```

Tiers can also be set explicitly using the `tier` attribute:
```
module "postgresql" {
  ...
  machine_size = {
    tier = "db-f1-micro"
  }
}
```