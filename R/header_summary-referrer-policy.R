#' @rdname header_summary
#' @export
`header_summary.referrer-policy` = function(value, ...) {
  header = class(value)
  value = tolower(as.character(value))

  # Other values can leak http settings
  secure = c(
    "strict-origin",
    "strict-origin-when-cross-origin",
    "no-referrer-when-downgrade",
    "no-referrer",
    "same-origin"
  )
  # Empty string OK, but then relies on meta tags
  weak = c("", "origin", "origin-when-cross-origin", "unsafe-url")
  policy = get_referrer_policy(value, c(secure, weak))

  if (policy %in% secure) {
    status = "OK"
    message = "Acceptable setting found"
  } else if (policy %in% weak) {
    status = "WARN"
    message = "Valid setting found, but a more secure value is recommended"
  } else {
    status = "WARN"
    message = "No legitimate value present"
  }
  dplyr::tibble(header = header, status = status, message = message, value = value)
}

# The header can list fallbacks, e.g. "no-referrer, strict-origin-when-cross-origin".
# Browsers use the last value they recognise.
get_referrer_policy = function(value, valid) {
  tokens = trimws(strsplit(value, ",", fixed = TRUE)[[1]])
  tokens = tokens[tokens %in% valid]
  if (length(tokens) == 0L) {
    return(value)
  }
  tokens[length(tokens)]
}
