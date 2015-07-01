require 'nydp'

module Nydp
  class Core
    def name ; "Nydp Core" ; end

    def relative_path name
      File.join File.expand_path(File.dirname(__FILE__)), name
    end

    def load_rake_tasks
      load relative_path '../tasks/tests.rake'
    end

    def loadfiles
      b = relative_path('../lisp/boot.nydp')
      t = relative_path('../lisp/test-runner.nydp')
      [b,t]
    end

    def testfiles
      Dir.glob(relative_path '../lisp/tests/**/*.nydp')
    end

    def setup ns
      Symbol.mk(:cons,  ns).assign(Nydp::Builtin::Cons.new)
      Symbol.mk(:car,   ns).assign(Nydp::Builtin::Car.new)
      Symbol.mk(:cdr,   ns).assign(Nydp::Builtin::Cdr.new)
      Symbol.mk(:+,     ns).assign(Nydp::Builtin::Plus.new)
      Symbol.mk(:-,     ns).assign(Nydp::Builtin::Minus.new)
      Symbol.mk(:*,     ns).assign(Nydp::Builtin::Times.new)
      Symbol.mk(:/,     ns).assign(Nydp::Builtin::Divide.new)
      Symbol.mk(:>,     ns).assign(Nydp::Builtin::GreaterThan.new)
      Symbol.mk(:<,     ns).assign(Nydp::Builtin::LessThan.new)
      Symbol.mk(:eval,  ns).assign(Nydp::Builtin::Eval.new(ns))
      Symbol.mk(:hash,  ns).assign(Nydp::Builtin::Hash.new)
      Symbol.mk(:apply, ns).assign(Nydp::Builtin::Apply.new)
      Symbol.mk(:error, ns).assign(Nydp::Builtin::Error.new)
      Symbol.mk(:quit,  ns).assign(Nydp::Builtin::Quit.new)
      Symbol.mk(:parse, ns).assign(Nydp::Builtin::Parse.new(ns))
      Symbol.mk(:p,     ns).assign(Nydp::Builtin::Puts.new)
      Symbol.mk(:PI,    ns).assign Literal.new(3.1415)
      Symbol.mk(:nil,   ns).assign Nydp.NIL
      Symbol.mk(:sqrt,  ns).assign Nydp::Builtin::Sqrt.new
      Symbol.mk(:t,     ns).assign Nydp.T
      Symbol.mk(:sym,   ns).assign Nydp::Builtin::ToSym.new(ns)
      Symbol.mk(:ensuring,      ns).assign(Nydp::Builtin::Ensuring.new)
      Symbol.mk(:inspect,       ns).assign(Nydp::Builtin::Inspect.new)
      Symbol.mk(:comment,       ns).assign(Nydp::Builtin::Comment.new)
      Symbol.mk(:millisecs,     ns).assign(Nydp::Builtin::Millisecs.new)
      Symbol.mk("load-tests",   ns).assign(Nydp::Builtin::LoadTests.new(ns))
      Symbol.mk("handle-error"   , ns).assign(Nydp::Builtin::HandleError.new)
      Symbol.mk("parse-in-string", ns).assign(Nydp::Builtin::ParseInString.new(ns))
      Symbol.mk("random-string"  , ns).assign(Nydp::Builtin::RandomString.new)
      Symbol.mk("to-string"      , ns).assign(Nydp::Builtin::ToString.new)
      Symbol.mk("string-length"  , ns).assign(Nydp::Builtin::StringLength.new)
      Symbol.mk("string-replace" , ns).assign(Nydp::Builtin::StringReplace.new)
      Symbol.mk("string-split"   , ns).assign(Nydp::Builtin::StringSplit.new  )
      Symbol.mk("thread-locals"  , ns).assign(Nydp::Builtin::ThreadLocals.new)
      Symbol.mk("type-of",      ns).assign(Nydp::Builtin::TypeOf.new(ns))
      Symbol.mk(:"eq?",         ns).assign(Nydp::Builtin::IsEqual.new)
      Symbol.mk(:"pair?",       ns).assign(Nydp::Builtin::IsPair.new)
      Symbol.mk(:"cdr-set",     ns).assign(Nydp::Builtin::CdrSet.new)
      Symbol.mk(:"hash-get",    ns).assign(Nydp::Builtin::HashGet.new ns)
      Symbol.mk(:"hash-set",    ns).assign(Nydp::Builtin::HashSet.new)
      Symbol.mk(:"hash-keys",   ns).assign(Nydp::Builtin::HashKeys.new(ns))
      Symbol.mk(:"vm-info",     ns).assign Nydp::Builtin::VmInfo.new
      Symbol.mk(:"pre-compile", ns).assign Nydp::Builtin::PreCompile.new
    end
  end
end

Nydp.plug_in Nydp::Core.new
