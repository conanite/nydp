class Nydp::Builtin::Comment
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg Nydp::NIL
  end
end
