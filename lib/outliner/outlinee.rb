module Outliner
  class Outlinee
    attr_accessor :outline
    attr_reader :node
    
    def initialize(node)
      @node = node
    end
  end
end
