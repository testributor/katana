Testributor.Helpers ||= {}

class Testributor.Helpers.WithDots
  constructor: (text)->
    "#{text}<span class='dot'></span><span class='dot'></span><span class='dot'></span>"
