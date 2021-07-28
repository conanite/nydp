class Nydp::Builtin::PreCompile
  include Nydp::Builtin::Base, Singleton

  def builtin_call *args ; args.first ; end
end
