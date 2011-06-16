module Outliner
  class Document
    MARKDOWN = <<MARKDOWN
# A
B
## C
D
## E
F
MARKDOWN

    attr_reader :html, :outlinee, :section, :stack

    def initialize(markdown=MARKDOWN)
      @html = Nokogiri::HTML RDiscount.new(markdown).to_html
    end 

    def outline
      @outlinee, @section, @stack = nil, nil, [] # 1, 2, 3
      walk @html.root # 4
      raise 'No sectioning content or root found in the DOM' if @outlinee.nil? # 5
      # TODO: 6
      # TODO: 7
      # TODO: outlinee.name.casecmp('body') == 0 # 8
      #    puts "Outlinee: #{@outlinee.inspect}\n\n"
      #    puts "Section: #{@section.inspect}\n\n"
      #    puts "Stack: #{@stack}\n\n"
      @section
    end

    private

    def walk(root)
      node = root
      while node
        enter Outlinee.new(node)
        if node.first_element_child
          node = node.first_element_child
        else
          while node 
            exit Outlinee.new(node)
            if node.next_sibling
              node = node.next_sibling
            else
              if node == root
                node = nil
              else
                node = node.parent
              end
            end
          end
        end
      end
    end

    def enter(outlinee)
      return if !@stack.empty? && heading?(@stack.last.node)
      if any_section? outlinee.node # 4c
        puts "4c"
        @stack.push @outlinee unless @outlinee.nil? # 4c.2
        @outlinee = outlinee # 4c.3
        @section = Section.new # 4c.4, 4c.5
        @section.outlinee = @outlinee      
        @outlinee.outline = Outline.new @section # 4c.6
        return
      end
      return if @outlinee.nil?
      if heading? outlinee.node # 4h
        @section.heading = outlinee unless @section.heading? # 4h.1
        puts "4h"
        if rank(outlinee.node) >= rank(@outlinee.outline.last_section.heading.node) # 4h.2
          puts "4h.2"
          puts @outlinee.node
          @section = Section.new 
          @section.heading = outlinee
          @outlinee.outline.append @section 
        else # 4h.3
          puts "4h.3"
          candidate = @section # 4h.3.1
          abort = false
          while !abort
            if rank(outlinee.node) < rank(candidate.heading.node) # 4h.3.2
              @section = Section.new
              @section.heading = outlinee
              candidate.append @section
              abort = true
            else
              # TODO: 4h.3.3
              candidate = candidate.parent # 4h.3.4
            end # 4h.3.5
          end
        end
        @stack.push outlinee # 4h.4q
      end
    end

    def exit(outlinee)
      if !@stack.empty? && heading?(@stack.last.node) # 4a
        @stack.pop if @stack.last == outlinee
        return 
      end

      if content_section?(outlinee.node) && !@stack.empty? # 4d
        @outlinee = @stack.pop # 4d.1
        @section = @outlinee.outline.last_section # 4d.2
        outlinee.outline.sections.each { |s| @section.append s } # 4d.3
      end

      if root_section?(outlinee.node) && !@stack.empty? # 4e
        @outlinee = @stack.pop # 4e.1
        @section = @outlinee.outline # 4e.2
        while section.children? # 4e.3
          @section = @section.last_child # 4e.4
        end
      end

      if any_section?(outlinee.node) && @outlinee == outlinee # 4f.1
        @section = @outlinee.outline.first_section # 4f.2
      end
    end

    def rank(node)
      case node.name 
      when /^H([1-6])$/i
        - Integer($1)
      when /^H$/i
        1
      else
        0
      end
    end

    def any_section?(node)
      content_section?(node) || root_section?(node)
    end

    def content_section?(node)
      node_matches? node, /^ARTICLE|ASIDE|NAV|SECTION$/i
    end

    def root_section?(node)
      node_matches? node, /^BLOCKQUOTE|BODY|DETAILS|FIELDSET|FIGURE|TD$/i
    end

    def heading?(node)
      node_matches? node, /^H[1-6]|HGROUP$/i
    end

    def node_matches?(node, regex)
      node && node.element? && node.node_name =~ regex
    end
  end
end

