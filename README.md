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
  source = "github.com/entur/terraform-google-sql-db//modules/postgresql?ref=v0.0.1"
  ...
}
```
<!-- ci: x-release-please-end -->

See the `README.md` under each module's subfolder for a list of supported inputs and outputs. For examples showing how they're implemented, check the [examples](examples) subfolder.

### Version constraints
You can control the version of a module dependency by adding `?ref=TAG` at the end of the source argument, as shown in the example above. This is highly recommended. You can find a list of available versions [here](https://github.com/entur/terraform-google-sql-db/releases).

Dependency automation tools such as Renovate Bot will be able to discover new releases and suggest updates automatically.
