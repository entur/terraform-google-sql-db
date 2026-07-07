# Upgrade postgresql module from v1 to v2

Upgrade Terraform configurations that use the `entur/terraform-google-sql-db` postgresql module
from v1.x to v2.x.

## What changed in v2

### Breaking changes

| Variable | v1 behaviour | v2 behaviour |
|----------|-------------|--------------|
| `database_version` | Default: `"POSTGRES_14"` | **Required** - no default |
| `enable_basic_auth` | Did not exist | **Required** - no default |
| `enable_iam_auth` | Did not exist | **Required** - no default |
| `create_kubernetes_resources` | Optional (`true` by default) | **Removed** |
| `additional_users[*].create_kubernetes_secret` | Optional field | **Removed** |
| Non-prod default machine size | `db-f1-micro` | `db-custom-1-3840` |

### Removed resources

The module no longer creates these resources. Terraform will plan to destroy them on upgrade:

- `kubernetes_config_map.<name>-psql-connection`
- `kubernetes_secret.<name>-psql-credentials`
- `kubernetes_secret.<name>-<user>-psql-credentials` (per additional user)
- `google_secret_manager_secret.db_secret["HOST"]`
- `google_secret_manager_secret.db_secret["PORT"]`
- `google_secret_manager_secret_version.db_secret_version_main_database_credentials["HOST"]`
- `google_secret_manager_secret_version.db_secret_version_main_database_credentials["PORT"]`

### New optional variables

| Variable | Description | Default |
|----------|-------------|---------|
| `enable_pgaudit` | Enable pgaudit extension (restarts instance) | `false` |
| `iam_auth_default_application_user` | IAM auth for the app service account | enabled when `enable_iam_auth = true` |
| `iam_auth_additional_service_account_users` | Additional service account users | `{}` |
| `iam_auth_users` | Individual IAM users | `{}` |
| `iam_auth_groups` | IAM groups | `{}` |

### Resource moves

The upgrade includes `moved` blocks so these resources are renamed rather than recreated:

- `random_password.password` → `random_password.password[0]`
- `google_sql_user.main` → `google_sql_user.main[0]`

## Steps

### 1. Find module configurations

Search the working directory for files that reference this module:

```
grep -rl 'terraform-google-sql-db//modules/postgresql' .
```

Read each file found.

### 2. Update each file

For each Terraform file that references the postgresql module, apply these changes:

**a. Update the source ref**

Change the `?ref=` tag from `v1.x.x` to the latest v2 release. Check
https://github.com/entur/terraform-google-sql-db/releases for the current latest v2.x.x tag.

**b. Add `enable_basic_auth`**

Add this argument to preserve v1 behaviour (v1 always created a basic auth user):

```hcl
enable_basic_auth = true
```

If the user wants to disable basic auth and use only IAM auth, set `enable_basic_auth = false`
instead, but warn them that this will destroy the SQL user, its password, and the corresponding
Secret Manager secrets.

**c. Add `enable_iam_auth` and disable the default application user**

Enable IAM auth, but keep the default application user opt-in. Without the override the module
would automatically add the application service account as a database user, which teams should
choose to do deliberately.

```hcl
enable_iam_auth = true
iam_auth_default_application_user = { enabled = false }
```

`enable_iam_auth = true` adds the `cloudsql.iam_authentication` database flag and makes the
instance ready to accept IAM users and groups.

When a team is ready to grant the application service account database access, they can remove
the override (or set `enabled = true`) to add it.

**d. Ensure `database_version` is explicit**

If `database_version` is not set, add it. v1 defaulted to `"POSTGRES_14"`. Ask the user which
PostgreSQL version their instance is running if they are unsure, or confirm `POSTGRES_14` is
correct before using it as a safe default.

```hcl
database_version = "POSTGRES_14"  # confirm this matches the running instance
```

**e. Remove `create_kubernetes_resources`**

If present, remove the `create_kubernetes_resources` argument. The module no longer supports
Kubernetes resource creation.

**f. Remove `create_kubernetes_secret` from `additional_users`**

In v1, each entry in `additional_users` could have a `create_kubernetes_secret` field:

```hcl
# v1
additional_users = {
  reporting = {
    username               = "reporting"
    create_kubernetes_secret = true
  }
}
```

Remove the `create_kubernetes_secret` field from each entry. Only `username` is accepted in v2:

```hcl
# v2
additional_users = {
  reporting = {
    username = "reporting"
  }
}
```

### 3. Warn about removed resources

After making the code changes, tell the user what Terraform will destroy on next apply and what
they need to do before applying:

> **Before applying, check the following:**
>
> - **Keep the Kubernetes provider during the upgrade**: Terraform must destroy the old
>   Kubernetes resources as part of the upgrade, but v2 of the module no longer declares the
>   Kubernetes provider. Without it in the root module, `terraform plan` will error. Add the
>   provider to the root module's `required_providers` (or `provider` block) before running
>   plan, and remove it again after the apply succeeds.
>
>   ```hcl
>   terraform {
>     required_providers {
>       kubernetes = {
>         source  = "hashicorp/kubernetes"
>         version = "~> 2.0"
>       }
>     }
>   }
>   ```
>
> - **Kubernetes ConfigMap / Secrets**: The Kubernetes ConfigMap and Secrets previously created
>   by the module will be destroyed. If anything still reads them, migrate to the common Helm
>   chart v2 (see step 4) or read from Secret Manager directly.
>
> - **`PGHOST` and `PGPORT` secrets**: The module no longer writes host or port to Secret
>   Manager. The common Helm chart v2 provides these as environment variables automatically
>   (`localhost` and `5432`). If the application reads `PGHOST` or `PGPORT` from Secret Manager
>   directly (outside of the Helm chart), update it to use hardcoded values instead.
>
> Run `terraform plan` to see the full list of resources that will be created, moved, or
> destroyed. The `google_sql_user.main` and `random_password.password` resources will appear
> as "moved", not recreated - the database user and password are preserved.

### 4. Recommend the common Helm chart v2

The [common Helm chart v2](https://github.com/entur/helm-charts) is designed to work with this
Terraform module version. It reads `{prefix}INSTANCES`, `{prefix}USER`, and `{prefix}PASSWORD`
directly from Secret Manager via External Secrets - no Terraform-created Kubernetes secrets
needed. It also generates `{prefix}HOST=localhost` and `{prefix}PORT=5432` as environment
variables itself, and supports IAM authentication via Cloud SQL Auth Proxy v2 with Workload
Identity.

Tell the user to upgrade the Helm chart alongside the Terraform module, and to follow the
upgrade skill from the `entur/helm-charts` repository:

```
Read and follow the upgrade skill at:
https://raw.githubusercontent.com/entur/helm-charts/main/.claude/skills/upgrade-common-chart/SKILL.md
```

### 5. Summary

After making all changes, report:

- Which Terraform files were updated and which variables were added or removed
- Whether Kubernetes resources were in use (and whether the Helm chart v2 was recommended)
- Whether any applications read `PGHOST`/`PGPORT` from Secret Manager directly (and need updating)
- The next steps: `terraform plan`, then `helm dependency update` and `helm lint`
