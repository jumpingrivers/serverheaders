check_server_headers = function(server) {
  headers = get_response_headers(server)
  headers_summary = purrr::map2_df(headers, names(headers), header_summary)
  missing_headers = .primary_headers[!.primary_headers %in% headers_summary$header]
  all_headers = dplyr::bind_rows(headers_summary, get_missing_headers(missing_headers))

  all_headers = add_documentation_column(all_headers)
  all_headers = add_primary_column(all_headers)
  all_headers = dplyr::bind_rows(all_headers, check_ssl_functionality(server))
  cli_message_output(all_headers, .primary_headers)
  all_headers
}

get_response_headers = function(server) {
  res = httr::GET(server)
  headers = httr::headers(res)
  out = c(
    headers,
    list(scheme = httr::parse_url(res$url)[["scheme"]],
         redirection = is_redirected(res), # nolint: indentation_linter
         `subresource-integrity` = get_js_resources(res),
         cookies = httr::cookies(res)$secure
    )
  )
  # Add class to for header_summary functions
  out = purrr::map2(out, names(out), ~{
    class(.x) = .y
    .x
  })
  out
}

get_missing_headers = function(headers)  {
  if (length(headers) == 0L) return(NULL)
  dplyr::tibble(header = headers,
                status = "WARN",
                message = "Header not set",
                value = NA_character_)
}

get_status_codes = function(res) {
  all_headers = res$all_headers
  status_codes = purrr::map_dbl(all_headers, "status")
  return(status_codes)
}

# Does the website redirection implemented i.e. HTTP -> HTTPS?
is_redirected = function(res) {
  status_codes = get_status_codes(res)
  http_versions = purrr::map_chr(res$all_headers, "version")
  redirection = any(grepl("^3", status_codes)) || any(http_versions == "HTTP/2")
  return(redirection)
}

# Retrieves HTML attributes of any script tags to check
# subresource integrity
get_js_resources = function(res) {
  # Avoid encoding message. Handled above
  content = suppressMessages(httr::content(res))
  content %>%
    rvest::html_elements("script") %>%
    rvest::html_attrs()
}
