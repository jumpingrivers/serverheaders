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
