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

test_that("Unknown headers are reported but not judged", {
  out = summarise_header("abc", "x-made-up")
  expect_equal(out$header, "x-made-up")
  expect_equal(out$status, "UNKNOWN")
  expect_equal(out$value, "abc")
})

test_that("The scheme must be https", {
  expect_equal(summarise_header("https", "scheme")$status, "OK")
  expect_equal(summarise_header("http", "scheme")$status, "WARN")
})

test_that("Content-Type needs a charset", {
  expect_equal(summarise_header("text/html; charset=utf-8", "content-type")$status, "OK")
  expect_equal(summarise_header("text/html", "content-type")$status, "WARN")
})

test_that("Policy headers are noted when present", {
  policies = c(
    "report-to",
    "nel",
    "content-security-policy",
    "content-security-policy-report-only",
    "permissions-policy"
  )
  for (policy in policies) {
    out = summarise_header("some-policy", policy)
    expect_equal(out$status, "OK", label = policy)
    expect_equal(out$value, "some-policy", label = policy)
  }
  expect_equal(summarise_header("*", "access-control-allow-origin")$status, "NOTE")
  expect_match(summarise_header("nginx", "server")$message, "nginx")
})

test_that("X-Frame-Options allows deny or sameorigin only", {
  expect_equal(summarise_header("DENY", "x-frame-options")$status, "OK")
  expect_equal(summarise_header("sameorigin", "x-frame-options")$status, "OK")
  allow = summarise_header("allow-from https://example.com", "x-frame-options")
  expect_equal(allow$status, "WARN")
  expect_match(allow$message, "Other domains")
  expect_match(summarise_header("yes", "x-frame-options")$message, "not found")
})

test_that("X-Permitted-Cross-Domain-Policies needs a known value", {
  expect_equal(summarise_header("None", "x-permitted-cross-domain-policies")$status, "OK")
  expect_equal(summarise_header("everything", "x-permitted-cross-domain-policies")$status, "WARN")
})

test_that("Headers that leak or are deprecated get a WARN", {
  expect_equal(summarise_header("PHP/8.2", "x-powered-by")$status, "WARN")
  expect_match(summarise_header("pin-sha256=x", "public-key-pins")$message, "deprecated")
  expect_match(summarise_header("max-age=86400", "expect-ct")$message, "deprecated")
})

test_that("Cookies must all use the Secure flag", {
  expect_equal(summarise_header(logical(0), "cookies")$message, "No cookies detected")
  expect_equal(summarise_header(c(TRUE, TRUE), "cookies")$status, "OK")
  expect_equal(summarise_header(c(TRUE, FALSE), "cookies")$status, "WARN")
})

test_that("Redirection is reported", {
  expect_equal(summarise_header(TRUE, "redirection")$status, "OK")
  expect_equal(summarise_header(FALSE, "redirection")$status, "WARN")
})

test_that("Every cross-origin script needs integrity and crossorigin", {
  sri = function(value) summarise_header(value, "subresource-integrity")
  expect_match(sri(list())$message, "no cross-origin scripts")

  hashed = c(
    src = "https://cdn.example.com/a.js",
    integrity = "sha384-x",
    crossorigin = "anonymous"
  )
  empty_crossorigin = c(
    src = "https://cdn.example.com/b.js",
    integrity = "sha384-y",
    crossorigin = ""
  )
  expect_equal(sri(list(hashed, empty_crossorigin))$status, "OK")

  no_integrity = c(src = "https://cdn.example.com/c.js", crossorigin = "anonymous")
  no_crossorigin = c(src = "https://cdn.example.com/d.js", integrity = "sha384-z")
  out = sri(list(hashed, no_integrity, no_crossorigin))
  expect_equal(out$status, "WARN")
  expect_equal(out$message, "Subresource Integrity missing on 2 of 3 cross-origin scripts")
})
