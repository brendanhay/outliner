module Outliner
  module Htmlerizer
    def to_html
      title = respond_to?(:heading) ? "<a href='#'>#{heading.node.inner_text}</a>" : ''
      content = @sections.map { |section| "<li>#{section.to_html}</li>" }.join ''
      "<ol>#{title}#{content}</ol>"
    end
  end

  class Outline
    include Htmlerizer

    # Using a stack for sections since push is the most common operation
    # Insert only occurs when deliberately setting the last section (entering a heading node)
    def initialize(section)
      @sections = [section]
    end
    
    def first_section
      @sections.last
    end

    def last_section
      @sections.first
    end
    
    def push(*sections)
      sections.each { |section| @sections.push section }
    end

    def append(section)
      @sections.insert 0, section
    end
  end
end
