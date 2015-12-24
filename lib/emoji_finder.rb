##
## Compare a set of given colors and return an emoji with similar colors
##
class EmojiFinder
  def initialize(options = {})
    @options = options[:finder]
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

  def return_score(i)
    score = (i['red'] - @r).abs + (i['green'] - @g).abs + (i['blue'] - @b).abs
    {
      score: score,
      coverage: i['coverage']
    }
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
    @scores.select { |_k, v| v == min }.keys.first
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
