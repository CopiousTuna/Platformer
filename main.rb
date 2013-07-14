require 'rubygems'
require 'gosu'
require_relative 'player'
require_relative 'level'

module Z
	Background, Platform, Player, UI = *0..3
end

module T
	Air, Floor = *0..1
end

class Rect
	attr_reader :x1, :x2, :y1, :y2

	def initialize(x, y, width, height)
		update(x, y, width, height)
	end
	
	# Used to update the positions of the rectangle on moving objects
	def update(x, y, width, height)
		@x1 = x
		@x2 = @x1 + width
		@y1 = y
		@y2 = @y1 + height
	end
	
	def intersects?(*args)
		if args.length == 2
			return intersects?(Rect.new(args[0] * 32, args[1] * 32, 32, 32))
		else
			rect = args[0]
			return ( (rect.x1.between?(@x1, @x2) || rect.x2.between?(@x1, @x2)) &&
				(rect.y1.between?(@y1, @y2) || rect.y2.between?(@y1, @y2)) ) ||
					( (@x1.between?(rect.x1, rect.x2) || @x2.between?(rect.x1, rect.x2)) &&
					(@y1.between?(rect.y1, rect.y2) || @y2.between?(rect.y1, rect.y2)) )
		end
	end
	
end

class Window < Gosu::Window
	def initialize(width, height)
		super(width, height, false)
		self.caption = 'Platformer'
		
		@tick = 0
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
	#	@level = Level.new(38, 15, $map, self) # Map 1
	  @level = Level.new(53, 37, $first_cave, self)  # First cave
		@player = Player.new(36, 7, self)
		@level.set_camera(@player.draw_x, @player.draw_y)
	end
	
	def update
		if button_down? Gosu::KbZ
			@player.jump
		end
		if button_down? Gosu::KbLeft
			@player.move_left(@tick == 0)
		end
		if button_down? Gosu::KbRight
			@player.move_right(@tick == 0)
		end
		@player.fall # Gravity!
		@level.set_camera(@player.draw_x, @player.draw_y)
		@tick = @tick == 12 ? 0 : @tick + 1
	end
	
	def draw # Draws tiles, player, and UI
		@level.draw
		if standing_still?
			@player.stand_still
			@tick = 0
		end
		@player.draw
		# Frame rate
    # @font.draw(Gosu::fps(), 5, 205, Z::UI, 1.0, 1.0, 0xffffffff)
		# Player position
		# @font.draw("(" + (@player.x / 32).to_s + ", " + (@player.y / 32).to_s + ")", 270, 205, Z::UI, 1.0, 1.0, 0xffffffff)
	end
	
	def button_down(id)
		if id == Gosu::KbEscape
			close # Closes the application
		end
	end
	
	def button_up(id)
		if id == Gosu::KbZ
			@player.stop_jump
		end
	end
	
	def standing_still?
	  return ( !(button_down? Gosu::KbLeft) && !(button_down? Gosu::KbRight) ) || 
      ( button_down? Gosu::KbLeft) && ( button_down? Gosu::KbRight )
	end
	
end

$win_width = 640
$win_height = 480
# $map = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooooooooooooooooooooooooooxxxxxxxxxooooxxxoooooooooooooooooooooooxxxxxxxxooooooooooooooooooooooooooooooxxxxxxxxoooxxxxxxooxxxoooxxoooxoooxxxxxxxxxxxxooxxxxxxxoooooooooooooooooooooxxxxxxxxoooxxxooxxooooooooooooooooooooxxxxxxxxxoooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooxoooooooxxxxxxxxxxxxxxxxxxxxxxxxxoooooxxxxxxooxxxxxxxxxxxxxxxxxxxxxxxxxoooooooooooooxxxxxxxxxxxxxxxxxxxxxxxxxxooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$first_cave = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooxxoooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooxooooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooooooooooooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooooooxooooooooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooooooooooooooooooooxxxxxxxxxxxxxxxxxxxxxxxxxoooooooooxxxxxxxxxxxx\\ooo/xxxxxxxxxxxxxxxxxxxxxxxxxxxooooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooo/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooo/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoxoxxxoooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooooooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooooooooooo/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooooxooo/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooooxoooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooxoooo/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooooooo/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooo/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooxooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\\ooooxooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\\ooooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoooooxxxoooooxxxxoxoxxxxxxxxxxxxxxxxxoooxxxxxxxxxxxxxxxxoooooooooooooooxoooooxxxxxxxxxxxxxoooooxxxxxxxxxxxxxxoooooooooooooooooooooxxxxxxxxxxxxxoooooxxxxxxxxxxxxxx\\ooooooooooooooooooooxxxxxxxxxxxoooooooxxxxxxxxxxxxxxxxx\\ooooooooooooooooooxxxxxxxxoooooooooxxxxxxxxxxxxxxxxxxxx\\ooooooooxooooooooooxxoooo/xoxxxoxxxxxxxxxxxxxxxxxxxxxxxx\\ooooxooooooooooooo/xxxxoooooxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxooooxx\\oooo/xxxxxxx\\oo/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxoo/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
window = Window.new($win_width, $win_height) # 10x7 Grid
window.show