require 'Rmagick'
require 'JSON'
require 'pry'

require_relative 'progress'
require_relative 'image_replacer'

##
## Creates multiple emoji mosaics and strings them together into an animation
##
class GifMaker
  def initialize(options = {})
    @replacer = ImageReplacer.new(options)
  end

  def make_emoji_gif(name)
    @name = name
    @image = Magick::ImageList.new.read("images/#{name}.gif")
    @image = @image.coalesce
    write_frames
    # bar = ProgressBar.new(@files.length, 'creating gif frames')
    @files.each do |filename|
      @replacer.replace_image(filename)
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
    gif.write("output/#{@name}.gif")
  end

  def write_frames
    @files = []
    @image.each_with_index do |image, index|
      index > 9 ? filename = index : filename = "0#{index}"
      new_filename = "tmp/#{@name}-#{filename}.png"
      @files << new_filename
      image.write(new_filename)
    end
  end
end

# options = {
#   replace: {
#     noisy: true,
#     quality: 5,
#     # random_offset: 0
#   },
#   compare: {
#     # range: 100
#   }
# }
# t = GifMaker.new(options)

# t.make_emoji_gif('akira1')
# t.make_emoji_gif('akira2')
# t.make_emoji_gif('akira3')
