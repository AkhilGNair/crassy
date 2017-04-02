# crassy
A `Sparklyr-Cassandra-Connector` using the Datastax `Spark-Cassandra-Connector`.

This library does two simple things to allow for an analysis pipeline for Cassandra data.
 
 - Load Cassandra partitions or whole tables
 - Writes (updates) Cassandra tables

## Usage

Connect to a spark cluster and get the session

```
library(sparklyr)
library(dplyr)
library(crassy)

spark_install("2.0.2")

sc <- spark_connect(
  master     = 'local', 
  spark_home = spark_home_dir()
)
```

Load some table into spark

```
spk_handle = crassy::spark_load_cassandra_table(
  session       = sc,
  cass_keyspace = "system_auth", 
  cass_tbl      = "roles", 
  spk_tbl_name  = "spk_tbl",
  select_cols   = c("role", "can_login")
)
```

Write some table to Cassandra, assuming the table already exists

```
tbl_iris = copy_to(sc, iris, overwrite = TRUE)

# Will throw an error if the table does not exist!
crassy::spark_write_cassandra_table(tbl_iris, "test", "iris")
```
