class Nydp::Pair
  include Nydp::Helper, Enumerable
  extend Nydp::Helper

  attr_accessor :car, :cdr

  def initialize car, cdr
    @car, @cdr = car, cdr
  end

  def self.mk a, b
    new a, b
  end

  def nydp_type ; :pair   ; end
  def caar      ; car.car ; end
  def cadr      ; cdr.car ; end
  def cdar      ; car.cdr ; end
  def cddr      ; cdr.cdr ; end

  def to_ruby list=[]
    list << n2r(car)
    cdr.is_a?(Nydp::Pair) ? cdr.to_ruby(list) : list
  end

  def self.parse_list list
    if sym? list.slice(-2), "."
      from_list(list[0...-2], list.slice(-1))
    else
      from_list list
    end
  end

  def self.from_list list, last=Nydp.NIL, n=0
    if n >= list.size
      last
    else
      mk list[n], from_list(list, last, n+1)
    end
  end

  def copy
    cons(car, cdr.copy)
  end

  def + other
    copy.append other
  end

  def == other
    (other.respond_to? :car) && (self.car == other.car) && (self.cdr == other.cdr)
  end

  def size
    1 + (cdr.is_a?(Nydp::Pair) ? cdr.size : 0)
  end

  def proper?
    Nydp.NIL.is?(cdr) || (cdr.is_a?(Nydp::Pair) && cdr.proper?)
  end

  def each &block
    yield car
    cdr.each(&block) unless Nydp.NIL.is?(cdr)
  end

  def inspect
    "(#{inspect_rest})"
  end

  def to_s
    if car.is_a?(Nydp::Symbol) && car.is?(:quote)
      if Nydp.NIL.is? cdr.cdr
        "'#{cdr.car.to_s}"
      else
        "'#{cdr.to_s}"
      end
    elsif car.is_a?(Nydp::Symbol) && car.is?(:"brace-list")
      if Nydp.NIL.is? cdr.cdr
        "{}"
      else
        "{ #{cdr.to_s_rest} }"
      end
    elsif car.is_a?(Nydp::Symbol) && car.is?(:quasiquote)
      if Nydp.NIL.is? cdr.cdr
        "`#{cdr.car.to_s}"
      else
        "`#{cdr.to_s}"
      end
    elsif car.is_a?(Nydp::Symbol) && car.is?(:unquote)
      if Nydp.NIL.is? cdr.cdr
        ",#{cdr.car.to_s}"
      else
        ",#{cdr.to_s}"
      end
    elsif car.is_a?(Nydp::Symbol) && car.is?(:"unquote-splicing")
      if Nydp.NIL.is? cdr.cdr
        ",@#{cdr.car.to_s}"
      else
        ",@#{cdr.to_s}"
      end
    else
      "(#{to_s_rest})"
    end
  end

  def to_s_rest
    cdr_s = if cdr.is_a?(self.class)
              cdr.to_s_rest
            elsif Nydp.NIL.is? cdr
              nil
            else
              ". #{cdr.to_s}"
            end

    [car.to_s, cdr_s].compact.join " "
  end

  def inspect_rest
    cdr_s = if cdr.is_a?(self.class)
              cdr.inspect_rest
            elsif cdr == Nydp.NIL
              nil
            else
              ". #{cdr.inspect}"
            end

    [car.inspect, cdr_s].compact.join " "
  end

  def append thing
    if Nydp.NIL.is? self.cdr
      self.cdr = thing
    elsif pair? self.cdr
      self.cdr.append thing
    else
      raise "can't append #{thing} to list #{self} : cdr is #{self.cdr.inspect}"
    end
    self
  end

  def repush instructions, _
    instructions.push self
  end

end
