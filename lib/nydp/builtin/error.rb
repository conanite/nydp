class Nydp::Builtin::Error
  def invoke vm, args
    raise Nydp::Error.new(args.inspect)
  end
end
