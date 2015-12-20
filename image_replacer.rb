require_relative 'pixel_comparison'

class ImageReplacer
  def initialize
    @comparer = PixelComparer.new
    # get each pixel or set of pixels
    # create a new image
    # for each pixel or set of pixels, replace with emoji
  end

  def replace_image(filename)
    @filename = filename
    @old_image = Magick::Image.read(filename)[0]
    @new_image = Magick::Image.new(@old_image.columns, @old_image.rows)
    scan_in_blocks
    add_emojis_in_blocks
  end

  def scan_in_blocks
    @pixels = []
    x = 0
    y = 0
    until y > @old_image.rows
      until x > @old_image.columns
        @pixels << average_area(x, y, 8, 8)
        x += 8
      end
      x = 0
      y += 8
    end
  end

  def average_area(start_x, start_y, width, height)
    total_pixels = width * height
    red = 0
    green = 0
    blue = 0

    height.times do |h|
      y = start_y + h 
      width.times do |w|
        x = start_x + w
        pixel = @old_image.pixel_color(x, y)
        red += pixel.red / 257
        blue += pixel.blue / 257
        green += pixel.green / 257
      end
    end
    red = red / total_pixels
    green = green / total_pixels
    blue = blue / total_pixels
    result = [start_x, start_y, red, green, blue]
    result 
  end

  def scan_old_image
    @pixels = []
    @old_image.columns.times do |x|
      @old_image.rows.times do |y|
        pixel = @old_image.pixel_color(x, y)
        emoji = @comparer.compare(pixel)
        @pixels << [x, y, emoji]
      end
    end
  end

  def add_emojis_in_blocks
    # [start_x, start_y, red, green, blue]
    @pixels.each_with_index do |pixel_map, index|
      x = pixel_map[0]
      y = pixel_map[1]
      r = pixel_map[2]
      g = pixel_map[3]
      b = pixel_map[4]
      # x += rand(-1..1)
      # y += rand(-1..1)
      emoji_filename = @comparer.compare_rgb(r, g, b)      
      emoji = Magick::Image.read(emoji_filename)[0]
      emoji.resize!(8, 8)
      @new_image.composite!(emoji, x, y, Magick::OverCompositeOp)
    end
    @new_image.write("#{@filename}")
  end

  def add_emojis_to_new_image
    puts "adding emojis now"
    @pixels.each do |pixel_map|
      x = pixel_map[0] + rand(-3..3)
      y = pixel_map[1] + rand(-3..3)
      emoji = Magick::Image.read(pixel_map[2])[0]
      emoji.resize!(8, 8)
      @new_image.composite!(emoji, x, y, Magick::OverCompositeOp)
    end
    @new_image.write(filename)
  end

    #start at 0 0 
    # move right by 16 px
    #when x is greater than total width, move down 16 px
    # start over
    # when y is greater than total, print image

  def scan_pixel(pixel)
    @red += pixel.red / 257
    @blue += pixel.blue / 257
    @green += pixel.green / 257
  end
end

