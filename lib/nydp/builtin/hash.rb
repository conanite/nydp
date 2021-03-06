require "nydp/hash"

class Nydp::Builtin::Hash
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    vm.push_arg(build_hash Nydp::Hash.new, args)
  end

  def build_hash h, args
    return h if Nydp::NIL.is? args
    k = args.car
    rest = args.cdr
    v = rest.car
    h[k] = v
    build_hash h, rest.cdr
  end
end

class Nydp::Builtin::HashGet
  include Nydp::Helper, Nydp::Builtin::Base, Singleton
  def builtin_invoke vm, args
    vm.push_arg(args.car._nydp_get(args.cdr.car)._nydp_wrapper || Nydp::NIL)
  end
end

class Nydp::Builtin::HashSet
  include Nydp::Helper, Nydp::Builtin::Base, Singleton
  def builtin_invoke vm, args
    value = args.cdr.cdr.car
    args.car._nydp_set(args.cdr.car, value)
    vm.push_arg value
  end
end

class Nydp::Builtin::HashKeys
  include Nydp::Helper, Nydp::Builtin::Base, Singleton
  def builtin_invoke vm, args
    vm.push_arg args.car._nydp_keys._nydp_wrapper
  end
end

class Nydp::Builtin::HashKeyPresent
  include Nydp::Helper, Nydp::Builtin::Base, Singleton
  def builtin_invoke vm, args
    hash = args.car
    key  = args.cdr.car
    truth = case hash
            when Nydp::Hash
              hash.key? key
            else
              hash.key? n2r key
            end
    vm.push_arg(truth ? Nydp::T : Nydp::NIL)
  end
  def name ; "hash-key?" ; end
end

class Nydp::Builtin::HashMerge
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    hash_0 = args.car
    hash_1 = args.cdr.car

    vm.push_arg hash_0.merge hash_1
  end
end

class Nydp::Builtin::HashSlice
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke vm, args
    old   = args.car
    h     = old.class.new
    slice = args.cdr.car
    slice = slice.map { |k| n2r k } unless old.is_a? Nydp::Hash
    slice.each { |k| h[k] = old[k] if old.key?(k) }
    vm.push_arg h
  end
end
