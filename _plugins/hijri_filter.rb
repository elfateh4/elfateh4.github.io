require 'hijri'

module Jekyll
  module HijriFilter
    def hijri_date(input)
      hijri = Date.today.to_hijri
      hijri.strftime('%-d %B %Y AH')
    end
  end
end

Liquid::Template.register_filter(Jekyll::HijriFilter)