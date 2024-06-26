require 'date'
require 'set'

module Nydp
  GENERATED_CLASS_PREFIX = "NydpGenerated"

  class << self
    attr_accessor :logger # set this if you plan on using 'log
  end

  def self.apply_function      ns, name, *args ; ns.apply name, *args                                 ; end
  def self.reader                    name, txt ; Nydp::StringReader.new name, txt                     ; end
  def self.eval_src      ns, src_txt, name=nil ; eval_with Nydp::Runner, ns, src_txt, name            ; end
  def self.eval_with runner, ns, src_txt, name ; runner.new(ns, reader(name, src_txt), nil, name).run ; end
  def self.ms                           t1, t0 ; ((t1 - t0) * 1000).to_i                              ; end
  def self.new_tokeniser                reader ; Nydp::Tokeniser.new reader                           ; end
  def self.new_parser                          ; Nydp::Parser.new                                     ; end

  def self.indent_message indent, msg
    msg.split(/\n/).map { |line| "#{indent}#{line}" }.join("\n")
  end

  def self.handle_run_error e, indent=""
    puts "#{indent}#{e.class.name}"
    puts "#{indent_message indent, e.message}"
    if e.cause
      puts "#{indent}#{e.backtrace[0]}"
      puts "#{indent}#{e.backtrace[1]}"
      puts "#{indent}#{e.backtrace[2]}"
      puts "#{indent}#{e.backtrace[3]}"
      puts "\n#{indent}Caused by:"
      handle_run_error e.cause, "#{indent}    "
    else
      Nydp.enhance_backtrace(e.backtrace).each do |b|
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
    while !options[:exit]
      toplevel do
        Nydp::Runner.new(ns, reader, $stdout, "<stdin>").run
        options[:exit] = true
      end
    end
    # Nydp::Invocation.whazzup
  end

  def self.tests *options
    toplevel do
      verbose = options.include?(:verbose) ? true : nil
      puts "welcome to nydp : running tests"
      build_nydp.apply :"run-all-tests", verbose
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
require "nydp/namespace"
