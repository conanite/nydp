class Nydp::Builtin::Ensuring
  include Nydp::Helper

  class InvokeProtection
    attr_reader :protection

    def initialize protection
      @protection = protection
    end

    def execute vm
      protection.invoke vm, Nydp.NIL
    end
  end

  def invoke vm, args
    fn_ensure = args.car
    fn_tricky = args.cdr.car

    protection_instructions = Nydp::Pair.from_list [InvokeProtection.new(fn_ensure), Nydp::PopArg]
    vm.push_instructions protection_instructions, vm.peek_context

    fn_tricky.invoke vm, Nydp.NIL
  end
end
