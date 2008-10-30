module Babygitter
  class RepoVersionTracker
    def submodule_codes
      `git submodule`
    end
    
    def main_repo_code
      `git describe --always`
    end
  end
  
  class ReportGenerator
    attr_accessor :submodule_list, :main_repo_code
    
    def initialize
      self.submodule_list = RepoVersionTracker.new.submodule_codes
      self.main_repo_code = RepoVersionTracker.new.main_repo_code
    end
    
    def write_report
      r = File.open('public/babygitter_report.html', 'w+')
      r.write templated_report
      r.close
    end
    
    def templated_report
      <<-TEMPLATE
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html>
      <head>
        <title>babygitter report on git repositories in use</title>
      </head>
      <body>
      <div id="intro">
      this project is being stored with <a href='http://git.or.cz'>git</a> and hosted on <a href='http://github.com'>github</a>
      <br><br>
      git uses alphanumerical codes to name the different versions of each codebase.  you can use github to look them up or plug them into your own copy of the repos to investigate.
      </div>
      <div id="main_repo">
      the main repository on this server is at version <strong>#{@main_repo_code}</strong>.<br><br>
      </div>
      <div id="submodules">
      #{@submodule_list == '' ? '' : "here are the version codes for the submodules in use:<br><br>" + @submodule_list.gsub("\n", '<br>')}
      </div>
      </body>
      </html>
      TEMPLATE
    end
  end
end