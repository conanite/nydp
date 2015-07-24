require "nydp/hash"

class Nydp::Builtin::Hash
  include Nydp::Helper, Nydp::Builtin::Base
  def builtin_invoke vm, args
    vm.push_arg(Nydp::Hash.new)
  end
end

class Nydp::Builtin::HashGet
  include Nydp::Helper, Nydp::Builtin::Base
  attr_accessor :ns
  def initialize ns ; @ns = ns; end
  def builtin_invoke vm, args
    hash = args.car
    key = args.cdr.car
    case hash
    when Nydp::Hash
      vm.push_arg(hash[key] || Nydp.NIL)
    else
      key = n2r args.cdr.car
      vm.push_arg(r2n hash[key], ns)
    end
  end
end

class Nydp::Builtin::HashSet
  include Nydp::Helper, Nydp::Builtin::Base
  def builtin_invoke vm, args
    hash = args.car
    key = args.cdr.car
    value = args.cdr.cdr.car
    case hash
    when Nydp::Hash
      hash[key] = value
    else
      hash[n2r key] = n2r value
    end
    vm.push_arg value
  end
end

class Nydp::Builtin::HashKeys
  include Nydp::Helper, Nydp::Builtin::Base
  attr_accessor :ns
  def initialize ns ; @ns = ns; end
  def builtin_invoke vm, args
    hash = args.car
    case hash
    when Nydp::Hash
      vm.push_arg Nydp::Pair.from_list hash.keys
    else
      vm.push_arg r2n(hash.keys, ns)
    end
  end
end

class Nydp::Builtin::HashMerge
  include Nydp::Helper, Nydp::Builtin::Base

  def builtin_invoke vm, args
    hash_0 = args.car
    hash_1 = args.cdr.car

    vm.push_arg hash_0.merge hash_1
  end
end
