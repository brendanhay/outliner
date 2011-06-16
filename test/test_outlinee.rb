require 'helper'

class OutlineeTest < Test::Unit::TestCase
  context "A new outlinee" do
    setup do
      @node = Nokogiri::XML::Node.new 'h3', Nokogiri::XML::Document.new
      @outlinee = Outliner::Outlinee.new @node
    end
    
    should "have a reference to the initalising node" do
      assert_equal @node, @outlinee.node
    end

    context "after setting the outline" do
      setup do
        @outline = Outliner::Outline.new Outliner::Section.new
        @outlinee.outline = @outline
      end

      should "have the same outline" do
        assert_equal @outline, @outlinee.outline
      end
    end
  end
end
