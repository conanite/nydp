class Nydp::Cond
  attr_reader :cond, :when_true, :when_false

  def initialize cond, when_true, when_false
    @cond, @when_true, @when_false = cond, when_true, when_false
  end

  def lisp_apply
    if cond.lisp_apply != Nydp::NIL
      when_true.lisp_apply
    else
      when_false.lisp_apply
    end
  end

  def self.build expressions
    if expr.is_a? Pair
      cond = Compiler.compile expressions.car
      when_true = Compiler.compile expressions.cdr.car
      when_false = Compiler.compile expressions.cdr.cdr
      Nydp::Cond.new cond, when_true, when_false
    else
      raise "can't compile Cond: #{expr.inspect}"
    end
  end
end
