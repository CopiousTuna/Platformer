class Tile

  attr_reader :solid, :rect, :x, :y

  def initialize(x, y, index, type, sprites)
    @@sprites ||= sprites
    @x = x * 32
    @y = y * 32
    @type = type
    @solid = type == 1 ? true : false
    @rect = Rect.new(@x, @y, 32, 32)
  end
  
  # Tile checks surrounding tiles and finds its proper image
  def autotile
    @img = @type == T::Floor ? @@sprites[0] : @@sprites[47]
  end
  
  def is_solid?
    return @type == T::Floor
  end
  
  def draw(x_offset = 0, y_offset = 0)
    @img.draw(@x - $cam_x, @y - $cam_y, Z::Platform)
  end
  
end

class Level

  attr_accessor :view_index
  
  def initialize(level_width, level_height, map, window)
    $level_width = level_width
    $level_height = level_height
    $grid = Array.new
    $cam_x = $cam_y = 0
    @@tile_sprites ||= Gosu::Image::load_tiles(window, "img/floor.png", 32, 32, false)
    @view_width = 20
    @view_height = 15
    
    tile_x = tile_y = index = 0
    row = Array.new
    map.each_char{ |c|
      if c == 'x'
        row << Tile.new(tile_x, tile_y, index, T::Floor, @@tile_sprites)
      elsif c == 'o'
        row << Tile.new(tile_x, tile_y, index, T::Air, @@tile_sprites)
      end
      index += 1
      tile_x += 1
      if index % $level_width == 0
        $grid << row
        row = Array.new
        index = 0
        tile_x = 0
        tile_y += 1
      end
    }
    
    $grid.each{ |r| r.each {|tile| tile.autotile }}
  end
  
  def set_camera(x, y)  
    x -= (@view_width / 2) * 32
    if x < 0
      x = 0 # Ensure camera is not outside left bound
    elsif $level_width * 32 - x < $win_width
      x = $level_width * 32 - $win_width    # Ensure camera is not outside right bound
    end
    
    y -= (@view_height / 2) * 32
    if y < 0
      y = 0 # Ensure camera is not outside top bound
    elsif $level_height * 32 - y < $win_height
      y = $level_height * 32 - $win_height  # Ensure camera is not outside bottom bound
    end
    
    $cam_x = x
    $cam_y = y
  end

  def draw
    draw_x = $cam_x / 32
    draw_y = $cam_y / 32
    for y in 0..@view_height
      if draw_y + y >= $level_height  # Don't render outside of the y-range of the level
        return
      end
      for x in 0..@view_width
        if draw_x + x >= $level_width # Don't render outside of the x-range of the level
          next
        end
        $grid[draw_y + y][draw_x + x].draw
      end
    end
  end
  
end