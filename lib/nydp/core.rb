require 'nydp/plugin'

module Nydp
  class Core
    def name ; "Nydp Core" ; end

    def relative_path name
      File.join File.expand_path(File.dirname(__FILE__)), name
    end

    def base_path
      relative_path "../lisp/"
    end

    def load_rake_tasks
      load relative_path '../tasks/tests.rake'
    end

    def loadfiles
      Dir.glob(relative_path '../lisp/core-*.nydp').sort
    end

    def testfiles
      Dir.glob(relative_path '../lisp/tests/**/*.nydp')
    end

    def setup ns
      Symbol.mk(:cons         , ns).assign(Nydp::Builtin::RubyWrap::Cons.instance)
      Symbol.mk(:car          , ns).assign(Nydp::Builtin::RubyWrap::Car.instance )
      Symbol.mk(:cdr          , ns).assign(Nydp::Builtin::RubyWrap::Cdr.instance )
      Symbol.mk(:log          , ns).assign(Nydp::Builtin::RubyWrap::Log.instance )

      Symbol.mk(:+,     ns).assign(Nydp::Builtin::Plus.instance)
      Symbol.mk(:-,     ns).assign(Nydp::Builtin::Minus.instance)
      Symbol.mk(:*,     ns).assign(Nydp::Builtin::Times.instance)
      Symbol.mk(:/,     ns).assign(Nydp::Builtin::Divide.instance)
      Symbol.mk(:>,     ns).assign(Nydp::Builtin::GreaterThan.instance)
      Symbol.mk(:<,     ns).assign(Nydp::Builtin::LessThan.instance)
      Symbol.mk(:mod,   ns).assign(Nydp::Builtin::Modulo.instance)
      Symbol.mk(:eval,  ns).assign(Nydp::Builtin::Eval.instance)
      Symbol.mk(:false, ns).assign(false)
      Symbol.mk(:hash,  ns).assign(Nydp::Builtin::Hash.instance)
      Symbol.mk(:apply, ns).assign(Nydp::Builtin::Apply.instance)
      Symbol.mk(:date,  ns).assign(Nydp::Builtin::Date.instance)
      Symbol.mk(:error, ns).assign(Nydp::Builtin::Error.instance)
      Symbol.mk(:parse, ns).assign(Nydp::Builtin::Parse.instance)
      Symbol.mk(:p,     ns).assign(Nydp::Builtin::Puts.instance)
      Symbol.mk(:PI,    ns).assign 3.1415
      # Symbol.mk(:nil,   ns).assign Nydp::NIL
      Symbol.mk(:rand,  ns).assign Nydp::Builtin::Rand.instance
      Symbol.mk(:sort,  ns).assign Nydp::Builtin::Sort.instance
      Symbol.mk(:abs,   ns).assign Nydp::Builtin::Abs.instance
      Symbol.mk(:sqrt,  ns).assign Nydp::Builtin::Sqrt.instance
      # Symbol.mk(:t,     ns).assign Nydp::T
      Symbol.mk(:sym,   ns).assign Nydp::Builtin::Sym.instance
      Symbol.mk(:ensuring          , ns).assign(Nydp::Builtin::Ensuring.instance)
      Symbol.mk(:inspect           , ns).assign(Nydp::Builtin::Inspect.instance)
      Symbol.mk(:comment           , ns).assign(Nydp::Builtin::Comment.instance)
      Symbol.mk("handle-error"     , ns).assign(Nydp::Builtin::HandleError.instance)
      Symbol.mk("parse-in-string"  , ns).assign(Nydp::Builtin::ParseInString.instance)
      Symbol.mk("random-string"    , ns).assign(Nydp::Builtin::RandomString.instance)
      Symbol.mk("regexp"           , ns).assign(Nydp::Builtin::Regexp.instance)
      Symbol.mk("to-string"        , ns).assign(Nydp::Builtin::ToString.instance)
      Symbol.mk("to-integer"       , ns).assign(Nydp::Builtin::ToInteger.instance)
      Symbol.mk("string-length"    , ns).assign(Nydp::Builtin::StringLength.instance)
      Symbol.mk("string-replace"   , ns).assign(Nydp::Builtin::StringReplace.instance)
      Symbol.mk("string-match"     , ns).assign(Nydp::Builtin::StringMatch.instance)
      Symbol.mk("string-split"     , ns).assign(Nydp::Builtin::StringSplit.instance)
      Symbol.mk("string/pad-left"  , ns).assign(Nydp::Builtin::StringPadLeft.instance)
      Symbol.mk("string/pad-right" , ns).assign(Nydp::Builtin::StringPadRight.instance)
      Symbol.mk("time"             , ns).assign(Nydp::Builtin::Time.instance)
      Symbol.mk("thread-locals"    , ns).assign(Nydp::Builtin::ThreadLocals.instance)
      Symbol.mk("type-of"          , ns).assign(Nydp::Builtin::TypeOf.instance)
      Symbol.mk(:"eq?"             , ns).assign(Nydp::Builtin::IsEqual.instance)
      Symbol.mk(:"cdr-set"         , ns).assign(Nydp::Builtin::CdrSet.instance)
      Symbol.mk(:"hash-get"        , ns).assign(Nydp::Builtin::HashGet.instance)
      Symbol.mk(:"hash-set"        , ns).assign(Nydp::Builtin::HashSet.instance)
      Symbol.mk(:"hash-keys"       , ns).assign(Nydp::Builtin::HashKeys.instance)
      Symbol.mk(:"hash-key?"       , ns).assign(Nydp::Builtin::HashKeyPresent.instance)
      Symbol.mk(:"hash-merge"      , ns).assign(Nydp::Builtin::HashMerge.instance)
      Symbol.mk(:"hash-slice"      , ns).assign(Nydp::Builtin::HashSlice.instance)
      Symbol.mk(:"vm-info"         , ns).assign Nydp::Builtin::VmInfo.instance
      Symbol.mk(:"pre-compile"     , ns).assign Nydp::Builtin::PreCompile.instance
      Symbol.mk(:"script-run"      , ns).assign Nydp::Builtin::ScriptRun.instance
      Symbol.mk(:"**"              , ns).assign Nydp::Builtin::MathPower.instance
      Symbol.mk(:"⌊"               , ns).assign Nydp::Builtin::MathFloor.instance
      Symbol.mk(:"math-floor"      , ns).assign Nydp::Builtin::MathFloor.instance
      Symbol.mk(:"⌈"               , ns).assign Nydp::Builtin::MathCeiling.instance
      Symbol.mk(:"math-ceiling"    , ns).assign Nydp::Builtin::MathCeiling.instance
      Symbol.mk(:"math-round"      , ns).assign Nydp::Builtin::MathRound.instance
      Symbol.mk(:"⋂"               , ns).assign Nydp::Builtin::SetIntersection.instance
      Symbol.mk(:"set-intersection", ns).assign Nydp::Builtin::SetIntersection.instance
      Symbol.mk(:"⋃"               , ns).assign Nydp::Builtin::SetUnion.instance
      Symbol.mk(:"set-union"       , ns).assign Nydp::Builtin::SetUnion.instance
    end
  end
end

Nydp.plug_in Nydp::Core.new
