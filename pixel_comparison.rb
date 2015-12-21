require 'JSON'
require 'pry'

class PixelComparer
  def initialize
    @map = JSON.parse(File.open('map.json').read)
    @scores = {}
  end

  def compare_pixel(pixel)
    @pixel = pixel
    set_pixel_colors
    check_every_emoji
    return_matching_emoji
  end

  def compare_rgb(r, g, b)
    @red = r
    @green = g
    @blue = b
    check_every_emoji
    return_matching_emoji
  end

  def check_every_emoji
    @map.each do |filename, emoji_info|
      score_emoji(filename, emoji_info)
    end
  end

  def score_emoji(filename, emoji_info)
    @scores[filename] = return_score(emoji_info)
  end

  def return_score(emoji_info)
    score = 0
    score += absolute_difference(emoji_info['red'], @red)
    score += absolute_difference(emoji_info['green'], @green)
    score += absolute_difference(emoji_info['blue'], @blue)
    score
  end

  def return_matching_emoji
    # minimum_score = @scores.values.min
    # potentials = @scores.select { |_k, score| score == minimum_score }
    # potentials.keys.sample
    ### good place for a variable
    @scores.sort_by{ |k, v| v }[0..1].sample.first
  end

  def set_pixel_colors
    @red = @pixel.red / 257
    @green = @pixel.green / 257
    @blue = @pixel.blue / 257
  end

  def absolute_difference(x, y)
    (x - y).abs
  end
end