class Nydp::Builtin::RandomString
  include Nydp::Builtin::Base

  @@random_chars = ["A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","Y","Z","2","3","4","5","6","7","8","9"]

  def builtin_invoke vm, args
    length = args.car unless Nydp.NIL.is?(args)
    s = (0...(length || 10)).map { @@random_chars[rand(@@random_chars.size)] }.join
    vm.push_arg Nydp::StringAtom.new s
  end
end
