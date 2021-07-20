class Nydp::Builtin::Times
  include Nydp::Builtin::Base, Singleton

  # def invoke_1 vm             ; vm.push_arg 1             ; end
  # def invoke_2 vm, a          ; vm.push_arg a             ; end
  # def invoke_3 vm, a0, a1     ; vm.push_arg(a0 * a1)      ; end
  # def invoke_4 vm, a0, a1, a2 ; vm.push_arg(a0 * a1 * a2) ; end

  def invoke_1 vm             ;  1             ; end
  def invoke_2 vm, a          ;  a             ; end
  def invoke_3 vm, a0, a1     ; (a0 * a1)      ; end
  def invoke_4 vm, a0, a1, a2 ; (a0 * a1 * a2) ; end

  def builtin_invoke vm, args
    multiply(args, 1)
  end

  def multiply args, accum
    if Nydp::NIL.is? args
      accum
    else
      multiply(args.cdr, (accum * args.car))
    end
  end

  def name ; "*" ; end

  def call ns, *args
    (args.reduce &:*)._nydp_wrapper
  end
end
