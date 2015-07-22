class Nydp::Hash < ::Hash
  include Nydp::Helper

  def to_ruby
    @_ruby_hash ||= Hash.new { |h, k|
      self[case k
           when String
             Nydp::StringAtom.new(k)
           when Symbol
             Nydp::Symbol.new(k)
           else
             k
           end]
    }
  end
end
