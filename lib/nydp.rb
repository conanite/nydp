require 'date'
require 'set'

module Nydp
  def self.apply_function ns, function_name, *args
    function = r2n(function_name.to_sym, ns).value
    args     = r2n args, ns
    vm       = VM.new(ns)

    function.invoke vm, args
    vm.thread
  end

  def self.reader                          txt ; Nydp::StringReader.new txt                                 ; end
  def self.eval_src      ns, src_txt, name=nil ; eval_with Nydp::Runner, ns, src_txt, name                  ; end
  def self.eval_src!     ns, src_txt, name=nil ; eval_with Nydp::ExplodeRunner, ns, src_txt, name           ; end
  def self.eval_with runner, ns, src_txt, name ; runner.new(VM.new(ns), ns, reader(src_txt), nil, name).run ; end

  def self.repl
    puts "welcome to nydp"
    puts "^D to exit"
    reader = Nydp::ReadlineReader.new $stdin, "nydp > "
    ns     = build_nydp
    Nydp::Runner.new(VM.new(ns), ns, reader, $stdout, "<stdin>").run
  end

  def self.tests *options
    verbose = options.include?(:verbose) ? "t" : "nil"
    puts "welcome to nydp : running tests"
    reader = Nydp::StringReader.new "(run-all-tests #{verbose})"
    ns     = build_nydp
    Nydp::Runner.new(VM.new(ns), ns, reader, nil, "<test-runner>").run
  end
end

require "nydp/plugin"
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
