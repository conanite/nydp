class Nydp::Builtin::IsEqual
  include Nydp::Builtin::Base, Singleton

  def _eq?  arg, args ; args.all? { |a| a == arg }   ; end
  def eq?        args ; _eq? args.first, args[1..-1] ; end
  def name            ; "eq?"                        ; end

  def builtin_call *args
    eq?(args) || nil
  end
end
