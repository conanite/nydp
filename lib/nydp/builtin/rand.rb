class Nydp::Builtin::Rand
  include Nydp::Builtin::Base, Singleton

  def builtin_call a0=nil, a1=nil
    if a0 == nil
      rand
    elsif a1 == nil
      rand(a0)
    else
      (a0 + rand(a1 - a0))
    end
  end
end
