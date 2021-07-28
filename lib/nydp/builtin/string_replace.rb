class Nydp::Builtin::StringReplace
  include Nydp::Builtin::Base, Singleton

  def builtin_call remove, insert, str
    str.to_s.to_s.gsub Regexp.new(remove.to_ruby), insert.to_ruby
  end
end
