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
    }
  ensure
    apply_function ns, :"script-run", :"plugin-end", plugin.name if plugin
  end

  def self.build_nydp extra_files=nil
    ns = { }
    setup(ns)
    PLUGINS.each { |plg|
      loadall ns, plg, plg.loadfiles
      loadall ns, plg, plg.testfiles
    }
    loadall ns, nil, extra_files if extra_files
    ns
  end
end
