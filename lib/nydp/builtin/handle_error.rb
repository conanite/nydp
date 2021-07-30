# require "nydp/vm"

class Nydp::Builtin::HandleError
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

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
