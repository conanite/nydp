class Nydp::Builtin::ParseInString
  include Nydp::Builtin::Base

  def initialize ns
    @ns = ns
    super()
  end

  def builtin_invoke vm, args
    parser = Nydp.new_parser(vm.ns)
    parsable = args.car.to_s
    tokens = Nydp.new_tokeniser Nydp::StringReader.new parsable
    expr = parser.embedded(tokens)
    # vm.push_arg expr
    expr
  rescue StandardError => e
    new_msg = "parse error: #{e.message._nydp_inspect} in\n#{Nydp.indent_text parsable}"
    raise Nydp::Error.new new_msg
  end

  def builtin_call arg
    parser = Nydp.new_parser(@ns)
    tokens = Nydp.new_tokeniser Nydp::StringReader.new arg.to_s
    parser.embedded(tokens)
  rescue StandardError => e
    new_msg = "parse error: #{e.message._nydp_inspect} in\n#{Nydp.indent_text arg.to_s}"
    raise Nydp::Error.new new_msg
  end
end
