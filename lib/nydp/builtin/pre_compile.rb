class Nydp::Builtin::PreCompile
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    raise Nydp:Error.new("pre-compile: expects one arg, got #{args.inspect}") unless Nydp::NIL == args.cdr
    vm.push_arg args.car
  end
end
