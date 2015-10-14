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
    hsh = args.car
    key = args.cdr.car
    case hsh
    when Nydp::Hash
      vm.push_arg(hsh[key] || Nydp.NIL)
    when NilClass, Nydp.NIL
      vm.push_arg Nydp.NIL
    else
      v = hsh.respond_to?(:[]) ? hsh[n2r key] : ruby_call(hsh, key)
      vm.push_arg(r2n v, ns)
    end
  end

  def ruby_call obj, method_name
    if obj.respond_to? :_nydp_safe_methods
      m       = n2r(method_name).to_s.to_sym
      allowed = obj._nydp_safe_methods

      obj.send n2r(m) if allowed.include?(m)
    else
      raise "hash-get: Not a hash: #{obj.class.name}"
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
    when NilClass, Nydp.NIL
      nil
    else
      if hash.respond_to?(:[]=)
        hash[n2r key] = n2r value
      else
        raise "hash-set: Not a hash: #{hash.class.name}"
      end
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

class Nydp::Builtin::HashKeyPresent
  include Nydp::Helper, Nydp::Builtin::Base
  attr_accessor :ns
  def initialize ns ; @ns = ns; end
  def builtin_invoke vm, args
    hash = args.car
    key  = args.cdr.car
    truth = case hash
            when Nydp::Hash
              hash.key? key
            else
              hash.key? n2r key
            end
    vm.push_arg(truth ? Nydp.T : Nydp.NIL)
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
