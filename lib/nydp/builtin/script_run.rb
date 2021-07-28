class Nydp::Builtin::ScriptRun
  include Nydp::Builtin::Base, Singleton

  def builtin_call *args ; args ; end
end
