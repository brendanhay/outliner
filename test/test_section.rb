require 'helper'

class SectionTest < Test::Unit::TestCase
  context 'A new section' do
    setup do
      @section = Outliner::Section.new
    end

    should 'have no children' do
      assert !@section.children?
    end

    should 'have no heading' do
      assert !@section.heading?
    end

    context 'after appending multiple sections' do
      setup do
        5.times { @section.append Outliner::Section.new }
        @appended = Outliner::Section.new
        @section.append @appended
      end

      should 'have children' do
        assert @section.children?
      end

      should 'have the last section the same as the appended section' do
        assert_same @appended, @section.last_section
      end

      should 'raise if same section is re-added' do
        assert_raise(Outliner::SectionExistsError) { @section.append @appended }
      end

      context 'the html output' do
        setup do
          @document = Nokogiri::HTML.parse(@section.to_html)
        end

        should 'contain one root ordered list' do
          assert_equal 1, @document.css('body > ol').length
        end

        should 'contain the same number of list items as child sections' do
          assert_equal @section.length, @document.css('body > ol > li').length
        end
      end
    end

    context 'after setting a heading' do
      setup do
        @node = Nokogiri::XML::Node.new 'h1', Nokogiri::XML::Document.new
        @heading = Outliner::Outlinee.new @node
        @section.heading = @heading
      end

      should 'have the same heading' do
        assert_same @section.heading, @heading
      end
    end
  end
end
