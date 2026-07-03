//go:build integration

package postgresql_replica

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

const exampleDir = "../../fixtures/postgres-replica"
const iamGroupEmail = "sg-dig-team-produkt@entur.no"

func TestPostgreSqlReplicaModule(t *testing.T) {
	cloudSqlT := tft.NewTFBlueprintTest(t,
		tft.WithTFDir(exampleDir),
	)

	cloudSqlT.DefineVerify(func(assert *assert.Assertions) {
		// pSql.DefaultVerify(assert)

		instanceNames := []string{cloudSqlT.GetStringOutput("instance_name")}
		projectId := cloudSqlT.GetStringOutput("project_id")
		op := gcloud.Runf(t, "sql instances describe %s --project %s", instanceNames[0], projectId)

		assert.Equal(1, len(op.Get("replicaNames").Array()), "Expected 1 replicas")
		
		instanceNames = append(instanceNames, utils.GetResultStrSlice(op.Get("replicaNames").Array())...)

		for _, instance := range instanceNames {
			op = gcloud.Runf(t, "sql instances describe %s --project %s", instance, projectId)

			// assert general database settings
			assert.Equal("POSTGRES_14", op.Get("databaseVersion").String(), "Expected POSTGRES_14 databaseVersion")
			assert.Equal("RUNNABLE", op.Get("state").String(), "Expected RUNNABLE state")
			assert.Equal("europe-west1", op.Get("region").String(), "Expected europe-west1 region")

			// IAM database authentication must be forced on for every instance
			// (master and replicas), regardless of caller-provided database_flags.
			iamAuthEnabled := false
			for _, flag := range op.Get("settings.databaseFlags").Array() {
				if flag.Get("name").String() == "cloudsql.iam_authentication" && flag.Get("value").String() == "on" {
					iamAuthEnabled = true
					break
				}
			}
			assert.True(iamAuthEnabled, "Expected cloudsql.iam_authentication=on on instance %s", instance)

			// master specific validation
			if instance == cloudSqlT.GetStringOutput("instance_name") {
				// assert general database settings
				assert.Equal("REGIONAL", op.Get("settings.availabilityType").String(), "Expected REGIONAL availabilityType")
				assert.Equal(op.Get("settings.ipConfiguration.sslMode").String(), "ENCRYPTED_ONLY")

				users := gcloud.Runf(t, "sql users list --instance %s --project %s", instance, projectId)
				iamGroupFound := false
				for _, u := range users.Array() {
					if u.Get("name").String() == iamGroupEmail && u.Get("type").String() == "CLOUD_IAM_GROUP" {
						iamGroupFound = true
						break
					}
				}
				assert.True(iamGroupFound, "Expected CLOUD_IAM_GROUP user %s on primary instance %s", iamGroupEmail, instance)

				// replica specific validation
			} else {
				// assert general database settings
				assert.Equal("ZONAL", op.Get("settings.availabilityType").String(), "Expected ZONAL availabilityType")
				assert.Equal(op.Get("settings.ipConfiguration.sslMode").String(), "ENCRYPTED_ONLY")
			}
		}

	})

	cloudSqlT.Test()
}
