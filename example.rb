require_relative 'emojisaic'

options = {
  generator: {
    size: 32,
    zoom: 1,
    random_offset: 0
  },
  finder: {
    coverage: 20
  }
}

gif = GifMaker.new(options)
gif.make_emoji_gif('missy')
