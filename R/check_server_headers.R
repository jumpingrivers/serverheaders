.security_headers = c(
  "access-control-allow-origin",
  "content-security-policy", "content-security-policy-report-only",
  "nel",
  "permissions-policy",
  "referrer-policy",
  "report-to",
  "scheme", "server",
  "strict-transport-security",
  "x-content-type-options",
  "x-frame-options",
  "x-permitted-cross-domain-policies",
  "x-powered-by","x-xss-protection")

get_status_col = function(status) {
  if (status %in% c("OK", "NOTE")) {
    cli::col_green
  } else if (status == "UNKNOWN") {
    cli::col_blue
  } else {
    cli::col_red
  }
}

check_server_headers = function(server) {
  headers = get_response_headers(server)
  headers_summary = purrr::map2_df(headers, names(headers), header_summary)
  missing_headers = .security_headers[!.security_headers %in% headers_summary$security_header]
  all_headers = dplyr::bind_rows(headers_summary, get_missing_headers(missing_headers)) |>
    dplyr::arrange(.data$security_header)
  for (s_header in .security_headers) {
    header = all_headers[all_headers$security_header == s_header, ]
    col = get_status_col(header$status) # nolint
    cli::cli_alert_info("{col(header$security_header)}: {header$message}")
  }
  all_headers
}

get_response_headers = function(server) {
  res = httr::HEAD(server)
  out = c(
    httr::headers(res),
    list(scheme = httr::parse_url(res$url)[["scheme"]])
  )
  # Add class to for header_summary functions
  out = purrr::map2(out, names(out), ~{
    class(.x) = .y
    .x
  })
  out
}

get_missing_headers = function(security_headers)  {
  if (length(security_headers) == 0L) return(NULL)
  dplyr::tibble(security_header = security_headers,
                status = "WARN",
                message = "Header not set",
                value = NA_character_)
}
