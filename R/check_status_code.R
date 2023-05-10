check_status_code = function(server) {
  res = httr::HEAD(server)
  status_codes = get_status_codes(res)
  status_code_msg = glue::glue(paste(status_codes, collapse = " {cli::symbol$arrow_right} ")) # nolint
  if (any(stringr::str_starts(status_codes, "2"))) {
    cli::cli_alert_success("{cli::col_green('Status code')}: {status_code_msg}")
  } else {
    cli::cli_alert_danger("{cli::col_red('Status code')}: {status_code_msg}")
  }
  return(status_codes)
}
