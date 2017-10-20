require 'digest'

module Nydp
  class ImageStore
    attr_accessor :store

    def initialize store=nil
      @store = store
      FileUtils.mkdir_p(store, mode: 0775) if store
    end

    def digest          ; Digest::MD5.hexdigest(Nydp.all_files.map { |f| File.read f }.join) ; end
    def file_name    id ; File.join @store, "#{id}.nydp_image"                               ; end
    def load?     fname ; File.binread(fname) if File.exists?(fname)                         ; end
    def load         id ; load?(file_name id) if @store                                      ; end
    def store id, image ; File.open(file_name(id), "wb") { |f| f.write(image) } if @store    ; end
    def generate     id ; Marshal.dump(::Nydp.build_nydp).tap { |im| store id, im }          ; end
    def resurrect    id ; load(id) || generate(id)                                           ; end
    def get             ; Marshal.load(@image ||= resurrect(digest))                         ; end
  end
end
