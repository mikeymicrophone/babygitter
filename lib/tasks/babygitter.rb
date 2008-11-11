require 'lib/babygitter'
namespace :babygitter do
  desc 'reports repo metadata to public/babygitter_report.html'
  task :report do
    Babygitter::ReportGenerator.new.write_report
  end
end