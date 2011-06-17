module Outliner
  class SectionExistsError < RuntimeError; end
  class Section
    DEFAULT_NUMBER = '1'

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

    def each_section
      raise ArgumentError unless block_given?
      @sections.each { |s| yield s }
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
      if heading?
        heading.number = parent? ? "#{parent.numberize}.#{parent.find_depth(self)}" : DEFAULT_NUMBER
      else
        DEFAULT_NUMBER
      end
    end
     
    def id
      heading.node['id'] || generate_id
    end

    def to_html
      "#{title_html if heading?}<ol>#{inner_html}</ol>"
    end

    def to_xhtml
      Nokogiri::XML.parse(to_html).to_xhtml
    end

    def inspect
      "<Section:#{heading? ? heading.node.name : 'blank!'} #{@sections.map { |s| s.inspect }}>"
    end

    private

    def ensure_unique!(section)
      raise SectionExistsError if @sections.include? section
      section.parent = self
    end

    def generate_id
      suffix = heading.node.text.strip.gsub(/\s+/, '-').downcase
      value = [numberize.gsub('.', '-'), suffix].join('-')
      heading.node['id'] = value
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
