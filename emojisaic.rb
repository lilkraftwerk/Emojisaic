require_relative 'config'

def generate_emoji_map
  File.open('lib/map.json', 'w') do |f|
    f.write(JSON.pretty_generate({}))
  end

  Dir['emojis/*.png'].each do |file|
    EmojiScanner.new(file)
  end
end
