class Nydp::Builtin::StringReplace
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    to_remove = Regexp.new args.car.to_ruby
    to_insert = args.cdr.car.to_ruby
    target    = args.cdr.cdr.car.to_s
    result    = target.to_s.gsub to_remove, to_insert

    result
  end
end
