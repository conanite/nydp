module Nydp
  # class LoopBodyInstruction
  #   extend Helper
  #   include Helper

  #   def initialize loop_body, condition
  #     @loop_body, @condition = loop_body, cons(Nydp::PopArg, cons(condition))
  #     # @loop_body, @condition = loop_body, cons(condition)
  #   end

  #   def lexical_reach n
  #     @loop_body.lexical_reach(n)
  #   end

  #   def execute vm
  #     if vm.args.pop
  #       vm.push_ctx_instructions @condition
  #       @loop_body.execute vm
  #     else
  #       vm.push_arg nil
  #     end
  #   end

  #   def inspect
  #     "loop_body:#{@loop_body._nydp_inspect}"
  #   end

  #   def to_s
  #     "#{@loop_body.to_s}"
  #   end
  # end

  class Loop
    extend Helper
    include Helper
    attr_reader :condition, :loop_body

    def initialize cond, loop_body
      @condition, @loop_body = cond, loop_body
    end

    def lexical_reach n
      [condition.lexical_reach(n), loop_body.lexical_reach(n)].max
    end

    def execute vm
      while(condition.execute vm)
        loop_body.execute(vm)
      end
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

    def compile_to_ruby indent, srcs
      "#{indent}while (#{condition.compile_to_ruby "", srcs})
#{loop_body.compile_to_ruby(indent + "  ", srcs)}
#{indent}end"
    end
  end
end
