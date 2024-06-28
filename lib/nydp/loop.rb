module Nydp
  class Loop
    extend Helper
    include Helper
    attr_reader :condition, :loop_body

    def initialize cond, loop_body
      @condition, @loop_body = cond, loop_body
    end

    def inspect
      "loop:#{condition._nydp_inspect}:#{loop_body._nydp_inspect}"
    end

    def to_s
      "(loop #{condition.to_s} #{loop_body.to_s})"
    end

    def self.build expressions, bindings, ns
      if expressions.is_a? Nydp::Pair
        cond       = Compiler.compile expressions.car, bindings, ns
        loop_body  = Compiler.compile expressions.cdr.car, bindings, ns
        csig       = sig(cond)
        new(cond, loop_body)
      else
        raise "can't compile Loop: #{expressions._nydp_inspect}"
      end
    end

    def compile_to_ruby indent, srcs, opts=nil
      "#{indent}##> #{to_s.split(/\n/).join('\n')}\n" +
      "#{indent}while (#{condition.compile_to_ruby "", srcs})
#{loop_body.compile_to_ruby(indent + "  ", srcs, cando: true)}
#{indent}end"
    end
  end
end
