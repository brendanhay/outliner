module Outliner
  class Outlinee
    attr_accessor :outline
    attr_reader :node
    
    def initialize(node)
      @node = node
    end

    def number=(value)
      if @number.nil?
        @number = Nokogiri::XML::Node.new 'span', node.document
        node.before @number
      end
      @number.content = value
    end

    def rank
      case node.name 
      when /^H([1-6])$/i
        - Integer($1)
      when /^H$/i
        1
      else
        0
      end
    end

    def content_or_root?
      content? || root?
    end

    def content?
      matches? /^ARTICLE|ASIDE|NAV|SECTION$/i
    end

    def root?
      matches? /^HTML|BLOCKQUOTE|BODY|DETAILS|FIELDSET|FIGURE|TD$/i
    end

    def heading?
      matches? /^H[1-6]|HGROUP$/i
    end

    private

    def matches?(regex)
      node && node.element? && node.node_name =~ regex
    end
  end
end
