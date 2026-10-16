test_that("Is redirected works", {
  response = function(status, version = "HTTP/1.1") {
    list(all_headers = purrr::map2(status, version, \(s, v) list(status = s, version = v)))
  }
  expect_false(is_redirected(response(200)))
  expect_true(is_redirected(response(c(301, 200))))
  expect_true(is_redirected(response(200, "HTTP/2")))
})

test_that("check() copes with a site that has no https", {
  skip_if_offline()
  expect_true(is.data.frame(suppressMessages(check("http://httpforever.com/"))$headers))
})

fake_response = function(type, body) {
  structure(
    list(
      url = "https://example.com",
      headers = structure(list(`content-type` = type), class = c("insensitive", "list")),
      content = charToRaw(body)
    ),
    class = "response"
  )
}

test_that("Script tags are only looked for in HTML", {
  json = fake_response("application/json", '{"a": 1}')
  expect_equal(get_js_resources(json), list())

  html = fake_response(
    "text/html; charset=utf-8",
    '<html><head><script src="a.js"></script></head></html>'
  )
  expect_equal(get_js_resources(html)[[1]][["src"]], "a.js")
})
