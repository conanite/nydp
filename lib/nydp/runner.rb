require 'readline'
require 'nydp/readline_history'

module Nydp
  class StringReader
    def initialize string ; @string = string ; end
    def nextline
      s = @string ; @string = nil ; s
    end
  end

  class StreamReader
    def initialize stream ; @stream = stream ; end
    def nextline
      @stream.readline unless @stream.eof?
    end
  end

  class ReadlineReader
    include Nydp::ReadlineHistory

    def initialize stream, prompt
      @prompt = prompt
      setup_readline_history
    end

    # with thanks to http://ruby-doc.org/stdlib-1.9.3/libdoc/readline/rdoc/Readline.html
    # and http://bogojoker.com/readline/
    def nextline
      line = Readline.readline(@prompt, true)
      return nil if line.nil?
      if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
        Readline::HISTORY.pop
      end
      line
    end
  end

  class Evaluator
    attr_accessor :vm, :ns, :name

    def initialize vm, ns, name
      @name = name
      @vm   = vm
      @ns   = ns
      @rubydir = FileUtils.mkdir_p "rubycode"
    end

    def compile_expr expr
      begin
        Compiler.compile(expr, Nydp::NIL, ns)
      rescue StandardError => e
        raise Nydp::Error, "failed to compile #{expr._nydp_inspect}"
      end
    end

    def mk_ruby_source src, precompiled, compiled_expr, cname
      srcs       = []
      ruby_expr  = compiled_expr.compile_to_ruby "    ", srcs
      six        = 0
      srcs       = srcs.map { |s|
        s = "  @@src_#{six} = #{s.inspect}"
        six += 1
        s
      }
      class_expr = "class #{cname}
  attr_accessor :ns

#{srcs.join("\n")}

  def initialize ns
    @ns = ns
  end

  def src
    #{src.inspect.inspect}
  end

  def precompiled
    #{precompiled.inspect.inspect}
  end

  def call
#{ruby_expr}
  end
end

#{cname}
"
      File.open("rubycode/#{cname}.rb", "w") { |f| f.write class_expr }
      class_expr
    end

    def mk_ruby_class src, precompiled, compiled_expr, cname
      fname = "rubycode/#{cname}.rb"
      txt = if File.exists?(fname)
              File.read(fname)
            else
              mk_ruby_source src, precompiled, compiled_expr, cname
            end

      eval txt, nil, fname
    end

    def eval_compiled compiled_expr, precompiled, src
      name    = if src.respond_to? :cadr
                  src.cadr
                else
                  src
                end.to_s.gsub(/[^a-zA-Z0-9]/, '_').gsub(/_+/, '_').upcase[0,20]
      digest  = Digest::SHA256.hexdigest(precompiled.inspect)
      cname   = "NydpGenerated_#{name}_#{digest.upcase}"

      kla     = mk_ruby_class src, precompiled, compiled_expr, cname

      kla.new(ns).call

    rescue Exception => e
      raise Nydp::Error, "failed to eval #{compiled_expr._nydp_inspect} from src #{src._nydp_inspect}"
    end

    def pre_compile expr
      Nydp.apply_function ns, :"pre-compile", expr
    end

    def evaluate expr
      precompiled = pre_compile(expr)
      compiled    = compile_expr precompiled
      eval_compiled compiled, precompiled, expr
    end
  end

  class Runner < Evaluator
    def initialize vm, ns, stream, printer=nil, name=nil
      super vm, ns, name
      @printer    = printer
      @parser     = Nydp.new_parser
      @tokens     = Nydp.new_tokeniser stream
    end

    def print val
      @printer.puts val._nydp_inspect if @printer
    end

    def run
      Nydp.apply_function ns, :"script-run", :"script-start", name
      res = Nydp::NIL
      begin
        while !@tokens.finished
          expr = @parser.expression(@tokens)
          print(res = evaluate(expr)) unless expr.nil?
        end
      ensure
        Nydp.apply_function ns, :"script-run", :"script-end", name
      end
      res
    end
  end
end
