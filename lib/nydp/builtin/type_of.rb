class Nydp::Builtin::TypeOf
  include Nydp::Builtin::Base, Singleton

  def builtin_call arg
    if arg == nil
      nil
    elsif arg.respond_to?(:nydp_type)
      arg.nydp_type.to_sym
    elsif arg.is_a? Numeric
      :number
    else
      "ruby/#{arg.class.name}".to_sym
    end
  end
end
