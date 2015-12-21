require 'Rmagick'
require 'JSON'
require 'pry'

require_relative 'progress'
require_relative 'image_replacer'

class GifMaker
  def initialize
    @replacer = ImageReplacer.new
  end

  def make_emoji_gif(name)
    puts "doing #{name}"
    @name = name
    @image = Magick::ImageList.new.read("images/#{name}.gif")
    @image = @image.coalesce
    write_frames

    bar = ProgressBar.new(@files.length, 'creating gif frames')

    @files.each_with_index do |filename, index|
      # puts "on frame #{index + 1} of #{@files.length}"
      @replacer.replace_image(filename)
      bar.add(1)
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
      if index > 9
        filename = index
      else
        filename = "0#{index}"
      end
      new_filename = "tmp/#{@name}-#{filename}.png"
      @files << new_filename
      image.write(new_filename)
    end
  end
end

t = GifMaker.new
t.make_emoji_gif('ash')
