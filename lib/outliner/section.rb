module Outliner
  class Section
    attr_accessor :heading, :outlinee
    
    def initialize
      @sections = []
    end
    
    def heading?
      !heading.nil?
    end
    
    def append(section)
      @sections.push section
    end
    
    def sections
      @sections
    end
  end
end
