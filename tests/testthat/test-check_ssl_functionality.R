test_that("SSL errors report the real error and keep the value", {
  res = try(stop("Could not resolve host: example.invalid"), silent = TRUE)
  rtn = suppressMessages(get_ssl_error(res))
  expect_equal(rtn$status, "WARN")
  expect_equal(rtn$status_code_msg, "Could not resolve host: example.invalid")

  # Fails on DNS lookup, so needs no network
  ssl = suppressMessages(check_ssl("does-not-exist.invalid"))
  expect_true("value" %in% colnames(ssl))
  expect_false(is.na(ssl$value))
  expect_no_match(ssl$value, "expired")
})

test_that("Sites without an SSL certificate get a WARN", {
  # What curl reports for a site that doesn't serve https
  local_mocked_bindings(
    HEAD = function(...) stop("SSL connect error"),
    .package = "httr"
  )
  ssl = suppressMessages(check_ssl("no-https.example.com"))
  expect_equal(ssl$status, "WARN")
  expect_equal(ssl$message, "SSL incorrect")
  expect_false(is.na(ssl$value))
  expect_no_match(ssl$value, "expired")
})

test_that("Only a leading scheme is stripped, in any case", {
  local_mocked_bindings(
    check_ssl = function(clean_server) dplyr::tibble(header = clean_server),
    check_ssl_redirect = function(clean_server) NULL
  )
  expect_equal(check_ssl_functionality("HTTPS://example.com")$header, "example.com")
  expect_equal(check_ssl_functionality("http://example.com")$header, "example.com")
  expect_equal(
    check_ssl_functionality("example.com/?next=https://other.com")$header,
    "example.com/?next=https://other.com"
  )
})

test_that("An http request must end on a working https page", {
  response = function(url, status) {
    list(url = url, all_headers = lapply(status, \(s) list(status = s)))
  }
  expect_true(is_https_redirect(response("https://example.com/", c(301, 200))))
  expect_true(is_https_redirect(response("HTTPS://example.com/", c(301, 301, 204))))
  # Redirects to another http page
  expect_false(is_https_redirect(response("http://www.example.com/", c(301, 200))))
  # No redirect at all
  expect_false(is_https_redirect(response("http://example.com/", 200)))
  # Ends on an error page
  expect_false(is_https_redirect(response("https://example.com/", c(301, 404))))
  # Connection failed
  expect_false(is_https_redirect(try(stop("Timeout"), silent = TRUE)))
})
