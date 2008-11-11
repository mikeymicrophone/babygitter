require 'lib/babygitter'
namespace :babygitter do
  task :report do
    Babygitter::ReportGenerator.new.write_report
  end
end