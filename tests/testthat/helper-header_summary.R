# Summarise a header value as get_response_headers() would pass it
summarise_header = function(value, header) {
  header_summary(structure(value, class = header))
}
