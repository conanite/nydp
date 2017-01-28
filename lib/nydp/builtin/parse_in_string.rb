class Nydp::Builtin::ParseInString
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    parser = Nydp::Parser.new(vm.ns)
    parsable = args.car.to_s
    tokens = Nydp::Tokeniser.new Nydp::StringReader.new parsable
    expr = parser.string(tokens, "", :eof)
    vm.push_arg expr
  rescue StandardError => e
    new_msg = "parse error: #{e.message.inspect} in\n#{Nydp.indent_text parsable}"
    raise Nydp::Error.new new_msg
  end
end
