require 'thor'

class Thor
  module Shell
    class Color < Basic
      # The start of an ANSI dim sequence.
      DIM       = "\e[2m"
      # The start of an ANSI underline sequence.
      UNDERLINE = "\e[4m"

      # Set the terminal's foreground ANSI color to dark gray.
      DARK_GRAY = "\e[90m"
    end
  end
end
