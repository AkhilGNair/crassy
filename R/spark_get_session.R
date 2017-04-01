#' spark_get_session
#'
#' Get the spark session
#'
#' @param sc A spark context created with \code{sparklyr::spark_connect}
#'
#' @importFrom magrittr "%>%"
#'
#' @export

spark_get_session = function(sc) {
  session = sparklyr::invoke_static(sc, "org.apache.spark.sql.SparkSession", "builder") %>%
    sparklyr::invoke("getOrCreate")

  # return
  session
}
