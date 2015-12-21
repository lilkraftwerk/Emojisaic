require 'pry'

class ProgressBar
  def initialize(finish, text = 'progress', steps = 1)
    puts
    @counter = 0.0
    @finish = finish.to_f
    @one_percent = finish / 100.00
    @text = text
    @steps = 1
  end

  def current_percentage
    return 100 if @counter >= @finish
    @counter / @one_percent
  end

  def write_to_console
    print "\r#{@text}: #{current_percentage.to_i}%"
  end

  def add(amount_to_increment)
    old_percentage = current_percentage
    @counter += amount_to_increment
    write_to_console
  end
end
