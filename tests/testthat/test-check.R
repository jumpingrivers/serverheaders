test_that("check() returns status codes and a header summary", {
  skip_if_offline()
  skip_on_ci()
  x = suppressMessages(check("jumpingrivers.com"))
  expect_equal(x$status_codes[length(x$status_codes)], 200)
  expect_named(
    x$headers,
    c("header", "status", "message", "value", "documentation", "primary_header")
  )
  expect_true(all(c("ssl", "ssl-redirection", "strict-transport-security") %in% x$headers$header))
})
