package postgresql_test

import (
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("Creating postgres from examples", func() {
	Context("with one database", func() {
		terraformOptions := &terraform.Options{
			TerraformDir: "../examples/minimal",
			PlanFilePath: "tfplan",
			NoColor:      true,
			Logger:       logger.Discard,
		}

		defer terraform.Destroy(GinkgoT(), terraformOptions)
		plan := terraform.InitAndPlanAndShowWithStruct(GinkgoT(), terraformOptions)

		It("should create a Postgres database", func() {
			resource := plan.ResourcePlannedValuesMap["module.postgresql.google_sql_database.main[\"my-database\"]"]
			Expect(resource).To(HaveField("Type", "google_sql_database"))
			Expect(resource).To(HaveField("Index", "my-database"))
		})
	})
})
