# Changelog

## [1.7.0](https://github.com/entur/terraform-google-sql-db/compare/v1.6.0...v1.7.0) (2023-08-29)


### Features

* Add option to store credentials in secrets manager for additional users ([#43](https://github.com/entur/terraform-google-sql-db/issues/43)) ([a401b7c](https://github.com/entur/terraform-google-sql-db/commit/a401b7c1ed789fccba73180289a6895956f88d98))

## [1.6.0](https://github.com/entur/terraform-google-sql-db/compare/v1.5.0...v1.6.0) (2023-08-25)


### Features

* push database credentials to Secret Manager ([#40](https://github.com/entur/terraform-google-sql-db/issues/40)) ([8a01a3f](https://github.com/entur/terraform-google-sql-db/commit/8a01a3ff0f9f94f87374ed688887e7269f440265))

## [1.5.0](https://github.com/entur/terraform-google-sql-db/compare/v1.4.0...v1.5.0) (2023-08-08)


### Features

* Add integration test ([#37](https://github.com/entur/terraform-google-sql-db/issues/37)) ([b0bbbb0](https://github.com/entur/terraform-google-sql-db/commit/b0bbbb03b186b44cfc9fb5b57fd2fffbea83e7d5))

## [1.4.0](https://github.com/entur/terraform-google-sql-db/compare/v1.3.1...v1.4.0) (2023-07-14)


### Features

* open up for modifying allowed networks ([#35](https://github.com/entur/terraform-google-sql-db/issues/35)) ([b5ac641](https://github.com/entur/terraform-google-sql-db/commit/b5ac6411dacc2c9a9231ab9f4a2a165b285b0a65))

## [1.3.1](https://github.com/entur/terraform-google-sql-db/compare/v1.3.0...v1.3.1) (2023-05-10)


### Bug Fixes

* `point_in_time_recovery_enabled` input, default true ([#32](https://github.com/entur/terraform-google-sql-db/issues/32)) ([48c31bd](https://github.com/entur/terraform-google-sql-db/commit/48c31bd451ed74d845df55f5b5906a009dca47dc))

## [1.3.0](https://github.com/entur/terraform-google-sql-db/compare/v1.2.0...v1.3.0) (2023-01-23)


### Features

* New module postgresql-replica ([#28](https://github.com/entur/terraform-google-sql-db/issues/28)) ([c71b2ac](https://github.com/entur/terraform-google-sql-db/commit/c71b2ac1df87e6f982759129ae54f33442ecb01e))

## [1.2.0](https://github.com/entur/terraform-google-sql-db/compare/v1.1.0...v1.2.0) (2022-12-12)


### Features

* Support specifying database-flags for custom configuration ([#26](https://github.com/entur/terraform-google-sql-db/issues/26)) ([63c6a82](https://github.com/entur/terraform-google-sql-db/commit/63c6a822b9991617231163e95022973ba343683a))

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
