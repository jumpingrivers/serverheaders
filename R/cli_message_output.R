cli_message_output = function(all_headers, security_headers) {
  for (i in seq_len(nrow(all_headers))) {
    row = all_headers[i, ]
    if (row$security_header %in% security_headers) {
      col = get_status_col(row$status) # nolint
      if (row$status == "WARN") {
        msg = "{col(row$security_header)}: {row$message} ({.href [Documentation]({row$documentation})})"
      } else {
        msg = "{col(row$security_header)}: {row$message}"
      }
      cli::cli_alert_info(msg)
    }
  }
}

get_status_col = function(status) {
  if (status %in% c("OK", "NOTE")) {
    cli::col_green
  } else if (status == "UNKNOWN") {
    cli::col_blue
  } else {
    cli::col_red
  }
}
