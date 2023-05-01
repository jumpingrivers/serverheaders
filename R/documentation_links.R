# nolint start: line_length_linter
.documentation_links = c(
  "content-security-policy" = "https://infosec.mozilla.org/guidelines/web_security#content-security-policy",
  "cookies" = "https://infosec.mozilla.org/guidelines/web_security#cookies",
  "access-control-allow-origin" = "https://infosec.mozilla.org/guidelines/web_security#cross-origin-resource-sharing",
  "strict-transport-security" = "https://infosec.mozilla.org/guidelines/web_security#http-strict-transport-security",
  "redirection" = "https://infosec.mozilla.org/guidelines/web_security#http-redirections",
  "referrer-policy" = "https://infosec.mozilla.org/guidelines/web_security#referrer-policy",
  "subresource-integrity" = "https://infosec.mozilla.org/guidelines/web_security#subresource-integrity",
  "x-content-type-options" = "https://infosec.mozilla.org/guidelines/web_security#x-content-type-options",
  "x-frame-options" = "https://infosec.mozilla.org/guidelines/web_security#x-frame-options",
  "x-xss-protection" = "https://infosec.mozilla.org/guidelines/web_security#x-xss-protection"
)
# nolint end

add_documentation_column = function(all_headers) {
  doc_links_tibble = dplyr::tibble(
    security_header = names(.documentation_links),
    documentation = .documentation_links
  )
  all_headers = dplyr::left_join(all_headers, doc_links_tibble, by = "security_header")
  dplyr::arrange(all_headers, .data$security_header)
}
