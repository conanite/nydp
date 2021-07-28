class Nydp::Builtin::Plus
  include Nydp::Builtin::Base, Singleton

  def name ; "+" ; end

  def builtin_call *args
    if args == []
      0
    else
      case args.first
      when Nydp::Pair
        args.reduce &:+
      when String
        args.each_with_object("") { |str, res| res << str.to_s }
      when Date
        args.first._nydp_date + args[1]
      else
        args.reduce &:+
      end
    end._nydp_wrapper
  end
end
