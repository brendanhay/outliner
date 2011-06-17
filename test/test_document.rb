require 'helper'

class DocumentTest < Test::Unit::TestCase
  context "From valid markdown" do
    setup do
      @html = Outliner::Document.new(markdown).html
    end

    should "be well formed html" do
      assert @html.errors.empty?, @html.errors.join(', ')
    end

    should "have one H1 heading" do
      assert_equal 1, @html.css('h1').length
    end

    should "have two H2 headings" do
      assert_equal 2, @html.css('h2').length
    end

    should "have three paragraphs" do
      assert_equal 3, @html.css('p').length
    end

    context "outline" do
      should "not have duplicate sections" do
        
      end
    end
  end
end


