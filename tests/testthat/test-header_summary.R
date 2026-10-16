test_that("Strict-Transport-Security max-age is measured in days", {
  sts = function(value) {
    header_summary(structure(value, class = "strict-transport-security"))
  }
  expect_equal(sts("max-age=31536000")$status, "OK")
  expect_equal(sts("max-age=400")$status, "WARN")
  expect_equal(sts("max-age=86400")$status, "WARN")
  expect_match(sts("max-age=86400")$message, "max_age = 1 days")
  expect_equal(sts("includeSubDomains")$status, "WARN")
})

test_that("Referrer-Policy uses the last recognised value in a list", {
  rp = function(value) header_summary(structure(value, class = "referrer-policy"))
  expect_equal(rp("no-referrer, strict-origin-when-cross-origin")$status, "OK")
  expect_equal(rp("strict-origin, unsafe-url")$status, "WARN")
  expect_equal(rp("unsafe-url, made-up-policy")$status, "WARN")
  expect_match(rp("unsafe-url, made-up-policy")$message, "more secure")
  expect_equal(rp("Same-Origin")$status, "OK")
  expect_equal(rp("made-up-policy")$message, "No legitimate value present")
  expect_match(rp("")$message, "more secure")
})

test_that("Header values are compared case-insensitively", {
  xcto = function(value) header_summary(structure(value, class = "x-content-type-options"))
  expect_equal(xcto("NoSniff")$status, "OK")
  expect_equal(xcto("sniff")$status, "WARN")

  xss = function(value) header_summary(structure(value, class = "x-xss-protection"))
  expect_equal(xss("0")$status, "OK")
  expect_equal(xss("1; Mode=Block")$status, "OK")
  expect_equal(xss("1;mode=block")$status, "OK")
  expect_equal(xss("1")$status, "WARN")
})
