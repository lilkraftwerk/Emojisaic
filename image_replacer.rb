require 'Rmagick'
require 'JSON'

require_relative 'pixel_comparison'

class ImageReplacer
  def initialize
    @comparer = PixelComparer.new
    # get each pixel or set of pixels
    # create a new image
    # for each pixel or set of pixels, replace with emoji

  end

  def replace_image(filename)
    @old_image = Magick::Image.read(filename)[0]
    @new_image = Magick::Image.new(@old_image.columns, @old_image.rows)
    scan_old_image
    p @pixels
    add_emojis_to_new_image
  end


  def scan_old_image
    @pixels = []
    @old_image.columns.times do |x|
      puts "#{x} / #{@old_image.columns}"
      @old_image.rows.times do |y|
        pixel = @old_image.pixel_color(x, y)
        emoji = @comparer.compare(pixel)
        @pixels << [x, y, emoji]
      end
    end
  end

  def add_emojis_to_new_image
    puts "adding emojis now"
    @pixels.each do |pixel_map|
      x = pixel_map[0]
      y = pixel_map[1]
      emoji = Magick::Image.read(pixel_map[2])[0]
      emoji.resize!(8, 8)
      @new_image.composite!(emoji, x, y, Magick::OverCompositeOp)
    end
    @new_image.write('giraffe.jpg')
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

c = ImageReplacer.new
c.replace_image('images/giraffe.jpg')