require 'helper'

class OutlineTest < Test::Unit::TestCase
  context "A new outline" do
    setup do
      @section = Outliner::Section.new
      @outline = Outliner::Outline.new @section
    end

    should "have the initial section in first position" do
      assert_same @section, @outline.first_section
    end

    should "have the intial section in last position" do
      assert_same @section, @outline.last_section
    end

    context "after pushing multiple sections" do
      setup do
        5.times { @outline.push Outliner::Section.new }
      end      

      should "not have the initial section in first position" do
        assert_not_same @section, @outline.first_section
      end

      should "still have the initial section in last position" do
        assert_same @section, @outline.last_section
      end

      should 'raise if same section is pushed again' do
        assert_raise(Outliner::SectionExistsError) { @outline.push @outline.first_section }
      end

      context 'and appending a section' do
        setup do
          @appended = Outliner::Section.new
          @outline.append @appended
        end
        
        should 'have the newly appended section in last position' do
          assert_same @appended, @outline.last_section
        end

        should 'raise if same section is appended' do
          assert_raise(Outliner::SectionExistsError) { @outline.append @appended }
        end
      end
    end
  end
end
