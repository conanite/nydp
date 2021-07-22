require 'nydp/helper'

module Nydp
  class Date
    include Nydp::Helper

    attr_accessor :ruby_date

    MONTH_SIZES = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    def build y, m, d
      if m < 1
        build( y - 1, m + 12, d )
      else
        s = MONTH_SIZES[m]
        ::Date.new(y, m, (d > s ? s : d))
      end
    end

    def initialize ruby_date ; @ruby_date = ruby_date ; end

    def to_date        ; ruby_date                              ; end
    def to_s           ; ruby_date.to_s                         ; end
    def to_ruby        ; ruby_date                              ; end
    def inspect        ; ruby_date.inspect                      ; end
    def nydp_type      ; :date                                  ; end
    def >        other ; is_date?(other) && ruby_date > other   ; end
    def <        other ; is_date?(other) && ruby_date < other   ; end
    def ==       other ; is_date?(other) && ruby_date == other  ; end
    def <=>      other ; is_date?(other) && ruby_date <=> other ; end
    def eql?         d ; self == d                              ; end
    def hash           ; ruby_date.hash                         ; end
    def is_date? other ; other.is_a? ::Date                     ; end
    def -        other ; r2n(ruby_date - (is_date?(other) ? other.ruby_date : other))          ; end
    def +          int ; int.is_a?(Integer) ? r2n(ruby_date + int) : r2n(change(*int.to_ruby)) ; end

    @@pass_through = %i{ monday? tuesday? wednesday? thursday? friday? saturday? sunday? }
    @@keys = Set.new %i{
      year       month      week_day           day
      last_year  next_year  beginning_of_year  end_of_year
      last_month next_month beginning_of_month end_of_month
      last_week  next_week  beginning_of_week  end_of_week
      yesterday  tomorrow   age
    } + @@pass_through

    def year               y, m, d, w ; y ; end
    def month              y, m, d, w ; m ; end
    def day                y, m, d, w ; d ; end
    def week_day           y, m, d, w ; w ; end

    def last_year          y, m, d, w ; ruby_date.prev_year          ; end
    def next_year          y, m, d, w ; ruby_date.next_year          ; end
    def beginning_of_year  y, m, d, w ; build(y, 1, 1)               ; end
    def end_of_year        y, m, d, w ; build(y, 12, 31)             ; end

    def last_month         y, m, d, w ; ruby_date.prev_month         ; end
    def next_month         y, m, d, w ; ruby_date.next_month         ; end
    def beginning_of_month y, m, d, w ; build(y, m, 1)               ; end
    def end_of_month       y, m, d, w ; beginning_of_month(*splat(ruby_date.next_month)) - 1 ; end

    def last_week          y, m, d, w ; ruby_date - 7                ; end
    def next_week          y, m, d, w ; ruby_date + 7                ; end
    def beginning_of_week  y, m, d, w ; ruby_date - ((w - 1) % 7)    ; end
    def end_of_week        y, m, d, w ; ruby_date + ((7 - w) % 7)    ; end

    def yesterday          y, m, d, w ; ruby_date - 1                ; end
    def tomorrow           y, m, d, w ; ruby_date + 1                ; end

    def age y,m,d,w # args not used
      interval = (::Date.today - ruby_date) / 365.0
      age_in_years = interval.to_i
      extra_months = (12 * (interval - age_in_years)).to_i
      { years: age_in_years, months: extra_months }
    end

    @@pass_through.each do |n|
      class_eval "def #{n} * ; ruby_date.#{n} ; end"
    end

    def _nydp_keys                ; @@keys.to_a                                                              ; end
    def dispatch  key, y, m, d, w ; self.send(key, y, m, d, w) if _nydp_keys.include?(key)                   ; end
    def splat                date ; [date.year, date.month, date.day, date.wday]                             ; end
    def lookup          key, date ; r2n(dispatch(key.to_s.gsub(/-/, '_').to_sym, *splat(date)))              ; end
    def _nydp_get             key ; lookup key, ruby_date                                                    ; end
    def change       amount, attr
      if    attr == :day   ; (ruby_date + amount)
      elsif attr == :week  ; (ruby_date + (7 * amount))
      elsif attr == :month ; (ruby_date >> amount)
      elsif attr == :year  ; (ruby_date >> (12 * amount))
      end
    end
  end
end
