class Nydp::Builtin::Eval
  def initialize ns
    @ns = ns
  end

  def invoke vm, args
    evaluator = Nydp::Runner.new vm, @ns
    vm.push_arg evaluator.evaluate args.car
  end

  def to_s
    "Builtin:eval"
  end
end
