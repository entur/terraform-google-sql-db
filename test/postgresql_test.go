package postgresql_test

import (
	"fmt"
	"strings"

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
			Expect(plan.ResourcePlannedValuesMap).To(ContainElement(And(HaveField("Type", "google_sql_database"), HaveField("Index", "my-database"))))
		})

		It("should create a Postgres database instance with compliant name", func() {
			resource := plan.ResourcePlannedValuesMap["module.postgresql.google_sql_database_instance.main"]
			Expect(resource).To(Not(BeNil()))
			Expect(resource.AttributeValues).To(HaveKeyWithValue("name", "sql-tfmodules-dev-001"))

			//Expect(find(plan.ResourcePlannedValuesMap, func(resource *tfjson.StateResource) bool { return resource.Type == "google_sql_database_instance" }).AttributeValues).To(HaveKeyWithValue("name", "sql-tfmodules-dev-001"))
		})

		It("should create database credentials as a secret", func() {
			Expect(plan.ResourcePlannedValuesMap).To(ContainElement(And(HaveField("Type", "kubernetes_secret"), HaveField("Name", "main_database_credentials"))))
		})

		It("should have defaults", func() {
			values := plan.ResourcePlannedValuesMap["module.postgresql.google_sql_database_instance.main"].AttributeValues
			settings := values["settings"].([]interface{})[0].(map[string]interface{})
			backupConfig := settings["backup_configuration"]
			fmt.Println()
			fmt.Printf("Type: %T (value: %v)\n", backupConfig, backupConfig)
		})

		DescribeTable("and default config", func(path string, value interface{}) {
			values := plan.ResourcePlannedValuesMap["module.postgresql.google_sql_database_instance.main"].AttributeValues
			actual := findElementOnPath(values, strings.Split(path, "."))
			Expect(actual).To(Equal(value))
		},
			Entry("is of regional availability type", "settings.availability_type", "REGIONAL"),
			Entry("has automatic resizing", "settings.disk_autoresize", true),
			Entry("has no deletion protection in non-prod environment", "deletion_protection", false),
			//TODO: Entry("has deletion protection in production", "deletion_protection", true),
			//TODO: Entry("has a disk size of 10 GB", "settings.disk_size", 10),
			Entry("demand SSD disks", "settings.disk_type", "PD_SSD"),
			Entry("has backup enabled", "settings.backup_configuration.enabled", true),
			Entry("has a transaction log retention of seven days", "settings.backup_configuration.transaction_log_retention_days", float64(7)),
			Entry("retains seven backups in non prod", "settings.backup_configuration.backup_retention_settings.retained_backups", float64(7)),
			//TODO: Entry("retains thirty backups in prod", "settings.backup_configuration.backup_retention_settings.retained_backups", float64(30)),
			Entry("require ssl", "settings.ip_configuration.require_ssl", true),
			Entry("is of tier db-custom-1-3840", "settings.tier", "db-custom-1-3840"),
			Entry("is located in Western Europe", "region", "europe-west1"),
		)
		/*

			"backup":                         "+ enabled                        = true",
			"availability_type":              "+ availability_type     = \"REGIONAL\"",
			"auto_resize":                    "+ disk_autoresize       = true",
			"deletion_protection":            "+ deletion_protection           = false",
			"deletion_protection_prod":       "+ deletion_protection           = true",
			"disk_size":                      "+ disk_size             = 10",
			"pricing_plan":                   "+ disk_type             = \"PD_SSD\"",
			"transaction_log_retention_days": "+ transaction_log_retention_days = 7",
			"retained_backups_dev_and_tst":   "+ retained_backups = 7",
			"retained_backups_prd":           "+ retained_backups = 30",
			"ssl":                            "+ require_ssl",
			"tier":                           "+ tier                  = \"db-custom-1-3840\"",
			"region":                         "+ region                        = \"europe-west1\"",
			"psql-credentials":               "+ name             = \"some-postgres-app-psql-credentials\"",
			"psql-connection":                "+ name             = \"some-postgres-app-psql-connection\"",
			"psql-user":                      "+ resource \"google_sql_user\" \"user\" {",

		*/

	})
})

func findElementOnPath(node interface{}, path []string) interface{} {
	if len(path) == 0 {
		return node
	}
	switch currentElement := node.(type) {
	case []interface{}:
		return findElementOnPath(currentElement[0], path)
	case map[string]interface{}:
		return findElementOnPath(currentElement[path[0]], path[1:])
	default:
		return currentElement
	}
}

/*
func getResource(plan terraform.PlanStruct, resourceType string) tfjson.StateResource {

}

func find(resourceMap map[string]*tfjson.StateResource, filter func(*tfjson.StateResource) bool) tfjson.StateResource {
	for _, resource := range resourceMap {
		if filter(resource) {
			return *resource
		}
	}
	return *new(tfjson.StateResource)
}

//			Expect(plan).To(ContainElement(&ResourceMatcher{Type: Equal("google_sql_database"), Index: Equal("my-database")}))

/*type ResourceMatcher struct {
	Type         types.GomegaMatcher
	Name         types.GomegaMatcher
	Index        types.GomegaMatcher
	ProviderName types.GomegaMatcher
}

func (matcher ResourceMatcher) Match(actual interface{}) (success bool, err error) {
	switch actual := actual.(type) {
	case *tfjson.StateResource:
		matchers := []types.GomegaMatcher{}
		values := []interface{}{}
		matchers = append(matchers, matcher.Type, matcher.Name, matcher.Index, matcher.ProviderName)
		values = append(values, actual.Type, actual.Name, actual.Index, actual.ProviderName)
		for index, currentMatcher := range matchers {
			if currentMatcher != nil {
				result, err := currentMatcher.Match(values[index])
				if !result {
					return false, err
				}
			}
		}
	}
	return true, nil
}

func checkMatcher(matcher M)
*/
