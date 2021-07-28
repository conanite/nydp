class Nydp::Builtin::StringSplit
  include Nydp::Builtin::Base, Singleton

  def builtin_call str, sep=nil
    sep = sep.to_s unless sep.is_a? Regexp
    Nydp::Pair.from_list str.to_s.split(sep, -1)
  end
end
