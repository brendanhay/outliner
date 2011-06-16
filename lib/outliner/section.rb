module Outliner
  class Section
    include Htmlerizer

    attr_accessor :heading, :outlinee
    
    def initialize
      @sections = []
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
      @sections << section
    end

    def length
      @sections.length
    end
  end
end
