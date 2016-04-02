Testributor.Helpers ||= {}
class Testributor.Helpers.Helper
  constructor: ()->
    Handlebars.registerHelper("percentage", (number1, number2)->
      (number1 / number2) * 100
    )

class Testributor.Helpers.WithDots
  constructor: (text)->
    "#{text}<span class='dot'></span><span class='dot'></span><span class='dot'></span>"
