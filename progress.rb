class ProgressBar
  def initialize(finish, text = 'progress')
    @counter = 0
    @finish = finish
    @one_percent = finish / 100
    @text = text
  end

  def current_percentage
    (@counter / @one_percent) / 2
  end

  def write_to_console
    print "\r#{@text}: #{@counter} of #{@finish} #{'*' * current_percentage} #{' ' * (50 - current_percentage)} |"
  end

  def update(amount_to_increment)
    @counter += amount_to_increment
    write_to_console
  end
end
