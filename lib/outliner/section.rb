module Outliner
  class SectionExistsError < RuntimeError; end
  class Section
    attr_reader :heading
    attr_accessor :parent
    
    def initialize(section=nil)
      @sections = [section].compact
    end

    def heading=(outlinee)
      @heading = outlinee
    end
    
    def heading?
      !heading.nil?
    end

    def parent?
      !parent.nil?
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

    def find_depth(section)
      @sections.find_index(section) + 1
    end

    def numberize
      (parent? ? "#{parent.numberize}.#{parent.find_depth(self)}" : '1').tap do |n| 
        heading.number = n
      end
    end
     
    def id
      heading.node['id'] || generate_id
    end

    def to_html
      "#{title_html}<ol>#{inner_html}</ol>"
    end

    def to_xhtml
      Nokogiri::XML.parse(to_html).to_xhtml
    end

    private

    def ensure_unique!(section)
      raise SectionExistsError if @sections.include? section
      section.parent = self
    end

    def generate_id
      suffix = heading.node.text.strip.gsub(/\s+/, '-').downcase
      prefix = numberize.gsub('.', '-')
      "#{prefix}#{'-' unless suffix.empty?}#{suffix}".tap do |i|
        heading.node['id'] = i
      end
    end

    def title_html
      "<a href='##{id}'>#{heading.node.text}</a>" if heading?
    end

    def inner_html
      if @sections.any?
        @sections.map { |s| "<li>#{s.to_html}</li>" }.join('') 
      end
    end
  end
end
