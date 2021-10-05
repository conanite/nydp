require 'nydp/plugin'

module Nydp
  class Core
    include Nydp::PluginHelper

    def name ; "Nydp Core" ; end

    def base_path
      relative_path "../lisp/"
    end

    def load_rake_tasks
      load relative_path '../tasks/tests.rake'
    end

    def loadfiles
      file_readers Dir.glob(relative_path '../lisp/core-*.nydp').sort
    end

    def testfiles
      file_readers Dir.glob(relative_path '../lisp/tests/**/*.nydp')
    end

    def setup ns
      ns.assign(:cons              , Nydp::Builtin::RubyWrap::Cons.instance          )
      ns.assign(:car               , Nydp::Builtin::RubyWrap::Car.instance           )
      ns.assign(:cdr               , Nydp::Builtin::RubyWrap::Cdr.instance           )
      ns.assign(:log               , Nydp::Builtin::Log.instance                     )
      ns.assign(:ln                , Nydp::Builtin::RubyWrap::Ln.instance            )
      ns.assign(:mod               , Nydp::Builtin::RubyWrap::Modulo.instance        )
      ns.assign(:sqrt              , Nydp::Builtin::RubyWrap::Sqrt.instance          )
      ns.assign(:regexp            , Nydp::Builtin::RubyWrap::Regexp.instance        )
      ns.assign("string/pad-left"  , Nydp::Builtin::RubyWrap::StringPadLeft.instance )
      ns.assign("string/pad-right" , Nydp::Builtin::RubyWrap::StringPadRight.instance)
      ns.assign("to-list"          , Nydp::Builtin::RubyWrap::ToList.instance        )
      ns.assign(:+                 , Nydp::Builtin::Plus.instance                    )
      ns.assign(:-                 , Nydp::Builtin::Minus.instance                   )
      ns.assign(:*                 , Nydp::Builtin::Times.instance                   )
      ns.assign(:/                 , Nydp::Builtin::Divide.instance                  )
      ns.assign(:>                 , Nydp::Builtin::GreaterThan.instance             )
      ns.assign(:<                 , Nydp::Builtin::LessThan.instance                )
      ns.assign(:eval              , Nydp::Builtin::Eval.new(ns)                     )
      ns.assign(:false             , false                                           )
      ns.assign(:hash              , Nydp::Builtin::Hash.instance                    )
      ns.assign(:apply             , Nydp::Builtin::Apply.instance                   )
      ns.assign(:date              , Nydp::Builtin::Date.instance                    )
      ns.assign(:error             , Nydp::Builtin::Error.instance                   )
      ns.assign(:parse             , Nydp::Builtin::Parse.instance                   )
      ns.assign(:p                 , Nydp::Builtin::Puts.instance                    )
      ns.assign(:PI                , 3.1415                                          )
      ns.assign(:rand              , Nydp::Builtin::Rand.instance                    )
      ns.assign(:sort              , Nydp::Builtin::Sort.instance                    )
      ns.assign(:abs               , Nydp::Builtin::Abs.instance                     )
      ns.assign(:sym               , Nydp::Builtin::Sym.instance                     )
      ns.assign(:ensuring          , Nydp::Builtin::Ensuring.instance                )
      ns.assign(:inspect           , Nydp::Builtin::Inspect.instance                 )
      ns.assign(:comment           , Nydp::Builtin::Comment.instance                 )
      ns.assign("handle-error"     , Nydp::Builtin::HandleError.instance             )
      ns.assign("parse-in-string"  , Nydp::Builtin::ParseInString.instance           )
      ns.assign("random-string"    , Nydp::Builtin::RandomString.instance            )
      ns.assign("to-string"        , Nydp::Builtin::ToString.instance                )
      ns.assign("to-integer"       , Nydp::Builtin::ToInteger.instance               )
      ns.assign("string-length"    , Nydp::Builtin::StringLength.instance            )
      ns.assign("string-replace"   , Nydp::Builtin::StringReplace.instance           )
      ns.assign("string-match"     , Nydp::Builtin::StringMatch.instance             )
      ns.assign("string-split"     , Nydp::Builtin::StringSplit.instance             )
      ns.assign("time"             , Nydp::Builtin::Time.instance                    )
      ns.assign("thread-locals"    , Nydp::Builtin::ThreadLocals.instance            )
      ns.assign("type-of"          , Nydp::Builtin::TypeOf.instance                  )
      ns.assign(:"eq?"             , Nydp::Builtin::IsEqual.instance                 )
      ns.assign(:"cdr-set"         , Nydp::Builtin::CdrSet.instance                  )
      ns.assign(:"hash-get"        , Nydp::Builtin::HashGet.instance                 )
      ns.assign(:"hash-set"        , Nydp::Builtin::HashSet.instance                 )
      ns.assign(:"hash-keys"       , Nydp::Builtin::HashKeys.instance                )
      ns.assign(:"hash-key?"       , Nydp::Builtin::HashKeyPresent.instance          )
      ns.assign(:"hash-merge"      , Nydp::Builtin::HashMerge.instance               )
      ns.assign(:"hash-slice"      , Nydp::Builtin::HashSlice.instance               )
      ns.assign(:"vm-info"         , Nydp::Builtin::VmInfo.instance                  )
      ns.assign(:"pre-compile-new-expression", Nydp::Builtin::PreCompile.instance    )
      ns.assign(:"script-run"      , Nydp::Builtin::ScriptRun.instance               )
      ns.assign(:"**"              , Nydp::Builtin::MathPower.instance               )
      ns.assign(:"⌊"               , Nydp::Builtin::MathFloor.instance               )
      ns.assign(:"math-floor"      , Nydp::Builtin::MathFloor.instance               )
      ns.assign(:"⌈"               , Nydp::Builtin::MathCeiling.instance             )
      ns.assign(:"math-ceiling"    , Nydp::Builtin::MathCeiling.instance             )
      ns.assign(:"math-round"      , Nydp::Builtin::MathRound.instance               )
      ns.assign(:"⋂"               , Nydp::Builtin::SetIntersection.instance         )
      ns.assign(:"set-intersection", Nydp::Builtin::SetIntersection.instance         )
      ns.assign(:"⋃"               , Nydp::Builtin::SetUnion.instance                )
      ns.assign(:"set-union"       , Nydp::Builtin::SetUnion.instance                )
    end
  end
end

Nydp.plug_in Nydp::Core.new
