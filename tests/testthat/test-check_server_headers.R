test_that("Is redirected works", {
  res = httr::GET("neverssl.com")
  expect_false(is_redirected(res))
  res = httr::GET("google.com")
  expect_true(is_redirected(res))
  expect_true(is.data.frame(check("http://httpforever.com/")$headers))
})
