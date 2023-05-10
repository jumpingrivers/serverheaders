test_that("Test Status codes", {
  status_codes = check_status_code("jumpingrivers.com")
  expect_true(any(grepl(200, status_codes)))
  status_codes = check_status_code("jumpingrivers.com/bad-page")
  expect_true(any(grepl(404, status_codes)))
})
