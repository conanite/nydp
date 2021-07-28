
class Nydp::Builtin::Time
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  # when 0 arguments:
  #  return Time.now
  # when 1 argument:
  #  either an offset in seconds from now, or a Date to convert to a time, or a Time to subtract and return offset in seconds from now
  #  when Numeric : return now + offset in seconds from now
  #  when Nydp::Date : convert date to time
  #  when Time : calculate and return now - Time offset in seconds
  # when 2 arguments:
  #  first arg is a Time
  #  if second arg is numeric, add to first arg
  #  if second arg is a Time, subtract from first arg
  def builtin_call y=:unset, mo=:unset, d=:unset, h=nil, mi=nil, s=nil, ms=nil
    if y == :unset
      ::Time.now
    elsif mo == :unset
      case y
      when Numeric # relative time in seconds
        (Time.now + y)
      when ::Date
        y.to_time
      when ::Time
        ::Time.now - y
      else
        puts
        puts y.class
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
