class Nydp::Builtin::Times
  include Nydp::Builtin::Base

  def invoke_1 vm             ; vm.push_arg 1             ; end
  def invoke_2 vm, a          ; vm.push_arg a             ; end
  def invoke_3 vm, a0, a1     ; vm.push_arg(a0 * a1)      ; end
  def invoke_4 vm, a0, a1, a2 ; vm.push_arg(a0 * a1 * a2) ; end

  def builtin_invoke vm, args
    vm.push_arg multiply(args, 1)
  end

  def multiply args, accum
    if Nydp::NIL.is? args
      accum
    else
      multiply(args.cdr, (accum * args.car))
    end
  end

  def name ; "*" ; end
end
