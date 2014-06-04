class Nydp::Builtin::Error
  def invoke vm, args
    s = args.map { |a| a.to_s }
    puts s.join
    raise s
  end
end
