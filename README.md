# crassy
A `Sparklyr-Cassandra-Connector` using the Datastax `Spark-Cassandra-Connector`.

This purpose of this library is to allow existing data in Cassandra to be analysed in R. Therefore, the available operations in this extension are to  
 
 - Load Cassandra partitions or whole tables with server-side filtering and selecting 
 - Writes (updates) Cassandra tables

## Setup

Sparklyr automates much of the process of getting the connector loaded into the Spark Context. Simply ensure that you have the correct connector by cross-referencing this [compatibility table](https://github.com/datastax/spark-cassandra-connector#version-compatibility) with the [Spark-Cassandra-Connector package releases](https://spark-packages.org/package/datastax/spark-cassandra-connector) and choose one of the setup options below:

#### config.yml (recommended)
Create a file named `config.yml` in the R project working directory. Sparklyr will automatically use the packages specified in this file. An example is:
```
default:
  # local-only configuration
  spark.cassandra.connection.host: <your_cassandra_host_name>

  # default spark packages to load
  # match connector version to spark version
  sparklyr.defaultPackages:
    - com.datastax.spark:spark-cassandra-connector_2.11:2.0.0-M3
```
In addition, any other configuration options may be added here as well. Find a template in the Sparklyr package directory somewhere like: 
`~/R/x86_64-pc-linux-gnu-library/<R_VERSION>/sparklyr/conf/config-template.yml`

#### Call in script
You can also specify packages in the script using the `config` argument of `spark_connect` as such:
```
config <- spark_config()
config$sparklyr.defaultPackages = "com.datastax.spark:spark-cassandra-connector_2.11:2.0.0-M3"
config$spark.cassandra.connection.host = 'localhost'
```

#### Add jar to `spark_home`
Automatically load the package during every Spark Context by manually loading the associated `jar` file of your compatible package into your`spark_home/jars` directory. You may also use `wget` from your `jars` dir as such:
```
wget http://dl.bintray.com/spark-packages/maven/datastax/spark-cassandra-connector/2.0.0-M2-s_2.11/spark-cassandra-connector-2.0.0-M2-s_2.11.jar
```
In this case you must also ensure that your Scala version (2.10 or 2.11) matches.

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

sc <- spark_connect(
  master     = 'local', 
  spark_home = spark_home_dir()
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

For my use case - analysis on partitions, or sections of partitions - I have found this to be just enough functionality to be workable, and use this code in production. 

The other use case I've found I needed is where I need to search for a particular row in a Cassandra table, which doesn't need to overhead of passing the data to Spark. For an example of how submitting raw CQL to the cluster can be done through R, please refer to this library - https://github.com/AkhilNairAmey/CQLConnect.

Unfortunately the library is very specific to my use case, as I believe to make a more generic package would involve some fairly heavy duty Scala introspective techniques, and I'm just not there yet.  If you have any ideas how this could be achieved, please feel free to open an issue, or find me at akhil.nair@amey.co.uk

Thanks,
Akhil
