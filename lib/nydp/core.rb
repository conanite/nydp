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
      Symbol.mk(:cons         , ns).ns_assign(ns, Nydp::Builtin::RubyWrap::Cons.instance)
      Symbol.mk(:car          , ns).ns_assign(ns, Nydp::Builtin::RubyWrap::Car.instance )
      Symbol.mk(:cdr          , ns).ns_assign(ns, Nydp::Builtin::RubyWrap::Cdr.instance )
      Symbol.mk(:log          , ns).ns_assign(ns, Nydp::Builtin::RubyWrap::Log.instance )

      Symbol.mk(:+,     ns).ns_assign(ns, Nydp::Builtin::Plus.instance)
      Symbol.mk(:-,     ns).ns_assign(ns, Nydp::Builtin::Minus.instance)
      Symbol.mk(:*,     ns).ns_assign(ns, Nydp::Builtin::Times.instance)
      Symbol.mk(:/,     ns).ns_assign(ns, Nydp::Builtin::Divide.instance)
      Symbol.mk(:>,     ns).ns_assign(ns, Nydp::Builtin::GreaterThan.instance)
      Symbol.mk(:<,     ns).ns_assign(ns, Nydp::Builtin::LessThan.instance)
      Symbol.mk(:mod,   ns).ns_assign(ns, Nydp::Builtin::Modulo.instance)
      Symbol.mk(:eval,  ns).ns_assign(ns, Nydp::Builtin::Eval.instance)
      Symbol.mk(:false, ns).ns_assign(ns, false)
      Symbol.mk(:hash,  ns).ns_assign(ns, Nydp::Builtin::Hash.instance)
      Symbol.mk(:apply, ns).ns_assign(ns, Nydp::Builtin::Apply.instance)
      Symbol.mk(:date,  ns).ns_assign(ns, Nydp::Builtin::Date.instance)
      Symbol.mk(:error, ns).ns_assign(ns, Nydp::Builtin::Error.instance)
      Symbol.mk(:parse, ns).ns_assign(ns, Nydp::Builtin::Parse.instance)
      Symbol.mk(:p,     ns).ns_assign(ns, Nydp::Builtin::Puts.instance)
      Symbol.mk(:PI,    ns).assign 3.1415
      # Symbol.mk(:nil,   ns).assign Nydp::NIL
      Symbol.mk(:rand,  ns).ns_assign ns, Nydp::Builtin::Rand.instance
      Symbol.mk(:sort,  ns).ns_assign ns, Nydp::Builtin::Sort.instance
      Symbol.mk(:abs,   ns).ns_assign ns, Nydp::Builtin::Abs.instance
      Symbol.mk(:sqrt,  ns).ns_assign ns, Nydp::Builtin::Sqrt.instance
      # Symbol.mk(:t,     ns).assign Nydp::T
      Symbol.mk(:sym,   ns).assign Nydp::Builtin::Sym.instance
      Symbol.mk(:ensuring          , ns).ns_assign(ns, Nydp::Builtin::Ensuring.instance)
      Symbol.mk(:inspect           , ns).ns_assign(ns, Nydp::Builtin::Inspect.instance)
      Symbol.mk(:comment           , ns).ns_assign(ns, Nydp::Builtin::Comment.instance)
      Symbol.mk("handle-error"     , ns).ns_assign(ns, Nydp::Builtin::HandleError.instance)
      Symbol.mk("parse-in-string"  , ns).ns_assign(ns, Nydp::Builtin::ParseInString.instance)
      Symbol.mk("random-string"    , ns).ns_assign(ns, Nydp::Builtin::RandomString.instance)
      Symbol.mk("regexp"           , ns).ns_assign(ns, Nydp::Builtin::Regexp.instance)
      Symbol.mk("to-string"        , ns).ns_assign(ns, Nydp::Builtin::ToString.instance)
      Symbol.mk("to-integer"       , ns).ns_assign(ns, Nydp::Builtin::ToInteger.instance)
      Symbol.mk("string-length"    , ns).ns_assign(ns, Nydp::Builtin::StringLength.instance)
      Symbol.mk("string-replace"   , ns).ns_assign(ns, Nydp::Builtin::StringReplace.instance)
      Symbol.mk("string-match"     , ns).ns_assign(ns, Nydp::Builtin::StringMatch.instance)
      Symbol.mk("string-split"     , ns).ns_assign(ns, Nydp::Builtin::StringSplit.instance)
      Symbol.mk("string/pad-left"  , ns).ns_assign(ns, Nydp::Builtin::StringPadLeft.instance)
      Symbol.mk("string/pad-right" , ns).ns_assign(ns, Nydp::Builtin::StringPadRight.instance)
      Symbol.mk("time"             , ns).ns_assign(ns, Nydp::Builtin::Time.instance)
      Symbol.mk("thread-locals"    , ns).ns_assign(ns, Nydp::Builtin::ThreadLocals.instance)
      Symbol.mk("type-of"          , ns).ns_assign(ns, Nydp::Builtin::TypeOf.instance)
      Symbol.mk(:"eq?"             , ns).ns_assign(ns, Nydp::Builtin::IsEqual.instance)
      Symbol.mk(:"cdr-set"         , ns).ns_assign(ns, Nydp::Builtin::CdrSet.instance)
      Symbol.mk(:"hash-get"        , ns).ns_assign(ns, Nydp::Builtin::HashGet.instance)
      Symbol.mk(:"hash-set"        , ns).ns_assign(ns, Nydp::Builtin::HashSet.instance)
      Symbol.mk(:"hash-keys"       , ns).ns_assign(ns, Nydp::Builtin::HashKeys.instance)
      Symbol.mk(:"hash-key?"       , ns).ns_assign(ns, Nydp::Builtin::HashKeyPresent.instance)
      Symbol.mk(:"hash-merge"      , ns).ns_assign(ns, Nydp::Builtin::HashMerge.instance)
      Symbol.mk(:"hash-slice"      , ns).ns_assign(ns, Nydp::Builtin::HashSlice.instance)
      Symbol.mk(:"vm-info"         , ns).ns_assign ns, Nydp::Builtin::VmInfo.instance
      Symbol.mk(:"pre-compile"     , ns).ns_assign ns, Nydp::Builtin::PreCompile.instance
      Symbol.mk(:"script-run"      , ns).ns_assign ns, Nydp::Builtin::ScriptRun.instance
      Symbol.mk(:"**"              , ns).ns_assign ns, Nydp::Builtin::MathPower.instance
      Symbol.mk(:"⌊"               , ns).ns_assign ns, Nydp::Builtin::MathFloor.instance
      Symbol.mk(:"math-floor"      , ns).ns_assign ns, Nydp::Builtin::MathFloor.instance
      Symbol.mk(:"⌈"               , ns).ns_assign ns, Nydp::Builtin::MathCeiling.instance
      Symbol.mk(:"math-ceiling"    , ns).ns_assign ns, Nydp::Builtin::MathCeiling.instance
      Symbol.mk(:"math-round"      , ns).ns_assign ns, Nydp::Builtin::MathRound.instance
      Symbol.mk(:"⋂"               , ns).ns_assign ns, Nydp::Builtin::SetIntersection.instance
      Symbol.mk(:"set-intersection", ns).ns_assign ns, Nydp::Builtin::SetIntersection.instance
      Symbol.mk(:"⋃"               , ns).ns_assign ns, Nydp::Builtin::SetUnion.instance
      Symbol.mk(:"set-union"       , ns).ns_assign ns, Nydp::Builtin::SetUnion.instance

      # TODO this is for exploration purposes only, to be deleted
      Symbol.mk("compile-to-ruby"  , ns).ns_assign(ns, Nydp::Builtin::RubyWrap::CompileToRuby.instance)
    end
  end
end

Nydp.plug_in Nydp::Core.new
