# crassy
A `Sparklyr-Cassandra-Connector` using the Datastax `Spark-Cassandra-Connector`.

This purpose of this library is to allow existing data in Cassandra to be analysed in R. Therefore, the only available operations to this extension are to  
 
 - Load Cassandra partitions or whole tables
 - Writes (updates) Cassandra tables
 
_NOTE: For analysis on partitions, or sections of partitions, I have found this to be enough functionality.  The other use case I've found is when searching for a particular row in a Cassandra table, which doesn't need to overhead of passing the data to Spark. As an example of how submitting raw CQL to the cluster can be done through R, I've set up this [library](!https://github.com/AkhilNairAmey/CQLConnect) as an example of how that can be done._

_Unfortunately this is very specific to my use case, as I believe to make a more generic package would involve some fairly heavy duty Scala introspective techniques, and I'm just not there yet.  If you have any ideas how this could be achieved, please feel free to open an issue, or find me at akhil.nair@amey.co.uk_

## Usage

Connect to a spark cluster and get the session

```
library(sparklyr)
library(dplyr)
library(crassy)

sc <- spark_connect(
  master     = 'local', 
  spark_home = spark_home_dir()
)

spark_session = spark_get_session(sc)
```

Load some table into spark

```
spk_handle = crassy::spark_load_cassandra_table(
  session       = spark_session,
  cass_keyspace = "system_auth", 
  cass_tbl      = "roles", 
  spk_tbl_name  = "spk_tbl",
  select_cols   = c("role", "can_login")
)
```
