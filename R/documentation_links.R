# nolint start: line_length_linter
.primary_headers = c("content-security-policy",
                     "permissions-policy",
                     "referrer-policy",
                     "strict-transport-security",
                     "x-content-type-options",
                     "x-frame-options")

.documentation_links = c(
  "access-control-allow-origin" = "https://infosec.mozilla.org/guidelines/web_security#cross-origin-resource-sharing",
  "content-security-policy" = "https://infosec.mozilla.org/guidelines/web_security#content-security-policy",
  "cookies" = "https://infosec.mozilla.org/guidelines/web_security#cookies",
  "permissions-policy" = "https://scotthelme.co.uk/goodbye-feature-policy-and-hello-permissions-policy/",
  "redirection" = "https://infosec.mozilla.org/guidelines/web_security#http-redirections",
  "referrer-policy" = "https://infosec.mozilla.org/guidelines/web_security#referrer-policy",
  "strict-transport-security" = "https://infosec.mozilla.org/guidelines/web_security#http-strict-transport-security",
  "subresource-integrity" = "https://infosec.mozilla.org/guidelines/web_security#subresource-integrity",
  "x-content-type-options" = "https://infosec.mozilla.org/guidelines/web_security#x-content-type-options",
  "x-frame-options" = "https://infosec.mozilla.org/guidelines/web_security#x-frame-options",
  "x-xss-protection" = "https://infosec.mozilla.org/guidelines/web_security#x-xss-protection"
)
# nolint end

add_documentation_column = function(all_headers) {
  doc_links_tibble = dplyr::tibble(
    header = names(.documentation_links),
    documentation = .documentation_links
  )
  all_headers = dplyr::left_join(all_headers, doc_links_tibble, by = "header")
  dplyr::arrange(all_headers, .data$header)
}

add_primary_column = function(all_headers) {
  all_headers$primary_header = all_headers$header %in% .primary_headers
  all_headers
}
