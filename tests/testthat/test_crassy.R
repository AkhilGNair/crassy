library(sparklyr)
library(dplyr)
library(crassy)

if(!exists("sc")) {
  spark_install("2.0.2")
  sc = spark_connect(master="local", spark_home = spark_home_dir())
}

test_that("read existing Cassandra data", {
  skip_on_cran()

  cdf = crassy::spark_load_cassandra_table(
    sc            = sc,
    cass_keyspace = "system_auth",
    cass_tbl      = "roles",
    spk_tbl_name  = "spk_tbl",
    select_cols   = c("role", "can_login"),
    partition_filter = NULL
  )

  expect_true("cassandra" %in% (cdf %>% collect() %>% `[[`("role")))
})

test_that("write Spark DataFrame into Cassandra", {
  skip_on_cran()

  tbl_iris = copy_to(sc, iris, overwrite = TRUE)

  # Can't expect any keyspaces we can write to as no function to make or teardown keyspaces
  # For now, just check that it tried to look for the specified table to write to
  # TODO: Add keyspace/table sync methods and update this
  testthat::expect_error(
    crassy::spark_write_cassandra_table(tbl_iris, "test", "iris"),
    regexp = "Couldn't find test.iris or any similarly named keyspace and table pairs"
  )
})

spark_disconnect(sc)
