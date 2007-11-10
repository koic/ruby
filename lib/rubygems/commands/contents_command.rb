require 'rubygems/command'
require 'rubygems/version_option'

class Gem::Commands::ContentsCommand < Gem::Command

  include Gem::VersionOption

  def initialize
    super 'contents', 'Display the contents of the installed gems',
          :specdirs => [], :lib_only => false

    add_version_option

    add_option('-s', '--spec-dir a,b,c', Array,
               "Search for gems under specific paths") do |spec_dirs, options|
      options[:specdirs] = spec_dirs
    end

    add_option('-l', '--[no-]lib-only',
               "Only return files in the Gem's lib_dirs") do |lib_only, options|
      options[:lib_only] = lib_only
    end
  end

  def arguments # :nodoc:
    "GEMNAME       name of gem to list contents for"
  end

  def defaults_str # :nodoc:
    "--no-lib-only"
  end

  def usage # :nodoc:
    "#{program_name} GEMNAME"
  end

  def execute
    version = options[:version] || Gem::Requirement.default
    gem = get_one_gem_name

    s = options[:specdirs].map do |i|
      [i, File.join(i, "specifications")]
    end.flatten

    path_kind = if s.empty? then
                  s = Gem::SourceIndex.installed_spec_directories
                  "default gem paths"
                else
                  "specified path"
                end

    si = Gem::SourceIndex.from_gems_in(*s)

    gem_spec = si.search(/\A#{gem}\z/, version).last

    unless gem_spec then
      say "Unable to find gem '#{gem}' in #{path_kind}"

      if Gem.configuration.verbose then
        say "\nDirectories searched:"
        s.each { |dir| say dir }
      end

      terminate_interaction
    end

    files = options[:lib_only] ? gem_spec.lib_files : gem_spec.files
    files.each do |f|
      say File.join(gem_spec.full_gem_path, f)
    end
  end

end

