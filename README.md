# Terraform module(s) for creating Google Cloud SQL instances following Entur's conventions

Modules for provisioning Cloud SQL instances on Google Cloud Platform.

## PostgreSQL module

A PostgreSQL module that uses the [init module](https://github.com/entur/terraform-google-init) as minimum input, while allowing overrides and additional configuration.

[Module](modules/postgresql)

[Examples](examples)

## Usage instructions

### Version constraints
You can control the version of a module dependency by adding `?ref=TAG` at the end of the source argument. This is highly recommended. You can find a list of available versions [here](https://github.com/entur/terraform-google-sql-db/releases).

```
module "postgresql" {
  source = "github.com/entur/terraform-google-sql-db//modules/postgresql?ref=vVERSION"
  ...
}
```

Dependency automation tools such as Renovate Bot will be able to discover new releases and suggest updates automatically.

#### Example

```
module "postgresql" {
  source = "github.com/entur/terraform-google-sql-db//modules/postgresql?ref=v1.0.0"
  ...
}
```