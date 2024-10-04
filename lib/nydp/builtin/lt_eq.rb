class Nydp::Builtin::LtEq
  include Nydp::Builtin::Base, Singleton

  def name ; "<=" ; end

  def builtin_call arg, *args
    while !args.empty?
      return nil unless arg && args.first && (arg <= args.first)
      arg = args.shift
    end
    return arg
  end
end
