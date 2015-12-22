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
    @image = Magick::ImageList.new.read(@filename).coalesce
    write_frames
    @files.each_with_index do |filename, index|
      puts "Doing frame #{index}/#{@files.length}"
      @generator.create_image(filename)
    end
    write_gif
  end

  def write_preview
    gif = Magick::ImageList.new
    gif << Magick::Image.read(@files[0])[0]
    gif << Magick::Image.read(@files[1])[0]
    gif << Magick::Image.read(@files[2])[0]
    output_dest = "output/#{@name}-preview.gif"
    gif.write(output_dest)
    puts "wrote preview to #{output_dest}"
  end

  def write_gif
    gif = Magick::ImageList.new
    bar = ProgressBar.new(@files.length, 'writing gif')
    @files.each do |frame|
      gif << Magick::Image.read(frame)[0]
      bar.add(1)
    end
    output_dest = "output/#{@name}.gif"
    gif.write(output_dest)
    puts "wrote to #{output_dest}"
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
# gif = GifMaker.new(options)
# gif.make_emoji_gif('xwing')

# preview = PreviewGenerator.new
# preview.make_preview('obiwan', 5, 8)



