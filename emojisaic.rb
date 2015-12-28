require_relative 'config'

def generate_emoji_map
  File.open('lib/map.json', 'w') do |f|
    f.write(JSON.pretty_generate({}))
  end

  Dir['emojis/*.png'].each do |file|
    EmojiScanner.new(file)
  end
end

def generate_emoji_gif(options)
  gif = EmojiGifmaker(options)
  gif.make_emoji_gif
end

def generate_still_image(options)

end

def get_options_from_command_line
  opts = Slop.parse do |o|
    o.string '-g', '--gif', '[string] gif filename'
    o.string '-i', '--image', '[string] still image filename'
    o.integer '-s', '--size', '[int] emoji height in pixels', default: 8
    o.integer '-z', '--zoom', '[int] multiply size of original image by this', default: 1
    o.integer '-o', '--offset', '[int] random offset for emoji placement, in pixels', default: 0
    o.integer '-c', '--coverage', '[int] emoji offset for pixel coverage (see docs, it is complicated)', default: 0
    o.bool '-q', '--quiet', '[flag] be quiet! no output in this mode'
    o.bool '-h', '--help', '[flag] print options'
  end

  if opts[:help]
    puts opts
    exit
  end

  opts
end

def create_options_hash
  opts = get_options_from_command_line
  { filename: opts[:filename],
    quiet: opts[:quiet],
    size: opts[:size],
    zoom: opts[:zoom],
    random_offset: opts[:offset]
    coverage: opts[:coverage],
  }
end

opts = create_options_hash
generate_emoji_gif(opts) if opts[:g]
generate_still_image(opts) if opts[:g]

### to do: preview option


##
## sample options hash
##
# options = {
#   generator: {
#     size: 32,
#     zoom: 1,
#     random_offset: 0
#   },
#   finder: {
#     coverage: 20
#   }
# }



