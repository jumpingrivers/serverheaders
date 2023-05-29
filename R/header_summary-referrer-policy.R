#' @rdname header_summary
#' @export
`header_summary.referrer-policy` = function(value, ...) { #nolint
  header = class(value)
  value = tolower(as.character(value))

  if (value %in% c("strict-origin", "strict-origin-when-cross-origin",
                   "no-referrer-when-downgrade", "no-referrer", "same-origin")) {
    status = "OK"
    message = "Acceptable setting found"
    # Empty string OK, but then relies on meta tags
    # Other values can leak http settings
  } else if (tolower(value) %in% c("", "origin", "origin-when-cross-origin", "unsafe-url")) {
    status = "WARN"
    message = "Valid setting found, but would success changing value to something more secure"
  } else {
    status = "WARN"
    message = "No legitimate value present"
  }
  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = value)
}
