require 'grit'
module Babygitter
  class RepoVersionTracker
    
    def initialize(repo)
      @repo = Grit::Repo.new repo.path
    end
    
    def submodule_codes
      `git submodule`
    end
    
    def main_repo_code
      @repo.commits.first.id_abbrev
    end
    
    def committers
      @repo.commits.map { |c| c.author }.map { |a| a.name }.uniq
    end
    
    def commits
      @repo.commits
    end
    
    def commit_range_beginning
      @repo.commits.last.authored_date
    end
  end
  
  class ReportGenerator
    attr_accessor :submodule_list, :main_repo_code, :committers, :commit_range_beginning, :commits
    
    def initialize(repo_path = '.')
      repo = Dir.open repo_path
      repo_info = RepoVersionTracker.new(repo)
      self.main_repo_code = repo_info.main_repo_code
      self.committers = repo_info.committers
      self.commit_range_beginning = repo_info.commit_range_beginning
      self.commits = repo_info.commits

      # submodule list not supported when called from an arbitrary dir
      unless repo_path != '.'
        self.submodule_list = repo_info.submodule_codes
      end
    end
    
    def write_report
      r = File.open('public/babygitter_report.html', 'w+')
      r.write templated_report
      r.close
      'report written to public/babygitter_report.html'
    end
    
    def committer_list
      case @committers.length
      when 1
        'Only ' + @committers.first + ' has'
      else
        @committers[0..-2].join(', ') + ' and ' + @committers.last + ' have'
      end
    end
    
    def committer_detail
      @commits.sort_by { |c| c.author.name }.map do |c|
        c.author.name + ' committed at ' + c.authored_date.strftime("%I:%M %p %m/%d") + ': ' + c.message + '<br>'
      end.join
    end
    
    def templated_report
      <<-TEMPLATE
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
      <html>
      <head>
        <title>babygitter report on git repositories in use</title>
      </head>
      <body>

      <div id="main_repo">
      the main repository on this server is at version <strong>#{@main_repo_code}</strong>.<br><br>
      the last time it was deployed was at #{Time.now.strftime("%I:%M %p on %A")}
      </div>
      <div id="committers">
      #{committer_list} committed to this project since #{@commit_range_beginning.strftime("%I:%M %p on %A %B %d")}.
      <hr>
      #{committer_detail}
      <hr>
      </div>
      <div id="submodules">
      #{(@submodule_list.nil? || @submodule_list == '') ? '' : "here are the version codes for the submodules in use:<br><br>" + @submodule_list.gsub("\n", '<br>')}
      </div>
      <div id="babygitter">
      to investigate or add to the code that generated this report, visit <a href="http://github.com/schwabsauce/babygitter">http://github.com/schwabsauce/babygitter</a>.
      </div>
      <div id="intro">
      this project is being stored with <a href='http://git.or.cz'>git</a> and hosted on <a href='http://github.com'>github</a>
      <br><br>
      git uses alphanumerical codes to name the different versions of each codebase.<br><br>
      you can use github to look them up <br><br>
      <tt>http://github.com/<i>username</i>/<i>repository</i>/commit/<i>alphanumerical-code</i><br>
      http://github.com/schwabsauce/railevant/commit/6daae03</tt><br><br>
      or plug them into your own copy of the repos to investigate.<br><br>
      <tt>git checkout <i>alphanumerical-code</i><br>
      git checkout 8534273</tt>
      </div>
      </body>
      </html>
      TEMPLATE
    end
  end
end