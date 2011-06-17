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
      @outlinee.outline
    end

    private

    # This nasty piece of work is just to keep the control flow identical
    # to the algorithm mentioned at the bottom of the spec until I get some 
    # sort of regression tests around it
    def walk(root)
      @node, @root = root, root
      while @node
        catch :start do
          walk_inner
        end
      end
    end

    def walk_inner
      while @node
        enter_node Outlinee.new(@node)
        if @node.first_element_child
          @node = @node.first_element_child
          throw :start
        end
        while @node 
          exit_node Outlinee.new(@node)
          if @node.next_sibling
            @node = @node.next_sibling
            throw :start
          else
            if @node == @root
              @node = nil
            else
              @node = @node.parent
            end
          end
        end
      end
    end

    def enter_node(outlinee)
      # If the top of the stack is a heading content element - do nothing
      if @stack.any? && heading?(@stack.last)
        return
      end
      
      # When entering a sectioning content element or a sectioning root element
      if any_section? outlinee
        # If current outlinee is not null, push current outlinee onto the stack
        @stack.push(@outlinee) if @outlinee
     
        # Let current outlinee be the element that is being entered
        @outlinee = outlinee

        # Let current section be a newly created section for the current outlinee element
        @section = Section.new

        # Let there be a new outline for the new current outlinee, initialized with just the new current section as the only section in the outline
        @outlinee.outline = Outline.new @section
        
        return
      end

      # If the current outlinee is nil, do nothing
      return unless @outlinee

      # When entering a heading content element
      if heading? outlinee
        # If the current section has no heading, let the element being entered be the heading for the current section
        if !@section.heading?
          @section.heading = outlinee 
        # Otherwise, if the element being entered has a rank equal to or greater than the heading of the last section of the outline of the current outlinee,
        elsif rank(outlinee) >= rank(@outlinee.outlinee.last_section.heading)
          # Create a new section
          section = Section.new

          # Append it to the outline of the current outlinee, so that this new section is the last section of that outline
          @outlinee.outline.append section

          # Let the current section be that new section
          @section = section

          # Let the element being entered be the new heading for the current section
          @section.heading = outlinee
        # Otherwise run these substeps
        else
          abort = false

          # 1. Let candidate section be the current section
          candidate = @section

          while !abort
            # 2. If the element being entered has a rank lower than the rank of the heading of the candidate section
            if rank(outlinee) < rank(candidate.heading)
              # Create a new section
              section = Section.new

              # And append it to candidate section (this does not change the last section in the outline)
              candidate.append section

              # Let current section be this new section
              @section = section

              # Let the element being entered be the new heading for the current section
              @section.heading = outlinee

              # Abort these subteps
              abort = true
            end

            # 3. Let new candidate section be the section that contains candidate section in the outline of current outline
            section = candidate.parent

            # 4. Let candidate section be new candidate section
            candidate = section
          end # 5. Return to step 2
        end 
        @stack.push outlinee
      end
    end

    def exit_node(outlinee)
      # If the top of the stack is an element, and you are exiting that element
      # Note: The element being exited is a heading content element.
      # Pop that element from the stack.
      # If the top of the stack is a heading content element - do nothing
      if @stack.any? && heading?(@stack.last)
        @stack.pop if @stack.last == outlinee

        return
      end

      # ************ MODIFICATION OF ORIGINAL ALGORITHM *****************
      # existing sectioning content or sectioning root
      # this means, currentSection will change (and we won't get back to it)
      if any_section?(outlinee) && !@section.heading?
        @section.heading = Nokogiri::XML::Node.new 'i', @html
      end
      # ************ END MODIFICATION ***********************************

      # When exiting a sectioning content element, if the stack is not empty
      if content_section?(outlinee) && @stack.any?
        # Pop the top element from the stack, and let the current outlinee be that element
        @outlinee = @stack.pop

        # Let the current section be the last section in the outline of the current outlinee element
        @section = @outlinee.outline.last_section

        # Append the outline of the sectioning element being exited to the current section
        # This does not change which section is the last section in the outline
        puts "Line 204, potential problem"

        outlinee.outline.sections.each { |section| @section.append section }

        return
      end

      # When exiting a sectioning root element, if the stack is not empty
      if root_section?(outlinee) && @stack.any?
        # Pop the top element from the stack, and let the current outlinee be that element
        @outlinee = @stack.pop

        # Let the current section be the last section in the outline of the current outlinee element
        @section = @outlinee.last_section

        # Finding the deepest child: if current section has no children stop these steps
        while @section.children?
          @section = @section.last_child
        end

        return
      end

      # When exiting a sectioning content element or a sectioning root element
      if any_section?(outlinee)
        @section = @outlinee.outline.first_child
      end # Skip to the next step in the overall set of steps. (The walk is over.)
    end

    #   puts "entering: #{outlinee.node.name}"

    #   if any_section? outlinee # 4c
    #     puts "4c"
    #     @stack.push @outlinee unless @outlinee.nil? # 4c.2
    #     @outlinee = outlinee # 4c.3
    #     @section = Section.new # 4c.4, 4c.5
    #     @section.outlinee = @outlinee      
    #     @outlinee.outline = Outline.new @section # 4c.6
    #     return
    #   end

    #   return if @outlinee.nil?

    #   if heading? outlinee # 4h
    #     puts "4h"
    #     if !@section.heading? # 4h.1
    #       @section.heading = outlinee 
    #     elsif rank(outlinee) >= rank(@outlinee.outline.last_section.heading) # 4h.2
    #       puts "4h.2"
    #       puts @outlinee.node.name
    #       @section = Section.new 
    #       @section.heading = outlinee
    #       @outlinee.outline.append @section 
    #     else # 4h.3
    #       puts "4h.3"
    #       candidate = @section # 4h.3.1
    #       abort = false
    #       while !abort
    #         if rank(outlinee) < rank(candidate.heading) # 4h.3.2
    #           @section = Section.new
    #           puts "4h.3.2"
    #           @section.heading = outlinee
    #           candidate.append @section
    #           abort = true
    #         end
    #         # TODO: 4h.3.3
    #         candidate = candidate.parent # 4h.3.4
    #       end # 4h.3.5
    #     end
    #     @stack.push outlinee # 4h.4q
    #   end
    # end

    # def exit(outlinee)
    #   puts "exiting: #{outlinee.node.name}"

    #   if @stack.length > 0 && heading?(@stack.last) # 4a
    #     @stack.pop if @stack.last == outlinee
    #     return 
    #   end

    #   if content_section?(outlinee) && @stack.length > 0 # 4d
    #     puts "4d"
    #     @outlinee = @stack.pop # 4d.1
    #     @section = @outlinee.outline.last_section # 4d.2
    #     outlinee.outline.sections.each { |s| @section.append s } # 4d.3
    #   end

    #   if root_section?(outlinee) && @stack.length > 0 # 4e
    #     puts "4e"
    #     @outlinee = @stack.pop # 4e.1
    #     @section = @outlinee.outline # 4e.2
    #     while section.children? # 4e.3
    #       @section = @section.last_child # 4e.4
    #     end
    #   end

    #   if any_section?(outlinee) && @outlinee == outlinee # 4f.1
    #     @section = @outlinee.outline.first_section # 4f.2
    #   end
    # end

    def rank(outlinee)
      case outlinee.node.name 
      when /^H([1-6])$/i
        - Integer($1)
      when /^H$/i
        1
      else
        0
      end
    end

    def any_section?(outlinee)
      content_section?(outlinee) || root_section?(outlinee)
    end

    def content_section?(outlinee)
      node_matches? outlinee, /^ARTICLE|ASIDE|NAV|SECTION$/i
    end

    def root_section?(outlinee)
      node_matches? outlinee, /^BLOCKQUOTE|BODY|DETAILS|FIELDSET|FIGURE|TD$/i
    end

    def heading?(outlinee)
      node_matches? outlinee, /^H[1-6]|HGROUP$/i
    end

    def node_matches?(outlinee, regex)
      node = outlinee.node
      node && node.element? && node.node_name =~ regex
    end
  end
end

