class Nydp::Builtin::Modulo
  include Nydp::Builtin::Base

  def invoke_3 vm, a0, a1     ; vm.push_arg(a0 % a1)      ; end

  def builtin_invoke vm, args
    invoke_3 vm, args.car, args.cdr.car
  end

  def name ; "mod" ; end
end
