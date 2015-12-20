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
    @image = Magick::ImageList.new
    @image.read("images/#{name}.gif")
    @image = @image.coalesce
    write_frames
    @files.each_with_index do |filename, index|
      puts "on frame #{index + 1} of #{@files.length}"
      @replacer.replace_image(filename)
    end
    write_gif
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
      p image
      new_filename = "tmp/#{@name}-#{filename}.png"
      @files << new_filename
      duplicate = image.dup
      duplicate.write(new_filename)
    end
  end
end

t = GifMaker.new
# t.make_emoji_gif('xmas')
t.make_emoji_gif('dog')
t.make_emoji_gif('candy')
t.make_emoji_gif('tripdog')
t.make_emoji_gif('yoda')
t.make_emoji_gif('pizza')
t.make_emoji_gif('poke')

