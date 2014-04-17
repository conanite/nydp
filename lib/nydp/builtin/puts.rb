class Nydp::Builtin::Puts
  def lisp_call args
    puts args.car
  end
end
