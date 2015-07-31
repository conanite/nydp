require "nydp/vm"

class Nydp::Builtin::HandleError
  include Nydp::Helper, Nydp::Builtin::Base

  class CatchError
    include Nydp::Helper, Nydp::VM::HandleError

    attr_reader :handler, :vm_arg_array_size

    def initialize handler, vm_arg_array_size
      @handler, @vm_arg_array_size = handler, vm_arg_array_size
    end

    def execute vm
      e = vm.unhandled_error
      vm.unhandled_error = nil
      return unless e

      vm.args = vm.args[0...vm_arg_array_size]

      handler.invoke vm, cons(r2n e.message, nil)
    end

    def to_s
      "(on-err: #{handler})"
    end
  end


  def builtin_invoke vm, args
    fn_handle = args.car
    fn_tricky = args.cdr.car

    catcher_instructions = Nydp::Pair.from_list [CatchError.new(fn_handle, vm.args.size)]
    vm.push_instructions catcher_instructions, vm.peek_context

    fn_tricky.invoke vm, Nydp.NIL
  end
end
