test_that("Status codes follow each redirect", {
  skip_if_offline()
  skip_on_ci()
  status_codes = suppressMessages(check_status_code("jumpingrivers.com"))
  expect_equal(status_codes[length(status_codes)], 200)
  status_codes = suppressMessages(check_status_code("jumpingrivers.com/bad-page"))
  expect_equal(status_codes[length(status_codes)], 404)
})
