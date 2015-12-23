require 'Rmagick'
require 'JSON'
require 'pry'

require_relative 'progress'
require_relative 'image_generator'
require_relative 'preview_generator'


##
## Creates multiple emoji mosaics and strings them together into an animation
##
class GifMaker
  def initialize(options = {})
    @generator = EmojiMosaicGenerator.new(options)
  end

  def make_emoji_gif(name)
    @name = name
    @filename = "input/#{@name}.gif"
    @new_filenames = []
    @image = Magick::ImageList.new.read(@filename).coalesce
    write_frames
    @files.each_with_index do |filename, index|
      puts "Doing frame #{index}/#{@files.length}"
      @new_filenames << @generator.create_image(filename)
    end
    write_gif
    puts "done!"
  end

  def write_gif
    gif = Magick::ImageList.new
    gif.ticks_per_second = @image.ticks_per_second
    @new_filenames.each_with_index do |filename, index|
      new_frame = Magick::Image.read(filename)[0]
      new_frame.delay = @image[index].delay
      gif << new_frame
    end
    dest = "output/#{@name}.gif"
    puts "Writing to #{dest}..."
    gif.write(dest)
  end

  def write_frames
    puts 'splitting gif into frames...'
    @files = []
    @image.each_with_index do |image, index|
      index > 9 ? number = index : number = "0#{index}"
      new_filename = "tmp/#{@name}-#{number}.png"
      image.write(new_filename)
      @files << new_filename
    end
  end
end

options = {
  generator: {
    noisy: true,
    quality: 5,
    # random_offset: 0.2
  },
  compare: {
    # range: 0
  }
}

gif = GifMaker.new(options)
gif.make_emoji_gif('xmas')

preview = PreviewGenerator.new
# preview.make_preview('xwing', 18, 30)



