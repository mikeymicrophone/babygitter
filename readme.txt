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
-- git is not installed
-- wrong version of git
-- not in repo root when run
-- there is no public folder

* links to github for listed commits

* report how recently each developer’s work has been incorporated
* report whether newer work is available from each developer

* use db table to note the first appearance of each commit
* ability to flag a commit as buggy, and comment

* links that will check out different versions and restart mongrel or passenger

* report how many stories and specs are passing
* detail report on failing stories and specs
* detail report on passing stories and specs
* links to github and textmate for failing lines
* links to google, api.rubyonrails.org, ruby-forum for error messages
* links to pages on the deployed site where code implicated by failing specs and stories is in use
