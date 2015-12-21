require_relative 'image_scanner'
require 'pathname'
require 'pry'

##
## Generates emoji mosaics
##
class EmojiMosaicGenerator
  def initialize(options = {})
    @options = options[:generator]
    create_helpers(options)
    set_quality
  end

  def create_image(filename, output_dir = '')
    regex = /\/(.+)\./
    @name = regex.match(filename)[1]
    @image = Magick::Image.read(filename)[0]
    @new_image = Magick::Image.new(@image.columns * @zoom, @image.rows * @zoom)
    @pixel_map = @scanner.generate_pixel_map(@image, @emoji_size)
    add_emojis_to_new_image
    new_filename = filename[@name] = "#{@name}-mosaic"
    @new_image.write("#{output_dir}/#{filename}") if output_dir != ''
    @new_image.write(new_filename) unless output_dir != ''
    new_filename
  end

  def add_emojis_to_new_image
    @pixel_map.each do |p_map|
      p_map = adjust_coordinates(p_map)
      emoji = @comparer.closest_emoji(p_map)
      emoji.resize!(@emoji_size * @zoom, @emoji_size * @zoom)
      @new_image.composite!(emoji, p_map.x, p_map.y, Magick::OverCompositeOp)
      update
    end
  end

  private

  def update
    @bar = ProgressBar.new(@pixel_map.length, 'image generation') unless @bar
    @bar.add(1)
  end

  def adjust_coordinates(pixel_map)
    pixel_map.x *= @zoom
    pixel_map.y *= @zoom
    pixel_map = randomize_offset(pixel_map) if @options[:random_offset]
    pixel_map
  end

  def randomize_offset(pixel)
    offset = @options[:random_offset]
    pixel.x += rand(-offset..offset)
    pixel.y += rand(-offset..offset)
    pixel
  end

  def create_progress_bar
    @bar = ProgressBar.new(@pixel_map.length, 'new image generation') if noisy?
  end

  def create_helpers(options)
    @scanner = ImageScanner.new
    @comparer = EmojiFinder.new(options)
  end

  def noisy?
    @options[:noisy]
  end

  def set_quality
    quality_map = [[16, 1], [16, 2], [8, 2], [4, 1], [2, 2]]
    return quality_map[2] unless @options[:quality]
    selected_quality = quality_map[@options[:quality] - 1]
    @emoji_size = selected_quality[0]
    @zoom = selected_quality[1]
  end
end
