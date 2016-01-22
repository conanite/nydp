module Nydp::LexicalContextBuilder
  extend Nydp::Helper

  module B_0
    def initialize_names _           ; end
    def set_args_1 lc, a             ; end
    def set_args_2 lc, a_0, a_1      ; end
    def set_args_3 lc, a_0, a_1, a_2 ; end
    def set_args   lc, args          ; end
  end

  module B_1
    def initialize_names names             ; @param_name = names.car      ; end
    def set_args_1 lc, arg                 ; lc.set @param_name, arg      ; end
    def set_args_2 lc, arg_0, arg_1        ; lc.set @param_name, arg_0    ; end
    def set_args_3 lc, arg_0, arg_1, arg_2 ; lc.set @param_name, arg_0    ; end
    def set_args   lc, args                ; lc.set @param_name, args.car ; end
  end

  module B_2
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr.car
    end
    def set_args_1 lc, arg
      lc.set @param_name_0, arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, arg_1
    end
    def set_args lc, args
      lc.set @param_name_0, args.car
      lc.set @param_name_1, args.cdr.car
    end
  end

  module B_3
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr.car
      @param_name_2 = names.cdr.cdr.car
    end
    def set_args_1 lc, arg
      lc.set @param_name_0, arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, arg_1
      lc.set @param_name_2, arg_2
    end
    def set_args lc, args
      lc.set @param_name_0, args.car
      lc.set @param_name_1, args.cdr.car
      lc.set @param_name_2, args.cdr.cdr.car
    end
  end

  module B_0_Rest
    include Nydp::Helper
    def initialize_names names             ; @param_name = names                                       ; end
    def set_args_1 lc, arg                 ; lc.set @param_name, cons(arg)                             ; end
    def set_args_2 lc, arg_0, arg_1        ; lc.set @param_name, cons(arg_0, cons(arg_1))              ; end
    def set_args_3 lc, arg_0, arg_1, arg_2 ; lc.set @param_name, cons(arg_0, cons(arg_1, cons(arg_2))) ; end
    def set_args   lc, args                ; lc.set @param_name, args                                  ; end
  end

  module B_1_Rest
    include Nydp::Helper
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr
    end
    def set_args_1 lc, arg
      lc.set @param_name_0, arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, cons(arg_1)
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, cons(arg_1, cons(arg_2))
    end
    def set_args lc, args
      lc.set @param_name_0, args.car
      lc.set @param_name_1, args.cdr
    end
  end

  module B_2_Rest
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr.car
      @param_name_2 = names.cdr.cdr
    end
    def set_args_1 lc, arg
      lc.set @param_name_0, arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, arg_1
      lc.set @param_name_2, cons(arg_2)
    end
    def set_args lc, args
      lc.set @param_name_0, args.car
      lc.set @param_name_1, args.cdr.car
      lc.set @param_name_2, args.cdr.cdr
    end
  end

  module B_3_Rest
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr.car
      @param_name_2 = names.cdr.cdr
    end
    def set_args_1 lc, arg
      lc.set @param_name_0, arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.set @param_name_0, arg_0
      lc.set @param_name_1, arg_1
      lc.set @param_name_2, arg_2
    end
    def set_args lc, args
      lc.set @param_name_0, args.car
      lc.set @param_name_1, args.cdr.car
      lc.set @param_name_2, args.cdr.cdr.car
      lc.set @param_name_3, args.cdr.cdr.cdr
    end
  end

  module B_X
    def initialize_names names
      @param_names = names
    end
    def set_args_1 lc, arg
      lc.set @param_names.car, arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.set @param_names.car,     arg_0
      lc.set @param_names.cdr.car, arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.set @param_names.car,         arg_0
      lc.set @param_names.cdr.car,     arg_1
      lc.set @param_names.cdr.cdr.car, arg_2
    end
    def set_args lc, args
      _set_args lc, @param_names, args
    end
    def _set_args lc, names, args
      unless Nydp.NIL.is? names
        lc.set names.car, args.car
        _set_args lc, names.cdr, args.cdr
      end
    end
  end

  module B_X_Rest
    include Nydp::Helper
    def initialize_names names             ; @param_names = names                               ; end
    def set_args_1 lc, arg                 ; set_args lc, cons(arg)                             ; end
    def set_args_2 lc, arg_0, arg_1        ; set_args lc, cons(arg_0, cons(arg_1))              ; end
    def set_args_3 lc, arg_0, arg_1, arg_2 ; set_args lc, cons(arg_0, cons(arg_1, cons(arg_2))) ; end
    def set_args lc, args                  ; _set_args lc, @param_names, args                   ; end
    def _set_args lc, names, args
      if pair? names
        lc.set names.car, args.car
        _set_args lc, names.cdr, args.cdr
      elsif Nydp.NIL.isnt? names
        lc.set names, args
      end
    end
  end

  def self.select arg_names
    if pair? arg_names
      size = pair?(arg_names) ? arg_names.size : 0
      class_name = "B_#{size > 3 ? "X" : size}#{arg_names.proper? ? "" : "_Rest"}"
    else
      class_name = "B_0_Rest"
    end
    self.const_get(class_name.to_sym)
  end
end
