class Nydp::Builtin::ScriptRun
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    # vm.push_arg args
    args
  end

  def call *args
    args
  end
end
