require_relative 'progress'
require_relative 'pixel_comparison'

##
## Scan an image and return a map of average colors
##

class ImageScanner
  def generate_pixel_map(image, emoji_size)
    @image = image
    @emoji_size = emoji_size
    @pixels = []
    scan_image
    @pixels
  end

  def average_area(start_x, start_y, width, height)
    colors = { r: 0, g: 0, b: 0 }
    height.times do |h|
      y = start_y + h
      width.times do |w|
        x = start_x + w
        results = get_pixel_colors(x, y)
        colors = add_results_to_tally(results, colors)
      end
    end
    format_color_averages(start_x, start_y, colors, width, height)
  end

  def format_color_averages(start_x, start_y, colors, width, height)
    div = divide_pixels(colors, width * height)
    { x: start_x, y: start_y, r: div[:r], g: div[:g], b: div[:b] }
  end

  def add_results_to_tally(results, colors)
    colors[:r] += results[:r]
    colors[:g] += results[:g]
    colors[:b] += results[:b]
    colors
  end

  def scan_image
    x = 0
    y = 0
    until y > @image.rows
      until x > @image.columns
        @pixels << Pixel.new(average_area(x, y, @emoji_size, @emoji_size))
        x += @emoji_size
      end
      x = 0
      y += @emoji_size
    end
  end

  def divide_pixels(colors, total)
    {
      r: colors[:r] / total,
      g: colors[:g] / total,
      b: colors[:b] / total
    }
  end

  def get_pixel_colors(x, y)
    pixel = @image.pixel_color(x, y)
    {
      r: pixel.red / 257,
      g: pixel.green / 257,
      b: pixel.blue / 257
    }
  end

  def scan_pixel(pixel)
    @red += pixel.red / 257
    @blue += pixel.blue / 257
    @green += pixel.green / 257
  end
end

##
## Just a little holder for information about pixel color and location
##

class Pixel
  attr_accessor :x, :y, :r, :g, :b

  def initialize(options)
    @x = options[:x]
    @y = options[:y]
    @r = options[:r]
    @g = options[:g]
    @b = options[:b]
  end
end
