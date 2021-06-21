class Nydp::Builtin::Parse
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    parser = Nydp.new_parser(vm.ns)
    tokens = Nydp.new_tokeniser Nydp::StringReader.new args.car.to_s
    exprs  = []
    while !tokens.finished
      expr = parser.expression(tokens)
      exprs << expr unless expr == nil && tokens.finished
    end
    vm.push_arg Nydp::Pair.from_list exprs
  end
end
