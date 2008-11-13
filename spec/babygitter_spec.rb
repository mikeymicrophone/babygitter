require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Babygitter do
  
  it 'should be able to instantiate a RepoVersionTracker' do
    Babygitter::RepoVersionTracker.new(Dir.open('.')).should_not be_nil
  end
  
  it 'should be able to instantiate a ReportGenerator' do
    Babygitter::ReportGenerator.new.should_not be_nil
  end
  
  describe Babygitter::RepoVersionTracker do
    
    before do
      @rvt = Babygitter::RepoVersionTracker.new(Dir.open('.'))
    end
    
    it 'should get repo info if called from a repo root' do
      @rvt.main_repo_code.should == `git describe --always`.chomp
    end
    
    it 'should get submodule info if submodules exist' do
      @rvt.submodule_codes.should == `git submodule`
    end
  end
  
  describe Babygitter::ReportGenerator do
    it 'should populate attributes' do
      r = Babygitter::ReportGenerator.new
      r.submodule_list.should == `git submodule`
      r.main_repo_code.should == `git describe --always`.chomp
    end
    
    it 'should generate a report with repo codes' do
      r = Babygitter::ReportGenerator.new
      code = `git describe --always`.chomp
      r.templated_report.=~(/#{code}/).should_not be_nil
    end
    
    it 'should put a timestamp in the report' do
      r = Babygitter::ReportGenerator.new
      time_without_seconds = Time.now.strftime("%I:%M")
      r.templated_report.=~(/#{time_without_seconds}/).should_not be_nil
    end
    
    it 'should write a file' do
      Babygitter.report_file_path = File.join(File.dirname(__FILE__), 'babygitter_report.html')
      Babygitter::ReportGenerator.new.write_report
      File.open(Babygitter.report_file_path, 'r').should_not be_nil
      # Cleanup
      File.unlink(Babygitter.report_file_path)
    end
  end
  
end