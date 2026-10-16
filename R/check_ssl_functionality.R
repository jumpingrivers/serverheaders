check_ssl_functionality = function(server) {
  clean_server = stringr::str_remove(server, "http(s?)://")
  dplyr::bind_rows(
    check_ssl(clean_server),
    check_ssl_redirect(clean_server)
  )
}

check_ssl_redirect = function(clean_server) {
  server = paste0("http://", clean_server)
  res = try(httr::HEAD(server), silent = TRUE)
  if (!is_ssl_error(res)) {
    status_codes = get_status_codes(res)
    status_code_msg = glue::glue(paste(status_codes, collapse = " {cli::symbol$arrow_right} "))
  } else {
    status_codes = NA
    status_code_msg = "Connection failed"
  }

  if (length(status_codes) > 1 && any(stringr::str_starts(status_codes, "2"))) {
    status = "OK"
    message = "SSL redirection successful"
    cli::cli_alert_success("{cli::col_green({message})}: http -> https")
  } else {
    status = "WARN"
    message = "SSL redirection incorrect"
    cli::cli_alert_danger("{cli::col_red({message})}: {status_code_msg}")
  }
  dplyr::tibble(
    header = "ssl-redirection",
    status = status,
    message = message,
    value = status_code_msg,
    primary_header = TRUE,
  )
}

is_ssl_error = function(res) inherits(res, "try-error")
get_ssl_error = function(res) {
  rtn = list()
  rtn$status_codes = NA_integer_
  rtn$status = "WARN"
  rtn$message = "SSL incorrect"
  # e.g. expired or missing certificate, or host not found
  rtn$status_code_msg = conditionMessage(attr(res, "condition"))
  cli::cli_alert_danger("{cli::col_red({rtn$message})}: {rtn$status_code_msg}")
  rtn
}

get_ssl_route = function(res) {
  rtn = list()
  rtn$status_codes = get_status_codes(res)
  rtn$status_code_msg = glue::glue(paste(rtn$status_codes, collapse = " {cli::symbol$arrow_right} ")) #nolint
  if (any(stringr::str_starts(rtn$status_codes, "2"))) {
    rtn$status = "OK"
    rtn$message = "SSL available"
    cli::cli_alert_success("{cli::col_green({rtn$message})}: {rtn$status_code_msg}")
  } else {
    rtn$status = "WARN"
    rtn$message = "SSL incorrect"
    cli::cli_alert_danger("{cli::col_red({rtn$message})}: {rtn$status_code_msg}")
  }
  rtn
}

check_ssl = function(clean_server) {
  server = paste0("https://", clean_server)
  res = try(httr::HEAD(server), silent = TRUE)
  if (is_ssl_error(res)) {
    rtn = get_ssl_error(res)
  } else {
    rtn = get_ssl_route(res)
  }

  dplyr::tibble(
    header = "ssl",
    status = rtn$status,
    message = rtn$message,
    value = rtn$status_code_msg,
    primary_header = TRUE,
    documentation = "Server should redirect http to https"
  )
}
