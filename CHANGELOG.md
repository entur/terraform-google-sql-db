# Changelog

## [1.1.0](https://github.com/entur/terraform-google-sql-db/compare/v1.0.0...v1.1.0) (2022-11-25)


### Features

* Adds an option to disable k8s resources via variable ([#21](https://github.com/entur/terraform-google-sql-db/issues/21)) ([2c0499d](https://github.com/entur/terraform-google-sql-db/commit/2c0499dbb1d4e100ed6b298d8d1b26a0ab98adc7))
* Support additional users ([#22](https://github.com/entur/terraform-google-sql-db/issues/22)) ([9233d30](https://github.com/entur/terraform-google-sql-db/commit/9233d30e107b0e15fef6da43da6b0cdf7898bd4b))

## [1.0.0](https://github.com/entur/terraform-google-sql-db/compare/v0.2.0...v1.0.0) (2022-11-03)


### ⚠ BREAKING CHANGES

* use POSTGRES_14 default (#14)
* Add environment based sizing and availability defaults, support for specifying a machine tier (#17)

### Features

* Add environment based sizing and availability defaults, support for specifying a machine tier ([#17](https://github.com/entur/terraform-google-sql-db/issues/17)) ([ec34ece](https://github.com/entur/terraform-google-sql-db/commit/ec34ece689229746df0b372765f69afe2afefd2c))
* use POSTGRES_14 default ([#14](https://github.com/entur/terraform-google-sql-db/issues/14)) ([bfec952](https://github.com/entur/terraform-google-sql-db/commit/bfec952b9d9fb70dc838f7eb3d7b0bba3b7b233a))

## [0.2.0](https://github.com/entur/terraform-google-sql-db/compare/v0.1.2...v0.2.0) (2022-09-22)


### Features

* Variable for enabling Query Insights ([#15](https://github.com/entur/terraform-google-sql-db/issues/15)) ([a1dcfb2](https://github.com/entur/terraform-google-sql-db/commit/a1dcfb23d540a76fd1eaf66b322e816745b700c5))

## [0.1.2](https://github.com/entur/terraform-google-sql-db/compare/v0.1.1...v0.1.2) (2022-07-06)


### Bug Fixes

* add database_name override ([#5](https://github.com/entur/terraform-google-sql-db/issues/5)) ([a4fded1](https://github.com/entur/terraform-google-sql-db/commit/a4fded1096bb658633a05db57f8adcf248b776a5))
* force tcp for proxy ([#6](https://github.com/entur/terraform-google-sql-db/issues/6)) ([0aadb93](https://github.com/entur/terraform-google-sql-db/commit/0aadb931e78c203823a99e501d101dbee05cb798))
* override psql user ([#7](https://github.com/entur/terraform-google-sql-db/issues/7)) ([a1e6e62](https://github.com/entur/terraform-google-sql-db/commit/a1e6e622bdf5b85eda6fcc9280833ef7fd748fe4))
