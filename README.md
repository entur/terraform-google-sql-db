# Terraform module(s) for creating postgresql databases following Entur's best practices

Modules that helps deploying postgresql databases on Cloud SQL in GCP 2.0. The modules uses the init module to get defaults like application name and project.

## Main postgresql module

A postgresql module that uses the [init module](https://github.com/entur/terraform-google-init) as minimum input, while allowing overrides and additional configuration.

[Module](modules/postgresql)

[Examples](examples)
