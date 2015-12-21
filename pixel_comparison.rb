require 'JSON'
require 'pry'

##
## Compare a set of given colors and return an emoji with similar colors
##
class EmojiFinder
  def initialize(options = {})
    @options = options[:compare]
    @map = JSON.parse(File.open('map.json').read)
    @scores = {}
  end

  def compare_pixel(pixel)
    @pixel = pixel
    set_pixel_colors
    check_every_emoji
    return_matching_emoji
  end

  def closest_emoji(pixel)
    @red = pixel.r
    @green = pixel.g
    @blue = pixel.b
    check_every_emoji
    match_filename = return_matching_emoji
    Magick::Image.read(match_filename)[0]
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
    if search_range
      return @scores.sort_by { |_k, v| v }[0..search_range].sample.first
    else
      threshold = set_threshold
      potentials = @scores.select { |_k, score| score == threshold }
      potentials.keys.sample
    end
  end

  def set_threshold
    reverse? ? @scores.values.max : @scores.values.min
  end

  def reverse?
    @options[:reverse]
  end

  def set_pixel_colors
    @red = @pixel.red / 257
    @green = @pixel.green / 257
    @blue = @pixel.blue / 257
  end

  def absolute_difference(x, y)
    (x - y).abs
  end

  private

  def search_range
    return @options[:range] if @options[:range]
    false
  end
end
