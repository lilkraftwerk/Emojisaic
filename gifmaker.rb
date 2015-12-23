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
    get_delay_info
    write_frames
    @files.each_with_index do |filename, index|
      puts "Doing frame #{index}/#{@files.length}"
      @generator.create_image(filename)
    end
    write_gif
  end

  def get_delay_info
    delays = []
    @image.each { |frame| delays << frame.delay }
    delays
  end

  def write_gif
    gif = Magick::ImageList.new
    gif.ticks_per_second = @image.ticks_per_second
    delays = get_delay_info
    bar = ProgressBar.new(@files.length, 'writing gif')
    @files.each do |filename|
      new_frame = Magick::Image.read(filename)[0]
      new_frame.delay = delays.shift
      gif << new_frame
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
    quality: 1,
    # random_offset: 0.2
  },
  compare: {
    # range: 0
  }
}

gif = GifMaker.new(options)
gif.make_emoji_gif('xwing')

# preview = PreviewGenerator.new
# preview.make_preview('obiwan', 5, 8)



