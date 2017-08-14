`%&%` = function(a, b) paste0(a, b)

#' spark_get_master
#'
#' Get the spark master connection string from the running host
#'
#' @param port Spark master connection port
#'
#' @include utils.R
#' @export

spark_get_master = function(port = 7077) {
  spark_master = system("hostname -i", intern = TRUE)
  spark_master = "spark://" %&% spark_master %&% ":" %&% port
  spark_master
}

#' Infix paste0
`%&%` = function(a, b) paste0(a, b)

#' Helper to cast dates to cql dates, for use
#' in a partition filter, for example 
#'
#' @export
cassandra_cast_date = function(date) {
  "date = cast('" %&% date %&% "' as date)"
}
