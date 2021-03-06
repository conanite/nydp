class Nydp::Builtin::Plus
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke_1 vm             ; vm.push_arg 0             ; end
  def builtin_invoke_2 vm, a          ; vm.push_arg a             ; end
  def builtin_invoke_3 vm, a0, a1     ; vm.push_arg(a0 + a1)      ; end
  def builtin_invoke_4 vm, a0, a1, a2 ; vm.push_arg(a0 + a1 + a2) ; end

  def builtin_invoke vm, args
    vm.push_arg case args.car
                when Nydp::Pair
                  sum(args, Nydp::NIL)
                when String
                  string_concat("", args)
                else
                  sum(args.cdr, args.car)
                end
  end

  def string_concat init, others
    while others && !Nydp::NIL.is?(others)
      init << others.car.to_s
      others = others.cdr
    end
    init
  end

  def sum args, accum
    while args && !Nydp::NIL.is?(args)
      accum += args.car
      args = args.cdr
    end
    accum
  end

  def name ; "+" ; end
end
