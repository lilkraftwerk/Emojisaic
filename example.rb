require_relative 'emojisaic'

options = {
  generator: {
    size: 3,
    zoom: 2,
    random_offset: 0
  },
  finder: {
    coverage: 35
  }
}


gif = GifMaker.new(options)
gif.make_emoji_gif('missy')
