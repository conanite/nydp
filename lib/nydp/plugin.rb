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
  def self.plugin_names    ; PLUGINS.map(&:name)                 ; end

  def self.loadall ns, plugin, files, manifest
    ns.apply :"script-run", :"plugin-start", plugin.name if plugin
    files.each { |f|
      Nydp::Runner.new(ns, f, nil, f.name, manifest).run
      yield f.name if block_given?
    }
  ensure
    ns.apply :"script-run", :"plugin-end", plugin.name if plugin
  end

  def self.all_files ; PLUGINS.each_with_object([]) { |plg, list|  plg.loadfiles.each { |f| list << f } } ; end

  def self.build_nydp &block
    rc = File.expand_path("rubycode")
    $LOAD_PATH.unshift rc unless $LOAD_PATH.include?(rc)

    digest   = Digest::SHA256.hexdigest(all_files.map { |f| f.read }.join("\n"))
    mname    = "Manifest_#{digest}"

    ns = ::Nydp::Namespace.new
    setup(ns)

    digest = ""

    PLUGINS.each { |plugin|
      digest = install_plugin ns, plugin, digest, &block
    }

    ns
  end

  def self.install_plugin ns, plugin, digest, &block
    f0       = plugin.loadfiles.map { |f| f.read }.join("\n")
    f1       = plugin.testfiles.map { |f| f.read }.join("\n")
    digest   = Digest::SHA256.hexdigest([digest, f0, f1].join("\n"))
    mname    = "Manifest_#{digest}"

    if Nydp.logger
      Nydp.logger.info "manifest name for plugin #{plugin.name.inspect} is #{mname.inspect}"
    end

    begin
      require mname
      const_get(mname).build ns

    rescue LoadError => e
      manifest = []
      loadall ns, plugin, plugin.loadfiles, manifest, &block
      loadall ns, plugin, plugin.testfiles, manifest, &block
      Nydp::Evaluator.mk_manifest "Manifest_#{digest}", manifest
    end

    digest
  end
end
