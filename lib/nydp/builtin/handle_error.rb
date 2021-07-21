require "nydp/vm"

class Nydp::Builtin::HandleError
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    fn_handle = args.car
    fn_tricky = args.cdr.car

    begin
      res = fn_tricky.invoke_1 vm
    rescue Exception => e
      o = e
      msgs = []
      while e
        msgs << e.message
        e = e.cause
      end
      res = fn_handle.invoke_2 vm, r2n(msgs)
    end
    res
  end

  def builtin_call handler, tricky
    begin
      res = tricky.call
    rescue Exception => e
      o = e
      msgs = []
      while e
        msgs << e.message
        e = e.cause
      end
      res = handler.call msgs._nydp_wrapper
    end
    res._nydp_wrapper
  end
end
