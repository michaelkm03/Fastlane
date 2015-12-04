require 'colorize'

module VAMS
  class ColoredLogger < Logger
    def error(message)
      super(message.colorize(:white).on_red)
    end
  end
end
