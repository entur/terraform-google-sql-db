# Terraform module(s) for creating Google Cloud SQL instances following Entur's conventions

Modules for provisioning Cloud SQL instances on Google Cloud Platform.

## PostgreSQL module

A PostgreSQL module that uses the [init module](https://github.com/entur/terraform-google-init) as minimum input, while allowing overrides and additional configuration.

[Module](modules/postgresql)

[Examples](examples)

## Getting started

<!-- ci: x-release-please-start-version -->

### Example using the latest release

```terraform
module "postgresql" {
  source = "github.com/entur/terraform-google-sql-db//modules/postgresql?ref=v1.7.4"
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

| Environment    | Type           | CPU | Memory  | Highly available |
| -------------- | -------------- | --- | ------- | ---------------- |
| non-production | Shared vCPU    | <1  | 600 MB  | No               |
| production     | Dedicated vCPU | 1   | 3840 MB | Yes              |


### Edition

We highly recommend using the Enterprise Plus edition of SQL instances in production environments and the Enterprise edition for non-production environments.

Ensure you select the appropriate tier for your use case. For more details about instance editions, refer to the [official documentation](https://cloud.google.com/sql/docs/postgres/instance-settings).


### Sizing

To specify the size of a database instance, supply the `cpu` and `memory` attributes in `var.machine_size` (recommended):

```terraform
module "postgresql" {
  ...
  machine_size = {
    cpu    = 1
    memory = 3840
  }
}
```

Tiers can also be set explicitly using the `tier` attribute:

```terraform
module "postgresql" {
  ...
  machine_size = {
    tier = "db-f1-micro"
  }
}
```

### Integration Tests

Run local integration tests in test/integration folder.

> [!IMPORTANT]  
> Only Team-Plattform has rights to do this locally.
> Contributors can create a PR which will run the tests as well.

Make sure you are connected to the dev kubernetes cluster in GKE (kub-ent-dev-001)

```bash
cd test/integration
go test -v -tags=integration -timeout 30m ./...
```
