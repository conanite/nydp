class Nydp::Builtin::RandomString
  include Nydp::Builtin::Base, Singleton

  RANDOM_CHARS = ["A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","Y","Z","2","3","4","5","6","7","8","9"]

  def builtin_invoke vm, args
    length = args.car unless Nydp::NIL.is?(args)
    s = (0...(length || 10)).inject("") {|a,i| a << RANDOM_CHARS[rand(RANDOM_CHARS.size)] }
    vm.push_arg s
  end
end
