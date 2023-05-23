# Server Headers

A simple interface to retrieve and examine HTTP headers from a website.
The package is installed in the usual way

```
remotes::install_github("jumpingrivers/serverheaders")
```

The main function is `check()`

```
library("serverHeaders")
x = check("google.com")
```

The output from `check()` is contains the status code `x$status_code` and a data frame
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
# ✔ Status code: 200
# ✖ content-security-policy: Header not set (Docs)
# ✖ permissions-policy: Header not set (Docs)
# ✔ referrer-policy: Acceptable setting found
# ✔ strict-transport-security: max_age present and greater than 1 year
# ✔ x-content-type-options: Acceptable setting found
# ✔ x-frame-options: Acceptable setting found
```
highlights we still need to set our content security policy and our permissions policy.

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
[jumpingrivers.com](https://www.jumprivers.com) is the same as [http://jumpingrivers.com](https://www.jumprivers.com).

---

This package was based on the [hdrs](https://github.com/hrbrmstr/hdrs) R Package by Bob Rudis.
