babygitter

a library that helps keep track of which versions of your libraries are deployed

===
usage

[must be in repo root]

require 'babygitter'

b = Babygitter::ReportGenerator.new

b.write_report

[report is written to public/babygitter_report.html]

===
todo

* error handling for cases such as:
-- not in repo root when run
-- there is no public folder

* links to github for listed commits

