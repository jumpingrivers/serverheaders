#' Header Summaries
#'
#' Summaries server header elements.
#'
#' @param value Header element, likely obtained from httr::headers
#' @param ... Other values (not used)
#' @return A tibble or NULL (where the server element isn't known)
#' @export
header_summary = function(value, ...) UseMethod("header_summary")

#' @rdname header_summary
#' @export
header_summary.default = function(value, ...) {
  header = class(value)
  value = as.character(value)
  dplyr::tibble(
    header = header,
    status = "UNKNOWN",
    message = "Heading not considered",
    value = value
  )
}

#' @rdname header_summary
#' @export
header_summary.scheme = function(value, ...) {
  header = class(value)
  value = as.character(value)
  if (value == "https") {
    status = "OK"
    message = "Using https (as required)"
  } else {
    status = "WARN"
    message = "Should be https"
  }
  dplyr::tibble(header = header, status = status, message = message, value = value)
}

#' @rdname header_summary
#' @export
`header_summary.content-type` = function(value, ...) {
  header = class(value)
  value = as.character(value)
  if (stringr::str_detect(value, "charset")) {
    status = "OK"
    message = "charset set"
  } else {
    status = "WARN"
    message = "No charset found in the content type"
  }
  dplyr::tibble(header = header, status = status, message = message, value = value)
}

#' @rdname header_summary
#' @export
`header_summary.report-to` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "OK",
    message = "Policy present but not parsed",
    value = as.character(value)
  )
}

#' @rdname header_summary
#' @export
`header_summary.nel` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "OK",
    message = "Policy present but not parsed",
    value = as.character(value)
  )
}

#' @rdname header_summary
#' @export
# nolint next: object_length_linter. Name must match the header for S3 dispatch
`header_summary.content-security-policy-report-only` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "OK",
    message = "Policy present but not parsed",
    value = as.character(value)
  )
}

#' @rdname header_summary
#' @export
`header_summary.content-security-policy` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "OK",
    message = "Policy present but not parsed",
    value = as.character(value)
  )
}

#' @rdname header_summary
#' @export
`header_summary.access-control-allow-origin` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "NOTE",
    message = "Access-Control-Allow-Origin present",
    value = as.character(value)
  )
}

#' @rdname header_summary
#' @export
`header_summary.strict-transport-security` = function(value, ...) {
  header = class(value)
  value = as.character(value)
  max_age = stringr::str_match(value, "max-age=([0-9]+)")[1, 2]
  max_age = as.numeric(max_age)
  if (!is.na(max_age)) {
    max_age_days = max_age / 60 / 60 / 24
    # 1 year
    if (max_age_days >= 365) {
      status = "OK"
      message = paste("max_age =", max_age_days, "days and is greater than 1 year")
    } else {
      status = "WARN"
      message = paste("max_age =", max_age_days, "days but suggested value is 1 year")
    }
  } else {
    status = "WARN"
    message = "Minimum required value ('max-age') not present"
  }

  dplyr::tibble(header = header, status = status, message = message, value = value)
}

#' @rdname header_summary
#' @export
`header_summary.x-frame-options` = function(value, ...) {
  header = class(value)
  value = as.character(value)
  if (tolower(value) %in% c("deny", "sameorigin")) {
    status = "OK"
    message = "Acceptable setting found"
  } else if (any(grepl("allow-from", tolower(value)))) {
    status = "WARN"
    message = "Other domains are allowed to frame the site"
  } else {
    status = "WARN"
    message = "Values 'deny' or 'sameorigin' not found"
  }
  dplyr::tibble(header = header, status = status, message = message, value = value)
}

#' @rdname header_summary
#' @export
`header_summary.x-content-type-options` = function(value, ...) {
  header = class(value)
  value = as.character(value)
  if (tolower(trimws(value)) == "nosniff") {
    status = "OK"
    message = "Acceptable setting found"
  } else {
    status = "WARN"
    message = "Required value ('nosniff') not present"
  }
  dplyr::tibble(header = header, status = status, message = message, value = value)
}

#' @rdname header_summary
#' @export
`header_summary.permissions-policy` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "OK",
    message = "Value present but not verified",
    value = as.character(value)
  )
}

#' @rdname header_summary
#' @export
`header_summary.server` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "NOTE",
    message = paste("Server header found:", as.character(value)),
    value = as.character(value)
  )
}

# https://github.com/OWASP/CheatSheetSeries/issues/376
#' @rdname header_summary
#' @export
`header_summary.x-xss-protection` = function(value, ...) {
  header = class(value)
  value = as.character(value)
  if (gsub(" ", "", tolower(value), fixed = TRUE) %in% c("0", "1;mode=block")) {
    status = "OK"
    message = paste("Acceptable setting found: x-xss-protection:", value)
  } else {
    status = "WARN"
    message = "Recommendation: header should be set to 0"
  }
  dplyr::tibble(header = header, status = status, message = message, value = value)
}

#' @rdname header_summary
#' @export
# nolint next: object_length_linter. Name must match the header for S3 dispatch
`header_summary.x-permitted-cross-domain-policies` = function(value, ...) {
  header = class(value)
  value = as.character(value)
  if (tolower(value) %in% c("none", "master-only", "by-content-type", "by-ftp-filename", "all")) {
    status = "OK"
    message = paste("Acceptable setting found:", tolower(value))
  } else {
    status = "WARN"
    message = "No legitimate value present"
  }
  dplyr::tibble(header = header, status = status, message = message, value = value)
}

#' @rdname header_summary
#' @export
`header_summary.x-powered-by` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "WARN",
    message = "X-Powered-By header present",
    value = as.character(value)
  )
}

#' @rdname header_summary
#' @export
`header_summary.cookies` = function(value, ...) {
  header = class(value)
  value = as.logical(value)

  if (length(value) == 0 || all(is.na(value))) {
    status = "OK"
    message = "No cookies detected"
  } else if (all(value)) {
    status = "OK"
    message = "All cookies use the Secure flag"
  } else {
    status = "WARN"
    message = "Cookies set without using the Secure flag"
  }

  dplyr::tibble(header = header, status = status, message = message, value = NA_character_)
}

#' @rdname header_summary
#' @export
`header_summary.subresource-integrity` = function(value, ...) {
  header = class(value)

  # value holds the attributes of each cross-origin script
  if (length(value) == 0) {
    status = "OK"
    message = "Subresource Integrity is not needed since the page loads no cross-origin scripts"
  } else {
    # crossorigin = "" means anonymous, so any value will do
    is_protected = vapply(
      value,
      function(attrs) {
        integrity = attrs["integrity"]
        !is.na(integrity) && nzchar(integrity) && !is.na(attrs["crossorigin"])
      },
      logical(1)
    )

    if (all(is_protected)) {
      status = "OK"
      message = "Subresource Integrity is implemented"
    } else {
      status = "WARN"
      message = paste(
        "Subresource Integrity missing on",
        sum(!is_protected),
        "of",
        length(is_protected),
        "cross-origin scripts"
      )
    }
  }

  dplyr::tibble(header = header, status = status, message = message, value = NA_character_)
}

##############################
# Deprecated headers
##############################
#' @export
`header_summary.public-key-pins` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "WARN",
    message = "This header is deprecated",
    value = as.character(value)
  )
}

#' @export
`header_summary.expect-ct` = function(value, ...) {
  dplyr::tibble(
    header = class(value),
    status = "WARN",
    message = "This header is deprecated",
    value = as.character(value)
  )
}
