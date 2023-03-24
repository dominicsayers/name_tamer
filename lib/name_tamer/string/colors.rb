# frozen_string_literal: true

# Colorize strings
class String
  colors = %w[black red green yellow blue magenta cyan white]

  colors.each_with_index do |fg_color, i|
    fg = 30 + i
    define_method(fg_color) { ansi_attributes(fg) }

    colors.each_with_index do |bg_color, j|
      define_method("#{fg_color}_on_#{bg_color}") { ansi_attributes(fg, 40 + j) }
    end
  end

  def ansi_attributes(*args)
    "\e[#{args.join(';')}m#{self}\e[0m"
  end
end
