module Outliner
  module Htmlerizer
    def to_html
      "#{title_html}<ol>#{inner_html}</ol>"
    end

    def to_xhtml
      Nokogiri::XML.parse(to_html).to_xhtml
    end

    private

    def title_html
      "<a href='#'>#{heading.node.inner_text}</a>" if respond_to?(:heading) && !heading.nil?
    end

    def inner_html
      @sections.map { |section| "<li>#{section.to_html}</li>" }.join('') if @sections.any?
    end
  end
end
