class Nydp::SymbolLookup
  attr_reader :expression

  def initialize expression
    @expression = expression
  end

  def execute vm
    vm.push_arg expression.value
  end

  def self.build expression
    new expression
  end

  def inspect
    "lookup_symbol:#{@expression.inspect}"
  end
end
