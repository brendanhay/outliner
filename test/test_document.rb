require 'helper'

MARKDOWN = <<MARKDOWN
* A
B

** C
D

** E
F

MARKDOWN

class DocumentTest < Test::Unit::TestCase
  context "From valid markdown" do
    setup do
      @document = Outliner::Document.new MARKDOWN
    end

    should "have one H1 heading" do

    end

    should "have two H2 headings" do

    end

    should "have three paragraphs" do

    end
  end
end
