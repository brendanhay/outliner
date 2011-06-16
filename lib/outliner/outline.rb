module Outliner
  class Outline
    def initialize(section)
      @sections = [section]
    end
    
    def last_section
      @sections.last
    end
    
    def append(section)
      @sections << section
    end
  end
end
