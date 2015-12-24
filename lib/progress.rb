##
## Custom progress bar for when it takes a while
##
class ProgressBar
  def initialize(finish, text = 'progress')
    puts
    @counter = 0.0
    @finish = finish.to_f
    @one_percent = finish / 100.00
    @text = text
  end

  def current_percentage
    return 100 if @counter >= @finish
    @counter / @one_percent
  end

  def write_to_console
    print "\r#{@text}: #{current_percentage.to_i}%"
  end

  def set(current_amount)
    @counter = current_amount
    write_to_console
  end

  def add(amount_to_increment)
    @counter += amount_to_increment
    write_to_console
  end
end
