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
  database_version = "POSTGRES_18" # Use the latest postgres version
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
| non-production | Dedicated vCPU | 1   | 3840 MB | No               |
| production     | Dedicated vCPU | 1   | 3840 MB | Yes              |

### Edition

Changing this will cause a database restart on existing instances. Choosing **Enterprise Plus** (`ENTERPRISE_PLUS`) over **Enterprise** (`ENTERPRISE`) can also increase costs. Carefully evaluate your requirements before choosing this edition.

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

## IAM authentication

IAM authentication lets Google identities (service accounts, users, and groups) log in to Cloud SQL
using their Google credentials instead of a password.

Prefer `iam_auth_groups` over `iam_auth_users` for human access. Group membership is managed in
the identity provider, so access is revoked automatically when someone leaves the team - no
Terraform change required.

### Adding a team group

To allow all members of a team to connect to the database, add the team's Google group using
`iam_auth_groups`. The group email follows the pattern `sg-dig-team-<teamname>@entur.no`.

```terraform
module "postgresql" {
  ...
  enable_iam_auth = true

  iam_auth_groups = {
    team = {
      email = "sg-dig-team-<teamname>@entur.no"
    }
  }
}
```

The default `roles` value is `["cloudsqlsuperuser"]`, which allows the group to connect to the
instance. It does not grant access to existing schemas, tables, or sequences.

### Granting access to database objects

After applying the Terraform configuration, a existing database administrator user must run `GRANT` statements
to give the group access to existing objects. Connect to the database as a superuser and run:

```sql
-- Allow the group to use the schema
GRANT USAGE ON SCHEMA public TO "sg-dig-team-<teamname>@entur.no";

-- Grant access to existing tables and sequences
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "sg-dig-team-<teamname>@entur.no";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "sg-dig-team-<teamname>@entur.no";

-- Grant access to tables and sequences created in the future
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "sg-dig-team-<teamname>@entur.no";
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO "sg-dig-team-<teamname>@entur.no";
```

Adjust the privileges (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) to match the level of access the
team should have. A team that only needs read access should receive `SELECT` only.

### Connecting from a local machine

Use Cloud SQL Auth Proxy with Application Default Credentials to connect from a local machine.
See the official guide:
[Connect using Cloud SQL Auth Proxy with IAM authentication](https://docs.cloud.google.com/sql/docs/postgres/iam-logins#cloud-sql-auth-proxy)

### Integration Tests

Run local integration tests in test/integration folder.

> [!IMPORTANT]  
> Only Team-Plattform has rights to do this locally.
> Contributors can create a PR which will run the tests as well.

```bash
cd test/integration
go test -v -tags=integration -timeout 30m ./...
```
