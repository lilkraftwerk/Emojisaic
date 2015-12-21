require 'Rmagick'
require 'JSON'
require 'pry'

require_relative 'progress'
require_relative 'image_generator'

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
    @image = Magick::ImageList.new.read(@filename)
    @image = @image.coalesce
    write_frames
    # bar = ProgressBar.new(@files.length, 'creating gif frames')
    @files.each do |filename|
      @generator.create_image(filename)
    end
    write_gif
  end

  def write_gif
    gif = Magick::ImageList.new
    bar = ProgressBar.new(@files.length, 'writing gif')
    @files.each do |frame|
      this_frame = Magick::Image.read(frame)[0]
      gif << this_frame
      bar.add(1)
    end
    gif.write("output/#{@filename}.gif")
  end

  def write_frames
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
    quality: 1,
    random_offset: 0
  },
  compare: {
    range: 100
  }
}
t = GifMaker.new(options)

t.make_emoji_gif('akira1')
# t.make_emoji_gif('akira2')
# t.make_emoji_gif('akira3')
