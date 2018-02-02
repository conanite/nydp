class Nydp::Hash < ::Hash
  include Nydp::Helper

  def nydp_type      ; :hash                                             ; end
  def to_ruby        ; each_with_object({}) {|(k,v),h| h[n2r k] = n2r v} ; end
  def _nydp_get a    ; self[a]                                           ; end
  def _nydp_set a, v ; self[a] = v                                       ; end
  def _nydp_keys     ; keys                                              ; end
end
