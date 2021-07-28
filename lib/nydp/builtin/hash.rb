class Nydp::Builtin::Hash
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_call *args ; Hash[*args] ; end
end

class Nydp::Builtin::HashGet
  include Nydp::Helper, Nydp::Builtin::Base, Singleton
  def builtin_call hsh=nil, k=nil, *args
    hsh._nydp_get(k)._nydp_wrapper
  end
end

class Nydp::Builtin::HashSet
  include Nydp::Helper, Nydp::Builtin::Base, Singleton
  def builtin_call hsh, k, v=nil
    hsh._nydp_set(k, v)
    v
  end
end

class Nydp::Builtin::HashKeys
  include Nydp::Helper, Nydp::Builtin::Base, Singleton
  def builtin_call h
    h._nydp_keys._nydp_wrapper
  end
end

class Nydp::Builtin::HashKeyPresent
  include Nydp::Helper, Nydp::Builtin::Base, Singleton
  def name ; "hash-key?" ; end

  def builtin_call h, k
    h.key?(k) || nil
  end
end

class Nydp::Builtin::HashMerge
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_call a0, a1
    (a0.merge a1)._nydp_wrapper
  end
end

class Nydp::Builtin::HashSlice
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_call h, slice
    h.slice(*slice.to_a)
  end
end
