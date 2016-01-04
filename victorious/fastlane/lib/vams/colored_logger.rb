require 'colorize'
require 'logger'

module VAMS
  class ColoredLogger < Logger
    def error(message)
      super(message.colorize(:white).on_red)
    end
  end
end
