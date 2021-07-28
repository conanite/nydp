class Nydp::Builtin::Date
  include Nydp::Helper, Nydp::Builtin::Base, Singleton

  def builtin_call y=:unset, m=:unset, d=:unset
    if y == :unset
      Date.today
    elsif m == :unset
      if y.respond_to?(:to_date)
        y.to_date
      elsif y.is_a?(String)
        ::Date.parse(y)
      end
    else
      Date.new(y,m,d)
    end
  end
end
