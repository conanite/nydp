class Nydp::Builtin::Eval
  include Nydp::Builtin::Base

  def builtin_invoke vm, args
    evaluator = Nydp::Evaluator.new Nydp::VM.new(vm.ns), vm.ns
    vm.push_arg evaluator.evaluate args.car
  end
end
