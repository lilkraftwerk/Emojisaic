##
## Scan an image and return a map of average colors
##
class ImageScanner
  def initialize(options)
    @options = options
  end

  def generate_pixel_map(image, emoji_size)
    @image = image
    @emoji_size = emoji_size
    @pixels = []
    @x = 0
    @y = 0
    scan_image
    @pixels
  end

  def average_colors_for_area
    colors = { r: 0, g: 0, b: 0 }
    @emoji_size.times do |h|
      new_y = @y + h
      @emoji_size.times do |w|
        new_x = @x + w
        results = get_pixel_colors(new_x, new_y)
        colors = add_results_to_tally(results, colors)
      end
    end
    create_pixel_struct(colors)
  end

  def create_pixel_struct(colors)
    div = divide_pixels(colors, @emoji_size**2)
    Pixel.new(@x, @y, div[:r], div[:g], div[:b])
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
        @pixels << average_colors_for_area
        @x += @emoji_size
      end
      @x = 0
      @y += @emoji_size
      update unless @options[:quiet]
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
Pixel = Struct.new(:x, :y, :r, :g, :b)
