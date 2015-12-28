##
## Compare a set of given colors and return an emoji with similar colors
##
require 'pry'

### if you've already seen the same combination of pixel colors
### no need to go through all again
class EmojiFinder
  def initialize(options = {})
    @options = options[:finder]
    @map = JSON.parse(File.open('lib/map.json').read)
    @done_pixels = {}
  end

  def closest_emoji(pixel)
    @r = pixel.r
    @g = pixel.g
    @b = pixel.b
    match_filename = look_up_or_find_emoji(pixel)
    Magick::Image.read(match_filename)[0]
  end

  def look_up_or_find_emoji(pixel)
    pixel_i = "#{pixel.r}#{pixel.g}#{pixel.b}".to_i
    @done_pixels[pixel_i] ||= find_emoji(pixel)
  end

  def find_emoji(pixel)
    @scores = {}
    emoji = find_best_scoring_emoji
    @done_pixels["#{pixel.r}#{pixel.g}#{pixel.b}".to_i] = emoji
    emoji
  end

  def find_best_scoring_emoji
    best_scores = @map.min_by(@options[:coverage]) do |filename, rgb|
      (rgb['red'] - @r).abs + (rgb['green'] - @g).abs + (rgb['blue'] - @b).abs 
    end
    if @options[:coverage]
      chosen_one = best_scores.max_by{|x| x[1]["coverage"]}[0] if @options[:coverage]
    else
      chosen_one = best_scores[0]
    end
  end

  def score_emoji(filename, emoji_info)
    @scores[filename] = return_score(emoji_info)
  end

  def return_score(i)
    score = (i['red'] - @r).abs + (i['green'] - @g).abs + (i['blue'] - @b).abs
    Score.new(score, i['coverage'])
  end

  def return_matching_emoji
    if @options[:coverage]
      sort_by_pixel_coverage_and_color
    else
      sort_by_color
    end
  end

  def sort_by_pixel_coverage_and_color
    sorted = @scores.sort_by { |_k, v| v[:score] }[0..@options[:coverage]]
    sorted.sort_by { |r| r[1][:coverage] }.reverse.first.first
  end

  def sort_by_color
    min = @scores.values.min_by { |v| v[:score] }
    t = @scores.find { |_k, v| v == min }
  end

  def set_pixel_colors
    @r = @pixel.red / 257
    @g = @pixel.green / 257
    @b = @pixel.blue / 257
  end

  def set_coverage_threshold
    return false unless @options[:coverage]
    @coverage_threshold = @options[:coverage]
  end

  def search_range
    return @options[:range] if @options[:range]
    false
  end
end


Score = Struct.new(:score, :coverage)