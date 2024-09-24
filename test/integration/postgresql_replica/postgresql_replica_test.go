//go:build integration

package postgresql_replica

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

const exampleDir = "../../../fixtures/postgres-replica"

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

			// master specific validation
			if instance == cloudSqlT.GetStringOutput("instance_name") {
				// assert general database settings
				assert.Equal("REGIONAL", op.Get("settings.availabilityType").String(), "Expected REGIONAL availabilityType")
				assert.Equal(op.Get("settings.ipConfiguration.sslMode").String(), "ENCRYPTED_ONLY")

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
