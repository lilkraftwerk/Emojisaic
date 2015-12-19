require 'Rmagick'

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
  end

  def divide_result
    @red = @red / @total_pixels
    @blue = @blue / @total_pixels
    @green = @green / @total_pixels
  end

  def output
    puts @filename
    puts @red
    puts @green
    puts @blue
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
    @red += pixel.red / 257
    @blue += pixel.blue / 257
    @green += pixel.green / 257
  end
end