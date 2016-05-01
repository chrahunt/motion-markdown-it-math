# motion-markdown-it-math

This is a Ruby port of [`markdown-it-math`](https://github.com/runarberg/markdown-it-math) for use with [`motion-markdown-it`](https://github.com/digitalmoksha/motion-markdown-it).

## Usage

```ruby
md = MarkdownIt::Parser.new(:commonmark, { html: false })
inline = lambda {|s| "<span class='math'><script type='math/tex'>#{s}</script></span>" }}
block = lambda {|s| "<span class='math'><script type='math/tex; mode=display'>#{s}</script></span>" }
md.use(MotionMarkdownItMath::Plugin, {
  inlineOpen: '$',
  inlineClose: '$',
  blockOpen: '$$',
  blockClose: '$$',
  inlineRenderer: inline,
  blockRenderer: block
})
```

To use with multiple styles of delimeters, just call `use` again with the other style.

```ruby
md.use(MotionMarkdownItMath::Plugin, {
  inlineOpen: '\\(',
  inlineClose: '\\)',
  blockOpen: '\\[',
  blockClose: '\\]',
  inlineRenderer: inline,
  blockRenderer: block
})
```

## Credits

Thanks to @digitalmoksha for motion-markdown-it and motion-markdown-it-plugins on which this project is based.
