# frozen_string_literal: true

class Array
  def neighbours
    last_index = length - 1
    0.upto(last_index).flat_map { |i| i.upto(last_index).map { |j| self[i..j] } }
  end
end
