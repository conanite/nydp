class Nydp::Builtin::Plus
  include Nydp::Builtin::Base, Singleton

  def name ; "+" ; end

  def builtin_call *args
    if args.empty?
      0
    else
      case args.first
      when String
        args.each_with_object("") { |str, res| res << str.to_s }
      when Date
        (args.shift._nydp_date + builtin_call(*args)).to_ruby
      else
        args.reduce &:+
      end
    end._nydp_wrapper
  end
end
