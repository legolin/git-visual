module DecolorizeBash
  ESC_SEQ = Regexp.new("(.*?)\\e\\[([^m]+)+m")
  # Example: \e[36mUN\e[35mI\e[5mT\e[33mE\e[4mD\e[0m \e[1m\e[31mCO\e[32mL\e[5mO\e[34mR\e[4mS\e[0m
  # Renders: <fg-cyan>UN<fg-magenta>I<BLINK>T<fg-yellow>E<underline>D<RESET> <bold><fg-red>CO<fg-green>L<BLINK>O<fg-blue>R<underline>S<reset>

  class Chain
    attr_reader :first_node
    
    def initialize(string)
      @nodes = [Node.send(:allocate)]
      expand_string_to_nodes(string)
    end

    def to_s
      @nodes.collect {|n| n.text}.join
    end

    def to_html
      state = Node.send(:allocate)
      html = ''
      @nodes.each do |node|
        # Currently only working with background color and foreground colorizing
        add = {}
        add[:fg] = node.fg if node.fg != state.fg
        add[:bg] = node.bg if node.bg != state.bg
        html += '</span>' if (state.fg && add[:fg]) || (state.bg && add[:bg])
        style = []
        style << "color:#{add[:fg]}" if add[:fg]
        style << "background-color:#{add[:bg]}" if add[:bg]
        html += "<span style='#{style.join(';')}'>" if add[:fg] || add[:bg]
        html += node.text
        state = node
      end
      html += '</span>' if state.fg || state.bg
      html
    end

    private
      def expand_string_to_nodes(string)
        # For each escape code until the next, call next_from_segment(code, text)
        while(esc_code = string.match(ESC_SEQ))
          @nodes[-1].text = esc_code[1] if esc_code[1] != ''
          @nodes << @nodes[-1].next_from_segment(esc_code[2].to_s.split(';'))
          string.slice!(ESC_SEQ)
        end
      end
  end

  # Each bit of text will be in a Node. The Node will hold a sequence of text with its attributes,
  # and after that the sequence will be converted into blocks of spans with classes.
  class Node
    STYLES = {
      0 => 'normal',
      1 => 'bold',
      2 => 'normal',
      4 => 'underline',
      5 => 'blink'
    }
    FOREGROUND = 3
    BACKGROUND = 4
    COLORS = {
      0 => 'black',
      1 => 'red',
      2 => 'green',
      3 => 'yellow',
      4 => 'blue',
      5 => 'magenta',
      6 => 'cyan',
      7 => 'white'
    }

    attr_accessor :previous_node, :fg, :bg, :styles, :text
    def text; @text.to_s end

    def initialize(previous_node, codes)
      raise ArgumentError unless previous_node.is_a?(Node)
      @fg = previous_node.fg
      @bg = previous_node.bg
      @styles = previous_node.styles
      codes.each do |code|
        code = code.to_s
        if code.length == 1 # is a style
          # Not using styles yet 'cause I have to learn how to recognize the end-bold or end-underline escape-codes - ??
        elsif code[0..0] == '3' # is a foreground color
          @fg = COLORS[code[1..1].to_i]
        elsif code[0..0] == '4' # is a background color
          @bg = COLORS[code[1..1].to_i]
        end
      end
    end

    def next_from_segment(codes)
      # Determine the code, create a Node with the proper attributes
      self.class.new(self, codes)
    end
  end
end
