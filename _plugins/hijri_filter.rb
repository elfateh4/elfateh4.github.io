require 'hijri'

module Jekyll
  module HijriFilter
    def hijri_date(input)
      date = input.to_date
      hijri = date.to_hijri
      hijri.strftime('%-d %B %Y AH')
    end
  end
end

Liquid::Template.register_filter(Jekyll::HijriFilter)