require 'date'
require 'set'

module Nydp
  class Namespace < Hash
  end
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
  def self.ms                           t1, t0 ; ((t1 - t0) * 1000).to_i                                    ; end

  def self.repl options={ }
    silent = options[:silent]
    launch_time = Time.now
    last_script_time = Time.now
    puts "welcome to nydp #{options.inspect}" unless silent
    reader = Nydp::ReadlineReader.new $stdin, "nydp > "
    ns     = build_nydp do |script|
      this_script_time = Time.now
      puts "script #{script} time #{ms this_script_time, last_script_time}ms" if options[:verbose]
      last_script_time = this_script_time
    end
    load_time = Time.now
    puts "nydp v#{Nydp::VERSION} repl ready in #{ms(load_time, launch_time)}ms" unless silent
    puts "^D to exit" unless silent
    return if options[:exit]
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
