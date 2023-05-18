test_that("Testing check", {
  x = check("jumpingrivers.com")
  expect_true(any(grepl(200, x$status_codes)))
  expect_equal(ncol(x$headers), 5)
  expect_gt(nrow(x$headers), 18)

  x = check("https://report-uri.com/")
  expect_equal(x$status_codes, 200)
  expect_equal(ncol(x$headers), 5)
  expect_gt(nrow(x$headers), 18)
  })
