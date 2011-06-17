module Outliner
  class Outline
    include Htmlerizer

    attr_reader :sections

    # Using a stack for sections since push is the most common operation
    # Insert only occurs when deliberately setting the last section (entering a heading node)
    def initialize(section)
      @sections = [section]
    end
    
    def first_section
      @sections.last
    end

    def last_section
      @sections.first
    end
    
    def push(*sections)
      sections.each do |section| 
        "Pushing section into outline"
        ensure_unique section
        @sections.push section 
      end
    end

    def append(section)
      "Appending section to outline as last"
      ensure_unique section
      @sections.insert 0, section
    end

    private 

    def ensure_unique(section)
      raise SectionExistsError if @sections.include? section
    end
  end
end
