class Nydp::Pair
  NIL = Nydp::NIL
  include Nydp::Helper, Enumerable
  extend Nydp::Helper

  attr_reader :car, :cdr

  def initialize car, cdr
    @car, @cdr = car, cdr
  end

  def nydp_type  ; :pair                                      ; end
  def caar       ; car.car                                    ; end
  def cadr       ; cdr.car                                    ; end
  def cdar       ; car.cdr                                    ; end
  def cddr       ; cdr.cdr                                    ; end
  def car= thing ; @car = thing                               ; end
  def cdr= thing ; @cdr = thing                               ; end
  def eql? other ; self == other                              ; end
  def +    other ; copy_append other                          ; end
  def size       ; 1 + (cdr.is_a?(Nydp::Pair) ? cdr.size : 0) ; end
  def inspect    ; "(#{inspect_rest})"                        ; end
  def []       i ; nth i                                      ; end
  def &    other ; self.class.from_list((Set.new(self) & Array(other)).to_a)    ; end
  def |    other ; self.class.from_list((Set.new(self) | Array(other)).to_a)    ; end
  def -    other ; self.class.from_list((Set.new(self) - Array(other)).to_a)    ; end
  def proper?    ; Nydp::NIL.is?(cdr) || (cdr.is_a?(Nydp::Pair) && cdr.proper?) ; end

  # def method_missing m, *args
  #   to_a.send m, *args
  # end

  # can't cache hash of symbol, breaks when unmarshalling
  def hash
    a    = 0
    x    = self
    while (x.is_a? Nydp::Pair)
      a = a + x.car.hash
      x = x.cdr
    end

    a + x.hash
  end

  def copy
    a    = last = cons
    x    = self
    while (x.is_a? Nydp::Pair)
      last = last.cdr = cons(x.car)
      x    = x.cdr
    end

    last.cdr = x
    a.cdr
  end

  def copy_append lastcdr
    a    = last = cons
    x    = self
    while (x.is_a? Nydp::Pair)
      last = last.cdr = cons(x.car)
      x    = x.cdr
    end

    last.cdr = lastcdr
    a.cdr
  end

  def cons_map
    a    = last = cons
    x    = self
    while x
      last = last.cdr = cons(yield x.car)
      x    = x.cdr
    end

    a.cdr
  end

  def compile_to_ruby indent, srcs, opts=nil
    a,x = [], self
    while x.is_a?(Nydp::Pair)
      a << x.car.compile_to_ruby("", srcs)
      x = x.cdr
    end

    if !x || (x.is_a?(Nydp::Literal) && !x.expression)
      "#{indent}Nydp::Pair.from_list([" + a.join(", ") + "])"

    else
      "#{indent}Nydp::Pair.from_list([" + a.join(", ") + "], #{x.compile_to_ruby "", srcs})"
    end
  end

  def nth n
    xs = self
    while n > 0
      xs, n = xs.cdr, n-1
    end
    xs.car
  end

  def index_of x
    if x == car
      0
    elsif pair?(cdr)
      1 + cdr.index_of(x)
    else
      nil
    end
  end

  # returns Array of elements after calling #n2r on each element
  def to_ruby list=[], pair=self
    list << n2r(pair.car)
    while(pair.cdr.is_a?(Nydp::Pair))
      pair = pair.cdr
      list << n2r(pair.car)
    end

    list
  end

  # returns Array of elements as they are
  def to_a list=[]
    x = self
    while x.is_a?(Nydp::Pair)
      list << x.car
      x = x.cdr
    end
    list
  end

  def self.parse_list list
    if list.slice(-2) == :"."
      from_list(list[0...-2], list.slice(-1))
    else
      from_list list
    end
  end

  def self.from_list list, last=Nydp::NIL, n=list.size-1
    while (n >= 0)
      last = cons(list[n], last)
      n -= 1
    end

    last
  end

  def == other
    (NIL != other) && (other.respond_to? :car) && (self.car == other.car) && (self.cdr == other.cdr)
  end

  def each &block
    xs = self
    while xs
      yield xs.car
      xs = xs.cdr
    end
  end

  def to_s
    if (car == nil)
      "nil"
    elsif car.is_a?(String)
      car.inspect
    elsif car.is_a?(Nydp::Fn)
      car.to_s
    elsif (car == :quote)
      if Nydp::NIL.is? cdr.cdr
        "'#{cdr.car.to_s}"
      else
        "'#{cdr.to_s}"
      end
    elsif (car == :"brace-list")
      if Nydp::NIL.is? cdr
        "{}"
      else
        "{ #{cdr.to_s_rest} }"
      end
    elsif (car == :quasiquote)
      if Nydp::NIL.is? cdr.cdr
        "`#{cdr.car.to_s}"
      else
        "`#{cdr.to_s}"
      end
    elsif (car == :unquote)
      if Nydp::NIL.is? cdr.cdr
        ",#{cdr.car.to_s}"
      else
        ",#{cdr.to_s}"
      end
    elsif (car == :"unquote-splicing")
      if Nydp::NIL.is? cdr.cdr
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
            elsif Nydp::NIL.is? cdr
              nil
            else
              ". #{cdr.to_s}"
            end

    [car.to_s, cdr_s].compact.join " "
  end

  def inspect_rest
    res = [car._nydp_inspect]
    it = cdr
    while it && it != Nydp::NIL
      if it.is_a?(self.class)
        res << it.car._nydp_inspect
        it = it.cdr
      else
        res << "."
        res << it._nydp_inspect
        it = nil
      end
    end
    res.compact.join " "
  end

  # def append thing
  #   if Nydp::NIL.is? self.cdr
  #     self.cdr = thing
  #   elsif pair? self.cdr
  #     self.cdr.append thing
  #   else
  #     raise "can't append #{thing} to list #{self} : cdr is #{self.cdr._nydp_inspect}"
  #   end
  #   self
  # end
end
