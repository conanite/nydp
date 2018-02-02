require "nydp/hash"

class Nydp::Builtin::Hash
  include Nydp::Helper, Nydp::Builtin::Base, Singleton
  def builtin_invoke vm, args
    vm.push_arg(Nydp::Hash.new)
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
