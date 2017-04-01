#' Load and write Cassandra tables
#'
#' @name cassandra_tbl
#'
#' @param session The spark session
#' @param cass_keyspace A Cassandra keyspace
#' @param cass_tbl A Cassandra table/column family
#' @param spk_tbl_name The variable name of the loaded table in hive
#' @param spk_tbl A handle to a hive table to write
#' @param partition_filter A server-side filter clause
#' @param select_cols A server-side select clause
NULL

#' @name cassandra_tbl
#'
#' @importFrom magrittr "%>%"
#' @export
spark_load_cassandra_table = function(session, cass_keyspace, cass_tbl, spk_tbl_name, partition_filter = FALSE, select_cols = FALSE, cache_table = FALSE) {
  cass_df =
    sparklyr::invoke(session, "read") %>%
    sparklyr::invoke("format", "org.apache.spark.sql.cassandra") %>%
    sparklyr::invoke("option", "keyspace", cass_keyspace) %>%
    sparklyr::invoke("option", "table", cass_tbl) %>%
    sparklyr::invoke("load")

  if(is.character(partition_filter)) {
    cass_df = cass_df %>% sparklyr::invoke("where", partition_filter)
  }

  if(is.character(select_cols)) {
    if(length(select_cols) == 1) {
      cass_df = cass_df %>%
        sparklyr::invoke("select", select_cols, list())
    } else if(length(select_cols) > 1) {
      cass_df = cass_df %>%
        sparklyr::invoke("select", select_cols[[1]], as.list(select_cols[2:length(select_cols)]))
    }
  }

  spark_tbl = sparklyr:::spark_partition_register_df(sc, cass_df, spk_tbl_name, 0, cache_table)
  spark_tbl
}

#' @rdname cassandra_tbl
#'
#' @importFrom magrittr "%>%"
#' @export
spark_write_cassandra_table = function(spk_tbl, cass_keyspace, cass_tbl) {
  sparklyr::invoke(sparklyr::spark_dataframe(spk_tbl), "write") %>%
    sparklyr::invoke("format", "org.apache.spark.sql.cassandra") %>%
    sparklyr::invoke("option", "keyspace", cass_keyspace) %>%
    sparklyr::invoke("option", "table", cass_tbl) %>%
    sparklyr::invoke("mode", "append") %>%
    sparklyr::invoke("save")

  # return confirmation
  TRUE
}
