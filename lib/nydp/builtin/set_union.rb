class Nydp::Builtin::SetUnion
  include Nydp::Builtin::Base, Singleton

  # def builtin_invoke_2       vm, a ; vm.push_arg a               ; end
  # def builtin_invoke_3    vm, a, b ; vm.push_arg(a | b)          ; end
  # def builtin_invoke_4 vm, a, b, c ; vm.push_arg(a | b | c)      ; end
  # def builtin_invoke      vm, args ; vm.push_arg args.reduce &:| ; end

  def builtin_invoke_2       vm, a ;  a               ; end
  def builtin_invoke_3    vm, a, b ; (a | b)          ; end
  def builtin_invoke_4 vm, a, b, c ; (a | b | c)      ; end
  def builtin_invoke      vm, args ;  args.reduce &:| ; end
end
