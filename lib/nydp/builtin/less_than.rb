class Nydp::Builtin::LessThan
  include Nydp::Builtin::Base, Singleton

  def builtin_call arg, *args
    while !args.empty?
      return nil unless args.first && (arg < args.first)
      arg = args.shift
    end
    return arg
  end

  def name ; "<" ; end
end
