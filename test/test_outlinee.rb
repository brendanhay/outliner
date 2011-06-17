require 'helper'

class OutlineeTest < Test::Unit::TestCase
  context 'A new H3 outlinee' do
    setup do
      @node = new_node 'h3'
      @outlinee = Outliner::Outlinee.new @node
    end
    
    should 'have a reference to the initalising node' do
      assert_same @node, @outlinee.node
    end

    context 'after setting the outline' do
      setup do
        @outline = Outliner::Outline.new Outliner::Section.new
        @outlinee.outline = @outline
      end

      should 'have the same outline' do
        assert_same @outline, @outlinee.outline
      end
    end
  end

  context 'Various heading tags' do
    setup do
      @outlinees = (1..6).map { |i| new_outlinee "h#{i}" }
    end

    should 'be higher rank than the next' do
      previous = nil
      @outlinees.each do |outlinee|
        unless previous.nil?
          assert(previous.rank > outlinee.rank, "#{outlinee.node.name} wasn't less than #{previous.node.name}")
        end
        previous = outlinee
      end
    end
  end

  context 'Article' do
    should('be content') { assert new_outlinee('article').content? }
  end

  context 'Aside' do
    should('be content') { assert new_outlinee('aside').content? }
  end

  context 'Nav' do
    should('be content') { assert new_outlinee('nav').content? }
  end

  context 'Section' do
    should('be content') { assert new_outlinee('section').content? }
  end

  context 'Blockquote' do
    should('be a root') { assert new_outlinee('blockquote').root? }
  end

  context 'Body' do
    should('be a root') { assert new_outlinee('body').root? }
  end

  context 'Details' do
    should('be a root') { assert new_outlinee('details').root? }
  end

  context 'Fieldset' do
    should('be a root') { assert new_outlinee('fieldset').root? }
  end

  context 'Figure' do
    should('be a root') { assert new_outlinee('figure').root? }
  end

  context 'Td' do
    should('be a root') { assert new_outlinee('td').root? }
  end
end
