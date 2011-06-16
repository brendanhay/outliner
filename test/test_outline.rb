require 'helper'

class OutlineTest < Test::Unit::TestCase
  context "A new outline" do
    setup do
      @section = Outliner::Section.new
      @outline = Outliner::Outline.new @section
    end

    should "have the initial section in first position" do
      assert_equal @section, @outline.first_section
    end

    should "have the intial section in last position" do
      assert_equal @section, @outline.last_section
    end

    context "after pushing multiple sections" do
      setup do
        @outline.push 5.times.map { Outliner::Section.new }
      end      

      should "not have the initial section in first position" do
        assert_not_equal @section, @outline.first_section
      end

      should "still have the initial section in last position" do
        assert_equal @section, @outline.last_section
      end

      context "and appending a section" do
        setup do
          @appended = Outliner::Section.new
          @outline.append @appended
        end
        
        should "have the newly append section in last position" do
          assert_equal @appended, @outline.last_section
        end
      end
    end
  end
end
