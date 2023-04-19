.security_headers = c(
  "content-security-policy",
  "set-cookie",
  "access-control-allow-origin",
  "strict-transport-security",
  "redirection",
  "referrer-policy",
  "subresource-integrity",
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
  "subresource-integrity" = "https://infosec.mozilla.org/guidelines/web_security#subresource-integrity",
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
    dplyr::left_join(
      dplyr::tibble(
        security_header = names(.documentation_links),
        documentation = .documentation_links
      ),
      by = "security_header") |>
    dplyr::arrange(.data$security_header)
  for (i in seq_len(nrow(all_headers))) {
    row = all_headers[i, ]
    if (row$security_header %in% .security_headers) {
      col = get_status_col(row$status) # nolint
      if (row$status == "WARN") {
        msg = "{col(row$security_header)}: {row$message} ({.href [Documentation]({row$documentation})})"
      } else {
        msg = "{col(row$security_header)}: {row$message}"
      }
      cli::cli_alert_info(msg)
    }
  }
  all_headers
}

get_response_headers = function(server) {
  status_codes = get_all_status_codes(server)
  res = httr::GET(server)
  out = c(
    httr::headers(res),
    list(scheme = httr::parse_url(res$url)[["scheme"]],
         redirection = any(status_codes >= 300 & status_codes < 400),
         `subresource-integrity` = get_js_resources(res)
    )
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

get_all_status_codes = function(server) {
  server = gsub("https", "http", server)
  res = httr::GET(server)
  all_headers = res$all_headers
  purrr::map_dbl(all_headers, "status")
}

get_js_resources = function(res) {
  res |>
    httr::content() |>
    rvest::html_elements("script") |>
    rvest::html_attrs()
}
