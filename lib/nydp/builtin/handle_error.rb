# require "nydp/vm"

class Nydp::Builtin::HandleError
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_call handler, tricky
    begin
      res = tricky.call
    rescue Exception => e
      o = e
      msgs = []
      traces = []
      while e
        msgs << e.message
        traces << Nydp.enhance_backtrace(e.backtrace)
        e = e.cause
      end
      res = handler.call msgs._nydp_wrapper, traces._nydp_wrapper
    end
    res._nydp_wrapper
  end
end
