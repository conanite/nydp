class Nydp::Builtin::Parse
  include Nydp::Builtin::Base

  def initialize ns
    @parser = Nydp::Parser.new(ns)
  end

  def builtin_invoke vm, args
    tokens = Nydp::Tokeniser.new Nydp::StringReader.new args.car.to_s
    exprs  = []
    while !tokens.finished
      expr = @parser.expression(tokens)
      exprs << expr unless expr == nil
    end
    vm.push_arg Nydp::Pair.from_list exprs
  end
end
