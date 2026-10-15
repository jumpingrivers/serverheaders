test_that("Is redirected works", {
  res = httr::GET("neverssl.com")
  expect_false(is_redirected(res))
  res = httr::GET("google.com")
  expect_true(is_redirected(res))
  expect_true(is.data.frame(check("http://httpforever.com/")$headers))
})

fake_response = function(type, body) {
  structure(list(url = "https://example.com",
                 headers = structure(list(`content-type` = type),
                                     class = c("insensitive", "list")),
                 content = charToRaw(body)),
            class = "response")
}

test_that("Script tags are only looked for in HTML", {
  json = fake_response("application/json", '{"a": 1}')
  expect_equal(get_js_resources(json), list())

  html = fake_response("text/html; charset=utf-8",
                       '<html><head><script src="a.js"></script></head></html>')
  expect_equal(get_js_resources(html)[[1]][["src"]], "a.js")
})
