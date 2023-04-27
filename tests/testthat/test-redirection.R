test_that("Get redirection works", {
  res = list(
    all_headers = list(
    list(
      "status" = 200,
      "version" = "HTTP/2"
      )
    ))
  expect_true(get_redirection(res))
  res$all_headers[[1]][["version"]] = "HTTP/1.1"
  expect_false(get_redirection(res))
  res$all_headers[[1]][["status"]] = 301
  expect_true(get_redirection(res))
})
