require_relative 'progress'
require_relative 'emoji_finder'

##
## Scan an image and return a map of average colors
##
class ImageScanner
  def generate_pixel_map(image, emoji_size)
    @image = image
    @emoji_size = emoji_size
    @pixels = []
    @x = 0
    @y = 0
    scan_image
    @pixels
  end

  def average_area
    colors = { r: 0, g: 0, b: 0 }
    @emoji_size.times do |h|
      new_y = @y + h
      @emoji_size.times do |w|
        new_x = @x + w
        results = get_pixel_colors(new_x, new_y)
        colors = add_results_to_tally(results, colors)
      end
    end
    format_color_averages(colors)
  end

  def format_color_averages(colors)
    div = divide_pixels(colors, @emoji_size**2)
    { x: @x, y: @y, r: div[:r], g: div[:g], b: div[:b] }
  end

  def add_results_to_tally(results, colors)
    colors[:r] += results[:r]
    colors[:g] += results[:g]
    colors[:b] += results[:b]
    colors
  end

  def scan_image
    until @y > @image.rows
      until @x > @image.columns
        @pixels << Pixel.new(average_area)
        @x += @emoji_size
      end
      @x = 0
      @y += @emoji_size
      update
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

  def update
    @bar = ProgressBar.new(@image.rows, 'image scanning') unless @bar
    @bar.set(@y)
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

  def to_s
    "#{@r}#{@g}#{b}"
  end
end
