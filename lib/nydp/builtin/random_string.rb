class Nydp::Builtin::RandomString
  @@random_chars = ["A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","Y","Z","2","3","4","5","6","7","8","9"]

  def invoke vm, args
    s = ""
    1.upto(10) {
      s << @@random_chars[rand(@@random_chars.size)]
    }
    Nydp::StringAtom.new s
  end
end
