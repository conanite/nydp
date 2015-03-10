module Nydp
  PLUGINS = []

  def self.plug_in plugin ; PLUGINS << plugin                   ; end
  def self.load_rake_tasks; PLUGINS.each &:load_rake_tasks      ; end
  def self.setup ns;        PLUGINS.each { |plg| plg.setup ns } ; end
  def self.loadfiles;       PLUGINS.map(&:loadfiles).flatten    ; end
  def self.testfiles;       PLUGINS.map(&:testfiles).flatten    ; end
  def self.plugin_names   ; PLUGINS.map(&:name)                 ; end
  def self.loadall vm, ns, files
    files.each { |f|
      reader = Nydp::StreamReader.new(File.new(f))
      Nydp::Runner.new(vm, ns, reader).run
    }
  end

  def self.repl
    puts "welcome to nydp"
    ns = { }
    setup(ns)
    vm = VM.new
    loadall vm, ns, loadfiles
    reader = Nydp::ReadlineReader.new $stdin, "nydp > "
    Nydp::Runner.new(vm, ns, reader, $stdout).run
  end

  def self.tests *options
    verbose = options.include?(:verbose) ? "t" : "nil"
    puts "welcome to nydp : running tests"
    ns = { }
    setup(ns)
    vm = VM.new
    loadall vm, ns, loadfiles
    loadall vm, ns, testfiles
    reader = Nydp::StringReader.new "(run-all-tests #{verbose})"
    Nydp::Runner.new(vm, ns, reader).run
  end

end

require "nydp/core"
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
