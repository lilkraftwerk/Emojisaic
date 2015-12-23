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
    @r = pixel.r
    @g = pixel.g
    @b = pixel.b
    match_filename = find_emoji(pixel)
    Magick::Image.read(match_filename)[0]
  end

  def find_emoji(pixel)
    return @done_emojis[pixel.to_s] if @done_emojis[pixel.to_s]
    check_every_emoji
    emoji = return_matching_emoji
    @done_emojis[pixel.to_s] = emoji
    emoji
  end

  def check_every_emoji
    @map.each do |filename, emoji_info|
      score_emoji(filename, emoji_info)
    end
  end

  def score_emoji(filename, emoji_info)
    @scores[filename] = return_score(emoji_info)
  end

  def return_score(info)
    (info['red'] - @r).abs + (info['green'] - @g).abs + (info['blue'] - @b).abs
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
    # @scores.values.max
    @options[:reverse] ? @scores.values.max : @scores.values.min
  end

  def set_pixel_colors
    @r = @pixel.red / 257
    @g = @pixel.green / 257
    @b = @pixel.blue / 257
  end

  def search_range
    return @options[:range] if @options[:range]
    false
  end
end
