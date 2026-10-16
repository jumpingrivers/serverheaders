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
