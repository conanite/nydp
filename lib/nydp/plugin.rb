module Nydp
  PLUGINS = []

  def self.plug_in plugin ; PLUGINS << plugin                   ; end
  def self.load_rake_tasks; PLUGINS.each &:load_rake_tasks      ; end
  def self.setup ns;        PLUGINS.each { |plg| plg.setup ns } ; end
  def self.loadfiles;       PLUGINS.map(&:loadfiles).flatten    ; end
  def self.testfiles;       PLUGINS.map(&:testfiles).flatten    ; end
  def self.plugin_names   ; PLUGINS.map(&:name)                 ; end
  def self.loadall ns, plugin, files
    vm = VM.new(ns)
    apply_function ns, :"script-run", :"plugin-start", plugin.name if plugin
    files.each { |f|
      script_name = f.gsub plugin.base_path, ""
      reader = Nydp::StreamReader.new(File.new(f))
      Nydp::Runner.new(vm, ns, reader, nil, (script_name || f)).run
      yield script_name if block_given?
    }
  ensure
    apply_function ns, :"script-run", :"plugin-end", plugin.name if plugin
  end

  def self.build_nydp extra_files=nil, &block
    ns = Namespace.new
    setup(ns)
    PLUGINS.each { |plg|
      loadall ns, plg, plg.loadfiles, &block
      loadall ns, plg, plg.testfiles, &block
    }
    loadall ns, nil, extra_files, &block if extra_files
    ns
  end
end
