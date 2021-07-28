class Nydp::Builtin::ParseInString
  include Nydp::Builtin::Base, Singleton

  def builtin_call arg
    parser = Nydp.new_parser
    tokens = Nydp.new_tokeniser Nydp::StringReader.new arg.to_s
    parser.embedded(tokens)
  rescue StandardError => e
    new_msg = "parse error: #{e.message._nydp_inspect} in\n#{Nydp.indent_text arg.to_s}"
    raise Nydp::Error.new new_msg
  end
end
