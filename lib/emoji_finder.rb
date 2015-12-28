##
## Compare a set of given colors and return an emoji with similar colors
##
class EmojiFinder
  def initialize(options = {})
    @options = options
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
    @done_pixels["#{pixel.r}#{pixel.g}#{pixel.b}".to_i] ||= find_emoji(pixel)
  end

  def find_emoji(pixel)
    emoji = find_best_scoring_emoji
    @done_pixels["#{pixel.r}#{pixel.g}#{pixel.b}".to_i] = emoji
    emoji
  end

  def find_best_scoring_emoji
    scores = @map.min_by(@options[:coverage]) do |_, rgb|
      score_emoji(rgb)
    end

    return emoji_with_max_coverage(scores) if @options[:coverage]
    scores.first
  end

  def score_emoji(rgb)
    (rgb['red'] - @r).abs + (rgb['green'] - @g).abs + (rgb['blue'] - @b).abs
  end

  def emoji_with_max_coverage(scores)
    scores.max_by { |x| x[1]['coverage'] }[0]
  end
end
