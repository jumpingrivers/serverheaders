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

The output from `check()` is contains the status code `x$status_code` and a date frame
of headers `x$headers`. The data frame provides information about each header.

Note: An unknown header is expected.

---

This package is based on the [hdrs](https://github.com/hrbrmstr/hdrs) by Bob Rudis.
