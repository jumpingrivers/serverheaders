# serverHeaders 0.1.17

## Bug fixes and minor improvements

* The Subresource Integrity check now ignores inline and same-origin scripts, and needs `integrity` and `crossorigin` on every cross-origin script. One hashed script no longer passes the whole page.

# serverHeaders 0.1.16

## Bug fixes and minor improvements

* Every `header_summary()` method now has offline tests, and live tests skip when offline or on CI.
* R CMD check runs on GitHub Actions for pushes to main and pull requests.

# serverHeaders 0.1.15

## Bug fixes and minor improvements

* README: correct `x$status_codes`, the links and the example output.
* DESCRIPTION: fix the Description sentence and drop `LazyData`, as the package has no data.

# serverHeaders 0.1.14

## Bug fixes and minor improvements

* `referrer-policy` lists such as `no-referrer, strict-origin-when-cross-origin` are judged on the last recognised value.
* `x-content-type-options` and `x-xss-protection` are compared case-insensitively.
* Only a leading `http://` or `https://` is stripped from the server, in any case.

# serverHeaders 0.1.13

## Bug fixes and minor improvements

* The package is now MIT licensed.

# serverHeaders 0.1.12

## Bug fixes and minor improvements

* New test: a site without HTTPS gets a WARN from the SSL check.

# serverHeaders 0.1.11

## Bug fixes and minor improvements

* Now requires R >= 4.1.0, for the native pipe.
* Code is formatted with air (`air.toml`) and passes lintr.

# serverHeaders 0.1.10

## Bug fixes and minor improvements

* `check()` no longer errors on non-HTML responses such as JSON.

# serverHeaders 0.1.9

## Bug fixes and minor improvements

* The SSL check reports the real connection error, not always "certificate has expired", and the `ssl` row keeps its value.

# serverHeaders 0.1.8

## Bug fixes and minor improvements

* HSTS `max-age` is now compared in days, so values under a year get a WARN.

# serverHeaders 0.1.7 _2024-04-04_
- fix: Failed SSL redirects

# serverHeaders 0.1.6 _2024-02-12_
- fix: Handle non-ssl servers

# serverHeaders 0.1.5 _2023-09-30_
- feat: Make ssl checks a primary check with docs

# serverHeaders 0.1.4 _2023-09-29_
- feat: Explicit check for ssl redirection
- feat: Better cli output for STS

# serverHeaders 0.1.3 _2023-08-06_
- feat: Detect missing `charset` in `content-type`
- doc: Update README to install from r-universe

# serverHeaders 0.1.2 _2023-07-30_
- feat: Output of `check()` is now invisible
- fix: Minor changes to message

# serverHeaders 0.1.1 _2023-06-13_
- feat: Use %>% instead of |> to avoid R 4.1 dep

# serverHeaders 0.1.0 _2023-05-23_
- refactor: Use `header` instead of `security_header` for column name
- feat: Match `https://securityheaders.com/` for highlighting headers
- fix: Add message for successful STS header

# serverHeaders 0.0.4 _2023-05-18_
- fix: x-xss-protection should be disabled (https://github.com/OWASP/CheatSheetSeries/issues/376)

# serverHeaders 0.0.3 _2023-05-10_
- feat: Return all status codes - not just the final code
- tests: Add additional tests using different servers
- feat: Nicer output cli output

# serverHeaders 0.0.2 _2023-03-19_
- fix: Change loop over headers, as some headers appear multiple times

# serverHeaders 0.0.1 _2023-02-19_
- feat: Initialise
