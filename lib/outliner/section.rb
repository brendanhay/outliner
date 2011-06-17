module Outliner
  class SectionExistsError < RuntimeError; end

  class Section
    include Htmlerizer

    attr_accessor :heading, :outlinee, :parent
    
    def initialize
      @sections = []
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

    def last_child
      @sections.last
    end

    def append(section)
      puts "Appending section into parent section"
      raise SectionExistsError if @sections.include? section
      section.parent = self
      @sections << section
    end

    def length
      @sections.length
    end
  end
end
