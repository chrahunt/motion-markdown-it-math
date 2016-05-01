require 'motion-markdown-it'

module MotionMarkdownItMath
  class Plugin
    extend ::MarkdownIt::Common::Utils

    def self.init_plugin(md, options)
      math = Plugin.new(options)
      md.inline.ruler.before('escape', 'math_inline', math.method(:math_inline))
      md.block.ruler.after('blockquote', 'math_block', math.method(:math_block))
      md.renderer.rules["math_inline"] = math.method(:render_math_inline)
      md.renderer.rules["math_block"] = math.method(:render_math_block)
    end

    def initialize(options)
      @inlineOpen = options[:inlineOpen] || '$$'
      @inlineClose = options[:inlineClose] || '$$'
      @blockOpen = options[:blockOpen] || '$$$'
      @blockClose = options[:blockClose] || '$$$'
      @inlineRenderer = options[:inlineRenderer] || Proc.new do |s|
        "<span class='math'><script type='math/tex'>#{s}</script></span>"
      end
      @blockRenderer = options[:blockRenderer] || Proc.new do |s|
        "<span class='math'><script type='math/tex'>#{s}</script></span>"
      end
    end

    def math_inline(state, silent)
      max = state.posMax
      start = state.pos
      openDelim = state.src[start...start + @inlineOpen.length]
      return false if openDelim != @inlineOpen
      return false if silent

      res = Plugin.scan_delims(state, start, openDelim.length)
      startCount = res[:delims]

      if (!res[:can_open])
        state.pos += startCount
        # Earlier we checked !silent, but this implementation does not need it
        state.pending += state.src[start...state.pos]
        return true
      end

      state.pos = start + @inlineOpen.length

      while (state.pos < max)
        closeDelim = state.src[state.pos...state.pos + @inlineClose.length]
        if closeDelim == @inlineClose
          res = Plugin.scan_delims(state, state.pos, @inlineClose.length)
          if res[:can_close]
            found = true
            break
          end
        end
        state.md.inline.skipToken(state)
      end

      if (!found)
        # parser failed to find ending tag, so it's not valid emphasis
        state.pos = start
        return false
      end

      # found!
      state.posMax = state.pos
      state.pos    = start + @inlineClose.length

      # Earlier we checked !silent, but this implementation does not need it
      token        = state.push('math_inline', 'math', 0)
      token.content = state.src[state.pos...state.posMax]
      token.markup = @inlineOpen

      state.pos = state.posMax + @inlineClose.length
      state.posMax = max

      return true
    end

    def render_math_inline(tokens, idx, _options, env, renderer)
      @inlineRenderer.call(tokens[idx].content)
    end

    def self.scan_delims(state, start, delimLength)
      pos            = start
      left_flanking  = true
      right_flanking = true
      max            = state.posMax
      marker         = state.src.charCodeAt(start)

      # treat beginning of the line as a whitespace
      lastChar = start > 0 ? state.src.charCodeAt(start - 1) : 0x20

      if (pos >= max)
        can_open = false
      end

      pos += delimLength

      count = pos - start

      # treat end of the line as a whitespace
      nextChar = pos < max ? state.src.charCodeAt(pos) : 0x20

      isLastPunctChar = isMdAsciiPunct(lastChar) || isPunctChar(lastChar.chr(Encoding::UTF_8))
      isNextPunctChar = isMdAsciiPunct(nextChar) || isPunctChar(nextChar.chr(Encoding::UTF_8))

      isLastWhiteSpace = isWhiteSpace(lastChar)
      isNextWhiteSpace = isWhiteSpace(nextChar)

      if (isNextWhiteSpace)
        left_flanking = false
      elsif (isNextPunctChar)
        if (!(isLastWhiteSpace || isLastPunctChar))
          left_flanking = false
        end
      end

      if (isLastWhiteSpace)
        right_flanking = false
      elsif (isLastPunctChar)
        if (!(isNextWhiteSpace || isNextPunctChar))
          right_flanking = false
        end
      end

      can_open = left_flanking
      can_close = right_flanking

      return {can_open: can_open, can_close: can_close, delims: count}
    end

    def math_block(state, startLine, endLine, silent)
      pos = state.bMarks[startLine] + state.tShift[startLine]
      max = state.eMarks[startLine]

      return false if pos + @blockOpen.length > max

      openDelim = state.src[pos...pos + @blockOpen.length]

      return false if openDelim != @blockOpen

      pos += @blockOpen.length
      firstLine = state.src[pos...max]

      return true if silent

      haveEndMarker = false
      if firstLine.strip[-@blockClose.length..-1] == @blockClose
        firstLine = firstLine.strip[0...-@blockClose.length]
        haveEndMarker = true
      end

      nextLine = startLine

      while true
        break if haveEndMarker
        nextLine += 1
        break if nextLine >= endLine
        pos = state.bMarks[nextLine] + state.tShift[nextLine]
        max = state.eMarks[nextLine]

        break if pos < max && state.tShift[nextLine] < state.blkIndent

        next if state.src[pos...max].strip[-@blockClose.length..-1] != @blockClose

        next if state.tShift[nextLine] - state.blkIndent >= 4

        lastLinePos = state.src[0...max].rindex(@blockClose)
        lastLine = state.src[pos...lastLinePos]

        pos += lastLine.length + @blockClose.length

        pos = state.skipSpaces(pos)

        next if pos < max
        haveEndMarker = true
      end
      len = state.tShift[startLine]

      state.line = nextLine + (haveEndMarker ? 1 : 0)

      token = state.push('math_block', 'math', 0)
      token.block = true
      token.content = (firstLine && firstLine.strip ? "#{firstLine}\n" : '') +
        state.getLines(startLine + 1, nextLine, len, true) +
        (lastLine && lastLine.strip ? lastLine : '')
      token.info = nil
      token.map = [startLine, state.line]
      token.markup = @blockOpen

      return true
    end

    def render_math_block(tokens, idx, _options, env, renderer)
      @blockRenderer.call(tokens[idx].content)
    end
  end
end
