module Nydp
  class AssignmentInstruction
    def initialize name
      @name = name
    end

    def execute vm
      @name.assign vm.peek_arg
    end
  end

  class Assignment
    include Helper

    def self.build args
      Assignment.new args.car, args.cdr.car
    end

    def initialize name, value
      raise "can't assign to #{name.inspect}" unless name.respond_to?(:assign)
      n = AssignmentInstruction.new name
      v = Compiler.compile(value)
      @instructions = cons(v, cons(n))
    end

    def execute vm
      vm.push_instructions @instructions
    end
  end
end
