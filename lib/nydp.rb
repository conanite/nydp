require 'date'
require 'set'

module Nydp
  class << self
    attr_accessor :logger # not used by this gem but very useful in your app
  end

  class Namespace < Hash
  end

  # TODO: write VM #apply_function so we have fewer calls to VM.new
  def self.apply_function ns, function_name, *args
    vm         = VM.new(ns)
    function   = Symbol.mk(function_name.to_sym, ns).value if function_name.is_a?(String) || function_name.is_a?(::Symbol)
    function ||= function_name if function_name.respond_to?(:invoke)
    function.invoke vm, r2n(args)
    vm.thread
  rescue StandardError => e
    friendly_args = args.map { |a| a.respond_to?(:_nydp_compact_inspect) ? a._nydp_compact_inspect : a }
    raise Nydp::Error.new("Invoking #{function_name}\nwith args #{friendly_args._nydp_inspect}")
  end

  def self.reader                          txt ; Nydp::StringReader.new txt                                 ; end
  def self.eval_src      ns, src_txt, name=nil ; eval_with Nydp::Runner, ns, src_txt, name                  ; end
  def self.eval_with runner, ns, src_txt, name ; runner.new(VM.new(ns), ns, reader(src_txt), nil, name).run ; end
  def self.ms                           t1, t0 ; ((t1 - t0) * 1000).to_i                                    ; end
  def self.new_tokeniser                reader ; Nydp::Tokeniser.new reader                                 ; end
  # def self.new_parser                       ns ; Nydp::Parser.new(ns)                                       ; end
  def self.new_parser                       ns ; Nydp::Parser.new                                           ; end

  def self.indent_message indent, msg
    msg.split(/\n/).map { |line| "#{indent}#{line}" }.join("\n")
  end

  def self.handle_run_error e, indent=""
    puts "#{indent}#{e.class.name}"
    puts "#{indent_message indent, e.message}"
    if e.cause
      puts "#{indent}#{e.backtrace.first}"
      puts "\n#{indent}Caused by:"
      handle_run_error e.cause, "#{indent}    "
    else
      e.backtrace.each do |b|
        puts "#{indent}#{b}"
      end
    end
  end

  def self.toplevel
    begin
      yield
    rescue StandardError => e
      handle_run_error e
    end
  end

  def self.repl options={ }
    toplevel do
      launch_time      = Time.now
      silent           = options.delete :silent
      ns               = options.delete :ns
      last_script_time = Time.now
      puts "welcome to nydp #{options.inspect}" unless silent
      reader = Nydp::ReadlineReader.new $stdin, "nydp > "
      ns   ||= build_nydp do |script|
        this_script_time = Time.now
        puts "script #{script} time #{ms this_script_time, last_script_time}ms" if options[:verbose]
        last_script_time = this_script_time
      end
      load_time = Time.now
      puts "nydp v#{Nydp::VERSION} repl ready in #{ms(load_time, launch_time)}ms" unless silent
      puts "^D to exit" unless silent
      return if options[:exit]
      Nydp::Runner.new(VM.new(ns), ns, reader, $stdout, "<stdin>").run
      # Nydp::Invocation.whazzup
    end
  end

  def self.tests *options
    toplevel do
      verbose = options.include?(:verbose) ? "t" : "nil"
      puts "welcome to nydp : running tests"
      reader = Nydp::StringReader.new "(run-all-tests #{verbose})"
      ns     = build_nydp
      Nydp::Runner.new(VM.new(ns), ns, reader, nil, "<test-runner>").run
    end
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
require 'nydp/core_ext'
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
