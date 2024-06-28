#
# (rescue
#   (do (this) (that))
#   SomeError e
#   (do (notify e) (log-error e))
#   OtherError o
#   (ignore o))
#
# becomes
#
# begin
#   this.call
#   that.call
# rescue SomeError => e
#   notify.call(e)
#   log_error.call(e)
# rescue OtherError => o
#   ignore.call(o)
# end
#
module Nydp
  class Rescue
    extend Helper
    include Helper
    attr_reader :try_expr, :rescues

    def initialize try_expr, rescues
      @try_expr, @rescues = try_expr, rescues
    end

    def inspect
      "rescue:#{try_expr}:#{rescues}"
    end

    def to_s
      "(rescue #{try_expr} #{rescues})"
    end

    def self.valid_klass_name? name

    end
    def self.compile_rescue expr, bindings, ns
      ne_name = expr[0].to_s

      # can't have // in name or end with /
      raise "invalid exception name : #{expr[0].to_s}" if (ne_name =~ /\/\//) || (ne_name =~ /\/\Z/)

      ne_name = ne_name.split(/\//)
      re_name = ne_name.map { |n|
        # each part must start with letter and contain only letters, digits, and underscore
        raise "invalid exception name : #{expr[0].to_s}" unless n =~ /\A[a-z][a-z0-9_]*/
        n.split(/-/).map(&:capitalize).join
      }.join("::")

      var    = expr[1].to_s.to_sym

      rescue_params = { }
      Nydp::InterpretedFunction.index_parameters var, rescue_params

      body   = Nydp::Compiler.compile expr[2], cons(rescue_params, bindings), ns

      [re_name, var, body]
    end

    def self.build expressions, bindings, ns
      if expressions.is_a? Nydp::Pair
        try_expr    = Compiler.compile expressions.car, bindings, ns
        rescues     = expressions.cdr.threes.map { |ex| compile_rescue ex, bindings, ns }
        new(try_expr, rescues)
      else
        raise "can't compile Rescue, not a Pair : #{expressions._nydp_inspect}"
      end
    end

    def compile_rescue_to_ruby r, indent, srcs
      rubyarg = "_arg_#{r[1].to_s._nydp_name_to_rb_name}"

      "#{indent}rescue #{r[0]} => #{rubyarg}
#{r[2].compile_to_ruby(indent + "  ", srcs, cando: true)}"
    end

    def compile_to_ruby indent, srcs, opts=nil
      rexps = rescues.map { |r| compile_rescue_to_ruby r, indent, srcs }

      "#{indent}##> #{to_s.split(/\n/).join('\n')}\n" +
      "#{indent}begin
#{try_expr.compile_to_ruby(indent + "  ", srcs, cando: true)}
#{rexps.join("\n")}
#{indent}end"
    end
  end
end
