class Nydp::Builtin::StringSplit
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    target    = args.car.to_s
    separator = args.cdr.car
    separator = separator.to_s unless separator.is_a? Regexp

    result    = target.split separator, -1

    Nydp::Pair.from_list result
  end

  def builtin_call str, sep=nil
    sep = sep.to_s unless sep.is_a? Regexp
    Nydp::Pair.from_list str.to_s.split(sep, -1)
  end
end
