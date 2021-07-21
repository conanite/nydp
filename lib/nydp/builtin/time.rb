
class Nydp::Builtin::Time
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_invoke_1 vm
    ::Time.now
  end

  # either an offset in seconds from now, or a Date to convert to a time, or a Time to subtract and return offset in seconds from now
  # when Numeric : return now + offset in seconds from now
  # when Nydp::Date : convert date to time
  # when Time : calculate and return now - Time offset in seconds
  def builtin_invoke_2 vm, arg
    case arg
    when Numeric # relative time in seconds
      (Time.now + arg)
    when Nydp::Date
      arg.to_ruby.to_time
    when ::Time
      ::Time.now - arg
    else
      raise Nydp::Error.new "time : expected a number or a date or a time, got #{arg._nydp_inspect}"
    end
  end

  # first arg is a Time
  # if second arg is numeric, add to first arg
  # if second arg is a Time, subtract from first arg
  def builtin_invoke_3 vm, a0, a1
    case a1
    when Numeric # relative time in seconds
      (a0 + a1)
    when ::Time
       a0 - a1
    else
      raise Nydp::Error.new "time : expected a number or a date, got #{a1._nydp_inspect}"
    end
  end

  def builtin_invoke vm, args
    # assume ruby Time constructor args y mo d h mi s ms
    y  = args.car
    mo = args.cdr.car
    d  = args.cdr.cdr.car
    h  = args.cdr.cdr.cdr.car             if args.size > 3
    mi = args.cdr.cdr.cdr.cdr.car         if args.size > 4
    s  = args.cdr.cdr.cdr.cdr.cdr.car     if args.size > 5
    ms = args.cdr.cdr.cdr.cdr.cdr.cdr.car if args.size > 6

    (Time.new(y,mo,d,h,mi,s,ms))
  end

  def builtin_call y=:unset, mo=:unset, d=:unset, h=nil, mi=nil, s=nil, ms=nil
    if y == :unset
      ::Time.now
    elsif mo == :unseet
      case y
      when Numeric # relative time in seconds
        (Time.now + y)
      when Nydp::Date
        y.to_ruby.to_time
      when ::Time
        ::Time.now - y
      else
        raise Nydp::Error.new "time : expected a number or a date or a time, got #{y._nydp_inspect}"
      end
    elsif d == :unset
      # y is a date or time, mo is a number or time
      case mo
      when Numeric # relative time in seconds
        (y + mo)
      when ::Time
        y - mo
      else
        raise Nydp::Error.new "time : expected a number or a date, got #{mo._nydp_inspect}"
      end
    else
      Time.new(y,mo,d,h,mi,s,ms)
    end
  end
end
