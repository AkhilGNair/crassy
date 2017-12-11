# crassy
A `Sparklyr-Cassandra-Connector` using the Datastax `Spark-Cassandra-Connector`.

This purpose of this library is to allow existing data in Cassandra to be analysed in R. Therefore, the available operations in this extension are to  
 
 - Load Cassandra partitions or whole tables with server-side filtering and selecting 
 - Writes (updates) Cassandra tables

## Usage

Connect to a spark cluster and get the session

```
library(sparklyr)
library(dplyr)
library(crassy)

spark_install("2.0.2")

# Not the recommended way to handle config 
# Better to put in working directory under config.yml
# See http://spark.rstudio.com/deployment.html#configuration 
# and https://github.com/rstudio/config

config <- spark_config()
config$sparklyr.defaultPackages = "com.datastax.spark:spark-cassandra-connector_2.11:2.0.0-M3"
config$spark.cassandra.connection.host = 'localhost'

sc <- spark_connect(
  master     = 'local', 
  spark_home = spark_home_dir(),
  config = config
)
```

Load some table into spark

```
spk_handle = crassy::spark_load_cassandra_table(
  sc            = sc,
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

### Note

Writing Scala extensions for Sparklyr exposes all functions of the `Spark-Cassandra-Connector` which is extremely powerful. Please refer to https://github.com/AkhilNairAmey/CQLConnect to see how I have:
 - Submitted raw CQL to the cluster from R
 - Used the `cassandraTable` convenience function provided by the `Spark-Cassandra-Connecter` via R
 - Used `joinWithCassandraTable` to fetch a table of 500+ specific partitions from a table, and manipulate the result natively in R 

If any of these are particularly useful, please let me know via and issue, and I will try to continue development.
