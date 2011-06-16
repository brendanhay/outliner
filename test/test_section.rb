require 'helper'

class SectionTest < Test::Unit::TestCase
  context "A new section" do
    setup do
      @section = Outliner::Section.new
    end

    should "have no children" do
      assert !@section.children?
    end

    should "have no heading" do
      assert !@section.heading?
    end

    context "after appending multiple sections" do
      setup do
        @appended = Outliner::Section.new
        5.times { @section.append Outliner::Section.new }
        @section.append @appended
      end

      should "have children" do
        assert @section.children?
      end

      should "have the appended section as the last child" do
        assert_equal @appended, @section.last_child
      end
    end

    context "after setting a heading" do
      setup do
        @node = Nokogiri::XML::Node.new 'h1', Nokogiri::XML::Document.new
        @heading = Outliner::Outlinee.new @node
        @section.heading = @heading
      end

      should "have the same heading" do
        assert_equal @section.heading, @heading
      end
    end
  end
end
