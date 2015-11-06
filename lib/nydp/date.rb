require 'nydp/helper'

module Nydp
  class Date
    include Nydp::Helper

    attr_accessor :ruby_date

    MONTH_SIZES = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    def build y, m, d
      s = MONTH_SIZES[m]
      ::Date.new(y, m, (d > s ? s : d))
    end

    def initialize ruby_date
      @ruby_date = ruby_date
    end

    def to_s      ; ruby_date.to_s    ; end
    def to_ruby   ; ruby_date         ; end
    def inspect   ; ruby_date.inspect ; end
    def nydp_type ; :date             ; end
    def - other   ; r2n(ruby_date - other.ruby_date, nil) ; end
    def + int     ; r2n(ruby_date + int            , nil) ; end
    def > other   ; ruby_date > other.ruby_date           ; end
    def < other   ; ruby_date < other.ruby_date           ; end
    def == other  ; ruby_date == other.ruby_date          ; end

    @@keys = Set.new %i{
      year       month      week_day           day
      last_year  next_year  beginning_of_year  end_of_year
      last_month next_month beginning_of_month end_of_month
      last_week  next_week  beginning_of_week  end_of_week
      yesterday  tomorrow
    }

    def year               y, m, d, w ; y ; end
    def month              y, m, d, w ; m ; end
    def day                y, m, d, w ; d ; end
    def week_day           y, m, d, w ; w ; end

    def last_year          y, m, d, w ; build(y - 1, m, d)           ; end
    def next_year          y, m, d, w ; ruby_date.next_year          ; end
    def beginning_of_year  y, m, d, w ; build(y, 1, 1)               ; end
    def end_of_year        y, m, d, w ; build(y, 12, 31)             ; end

    def last_month         y, m, d, w ; build(y, m - 1, d)           ; end
    def next_month         y, m, d, w ; ruby_date.next_month         ; end
    def beginning_of_month y, m, d, w ; build(y, m, 1)               ; end
    def end_of_month       y, m, d, w ; build(y, m, 31)              ; end

    def last_week          y, m, d, w ; ruby_date - 7                ; end
    def next_week          y, m, d, w ; ruby_date + 7                ; end
    def beginning_of_week  y, m, d, w ; ruby_date + 1 - w            ; end
    def end_of_week        y, m, d, w ; ruby_date + 7 - w            ; end

    def yesterday          y, m, d, w ; ruby_date - 1                ; end
    def tomorrow           y, m, d, w ; ruby_date + 1                ; end

    def [] key
      key = key.to_s.gsub(/-/, '_').to_sym
      y = ruby_date.year
      m = ruby_date.month
      d = ruby_date.day
      w = ruby_date.wday

      adjusted = self.send(key, y, m, d, w) if @@keys.include?(key)
      r2n adjusted, nil
    end
  end
end
