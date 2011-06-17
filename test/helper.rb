require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'shoulda'
require 'mocha'
require 'redgreen'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'outliner'

def markdown 
<<MARKDOWN
# A
B
## C
D
## E
F
MARKDOWN
end

def new_node(tag)
  Nokogiri::XML::Node.new tag, Nokogiri::XML::Document.new
end

def new_outlinee(tag)
  Outliner::Outlinee.new new_node(tag)
end
