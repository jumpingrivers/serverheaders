check_server_headers = function(server) {
  headers = get_response_headers(server)
  headers_summary = purrr::map2_df(headers, names(headers), header_summary)
  security_headers = names(.documentation_links)
  missing_headers = security_headers[!security_headers %in% headers_summary$security_header]
  all_headers = dplyr::bind_rows(headers_summary, get_missing_headers(missing_headers)) |>
    join_with_documentation()
  cli_message_output(all_headers, security_headers)
  all_headers
}

get_response_headers = function(server) {
  res = httr::GET(server)
  out = c(
    httr::headers(res),
    list(scheme = httr::parse_url(res$url)[["scheme"]],
         redirection = get_redirection(res),
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

get_missing_headers = function(security_headers)  {
  if (length(security_headers) == 0L) return(NULL)
  dplyr::tibble(security_header = security_headers,
                status = "WARN",
                message = "Header not set",
                value = NA_character_)
}

get_redirection = function(res) {
  all_headers = res$all_headers
  status_codes = purrr::map_dbl(all_headers, "status")
  http_versions = purrr::map_chr(all_headers, "version")
  redirection = any(status_codes >= 300 & status_codes < 400) || any(http_versions == "HTTP/2")
  return(redirection)
}

get_js_resources = function(res) {
  res |>
    httr::content() |>
    rvest::html_elements("script") |>
    rvest::html_attrs()
}
