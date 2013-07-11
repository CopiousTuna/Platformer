class Num
  
  attr_reader :val
  
  def initialize(val)
    @val = val
  end
  
  def add(val)
    @val += val
  end
  
end


a = Array.new
a.push [Num.new(0), Num.new(1)]
a.push [Num.new(2), Num.new(3)]

a.each {|b|
  b.each {|c|
    c.add(1)
    }
  }

a.each {|b| b.each {|num| puts num.val}}
