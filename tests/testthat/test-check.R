test_that("Testing check", {
  x = check("www.google.com")
  expect_equal(x$status_code, 200)
  expect_equal(ncol(x$headers), 5)
  expect_gt(nrow(x$headers), 18)
})
