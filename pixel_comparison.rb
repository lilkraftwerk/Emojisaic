require 'JSON'
require 'pry'

class PixelComparer
  def initialize
    @map = JSON.parse(File.open('map.json').read)
    @scores = {}
    # take in a pixel or area
    # rgb 255
    # return the emoji that is closest to each of the
    # do it dumb at first then make it smarter yo.
    # get the min_by for each color 

    # go through each emoji in the map 
    # get and return the score for each emoji
  end

  def compare(pixel)
    @pixel = pixel
    set_pixel_colors
    check_every_emoji
    puts return_matching_emoji
  end

  def check_every_emoji
    @map.each do |filename, emoji_info|
      score_emoji(filename, emoji_info)
    end
  end

  def score_emoji(filename, emoji_info)
    @scores[filename] = set_score(emoji_info)
  end

  def set_score(emoji_info)
    score = 0
    score += absolute_difference(emoji_info['red'], @red)
    score += absolute_difference(emoji_info['green'], @green)
    score += absolute_difference(emoji_info['blue'], @blue)
    score
  end

  def return_matching_emoji
    minimum_score = @scores.values.min
    potentials = @scores.select { |_k, score| score == minimum_score }
    potentials.keys.sample
  end

  def set_pixel_colors
    @red = @pixel.red
    @green = @pixel.green
    @blue = @pixel.blue
  end

  def absolute_difference(x, y)
    (x - y).abs
  end
end

class PixelText
  attr_reader :green, :red, :blue

  def initialize
    @green = rand(255)
    @red = rand(255)
    @blue = rand(255)
  end

end

r = PixelComparer.new
pixel_test = PixelText.new

r.compare(pixel_test)