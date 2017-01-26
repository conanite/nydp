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

  class Cond_LEX
    extend Helper
    include Helper
    attr_reader :condition, :when_true, :when_false

    def initialize cond, when_true, when_false
      @condition, @when_true, @when_false = cond, when_true, when_false
    end

    def execute vm
      truth = !Nydp::NIL.is?(condition.value vm.current_context)
      vm.instructions.push (truth ? when_true : when_false)
      vm.contexts.push vm.current_context
    end

    def inspect ; "cond:#{condition.inspect}:#{when_true.inspect}:#{when_false.inspect}" ; end
    def to_s    ; "(cond #{condition.to_s} #{when_true.to_s} #{when_false.to_s})" ; end
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
        cond       = Compiler.compile expressions.car, bindings
        when_true  = Compiler.compile expressions.cdr.car, bindings
        when_false = Compiler.compile expressions.cdr.cdr.car, bindings
        csig       = sig(cond)
        case csig
        when "LEX"
          Cond_LEX.new(cond, cons(when_true), cons(when_false))
        else
          new(cons(cond), cons(when_true), cons(when_false))
        end

        # new(cons(cond), cons(when_true), cons(when_false))
      else
        raise "can't compile Cond: #{expr.inspect}"
      end
    end
  end
end
