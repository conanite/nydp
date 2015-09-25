class Nydp::Builtin::ParseInString
  include Nydp::Builtin::Base

  def initialize ns
    @parser = Nydp::Parser.new(ns)
  end

  def builtin_invoke vm, args
    parsable = args.car.to_s
    tokens = Nydp::Tokeniser.new Nydp::StringReader.new parsable
    expr = @parser.string(tokens, "", :eof)
    vm.push_arg expr
  rescue Exception => e
    new_msg = "parse error: #{e.message.inspect} in\n#{Nydp.indent_text parsable}"
    raise Nydp::Error.new new_msg
  end
end
