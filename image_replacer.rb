require_relative 'progress'
require_relative 'pixel_comparison'

class ImageReplacer
  def initialize
    @comparer = PixelComparer.new
    @emoji_size = 8
  end

  def replace_image(filename)
    regex = /\/(.+)\./
    @name = regex.match(filename)[1]
    @filename = filename
    @old_image = Magick::Image.read(filename)[0]
    @new_image = Magick::Image.new(@old_image.columns, @old_image.rows)
    scan_in_blocks
    add_emojis_in_blocks
    all_done
  end

  def scan_in_blocks
    @pixels = []
    x = 0
    y = 0

    bar = ProgressBar.new(@old_image.rows, 'image scan')

    until y > @old_image.rows
      until x > @old_image.columns
        @pixels << average_area(x, y, @emoji_size, @emoji_size)
        x += @emoji_size
      end
      x = 0
      y += @emoji_size
      bar.add(@emoji_size)
    end
  end

  def average_area(start_x, start_y, width, height)
    pixel_count = width * height
    colors = { r: 0, g: 0, b: 0 }
    height.times do |h|
      y = start_y + h 
      width.times do |w|
        x = start_x + w
        results = get_pixel_colors(x, y)
        colors[:r] += results[:r]
        colors[:b] += results[:b]
        colors[:g] += results[:g]
      end
    end
    div = divide_pixels(colors, pixel_count)
    { x: start_x, y: start_y, r: div[:r], g: div[:g], b: div[:b] }
  end

  def divide_pixels(colors, total)
    {
      r: colors[:r] / total,
      g: colors[:g] / total,
      b: colors[:b] / total
    }
  end


  def get_pixel_colors(x, y)
    pixel = @old_image.pixel_color(x, y)

    {
      r: pixel.red / 257,
      g: pixel.green / 257,
      b: pixel.blue / 257
    }
  end

  def add_emojis_in_blocks
    bar = ProgressBar.new(@pixels.length, 'new image generation')

    @pixels.each do |pixel_map|

      x = pixel_map[:x]
      y = pixel_map[:y]
      r = pixel_map[:r]
      g = pixel_map[:g]
      b = pixel_map[:b]

      # x += rand(-1..1)
      # y += rand(-1..1)

      emoji_filename = @comparer.compare_rgb(r, g, b)      
      emoji = Magick::Image.read(emoji_filename)[0]
      emoji.resize!(@emoji_size, @emoji_size)
      @new_image.composite!(emoji, x, y, Magick::OverCompositeOp)

      bar.add(1)
    end
  end

  def all_done
    @filename[@name] = "#{@name}-mosaic"
    puts
    puts "all done! writing #{@filename}"
    @new_image.write("#{@filename}")
  end

  def scan_pixel(pixel)
    @red += pixel.red / 257
    @blue += pixel.blue / 257
    @green += pixel.green / 257
  end
end
