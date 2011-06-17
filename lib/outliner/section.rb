module Outliner
  class SectionExistsError < RuntimeError; end
  class Section
    attr_accessor :heading, :outlinee, :parent
    
    def initialize(section=nil)
      @sections = [section].compact
    end

    def heading=(value)
      puts value.node.name
      @heading = value
    end
    
    def heading?
      !heading.nil?
    end

    def children?
      @sections.any?
    end

    def first_section
      @sections.last
    end

    def last_section
      @sections.first
    end

    def push(section)
      ensure_unique! section
      @sections.push section
    end

    def append(section)
      ensure_unique! section
      @sections.insert 0, section
    end

    def length 
      @sections.length
    end

    def ensure_unique!(section)
      raise SectionExistsError if @sections.include? section
      section.parent = self
    end

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
