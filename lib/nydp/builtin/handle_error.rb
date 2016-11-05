require "nydp/vm"

class Nydp::Builtin::HandleError
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  class CatchError
    include Nydp::Helper, Nydp::VM::HandleError

    attr_reader :handler, :vm_arg_array_size

    def initialize handler, vm_arg_array_size
      @handler, @vm_arg_array_size = handler, vm_arg_array_size
    end

    def execute vm
      e = vm.last_error = vm.unhandled_error
      vm.unhandled_error = nil
      return unless e

      vm.args = vm.args[0...vm_arg_array_size]

      msgs = []
      while e
        msgs << e.message
        e = e.cause
      end

      handler.invoke_2 vm, vm.r2n(msgs)
    end

    def to_s
      "(on-err: #{handler})"
    end
  end


  def builtin_invoke vm, args
    fn_handle = args.car
    fn_tricky = args.cdr.car

    catcher_instructions = Nydp::Pair.from_list [CatchError.new(fn_handle, vm.args.size)]
    vm.instructions.push catcher_instructions
    vm.contexts.push vm.current_context

    fn_tricky.invoke vm, Nydp::NIL
  end
end
