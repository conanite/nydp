module Nydp
  class ExecuteConditionalInstruction
    extend Helper
    attr_reader :when_true, :when_false

    def initialize when_true, when_false
      @when_true, @when_false = when_true, when_false
    end

    def execute vm
      vm.push_instructions (Nydp.NIL.is?(vm.pop_arg) ? when_false : when_true)
    end

    def inspect; to_s; end
    def to_s
      "when_true:#{when_true}:when_false:#{when_false}"
    end
  end

  class Cond
    extend Helper
    include Helper
    attr_reader :condition, :conditional

    def initialize cond, when_true, when_false
      @condition, @conditional = cond, cons(ExecuteConditionalInstruction.new(when_true, when_false))
    end

    def execute vm
      vm.push_instructions conditional
      vm.push_instructions condition
    end

    def inspect; to_s; end
    def to_s
      "cond:#{condition}:#{conditional}"
    end

    def self.build expressions, bindings
      if expressions.is_a? Nydp::Pair
        cond       = cons Compiler.compile expressions.car, bindings
        when_true  = cons Compiler.compile expressions.cdr.car, bindings
        when_false = cons Compiler.compile expressions.cdr.cdr.car, bindings
        new(cond, when_true, when_false)
      else
        raise "can't compile Cond: #{expr.inspect}"
      end
    end
  end
end
