class Nydp::Builtin::ThreadLocals
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_call *args
    Thread.current[:_nydp_thread_locals] ||= { }
  end
end
