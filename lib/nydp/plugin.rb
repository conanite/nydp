require 'digest'

module Nydp
  PLUGINS = []

  module PluginHelper
    def base_path ; "" ; end # override this to provide common prefix for plugin filenames

    def file_readers filenames, bp=base_path
      filenames.map { |f| Nydp::FileReader.new(f.gsub(bp, ""), f) }
    end

    def relative_path name
      # File.join File.expand_path(File.dirname(__FILE__)), name
      File.join File.expand_path(File.dirname(caller[0].split(/:\d+:/)[0])), name
    end
  end

  def self.plug_in  plugin ; PLUGINS << plugin                   ; end
  def self.load_rake_tasks ; PLUGINS.each &:load_rake_tasks      ; end
  def self.setup        ns ; PLUGINS.each { |plg| plg.setup ns } ; end
  # def self.loadfiles       ; PLUGINS.map(&:loadfiles).flatten    ; end
  # def self.testfiles       ; PLUGINS.map(&:testfiles).flatten    ; end

  def self.plugin_names    ; PLUGINS.map(&:name)                 ; end

  def self.loadall ns, plugin, files
    apply_function ns, :"script-run", :"plugin-start", plugin.name if plugin
    files.each { |f|
      Nydp::Runner.new(ns, f, nil, f.name).run
      yield f.name if block_given?
    }
  ensure
    apply_function ns, :"script-run", :"plugin-end", plugin.name if plugin
  end

  def self.all_files ; PLUGINS.each_with_object([]) { |plg, list|  plg.loadfiles.each { |f| list << f } } ; end

  def self.build_nydp &block
    # digest = Digest::SHA256.hexdigest(all_files.map { |f| f.read }.join("\n"))
    # puts
    # puts "digest for all code : #{digest}"
    # puts

    ns = ::Nydp::Namespace.new
    setup(ns)
    PLUGINS.each { |plg|
      loadall ns, plg, plg.loadfiles, &block
      loadall ns, plg, plg.testfiles, &block
    }
    ns
  end
end
