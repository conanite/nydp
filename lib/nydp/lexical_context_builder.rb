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
    def set_args_1 lc, arg                 ; lc.at_0= arg      ; end
    def set_args_2 lc, arg_0, arg_1        ; lc.at_0= arg_0    ; end
    def set_args_3 lc, arg_0, arg_1, arg_2 ; lc.at_0= arg_0    ; end
    def set_args   lc, args                ; lc.at_0= args.car ; end
  end

  module B_2
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr.car
    end
    def set_args_1 lc, arg
      lc.at_0= arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.at_0= arg_0
      lc.at_1= arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.at_0= arg_0
      lc.at_1= arg_1
    end
    def set_args lc, args
      lc.at_0= args.car
      lc.at_1= args.cdr.car
    end
  end

  module B_3
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr.car
      @param_name_2 = names.cdr.cdr.car
    end
    def set_args_1 lc, arg
      lc.at_0= arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.at_0= arg_0
      lc.at_1= arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.at_0= arg_0
      lc.at_1= arg_1
      lc.at_2= arg_2
    end
    def set_args lc, args
      lc.at_0= args.car
      lc.at_1= args.cdr.car
      lc.at_2= args.cdr.cdr.car
    end
  end

  module B_0_Rest
    include Nydp::Helper
    def initialize_names names             ; @param_name = names                                       ; end
    def set_args_1 lc, arg                 ; lc.at_0= cons(arg)                             ; end
    def set_args_2 lc, arg_0, arg_1        ; lc.at_0= cons(arg_0, cons(arg_1))              ; end
    def set_args_3 lc, arg_0, arg_1, arg_2 ; lc.at_0= cons(arg_0, cons(arg_1, cons(arg_2))) ; end
    def set_args   lc, args                ; lc.at_0= args                                  ; end
  end

  module B_1_Rest
    include Nydp::Helper
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr
    end
    def set_args_1 lc, arg
      lc.at_0= arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.at_0= arg_0
      lc.at_1= cons(arg_1)
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.at_0= arg_0
      lc.at_1= cons(arg_1, cons(arg_2))
    end
    def set_args lc, args
      lc.at_0= args.car
      lc.at_1= args.cdr
    end
  end

  module B_2_Rest
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr.car
      @param_name_2 = names.cdr.cdr
    end
    def set_args_1 lc, arg
      lc.at_0= arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.at_0= arg_0
      lc.at_1= arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.at_0= arg_0
      lc.at_1= arg_1
      lc.at_2= cons(arg_2)
    end
    def set_args lc, args
      lc.at_0= args.car
      lc.at_1= args.cdr.car
      lc.at_2= args.cdr.cdr
    end
  end

  module B_3_Rest
    def initialize_names names
      @param_name_0 = names.car
      @param_name_1 = names.cdr.car
      @param_name_2 = names.cdr.cdr
    end
    def set_args_1 lc, arg
      lc.at_0= arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.at_0= arg_0
      lc.at_1= arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.at_0= arg_0
      lc.at_1= arg_1
      lc.at_2= arg_2
    end
    def set_args lc, args
      lc.at_0= args.car
      lc.at_1= args.cdr.car
      lc.at_2= args.cdr.cdr.car
      lc.at_3= args.cdr.cdr.cdr
    end
  end

  module B_X
    def initialize_names names
      @param_names = names
    end
    def set_args_1 lc, arg
      lc.at_0= arg
    end
    def set_args_2 lc, arg_0, arg_1
      lc.at_0= arg_0
      lc.at_1= arg_1
    end
    def set_args_3 lc, arg_0, arg_1, arg_2
      lc.at_0= arg_0
      lc.at_1= arg_1
      lc.at_2= arg_2
    end
    def set_args lc, args
      _set_args lc, @param_names, args, 0
    end
    def _set_args lc, names, args, index
      unless Nydp::NIL.is? names
        lc.set_index index, args.car
        _set_args lc, names.cdr, args.cdr, (index + 1)
      end
    end
  end

  module B_X_Rest
    include Nydp::Helper
    def initialize_names names             ; @param_names = names                               ; end
    def set_args_1 lc, arg                 ; set_args lc, cons(arg)                             ; end
    def set_args_2 lc, arg_0, arg_1        ; set_args lc, cons(arg_0, cons(arg_1))              ; end
    def set_args_3 lc, arg_0, arg_1, arg_2 ; set_args lc, cons(arg_0, cons(arg_1, cons(arg_2))) ; end
    def set_args lc, args                  ; _set_args lc, @param_names, args, 0                ; end
    def _set_args lc, names, args, index
      if pair? names
        lc.set_index index, args.car
        _set_args lc, names.cdr, args.cdr, (index + 1)
      elsif Nydp::NIL.isnt? names
        lc.set_index index, args
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
