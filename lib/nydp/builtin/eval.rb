class Nydp::Builtin::Eval
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    evaluator = Nydp::Evaluator.new Nydp::VM.new(vm.ns), vm.ns, "<eval>"
    # vm.push_arg evaluator.evaluate args.car
    evaluator.evaluate args.car
  end

  def call ns, *args
    evaluator = Nydp::Evaluator.new Nydp::VM.new(ns), ns, "<eval>"
    evaluator.evaluate args.first
  end
end
