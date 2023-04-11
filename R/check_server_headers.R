.security_headers = c(
  "content-security-policy",
  "set-cookie",
  "access-control-allow-origin",
  "strict-transport-security",
  "redirection",
  "referrer-policy",
  "x-content-type-options",
  "x-frame-options",
  "x-xss-protection"
)

.documentation_links = c(
  "content-security-policy" = "https://infosec.mozilla.org/guidelines/web_security#content-security-policy",
  "set-cookie" = "https://infosec.mozilla.org/guidelines/web_security#cookies",
  "access-control-allow-origin" = "https://infosec.mozilla.org/guidelines/web_security#cross-origin-resource-sharing",
  "strict-transport-security" = "https://infosec.mozilla.org/guidelines/web_security#http-strict-transport-security",
  "redirection" = "https://infosec.mozilla.org/guidelines/web_security#http-redirections",
  "referrer-policy" = "https://infosec.mozilla.org/guidelines/web_security#referrer-policy",
  "x-content-type-options" = "https://infosec.mozilla.org/guidelines/web_security#x-content-type-options",
  "x-frame-options" = "https://infosec.mozilla.org/guidelines/web_security#x-frame-options",
  "x-xss-protection" = "https://infosec.mozilla.org/guidelines/web_security#x-xss-protection"
)

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
  for (i in seq_len(nrow(all_headers))) {
    row = all_headers[i, ]
    if (row$security_header %in% .security_headers) {
      col = get_status_col(row$status) # nolint
      if (row$status == "WARN") {
        documentation_link = .documentation_links[[row$security_header]]
        cli::cli_alert_info("{col(row$security_header)}: {row$message} ({.href [Documentation]({documentation_link})})")
      } else {
        cli::cli_alert_info("{col(row$security_header)}: {row$message}")
      }
    }
  }
  all_headers
}

get_response_headers = function(server) {
  res = httr::HEAD(server)
  out = c(
    httr::headers(res),
    list(scheme = httr::parse_url(res$url)[["scheme"]])
  )
  out$`set-cookie` = httr::cookies(res)$secure
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
