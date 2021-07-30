class Nydp::Builtin::Eval
  include Nydp::Builtin::Base

  def initialize ns
    @ns = ns
    super()
  end

  def builtin_call *args
    evaluator = Nydp::Evaluator.new @ns, "<eval>"
    evaluator.evaluate args.first
  end
end
