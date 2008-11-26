require 'grit'
module Babygitter
  
  # Customizable options
  
  def self.report_file_path
    @@report_file_path
  end
  def self.report_file_path=(report_file_path)
    @@report_file_path = report_file_path
  end
  self.report_file_path = File.join(File.dirname(__FILE__), '../../../../public/babygitter_report.html')
  
  def self.stylesheet
    @@stylesheet
  end
  def self.stylesheet=(stylesheet)
    @@stylesheet = stylesheet
  end
  self.stylesheet = File.join(File.dirname(__FILE__), '../assets/stylesheets/default.css')
  
  def self.template
    @@template
  end
  def self.template=(template)
    @@template = template
  end
  self.template = File.join(File.dirname(__FILE__), '../assets/templates/default.html.erb')

  def self.additional_links
    @@additional_links
  end
  def self.additional_links=(additional_links)
    @@additional_links = additional_links
  end
  self.additional_links = File.join(File.dirname(__FILE__), '../assets/guides/bdd_stack.html.erb')
  
  def self.instructions
    @@instructions
  end
  def self.instructions=(instructions)
    @@instructions = instructions
  end
  self.instructions = File.join(File.dirname(__FILE__), '../assets/guides/display_only.html.erb')
  
  class RepoVersionTracker
    
    def initialize(repo)
      @path = repo.path
      @repo = Grit::Repo.new repo.path
    end
    
    def submodule_codes
      `cd #{@path}; git submodule`
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
      self.submodule_list = repo_info.submodule_codes
      
      raise "Could not find stylesheet #{Babygitter.stylesheet}" unless File.exist?(Babygitter.stylesheet)
      
    end
    
    def write_report
      r = File.open(Babygitter.report_file_path, 'w+')
      r.write templated_report
      r.close
      "Report written to #{Babygitter.report_file_path}"
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
        '<li>' + c.message + 
        ' <cite>' + c.author.name + ' ' +
        c.authored_date.strftime("%b %d %I:%M %p") + 
        '</cite></li>'
      end.join("\n")
    end
    
    def templated_report
      require 'erb'
      
      stylesheet, additional_links, instructions = '', '', ''
      File.open(Babygitter.stylesheet, 'r') { |f| stylesheet = f.read }
      Babygitter.additional_links.is_a?(String) ?
        additional_links = Babygitter.additional_links :
        File.open(Babygitter.additional_links, 'r') { |f| additional_links = f.read }
      Babygitter.instructions.is_a?(String) ? 
        instructions = Babygitter.instructions :
        File.open(Babygitter.instructions, 'r') { |f| instructions = f.read }
      template = File.read(Babygitter.template)
      result = ERB.new(template).result(binding)

    end
  end
end