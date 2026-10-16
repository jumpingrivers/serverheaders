# Server Headers <img src="man/figures/logo.png" align="right" height="138" alt="" />

A simple interface to retrieve and examine HTTP headers from a website.
The package is installed in the usual way

```
install.packages('serverHeaders', repos = c('https://jumpingrivers.r-universe.dev', 'https://cloud.r-project.org'))
```

The main function is `check()`

```
library("serverHeaders")
x = check("google.com")
```

The output from `check()` contains the status codes `x$status_codes` and a data frame
of headers `x$headers`. The data frame provides information about each header.

Note: An unknown header is expected.

## Flagged Headers

As every web-page is different, there isn't a "one-size fits all" approach to server headers. 
These headings take a variety of values and need to be constructed to match the set.
However, there are a number of headings that some people suggest should be set. 
When you `check()` these headings are printed to the console and also indicated in the console
output.

For example, running 

```
check("jumpingrivers.com")
# ── Checking Server ──
# 
# ✔ Status code: 301 → 301 → 200
# ✔ SSL available: 301 → 200
# ✔ SSL redirection successful: http -> https
# ✔ content-security-policy: Policy present but not parsed
# ✔ content-type: charset set
# ✔ permissions-policy: Value present but not verified
# ✔ referrer-policy: Acceptable setting found
# ✔ strict-transport-security: max_age = 365 days and is greater than 1 year
# ✔ x-content-type-options: Acceptable setting found
# ✔ x-frame-options: Acceptable setting found
```
shows every flagged header passing. A header that fails is marked ✖, with a link to its documentation.

## Status Codes

When we check a website, there are typically a few redirects before we reach the final destination. 
For example,

> http://jumpingrivers.com -> https://jumpingrivers.com -> https://www.jumpingrivers.com

This corresponds to 

```
check("jumpingrivers.com")$status_codes
# 301 301 200
```

Where `301` indicates a redirect and `200` the final successful response.

Note: when we omit the transport protocol (the http part), the default is `http`, i.e.
`jumpingrivers.com` is the same as `http://jumpingrivers.com`.

---

This package was based on the [hdrs](https://github.com/hrbrmstr/hdrs) R Package by Bob Rudis.
