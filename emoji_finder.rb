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
    @done_emojis = {}
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
    match_filename = find_emoji(pixel)
    Magick::Image.read(match_filename)[0]
  end

  def find_emoji(pixel)
    return @done_emojis[pixel.to_s] if @done_emojis[pixel.to_s]
    check_every_emoji
    emoji = return_matching_emoji
    add_to_done_emojis(pixel, emoji)
    emoji
  end

  def add_to_done_emojis(pixel, emoji)
    @done_emojis[pixel.to_s] = emoji
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
      potentials.keys.first
    end
  end

  def set_threshold
    @options[:reverse] ? @scores.values.max : @scores.values.min
  end

  def set_pixel_colors
    @red = @pixel.red / 257
    @green = @pixel.green / 257
    @blue = @pixel.blue / 257
  end

  def absolute_difference(x, y)
    (x - y).abs
  end

  def search_range
    return @options[:range] if @options[:range]
    false
  end
end
