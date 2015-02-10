class Nydp::Builtin::Error
  def invoke vm, args
    s = args.map { |a| a.to_s }
    raise Nydp::Error.new("#{args.inspect}\n\n#{vm.error}")
  end
end
