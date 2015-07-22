module Nydp
  PLUGINS = []

  def self.plug_in plugin ; PLUGINS << plugin                   ; end
  def self.load_rake_tasks; PLUGINS.each &:load_rake_tasks      ; end
  def self.setup ns;        PLUGINS.each { |plg| plg.setup ns } ; end
  def self.loadfiles;       PLUGINS.map(&:loadfiles).flatten    ; end
  def self.testfiles;       PLUGINS.map(&:testfiles).flatten    ; end
  def self.plugin_names   ; PLUGINS.map(&:name)                 ; end
  def self.loadall ns, files
    vm = VM.new
    files.each { |f|
      reader = Nydp::StreamReader.new(File.new(f))
      Nydp::Runner.new(vm, ns, reader).run
    }
  end

  def self.build_nydp extra_files=nil
    ns = { }
    setup(ns)
    loadall ns, loadfiles
    loadall ns, extra_files if extra_files
    ns
  end

  def self.apply_function ns, function_name, *args
    function = Nydp::Symbol.mk(function_name, ns).value
    args     = Nydp::Pair.from_list args
    vm       = VM.new

    function.invoke vm, args
    return vm.pop_arg
  end

  def self.repl
    puts "welcome to nydp"
    puts "^D to exit"
    reader = Nydp::ReadlineReader.new $stdin, "nydp > "
    Nydp::Runner.new(VM.new, build_nydp, reader, $stdout).run
  end

  def self.tests *options
    verbose = options.include?(:verbose) ? "t" : "nil"
    puts "welcome to nydp : running tests"
    reader = Nydp::StringReader.new "(run-all-tests #{verbose})"
    Nydp::Runner.new(VM.new, build_nydp(testfiles), reader).run
  end

end

require "nydp/core"
require "nydp/date"
require "nydp/runner"
require "nydp/error"
require "nydp/truth"
require "nydp/version"
require "nydp/helper"
require "nydp/symbol"
require "nydp/symbol_lookup"
require "nydp/pair"
require "nydp/assignment"
require "nydp/builtin"
require "nydp/string_atom"
require "nydp/string_token"
require "nydp/tokeniser"
require "nydp/parser"
require "nydp/compiler"
require "nydp/vm"
