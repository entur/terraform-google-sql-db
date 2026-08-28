# Upgrading to v2

This guide covers all breaking changes and required migration steps when upgrading from v1 to v2
of the `postgresql` module.

The headline change in v2 is the removal of Kubernetes integration. The module no longer creates
Kubernetes ConfigMaps or Secrets - credentials are read from Secret Manager instead. v2 also adds
support for IAM authentication.

## Prerequisites

- Terraform `>=1.3`
- `google` provider `>=7.18`
- Temporary access to a `kubernetes` provider in your root module (needed only during the upgrade,
  see [step 6](#6-temporarily-keep-the-kubernetes-provider))
- The application upgraded to the [common Helm chart](https://github.com/entur/helm-charts) v2, or
  ready to be upgraded in the same change. v2 of this module stops creating the Kubernetes
  ConfigMap and Secret that Helm chart v1 reads credentials from - see
  [entur/helm-charts UPGRADE.md](https://github.com/entur/helm-charts/blob/main/UPGRADE.md) and
  [step 10](#10-upgrade-the-helm-chart-alongside)

## Breaking changes

| Variable                                       | v1 behaviour                     | v2 behaviour              |
| ---------------------------------------------- | -------------------------------- | ------------------------- |
| `database_version`                             | Default: `"POSTGRES_14"`         | **Required** - no default |
| `enable_basic_auth`                            | Did not exist, default behaviour | **Required** - no default |
| `enable_iam_auth`                              | Did not exist                    | **Required** - no default |
| `create_kubernetes_resources`                  | Optional (`true` by default)     | **Removed**               |
| `additional_users[*].create_kubernetes_secret` | Optional field                   | **Removed**               |
| Non-prod default machine size                  | `db-f1-micro`                    | `db-custom-1-3840`        |

### Resources removed on upgrade

The module no longer creates these resources. Terraform will plan to destroy them:

- `kubernetes_config_map.<name>-psql-connection`
- `kubernetes_secret.<name>-psql-credentials`
- `kubernetes_secret.<name>-<user>-psql-credentials` (per additional user)
- `google_secret_manager_secret.db_secret["HOST"]`
- `google_secret_manager_secret.db_secret["PORT"]`
- `google_secret_manager_secret_version.db_secret_version_main_database_credentials["HOST"]`
- `google_secret_manager_secret_version.db_secret_version_main_database_credentials["PORT"]`

### Resources renamed, not recreated

These `moved` blocks are included in the module, so the database user and password are preserved:

- `random_password.password` -> `random_password.password[0]`
- `google_sql_user.main` -> `google_sql_user.main[0]`

### Machine size changes in dev/tst

> [!WARNING]
> If `machine_size` is not set on a `dev` or `tst` instance, it is currently using the v1 default
> of `db-f1-micro`. v2 changes that default to `db-custom-1-3840`. Changing an instance's machine
> type causes Cloud SQL to **restart the instance**, so expect brief downtime on `terraform apply`.
> This happens whether you accept the new default or pin `machine_size` to a different tier - any
> machine size change triggers a restart.

## New optional variables

| Variable                                    | Description                                  | Default                               |
| ------------------------------------------- | -------------------------------------------- | ------------------------------------- |
| `enable_pgaudit`                            | Enable pgaudit extension (restarts instance) | `false`                               |
| `iam_auth_default_application_user`         | IAM auth for the app service account         | enabled when `enable_iam_auth = true` |
| `iam_auth_additional_service_account_users` | Additional service account users             | `{}`                                  |
| `iam_auth_users`                            | Individual IAM users                         | `{}`                                  |
| `iam_auth_groups`                           | IAM groups                                   | `{}`                                  |

See the [IAM authentication](README.md#iam-authentication) section in the README for how to grant a
team access using `iam_auth_groups`.

## Step-by-step upgrade instructions

### 1. Find your module blocks

```bash
grep -rl 'terraform-google-sql-db//modules/postgresql' .
```

### 2. Update the source ref

Change `?ref=v1.x.x` to the latest v2 release. See the
[releases page](https://github.com/entur/terraform-google-sql-db/releases) for the current tag.

### 3. Add `enable_basic_auth`

Add this to preserve v1 behaviour, which always created a basic auth user:

```hcl
enable_basic_auth = true
```

Set it to `false` only if you want to drop basic auth in favour of IAM auth. Doing so destroys the
existing SQL user, its password, and the corresponding Secret Manager secrets.

### 4. Add `enable_iam_auth`

```hcl
enable_iam_auth = true
iam_auth_default_application_user = { enabled = false }
```

`enable_iam_auth = true` adds the `cloudsql.iam_authentication` database flag and makes the
instance ready to accept IAM users and groups. `iam_auth_default_application_user` is set to
`enabled = false` here so the application's service account is not added as a database user
automatically - add it deliberately once you're ready (see below).

> [!NOTE]
> Any new IAM user added via `iam_auth_default_application_user`,
> `iam_auth_additional_service_account_users`, `iam_auth_users`, or `iam_auth_groups` can connect
> to the instance, but has no access to existing schemas, tables, or sequences until a database
> administrator runs `GRANT` statements for that user.

### 5. Set `database_version` explicitly

v1 defaulted to `"POSTGRES_14"`. Confirm this matches your running instance, or check with
`gcloud sql instances describe <instance>` if unsure:

```hcl
database_version = "POSTGRES_14"
```

### 6. Remove Kubernetes-only arguments

- Remove `create_kubernetes_resources` if present.
- Remove `create_kubernetes_secret` from every entry in `additional_users` - only `username` is
  accepted in v2.

```hcl
# v1
additional_users = {
  reporting = {
    username                  = "reporting"
    create_kubernetes_secret  = true
  }
}

# v2
additional_users = {
  reporting = {
    username = "reporting"
  }
}
```

### 7. Temporarily keep the kubernetes provider

Terraform must destroy the old Kubernetes resources as part of the upgrade, but v2 of the module no
longer declares the `kubernetes` provider itself. Without it in your root module, `terraform plan`
will error. Add it before planning, and remove it again once the apply has succeeded:

```hcl
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
```

### 8. Update anything that reads `PGHOST`/`PGPORT` from Secret Manager

The module no longer writes host or port to Secret Manager. The common Helm chart v2 provides
these as environment variables automatically (`localhost` and `5432`). If any application reads
`PGHOST` or `PGPORT` from Secret Manager directly, outside of the Helm chart, update it to use
hardcoded values instead.

### 9. Plan and review

```bash
terraform plan
```

Check that `google_sql_user.main` and `random_password.password` show up as **moved**, not
destroyed/recreated, and confirm the list of resources that will be destroyed matches the
[list above](#resources-removed-on-upgrade).

### 10. Upgrade the Helm chart alongside

The [common Helm chart v2](https://github.com/entur/helm-charts) is designed to work with this
module version - it reads credentials directly from Secret Manager via External Secrets, so no
Terraform-created Kubernetes secrets are needed. Follow its upgrade guide:
[entur/helm-charts UPGRADE.md](https://github.com/entur/helm-charts/blob/main/UPGRADE.md).

### 11. Apply, then remove the temporary provider

Once `terraform apply` has succeeded, remove the `kubernetes` provider block you added in step 7,
unless something else in the root module still needs it.

## Quick migration checklist

- [ ] Update the module `source` ref to the latest v2 tag
- [ ] Add `enable_basic_auth = true` (or `false` if intentionally dropping basic auth)
- [ ] Add `enable_iam_auth` and, if not adding the app's service account yet,
      `iam_auth_default_application_user = { enabled = false }`
- [ ] Add `database_version`, confirmed against the running instance
- [ ] Remove `create_kubernetes_resources`
- [ ] Remove `create_kubernetes_secret` from every `additional_users` entry
- [ ] If `dev`/`tst` relies on the default machine size, plan for a brief instance restart on apply
- [ ] Add a temporary `kubernetes` provider to the root module
- [ ] Update anything reading `PGHOST`/`PGPORT` from Secret Manager directly
- [ ] Run `terraform plan` and confirm the moved/destroyed resources match this guide
- [ ] Upgrade the common Helm chart to v2 (see [entur/helm-charts](https://github.com/entur/helm-charts))
- [ ] Run `terraform apply`
- [ ] Remove the temporary `kubernetes` provider block

## Automated upgrade with an AI coding agent

Paste this prompt into Claude Code, Copilot, Cursor, or any AI coding agent from **your
application's repo**:

```text
Upgrade the terraform-google-sql-db postgresql module from v1 to v2.

Read the upgrade skill and follow its instructions:
  https://raw.githubusercontent.com/entur/terraform-google-sql-db/main/.claude/skills/upgrade-v1-to-v2.md

Apply all migration steps to every Terraform file in this repository that uses the module.
Run `terraform plan` to verify.
```
