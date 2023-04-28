test_that("Get redirection works", {
  res = httr::GET("neverssl.com")
  expect_false(get_redirection(res))
  res = httr::GET("google.com")
  expect_true(get_redirection(res))
})
