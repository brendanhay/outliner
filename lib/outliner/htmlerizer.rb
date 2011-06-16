module Outliner
  module Htmlerizer
    def to_html
      content = "#{title_html}#{inner_html}"
      @sections.any? ? "<ol>#{content}</ol>" : content
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
