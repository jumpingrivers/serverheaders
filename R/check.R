#' Checks server headings
#'
#' @param server Server url
#' @export
check = function(server) {
  cli::cli_h2("Checking Server")
  status_code = check_status_code(server)
  headers = check_server_headers(server)
  list(status_code = status_code,
       headers = headers)
}
