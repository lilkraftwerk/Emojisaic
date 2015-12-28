require_relative 'config'

def generate_emoji_map
  File.open('lib/map.json', 'w') do |f|
    f.write(JSON.pretty_generate({}))
  end

  Dir['emojis/*.png'].each do |file|
    EmojiScanner.new(file)
  end
  exit
end

def clear_temp_files
  puts "Removing all files in tmp folder..."
  FileUtils.rm_rf(Dir.glob('tmp/*.png'))
  exit
end

def generate_emoji_gif(options)
  gif = GifMaker.new(options)
  gif.make_emoji_gif
end

def generate_still_image(options)
  generator = EmojiMosaicGenerator.new(options)
  generator.create_image(options[:filename])
end

def options_from_command_line
  opts = Slop.parse do |o|
    o.string '-g', '--gif', '[string] gif filename'
    o.string '-i', '--image', '[string] still image filename'
    o.integer '-s', '--size', '[int] emoji height in pixels', default: 8
    o.integer '-z', '--zoom', '[int] multiply size of original image by this', default: 1
    o.integer '-o', '--offset', '[int] random offset for emoji placement, in pixels', default: 0
    o.integer '-c', '--coverage', '[int] emoji offset for pixel coverage (see docs, it is complicated)', default: nil
    o.bool '-q', '--quiet', '[flag] be quiet! no output in this mode'
    o.bool '-h', '--help', '[flag] print options'
    o.bool '-t', '--tmp', '[flag] remove all temp files (use by itself)'
    o.bool '-m', '--map', '[flag] generate new emoji color map (use by itself)'
  end

  if opts[:help]
    puts opts
    exit
  end

  opts
end

def get_filename(opts)
  return opts[:g] if opts[:g]
  return opts[:i] if opts[:i]
end

def options_hash
  opts = options_from_command_line
  { filename: get_filename(opts).dup,
    quiet: opts[:quiet],
    size: opts[:size],
    zoom: opts[:zoom],
    random_offset: opts[:offset],
    coverage: opts[:coverage]
  }
end

cl_opts = options_from_command_line
clear_temp_files if cl_opts[:tmp]
generate_emoji_map if cl_opts[:map]
generate_emoji_gif(options_hash) if cl_opts[:gif]
generate_still_image(options_hash) if cl_opts[:image]
