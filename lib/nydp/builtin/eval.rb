class Nydp::Builtin::Eval
  include Nydp::Builtin::Base

  def initialize ns
    @ns = ns
    super()
  end

  def builtin_invoke vm, args
    evaluator = Nydp::Evaluator.new Nydp::VM.new(vm.ns), vm.ns, "<eval>"
    # vm.push_arg evaluator.evaluate args.car
    evaluator.evaluate args.car
  end

  def builtin_call *args
    evaluator = Nydp::Evaluator.new Nydp::VM.new(@ns), @ns, "<eval>"
    evaluator.evaluate args.first
  end
end
