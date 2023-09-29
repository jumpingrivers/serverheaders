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
header_summary.default = function(value, ...) { #nolint
  header = class(value)
  value = as.character(value)
  dplyr::tibble(header = header,
                status = "UNKNOWN",
                message = "Heading not considered",
                value = value)
}

#' @rdname header_summary
#' @export
header_summary.scheme = function(value, ...) { #nolint
  header = class(value)
  value = as.character(value)
  if (value == "https") {
    status = "OK"
    message = "Using https (as required)"
  } else {
    status = "WARN"
    message = "Should be https"
  }
  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = value)
}

#' @rdname header_summary
#' @export
`header_summary.content-type` = function(value, ...) { #nolint
  header = class(value)
  value = as.character(value)
  if (stringr::str_detect(value, "charset")) {
    status = "OK"
    message = "charset set"
  } else {
    status = "WARN"
    message = "No charset found in the content type"
  }
  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = value)
}

#' @rdname header_summary
#' @export
`header_summary.report-to` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "OK",
                message = "Policy present but not parsed",
                value = as.character(value))
}

#' @rdname header_summary
#' @export
`header_summary.nel` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "OK",
                message = "Policy present but not parsed",
                value = as.character(value))
}

#' @rdname header_summary
#' @export
`header_summary.content-security-policy-report-only` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "OK",
                message = "Policy present but not parsed",
                value = as.character(value))
}

#' @rdname header_summary
#' @export
`header_summary.content-security-policy` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "OK",
                message = "Policy present but not parsed",
                value = as.character(value))
}

#' @rdname header_summary
#' @export
`header_summary.access-control-allow-origin` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "NOTE",
                message = "Access-Control-Allow-Origin present",
                value = as.character(value))
}

#' @rdname header_summary
#' @export
`header_summary.strict-transport-security` = function(value, ...) { #nolint
  header = class(value)
  value = as.character(value)
  max_age = stringr::str_match(value, "max-age=([0-9]+)")[1, 2]
  max_age = as.numeric(max_age)
  if (!is.na(max_age)) {
    max_age_days = max_age / 60 / 60 / 24
    # 1 year
    if (max_age >= 365) {
      status = "OK"
      message = paste("max_age =", max_age_days, "days and is greater than 1 year")
    } else {
      status = "WARN"
      message = paste("max_age =", max_age, "days but suggested value is 1 year")
    }
  } else {
    status = "WARN"
    message = "Minimum required value ('max-age') not present"
  }

  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = value)
}

#' @rdname header_summary
#' @export
`header_summary.x-frame-options` = function(value, ...) { #nolint
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
  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = value)
}

#' @rdname header_summary
#' @export
`header_summary.x-content-type-options` = function(value, ...) { #nolint
  header = class(value)
  value = as.character(value)
  if (value == "nosniff") {
    status = "OK"
    message = "Acceptable setting found"
  } else {
    status = "WARN"
    message = "Required value ('nosniff') not present"
  }
  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = value)
}

#' @rdname header_summary
#' @export
`header_summary.permissions-policy` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "OK",
                message = "Value present but not verified",
                value = as.character(value))
}

#' @rdname header_summary
#' @export
`header_summary.server` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "NOTE",
                message = paste("Server header found:", as.character(value)),
                value = as.character(value))
}

# https://github.com/OWASP/CheatSheetSeries/issues/376
#' @rdname header_summary
#' @export
`header_summary.x-xss-protection` = function(value, ...) { #nolint
  header = class(value)
  value = as.character(value)
  if (value == "0" || value == "1; mode=block") {
    status = "OK"
    message = paste("Acceptable setting found: x-xss-protection:", value)
  } else {
    status = "WARN"
    message = "Recommendation: header should be set to 0"
  }
  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = value)
}

#' @rdname header_summary
#' @export
`header_summary.x-permitted-cross-domain-policies` = function(value, ...) { #nolint
  header = class(value)
  value = as.character(value)
  if (tolower(value) %in% c("none", "master-only", "by-content-type", "by-ftp-filename", "all")) {
    status = "OK"
    message = paste("Acceptable setting found:", tolower(value))
  } else {
    status = "WARN"
    message = "No legitimate value present"
  }
  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = value)
}

#' @rdname header_summary
#' @export
`header_summary.x-powered-by` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "WARN",
                message = "X-Powered-By header present",
                value = as.character(value))
}

#' @rdname header_summary
#' @export
`header_summary.cookies` = function(value, ...) { #nolint
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

  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = NA_character_)
}

#' @rdname header_summary
#' @export
`header_summary.redirection` = function(value, ...) { #nolint
  header = class(value)
  value = as.logical(value)
  if (value) {
    status = "OK"
    message = "Redirects to HTTPS"
  } else {
    status = "WARN"
    message = "Does not redirect to an HTTPS site"
  }
  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = NA_character_)
}

#' @rdname header_summary
#' @export
`header_summary.subresource-integrity` = function(value, ...) { #nolint
  header = class(value)

  if (length(value) == 0) {
    status = "OK"
    message = "Subresource Integrity is not needed since site contains no script tags"
  } else {
    integrity = purrr::map(value, "integrity") %>%
      purrr::list_c()

    crossorigin = purrr::map(value, function(x) {
      crossorigin_attr = x["crossorigin"]
      !is.na(crossorigin_attr) && crossorigin_attr == "anonymous"
    }) %>%
      purrr::list_c()

    if (all(crossorigin) && all(!is.null(integrity))) {
      status = "OK"
      message = "Subresource Integrity is implemented"
    } else {
      status = "WARN"
      message = "Subresource Integrity not implemented"
    }
  }

  dplyr::tibble(header = header,
                status = status,
                message = message,
                value = NA_character_)
}

##############################
# Depreciated headers
##############################
`header_summary.public-key-pins` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "WARN",
                message = "This header is deprecated",
                value = as.character(value))
}

`header_summary.expect-ct` = function(value, ...) { #nolint
  dplyr::tibble(header = class(value),
                status = "WARN",
                message = "This header is deprecated",
                value = as.character(value))
}
