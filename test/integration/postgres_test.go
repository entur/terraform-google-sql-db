//go:build integration

package postgres

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

const exampleDir = "../../examples/minimal_test"

func TestCloudSql(t *testing.T) {

	cloudSqlT := tft.NewTFBlueprintTest(t,
		tft.WithTFDir(exampleDir),
	)

	// asserts copied from https://github.com/terraform-google-modules/terraform-google-sql-db/blob/master/test/integration/postgresql-public/postgresql_public_test.go
	cloudSqlT.DefineVerify(func(assert *assert.Assertions) {
		db := gcloud.Run(t, fmt.Sprintf("sql instances describe %s --project %s", cloudSqlT.GetStringOutput("instance_name"), cloudSqlT.GetStringOutput("project_id")))
		assert.Equal("POSTGRES_14", db.Get("databaseVersion").String(), "Expected POSTGRES_14 databaseVersion")
		assert.Equal("RUNNABLE", db.Get("state").String(), "Expected RUNNABLE state")
		assert.Equal("europe-west1", db.Get("region").String(), "Expected europe-west1 region")
		assert.True(db.Get("settings.storageAutoResize").Bool(), "Expected TRUE storageAutoResize")
		assert.Equal("sql#maintenanceWindow", db.Get("settings.maintenanceWindow.kind").String(), "Expected sql#maintenanceWindow maintenanceWindow.kind")
		assert.Equal(int64(2), db.Get("settings.maintenanceWindow.day").Int(), "Expected 2 maintenanceWindow.day")
		assert.Equal(int64(0), db.Get("settings.maintenanceWindow.hour").Int(), "Expected 0 maintenanceWindow.hour")
	})

	cloudSqlT.Test()
}