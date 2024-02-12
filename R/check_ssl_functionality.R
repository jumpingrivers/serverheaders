check_ssl_functionality = function(server) {
  clean_server = stringr::str_remove(server, "http(s?)://")
  dplyr::bind_rows(
    check_ssl(clean_server),
    check_ssl_redirect(clean_server)
  )
}

check_ssl_redirect = function(clean_server) {
  server = paste0("http://", clean_server)
  res = httr::HEAD(server)
  status_codes = get_status_codes(res)
  status_code_msg = glue::glue(paste(status_codes, collapse = " {cli::symbol$arrow_right} "))
  if (any(stringr::str_starts(status_codes, "2")) && length(status_codes) > 1) {
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

is_ssl_expired = function(res) "try-error" %in% class(res)
get_ssl_expired = function(res) {
  rtn = list()
  rtn$status_codes = NA_integer_
  rtn$status = "WARN"
  rtn$message = "SSL incorrect"

  status_code_msg = "SSL certificate problem: certificate has expired" #nolint
  cli::cli_alert_danger("{cli::col_red({rtn$message})}: {status_code_msg}")
  rtn
}

get_ssl_route = function(res) {
  rtn = list()
  rtn$status_codes = get_status_codes(res)
  status_code_msg = glue::glue(paste(rtn$status_codes, collapse = " {cli::symbol$arrow_right} ")) #nolint
  if (any(stringr::str_starts(rtn$status_codes, "2"))) {
    rtn$status = "OK"
    rtn$message = "SSL available"
    cli::cli_alert_success("{cli::col_green({rtn$message})}: {status_code_msg}")
  } else {
    rtn$status = "WARN"
    rtn$message = "SSL incorrect"
    cli::cli_alert_danger("{cli::col_red({rtn$message})}: {status_code_msg}")
  }
  rtn
}

check_ssl = function(clean_server) {
  server = paste0("https://", clean_server)
  res = try(httr::HEAD(server), silent = TRUE)
  # Usually no cert at all
  if (is_ssl_expired(res)) {
    rtn = get_ssl_expired(res)
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
