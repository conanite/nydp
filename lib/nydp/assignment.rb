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

    def self.build args, bindings
      name = args.car
      raise "can't assign to #{name.inspect}" unless name.respond_to?(:assign)
      Assignment.new name, Compiler.compile(args.cdr.car, bindings)
    end

    def initialize name, value
      n = AssignmentInstruction.new name
      @instructions = cons(value, cons(n))
    end

    def execute vm
      vm.push_instructions @instructions
    end
  end
end
