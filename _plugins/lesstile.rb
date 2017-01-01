require 'lesstile'
require 'coderay'
require 'RedCloth'

module Jekyll
  class LesstileConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /^\.lesstile$/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      Lesstile.format_as_xhtml(
        content,
        :text_formatter => lambda {|text|
          RedCloth.new(CGI::unescapeHTML(text)).to_html
        },
        :code_formatter => Lesstile::CodeRayFormatter
      )
    rescue => e
      puts e
      puts e.backtrace
    end
  end
end
