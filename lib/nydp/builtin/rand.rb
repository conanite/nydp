class Nydp::Builtin::Rand
  include Nydp::Builtin::Base, Singleton

  # def builtin_invoke_1 vm             ; vm.push_arg rand                ; end
  # def builtin_invoke_2 vm, a          ; vm.push_arg rand(a)             ; end
  # def builtin_invoke_3 vm, a0, a1     ; vm.push_arg(a0 + rand(a1 - a0)) ; end
  def builtin_invoke_1 vm             ;  rand                ; end
  def builtin_invoke_2 vm, a          ;  rand(a)             ; end
  def builtin_invoke_3 vm, a0, a1     ; (a0 + rand(a1 - a0)) ; end
  def builtin_invoke   vm, args       ;
    if Nydp::NIL.is? args
      builtin_invoke_1 vm
    else
      case args.size
      when 1 ; builtin_invoke_2 vm, args.car
      when 2 ; builtin_invoke_3 vm, args.car, args.cadr
      else   ; raise "rand: 0, 1 or 2 args expected, got #{args.length}"
      end
    end
  end

  def builtin_call a0=nil, a1=nil
    if a0 == nil
      rand
    elsif a1 == nil
      rand(a0)
    else
      (a0 + rand(a1 - a0))
    end
  end
end
