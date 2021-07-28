class Nydp::Builtin::CdrSet
  include Nydp::Builtin::Base, Singleton

  def builtin_call a, b ; a.cdr = b ; end
end
