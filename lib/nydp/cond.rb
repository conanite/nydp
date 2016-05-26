module Nydp
  class ExecuteConditionalInstruction
    extend Helper
    attr_reader :when_true, :when_false

    def initialize when_true, when_false
      @when_true, @when_false = when_true, when_false
    end

    def execute vm
      truth = !Nydp::NIL.is?(vm.args.pop)
      vm.instructions.push (truth ? when_true : when_false)
      vm.contexts.push vm.current_context
    end

    def inspect
      "when_true:#{when_true.inspect}:when_false:#{when_false.inspect}"
    end
    def to_s
      "#{when_true.car.to_s} #{when_false.car.to_s}"
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
      vm.instructions.push conditional
      vm.contexts.push vm.current_context
      vm.instructions.push condition
      vm.contexts.push vm.current_context
    end

    def inspect
      "cond:#{condition.inspect}:#{conditional.inspect}"
    end
    def to_s
      "(cond #{condition.car.to_s} #{conditional.to_s})"
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
