class Nydp::Builtin::Sym
  include Nydp::Builtin::Base, Singleton

  def builtin_call s
    s.to_s.to_sym
  end
end
