class Nydp::Builtin::Comment
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    Nydp::NIL
  end

  def call *args
    nil
  end
end
