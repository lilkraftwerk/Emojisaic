require 'Rmagick'
require 'JSON'
require 'pry'

require_relative 'image_replacer'

class GifMaker
  def initialize
    @replacer = ImageReplacer.new
  end

  def make_emoji_gif(name)
    puts "doing #{name}"
    @name = name
    @image = Magick::Image.read("images/#{name}.gif")
    # binding.pry
    write_frames
    @files.each_with_index do |filename, index|
      puts "on frame #{index + 1} of #{@files.length}"
      # @replacer.replace_image(filename)
    end
    # write_gif
  end

  def write_gif
    gif = Magick::ImageList.new
    @files.each do |frame|
      gif << Magick::Image.read(frame)[0]
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
      duplicate = image.dup
      duplicate.write(new_filename)
    end
  end
end

t = GifMaker.new
t.make_emoji_gif('leia')
t.make_emoji_gif('bb8')
t.make_emoji_gif('skully')
