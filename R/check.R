#' Checks server headings
#'
#' @param server Server url
#' @export
check = function(server) {
  cli::cli_h2("Checking Server")

  status_codes = check_status_code(server)
  headers = check_server_headers(server)
  rtn = list(status_codes = status_codes,
             headers = headers)
  invisible(rtn)
}
