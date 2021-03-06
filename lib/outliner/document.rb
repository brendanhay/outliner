module Outliner
  class Document
    MARKDOWN = <<MARKDOWN
# A
B
# Q
Z
## C
D
## E 
F
### G
H
#### X
Y
## I
K
MARKDOWN

    attr_reader :table_of_contents, :formatted, :parsed

    def initialize(markdown=MARKDOWN)
      parsed = Nokogiri::HTML RDiscount.new(markdown).to_html
      @table_of_contents, @formatted = outline parsed
      @parsed = parsed.to_xhtml
    end 

    def to_s
      @parsed
    end

    private

    # TODO: 6
    # TODO: 7
    # TODO: outlinee.name.casecmp('body') == 0 # 8
    #    puts "Outlinee: #{@outlinee.inspect}\n\n"
    #    puts "Section: #{@section.inspect}\n\n"
    #    puts "Stack: #{@stack}\n\n"
    def outline(html)
      @outlinee, @section, @stack = nil, nil, [] # 1, 2, 3
      modified = html.dup
      walk modified.root # 4
      raise 'No sectioning content or root found in the DOM' if @outlinee.nil? # 5
      # TODO: Hacky .. calling .to_(x)html on outline is what actually modifies the document .. :S
      [@outlinee.outline.to_xhtml, modified.to_xhtml]
    end

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
      # TODO: Investigate why this breaks the algorithm (without too much handwaving)
      # If the top of the stack is a heading content element - do nothing
      #return if @stack.any? && @stack.last.heading?
      
      # When entering a sectioning content element or a sectioning root element
      if outlinee.content_or_root?
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
      if outlinee.heading? 
        # If the current section has no heading, let the element being entered be the heading for the current section
        if !@section.heading?
          @section.heading = outlinee 
        # Otherwise, if the element being entered has a rank equal to or greater than the heading of the last section of the outline of the current outlinee,
        elsif outlinee.rank >= @outlinee.outline.last_section.heading.rank
          # Create a new section
          # Append it to the outline of the current outlinee, so that this new section is the last section of that outline
          # Let the current section be that new section
          @section = Section.new
          @outlinee.outline.append @section
          # Let the element being entered be the new heading for the current section
          @section.heading = outlinee
        # Otherwise run these substeps
        else
          abort = false
          # 1. Let candidate section be the current section
          candidate = @section
          while !abort
            # 2. If the element being entered has a rank lower than the rank of the heading of the candidate section
            if outlinee.rank < candidate.heading.rank
              # Create a new section
              # And append it to candidate section (this does not change the last section in the outline)
              # Let current section be this new section
              @section = Section.new
              candidate.push @section
              # Let the element being entered be the new heading for the current section
              @section.heading = outlinee
              # Abort these subteps
              abort = true
            end
            # 3. Let new candidate section be the section that contains candidate section in the outline of current outline
            # 4. Let candidate section be new candidate section
            candidate = candidate.parent
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
      if @stack.any? && @stack.last.heading?
        @stack.pop if @stack.last == outlinee
        return
      end

      # When exiting a sectioning content element, if the stack is not empty
      if outlinee.content? && @stack.any?
        puts "exiting root: #{outlinee.node.name}"
        # Pop the top element from the stack, and let the current outlinee be that element
        @outlinee = @stack.pop
        # Let the current section be the last section in the outline of the current outlinee element
        @section = @outlinee.outline.last_section
        # Append the outline of the sectioning element being exited to the current section
        # This does not change which section is the last section in the outline
        outlinee.outline.each_section { |s| @section.append s }
        return
      end

      # When exiting a sectioning root element, if the stack is not empty
      if outlinee.root? && @stack.any?
        puts "exiting root: #{outlinee.node.name}"
        # Pop the top element from the stack, and let the current outlinee be that element
        @outlinee = @stack.pop
        # Let the current section be the last section in the outline of the current outlinee element
        @section = @outlinee.outline.last_section
        # Finding the deepest child: if current section has no children stop these steps
        while @section.children?
          @section = @section.last_child
        end
        return
      end

      # When exiting a sectioning content element or a sectioning root element
      @section = @outlinee.outline.first_child if outlinee.content_or_root?
      # Skip to the next step in the overall set of steps. (The walk is over.)
    end   
  end
end

