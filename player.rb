class Player

	attr_reader :draw_x, :draw_y, :width, :height, :jumping, :rect

	def initialize(x, y, window)
		@@sprites ||= Gosu::Image::load_tiles(window, "img/char.png", 32, 32, false)
		@frame = 3
		@step = false
		@img = @@sprites[@frame]
		@x = x
		@y = y
		@draw_x = x * 32
		@draw_y = y * 32
		@width = 20
		@height = 26
		@rect = Rect.new(x + 10, y + 6, 16, 26)
		update_position
		@y_offset = -1
		@jump_vel = 5
		@delta_vel = 0.13
		@jumping = false
		@jump_released = true
	end

	def update_position
		@rect.update(@draw_x + 10, @draw_y + 6, 13, 26)
		@x = @draw_x / 32
		@y = @draw_y / 32
	end
	
	def jump
		if @jump_released && @y > 0 && @y_offset == -1
			@y_offset = 0
			@jump_vel = 5
			@jumping = true
			@jump_released = false
			@frame = @frame < 3 ? 1 : 4
			fall
		end
	end
	
	def stop_jump
		@jumping = false
		@jump_released = true
	end

	def fall
		# If the player is jumping
		if @jumping == true
			# If the player can jump no higher, start falling
			if @draw_y <= 0 || @y_offset >= 69 # Maximum jump height is 69px | 2 blocks + "wiggle room"
				@jumping = false
				@jump_vel = 0
			else
				# Else, keep jumping
				@jump_vel -= @delta_vel
				jump_dist = @jump_vel.to_i
				@draw_y -= jump_dist
				@y_offset += jump_dist
				update_position
				# Check if the player hit a ceiling
				if @rect.y1 > 0
					solids_rect_left = $grid[@y][@x].is_solid? ?
						$grid[@y][@x].rect : nil

					solids_rect_right = @x < $level_width - 1 && $grid[@y][@x + 1].is_solid? ?
						$grid[@y][@x + 1].rect : nil
						
					while (solids_rect_left != nil && @rect.intersects?(solids_rect_left)) ||
						(solids_rect_right != nil && @rect.intersects?(solids_rect_right))	
						@draw_y += 1
						@jumping = false
						update_position
					end
				else
					stop_jump
				end
			end 
		# Else, if the player hasn't reached the limit of the map, obey gravity	& fall
		elsif @rect.y2 < $level_height * 32
			@jump_vel += @delta_vel * 2
			if @jump_vel > 10
				@jump_vel = 10	# Max velocity is 5px/sec
			end
			jump_dist = @jump_vel.to_i
			@draw_y += jump_dist
			@y_offset -= jump_dist
			update_position
			
			# Check collision with floor
			# First check to make sure player isn't referencing tiles below from bottom row
			if @y < $level_height - 1
				solids_rect_left = @x < $level_width - 1 && 
          $grid[@y + 1][@x].is_solid? ? $grid[@y + 1][@x].rect : nil
				
				solids_rect_right = @x < $level_width - 1 && 
				  $grid[@y + 1][@x + 1].is_solid? ? $grid[@y + 1][@x + 1].rect : nil
				
				landed = false
				
				while (solids_rect_left != nil && @rect.intersects?(solids_rect_left)) || 
					(solids_rect_right != nil && @rect.intersects?(solids_rect_right))
					@draw_y -= 1
					@y_offset = -1	# Indicate that player is grounded
					landed = true
					update_position
				end
				
				# Keeps player from floating 1px above the ground
				if landed
					@draw_y += 1
					@jump_vel = 2
					update_position
				end
				
			end
			
		end
	end
	
	def move_left(update_frame)
		if @rect.x1 > 0
			@draw_x -= 3
			update_position
			solids_rect_top = $grid[@y][@x].is_solid? ?
				$grid[@y][@x].rect : nil
				
			solids_rect_bottom = @draw_y % 32 != 0 && @y < $level_height - 1 &&
				$grid[@y + 1][@x].is_solid? ? $grid[@y + 1][@x].rect : nil
				
			while (solids_rect_top != nil && @rect.intersects?(solids_rect_top)) ||
				(solids_rect_bottom != nil && @rect.intersects?(solids_rect_bottom))
					@draw_x += 1
					update_position
			end
		end
		if update_frame
			if @frame == 0
				@frame = @step ? 2 : 1
				@step = !@step
			elsif @jumping
				@frame = 1
			else
				@frame = 0
			end
		end
	end
	
	def move_right(update_frame)
		if @rect.x2 < $level_width * 32
			@draw_x += 3
			update_position
			# First check that adjacent tile is not on the next row of the level
			if @x < $level_width - 1
				solids_rect_top = $grid[@y][@x + 1].is_solid? ? 
					$grid[@y][@x + 1].rect : nil
				
				solids_rect_bottom = @draw_y % 32 != 0 && @y < $level_height - 1 &&
					$grid[@y + 1][@x + 1].is_solid? ? $grid[@y + 1][@x + 1].rect : nil
					
				while(solids_rect_top != nil && @rect.intersects?(solids_rect_top)) ||
					(solids_rect_bottom != nil && @rect.intersects?(solids_rect_bottom))
						@draw_x -= 1
						update_position
				end
			end
		end
		if update_frame
			if @frame == 3
				@frame = @step ? 5 : 4
				@step = !@step
			elsif @jumping
				@frame = 4
			else
				@frame = 3
			end
		end
	end
	
	def stand_still
		if @y_offset == -1	# If the player is not airborne
			@frame = @frame < 3 ? 0 : 3
		end
	end
	
	def draw
		@img = @@sprites[@frame]
		@img.draw(@draw_x - $cam_x, @draw_y - $cam_y, Z::Player)
	end
	
end