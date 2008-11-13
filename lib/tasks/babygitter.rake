require File.join(File.dirname(__FILE__), '../babygitter')
namespace :babygitter do
  desc "Reports Git repository metadata to #{Babygitter.report_file_path}"
  task :report do
    Babygitter::ReportGenerator.new.write_report
    puts "Report written to #{Babygitter.report_file_path}"
  end
end