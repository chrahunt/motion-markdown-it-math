fixture_dir  = fixture_path('ins/fixtures')

#------------------------------------------------------------------------------
describe 'plugin-with-$-and-$$' do
  md = MarkdownIt::Parser.new
  inline = lambda {|s| "<script type='math/tex'>#{s}</script>" }
  block = lambda {|s| "<script type='math/tex; mode=display'>#{s}</script>" }
  md.use(MotionMarkdownItMath::Plugin, {
    inlineOpen: '$',
    inlineClose: '$',
    blockOpen: '$$',
    blockClose: '$$',
    inlineRenderer: inline,
    blockRenderer: block
  })

  generate(fixture_path("$-and-$$"), md)
end
