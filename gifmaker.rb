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
    @image = Magick::ImageList.new.read(@filename).coalesce
    write_frames
    @files.each_with_index do |filename, index|
      puts "Doing frame #{index}/#{@files.length}"
      @generator.create_image(filename)
    end
    write_gif
  end

  def write_gif
    puts "frames emoji'd, now writing gif...."
    gif = Magick::ImageList.new
    bar = ProgressBar.new(@files.length, 'writing gif')
    @files.each do |frame|
      this_frame = Magick::Image.read(frame)[0]
      gif << this_frame
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
    quality: 3,
    # random_offset: 0.2
  },
  compare: {
    # range: 0
  }
}
t = GifMaker.new(options)
# t.make_emoji_gif('akira3')
# t.make_emoji_gif('loop')
# t.make_emoji_gif('bb82')
# t.make_emoji_gif('whales')
# t.make_emoji_gif('arnold')
# t.make_emoji_gif('togepi')
# t.make_emoji_gif('bulba')
# t.make_emoji_gif('glitch1')
# t.make_emoji_gif('glitch2')
# t.make_emoji_gif('eyes')
t.make_emoji_gif('nate')










