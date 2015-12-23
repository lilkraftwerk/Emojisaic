class PreviewGenerator
  def make_preview(name, frames, start_at = 0)
    old_gif = Magick::Image.read("output/#{name}.gif")
    new_gif = Magick::ImageList.new
    (start_at..start_at + frames).to_a.each do |frame_number|
      new_gif << old_gif[frame_number]
    end
    output_dest = "output/#{name}-preview.gif"
    new_gif.write(output_dest)
    puts "wrote preview to #{output_dest}"
  end
end