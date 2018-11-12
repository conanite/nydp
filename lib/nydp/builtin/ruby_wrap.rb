class Nydp::Builtin::RubyWrap
  @@codes = { }

  class Coder < Struct.new(:name, :size, :code)
    def msize ; size + 1 ; end

    def arg_mapper
      case size
      when 0 ; ""
      when 1 ; ", a0"
      when 2 ; ", a0, a1"
      when 3 ; ", a0, a1, a2"
      when 4 ; ", a0, a1, a2, a3"
      else   ; raise "maximum 4 arguments!"
      end
    end

    def to_ruby
      generic_code = code.
                       gsub(/a0/, "args.car").
                       gsub(/a1/, "args.cdr.car").
                       gsub(/a2/, "args.cdr.cdr.car").
                       gsub(/a3/, "args.cdr.cdr.cdr.car")
      <<CODE
class #{name}
  include Nydp::Builtin::Base, Singleton

  def builtin_invoke_#{msize} vm#{ arg_mapper }
    vm.push_arg(#{code})
  end

  def builtin_invoke vm, args
    vm.push_arg(#{generic_code})
  end
end
CODE
    end
  end

  def self.const_missing const
    coder = @@codes[const]
    coder ? class_eval(coder.to_ruby) : super
    const_get const
  end

  def self.build name, args, code
    @@codes[name.to_sym] = Coder.new(name.to_sym, args, code)
  end

  build(:Cons, 2, %{ Nydp::Pair.new(a0, a1) })
  build(:Car , 1, %{ a0.car })
  build(:Cdr , 1, %{ a0.cdr })
end
