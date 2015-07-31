class Nydp::Builtin::Eval
  include Nydp::Builtin::Base

  def initialize ns
    @ns = ns
  end

  def builtin_invoke vm, args
    evaluator = Nydp::Evaluator.new Nydp::VM.new, @ns
    vm.push_arg evaluator.evaluate args.car
  end
end
