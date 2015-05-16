class Nydp::Builtin::Parse
  def initialize ns
    @parser = Nydp::Parser.new(ns)
  end

  def invoke vm, args
    tokens = Nydp::Tokeniser.new Nydp::StringReader.new args.car.to_s
    exprs  = []
    while !tokens.finished
      expr = @parser.expression(tokens)
      exprs << expr unless expr == nil
    end
    vm.push_arg Nydp::Pair.from_list exprs
  end
end
