##
## Generates emoji mosaics
##
class EmojiMosaicGenerator
  def initialize(options = {})
    @options = options
    create_helpers
    set_quality
  end

  def create_image(filename)
    regex = %r{\/?([\w-]+)\.}
    @name = regex.match(filename)[1]
    assign_images_and_pixel_map(filename)
    @bar = ProgressBar.new(@pixel_map.length, 'image generation') unless @options[:quiet]
    add_emojis_to_new_image
    filename[@name] = "#{@name}-mosaic"
    @new_image.write(filename)
    filename
  end

  def assign_images_and_pixel_map(filename)
    @image = Magick::Image.read(filename)[0]
    @new_image = Magick::Image.new(@image.columns * @zoom, @image.rows * @zoom)
    @pixel_map = @scanner.generate_pixel_map(@image, @emoji_size)
  end

  def add_emojis_to_new_image
    @pixel_map.each do |p_map|
      p_map = adjust_coordinates(p_map)
      emoji = @finder.closest_emoji(p_map)
      emoji.resize!(@emoji_size * @zoom, @emoji_size * @zoom)
      @new_image.composite!(emoji, p_map.x, p_map.y, Magick::OverCompositeOp)
      @bar.add(1) unless @options[:quiet]
    end
  end

  private

  def adjust_coordinates(pixel_map)
    pixel_map[:x] *= @zoom
    pixel_map[:y] *= @zoom
    pixel_map = randomize_offset(pixel_map) if @options[:random_offset]
    pixel_map
  end

  def randomize_offset(pixel)
    offset = @options[:random_offset]
    pixel.x += rand(-offset..offset)
    pixel.y += rand(-offset..offset)
    pixel
  end

  def create_helpers
    @scanner = ImageScanner.new(@options)
    @finder = EmojiFinder.new(@options)
  end

  def set_quality
    @emoji_size = @options[:size]
    @zoom = @options[:zoom]
  end
end
