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
