##
## Creates multiple emoji mosaics and strings them together into an animation
##
class GifMaker
  def initialize(options = {})
    @options = options
    @filename = options[:filename]
    @generator = EmojiMosaicGenerator.new(options)
    make_filenames
  end

  def make_filenames
    regex = %r{\/(.+)\.}
    @name = regex.match(@filename)[1]
    @new_filenames = []
  end

  def make_emoji_gif
    @image = Magick::ImageList.new.read(@filename).coalesce
    write_frames
    @files.each_with_index do |filename, index|
      puts "\nDoing frame #{index + 1}/#{@files.length}" unless @options[:quiet]
      @new_filenames << @generator.create_image(filename)
    end
    write_gif
    @new_filenames.length
  end

  # commented out for now
  # def make_preview(name, frames, start_at = 0)
  #   old_gif = Magick::Image.read("output/#{name}.gif")
  #   new_gif = Magick::ImageList.new
  #   (start_at..start_at + frames).to_a.each do |frame_number|
  #     new_gif << old_gif[frame_number]
  #   end
  #   output_dest = "output/#{name}-preview.gif"
  #   new_gif.write(output_dest)
  #   puts "wrote preview to #{output_dest}" unless @options[:quiet]
  # end

  def write_gif
    gif = Magick::ImageList.new
    gif.ticks_per_second = @image.ticks_per_second
    @new_filenames.each_with_index do |filename, index|
      new_frame = Magick::Image.read(filename)[0]
      new_frame.delay = @image[index].delay
      gif << new_frame
    end

    @filename[@name] = "#{@name}-mosaic"
    puts "Writing to #{@filename}..." unless @options[:quiet]
    gif.write(@filename)
  end

  def write_frames
    puts "\nsplitting gif into frames..." unless @options[:quiet]
    @files = []
    @image.each_with_index do |image, index|
      index > 9 ? number = index : number = "0#{index}"
      new_filename = "tmp/#{@name}-#{number}.png"
      image.write(new_filename)
      @files << new_filename
    end
  end
end
