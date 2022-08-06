require 'digest'
require 'readline'
require 'nydp/readline_history'

module Nydp
  class StringReader
    attr_accessor :name

    def initialize name, string
      @name, @string, @read = name, string, string
    end

    def nextline
      s = @read ; @read = nil ; s
    end

    def read
      @string
    end
  end

  class StreamReader
    attr_accessor :name

    def initialize name, stream
      @name, @stream = name, stream
    end

    def nextline
      @stream.readline unless @stream.eof?
    end

    def read
      ""
    end
  end

  class FileReader < StreamReader
    attr_accessor :filename

    def initialize name, filename
      super name, File.new(filename)
      @filename = filename
    end

    def read
      File.read filename
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
    attr_accessor :ns, :name

    def initialize ns, name
      @name = name
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

    def self.mk_manifest name, class_list
      class_expr = <<KLA
#{class_list.map {|k| "require '#{k}'" }.join("\n")}

class #{name}
  def self.build ns
    #{class_list.map {|k| "#{k}.new(ns).call" }.join("\n    ")}
  end
end
KLA
      File.open("rubycode/#{name}.rb", "w") { |f|
        fullpath = File.expand_path("rubycode/#{name}.rb")
        Nydp.logger.info "writing #{fullpath}" if Nydp.logger
        f.write class_expr
      }
    end

    class CompiledExpression
      attr_accessor :ns
      def initialize ns
        @ns = ns
      end

      def list *things
        Nydp::Pair.from_list things
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
      class_expr = "class #{cname} < Nydp::Runner::CompiledExpression

#{srcs.join("\n")}

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
      begin
        require cname
        self.class.const_get(cname)

      rescue LoadError => e
        # compiled_expr    = compile_expr precompiled # TODO : delete line in #evaluate and uncomment this one
        fname = "rubycode/#{cname}.rb"
        txt   = mk_ruby_source src, precompiled, compiled_expr, cname

        eval(txt, nil, fname) || raise("failed to generate class #{cname} from src #{src}")
      end
    end

    def eval_compiled compiled_expr, precompiled, src, manifest
      return nil if precompiled == nil

      digest  = Digest::SHA256.hexdigest(precompiled.inspect)
      cname   = "NydpGenerated_#{digest.upcase}"
      kla     = mk_ruby_class src, precompiled, compiled_expr, cname

      manifest << cname

      kla.new(ns).call

    rescue Exception => e
      raise Nydp::Error, "failed to eval #{compiled_expr._nydp_inspect} from src #{src._nydp_inspect}"
    end

    def evaluate expr, manifest=[]
      precompiled = ns.apply :"pre-compile-new-expression", expr
      compiled    = compile_expr precompiled # TODO : we don't need this step if the class already exists! Do it later only when we need it
      eval_compiled compiled, precompiled, expr, manifest
    end
  end

  class Runner < Evaluator
    def initialize ns, stream, printer=nil, name=nil, manifest=[]
      super ns, name
      @printer    = printer
      @parser     = Nydp.new_parser
      @tokens     = Nydp.new_tokeniser stream
      @manifest   = manifest
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
          print(res = evaluate(expr, @manifest)) unless expr.nil?
        end
      ensure
        Nydp.apply_function ns, :"script-run", :"script-end", name
      end
      res
    end
  end
end
