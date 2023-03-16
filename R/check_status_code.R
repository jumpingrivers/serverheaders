check_status_code = function(server) {
  res = httr::HEAD(server)
  status_code = httr::status_code(res)
  col = if (stringr::str_starts(status_code, "2")) cli::col_green else cli::col_red #nolint
  cli::cli_alert_info("{col('Status code')}: {status_code}")
  return(status_code)
}
