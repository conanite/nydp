class Nydp::Builtin::Abs
  include Nydp::Builtin::Base, Singleton

  def invoke_2         vm, a0 ; vm.push_arg(a0.abs)   ; end
  def builtin_invoke vm, args ; invoke_2 vm, args.car ; end

  def name ; "mod" ; end
end
