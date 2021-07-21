class Nydp::Builtin::IsEqual
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke_1 vm      ; raise "#{name} : requires at least two args"                    ; end
  def builtin_invoke_2 vm, arg ; raise "#{name} : requires at least two args, got one: (#{arg})" ; end

  # def builtin_invoke_3 vm, a0, a1     ; vm.push_arg ((a0 == a1)        ? Nydp::T : Nydp::NIL) ; end
  # def builtin_invoke_4 vm, a0, a1, a2 ; vm.push_arg (eq?([a0, a1, a2]) ? Nydp::T : Nydp::NIL) ; end
  # def builtin_invoke   vm, args       ; vm.push_arg (eq?(args.to_a)    ? Nydp::T : Nydp::NIL) ; end

  def builtin_invoke_3 vm, a0, a1     ; ((a0 == a1)        ? Nydp::T : Nydp::NIL) ; end
  def builtin_invoke_4 vm, a0, a1, a2 ; (eq?([a0, a1, a2]) ? Nydp::T : Nydp::NIL) ; end
  def builtin_invoke   vm, args       ; (eq?(args.to_a)    ? Nydp::T : Nydp::NIL) ; end

  def _eq?  arg, args ; args.all? { |a| a == arg }   ; end
  def eq?        args ; _eq? args.first, args[1..-1] ; end
  def name            ; "eq?"                        ; end

  def builtin_call *args
    eq?(args) || nil
  end
end
