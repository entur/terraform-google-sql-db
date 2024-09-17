//go:build integration

package postgresql_replica

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

const exampleDir = "../../../examples/postgres-replica"

func TestPostgreSqlReplicaModule(t *testing.T) {
	cloudSqlT := tft.NewTFBlueprintTest(t,
		tft.WithTFDir(exampleDir),
	)

	cloudSqlT.DefineVerify(func(assert *assert.Assertions) {
		// pSql.DefaultVerify(assert)

		instaceNames := []string{pSql.GetStringOutput("name")}
		projectId := pSql.GetStringOutput("project_id")
		op := gcloud.Runf(t, "sql instances describe %s --project %s", instaceNames[0], projectId)

		assert.Equal(1, len(op.Get("replicaNames").Array()), "Expected 1 replicas")
		
		instaceNames = append(instaceNames, utils.GetResultStrSlice(op.Get("replicaNames").Array())...)

		for _, instance := range instaceNames {
			op = gcloud.Runf(t, "sql instances describe %s --project %s", instance, projectId)

			// assert general database settings
			assert.Equal("POSTGRES_14", db.Get("databaseVersion").String(), "Expected POSTGRES_14 databaseVersion")
			assert.Equal("RUNNABLE", db.Get("state").String(), "Expected RUNNABLE state")
			assert.Equal("europe-west1", db.Get("region").String(), "Expected europe-west1 region")
			assert.Equal("sql#maintenanceWindow", db.Get("settings.maintenanceWindow.kind").String(), "Expected sql#maintenanceWindow maintenanceWindow.kind")
			assert.Equal(int64(2), db.Get("settings.maintenanceWindow.day").Int(), "Expected 2 maintenanceWindow.day")
			assert.Equal(int64(0), db.Get("settings.maintenanceWindow.hour").Int(), "Expected 0 maintenanceWindow.hour")

			// master specific validation
			if instance == pSql.GetStringOutput("name") {
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
