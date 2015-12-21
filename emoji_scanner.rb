require 'Rmagick'
require 'json'

class EmojiScanner
  def initialize(filename)
    @filename = filename
    @image = Magick::Image.read(@filename)[0]
    init_colors
    init_total
    scan_emoji
    divide_result
    output
  end

  def init_total
    @total_pixels = @image.columns * @image.rows
  end

  def init_colors
    @red = 0
    @blue = 0
    @green = 0
    @counted_pixels = 0
  end

  def divide_result
    @red /= @counted_pixels
    @blue /= @counted_pixels
    @green /= @counted_pixels
  end

  def output
    puts "doing #{@filename}"
    full_list = JSON.parse(File.open('map.json').read)
    full_list[@filename] = {
      red: @red,
      green: @green,
      blue: @blue
    }

    File.open('map.json', 'w') do |f|
      f.write(JSON.pretty_generate(full_list))
    end
  end

  def scan_emoji
    @image.columns.times do |x|
      @image.rows.times do |y|
        pixel = @image.pixel_color(x, y)
        scan_pixel(pixel)
      end
    end
  end

  def scan_pixel(pixel)
    return if (pixel.opacity / 257) > 245
    @counted_pixels += 1
    @red += pixel.red / 257
    @blue += pixel.blue / 257
    @green += pixel.green / 257
  end
end

def generate_emoji_map
  File.open('map.json', 'w') do |f|
    f.write(JSON.pretty_generate({}))
  end

  dir = Dir['emojis/*.png']
    # EmojiScanner.new('images/white.png')

  dir.each do |file|
    EmojiScanner.new(file)
  end
end

generate_emoji_map
