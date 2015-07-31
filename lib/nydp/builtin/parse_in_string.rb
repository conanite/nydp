class Nydp::Builtin::ParseInString
  include Nydp::Builtin::Base

  def initialize ns
    @parser = Nydp::Parser.new(ns)
  end

  def builtin_invoke vm, args
    tokens = Nydp::Tokeniser.new Nydp::StringReader.new args.car.to_s
    expr = @parser.string(tokens, "", :eof)
    vm.push_arg expr
  end
end
