class Nydp::InterpretedFunction
  extend Helper

  attr_accessor :args, :body

  def self.build arg_list, body
    ifn = Nydp::InterpretedFunction.new
    ifn.args = arg_list
    ifn.body = Nydp::Compiler.compile_each body
    ifn
  end


  def self.index_parameters arg_list, hsh
    return if Nydp::NIL.is?(arg_list)

    if pair? arg_list
      index_parameters arg_list.car, hsh
      index_parameters arg_list.cdr, hsh
    else
      hsh[arg_list] = hsh.size
    end
  end
end
