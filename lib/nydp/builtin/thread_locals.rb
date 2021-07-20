class Nydp::Builtin::ThreadLocals
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.locals
  end

  def call *args
    Thread.current[:_nydp_thread_locals] ||= { }
  end
end
