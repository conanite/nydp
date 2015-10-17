class Nydp::Hash < ::Hash
  include Nydp::Helper

  def nydp_type ; :hash   ; end
  def to_ruby
    h = Hash.new
    self.each { |k,v| h[n2r k] = n2r v }
    h
  end
end
