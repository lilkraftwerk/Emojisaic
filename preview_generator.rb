class PreviewGenerator
  def make_preview(name, frames, start_at = 0)
    gif = Magick::ImageList.new
    range = (start_at..start_at + frames).to_a
    range.each do |frame|
      gif << Magick::Image.read("tmp/#{name}-#{format_frame_number(frame)}-mosaic.png")[0]
    end
    output_dest = "output/#{name}-preview.gif"
    gif.write(output_dest)
    puts "wrote preview to #{output_dest}"
  end

  def format_frame_number(frame)
    if frame < 10
      return "0#{frame}"
    else
      return frame
    end
  end
end