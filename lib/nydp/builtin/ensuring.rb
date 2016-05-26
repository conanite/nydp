require "nydp/vm"

class Nydp::Builtin::Ensuring
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  class InvokeProtection
    include Nydp::VM::Finally
    attr_reader :protection

    def initialize protection
      @protection = protection
    end

    def execute vm
      protection.invoke vm, Nydp::NIL
    end
  end

  def builtin_invoke vm, args
    fn_ensure = args.car
    fn_tricky = args.cdr.car

    protection_instructions = Nydp::Pair.from_list [InvokeProtection.new(fn_ensure), Nydp::PopArg]
    vm.instructions.push protection_instructions
    vm.contexts.push vm.current_context

    fn_tricky.invoke vm, Nydp::NIL
  end
end
