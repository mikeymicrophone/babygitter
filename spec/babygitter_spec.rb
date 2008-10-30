require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Babygitter do
  it 'should be able to instantiate a RepoVersionTracker' do
    Babygitter::RepoVersionTracker.new.should_not be_nil
  end
  
  it 'should be able to instantiate a ReportGenerator' do
    Babygitter::ReportGenerator.new.should_not be_nil
  end
  
  describe Babygitter::RepoVersionTracker do
    it 'should get repo info if called from a repo root' do
      Babygitter::RepoVersionTracker.new.main_repo_code.should == `git describe --always`
    end
    
    it 'should get submodule info if submodules exist' do
      Babygitter::RepoVersionTracker.new.submodule_codes.should == `git submodule`
    end
  end
  
  describe Babygitter::ReportGenerator do
    it 'should populate attributes' do
      r = Babygitter::ReportGenerator.new
      r.submodule_list.should == `git submodule`
      r.main_repo_code.should == `git describe --always`
    end
    
    it 'should generate a report with repo codes' do
      r = Babygitter::ReportGenerator.new
      code = `git describe --always`
      r.templated_report.=~(Regexp.new(code)).should_not be_nil
    end
    
    it 'should write a file' do
      Babygitter::ReportGenerator.new.write_report
      File.open('public/babygitter_report.html', 'r').should_not be_nil
    end
  end
  
end