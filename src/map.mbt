///|
fn generate_map(backend : &@system.Backend) -> Unit {
  let world_width = 480.0 * 20.0
  let world_height = 320.0
  @camera.set_limits(top=0.0, bottom=world_height, left=0.0, right=world_width)
  add_background(@math.Vec2D(world_width, world_height))
  add_ground(@math.Vec2D(world_width, world_height))
  add_player(@math.Vec2D(0.0, 0.0))
}

///|
fn add_background(size : @math.Vec2D) -> Unit {
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/background.png", @math.Vec2D(0.0, size.1 * 0.0), @system.RepeatMode::Repeat, 0)
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/Cloud_1.png", @math.Vec2D(0.0, -size.1 * 0.20), @system.RepeatMode::Repeat, 1)
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/Cloud_2.png", @math.Vec2D(0.0, -size.1 * 0.15), @system.RepeatMode::Repeat, 2)
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/Cloud_3.png", @math.Vec2D(0.0, -size.1 * 0.10), @system.RepeatMode::Repeat, 3)
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/props_clouds.png", @math.Vec2D(size.0 * 0.20, size.1 * 0.15), @system.RepeatMode::NoRepeat, 4)
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/Back_Forest_1.png", @math.Vec2D(0.0, size.1 * 0.10), @system.RepeatMode::Repeat, 5)
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/Back_Forest_2.png", @math.Vec2D(0.0, size.1 * 0.15), @system.RepeatMode::Repeat, 6)
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/Back_tree_1.png", @math.Vec2D(0.0, size.1 * 0.20), @system.RepeatMode::Repeat, 7)
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/Back_tree_2.png", @math.Vec2D(0.0, size.1 * 0.25), @system.RepeatMode::Repeat, 8)
  add_layer(size, "assets/Country-village_asset_pack/2_Parallax background/Country.png", @math.Vec2D(0.0, size.1 * 0.30), @system.RepeatMode::Repeat, 9)
}



fn add_layer(size : @math.Vec2D, path : String, pos : @math.Vec2D, repeat_mode : @system.RepeatMode, z : Int) -> Unit {
  let entity = @system.Entity::new()
  let sprite = @sprite.Sprite::from_picture(
    @sprite.Picture::new(size, path, repeat=repeat_mode),
    z,
  )
  @sprite.sprites.set(entity, sprite)
  @position.positions.set(entity, pos)  
}

///|
fn add_ground(size : @math.Vec2D) -> Unit {
  let tile_size = @math.Vec2D(35.0, 70.0)
  let tile_offset = @math.Vec2D(280.0, 70.0)
  let path = "assets/Country-village_asset_pack/1_Tileset & props/country village tileset.png"
  let y = size.1 * 0.85
  let z = 10
  let tiles_x = (size.0 / tile_size.0).to_int() + 1
  for i in 0..<tiles_x {
    let x : Double = i.to_double() * tile_size.0
    add_ground_layer(tile_size, tile_offset, path, @math.Vec2D(x, y), z)
  }
}

fn add_ground_layer(
  tile_size : @math.Vec2D, 
  tile_offset : @math.Vec2D, 
  path : String, 
  pos : @math.Vec2D, 
  z : Int
  ) -> Unit {
  let ground = @system.Entity::new()
  let sprite = @sprite.Sprite::from_animation(
      @sprite.Animation::single_frame(
      path,
      tile_size,
      offset=tile_offset,
    ),
    z,
  )
  @sprite.sprites.set(ground, sprite)
  @position.positions.set(ground, pos)
  @collision.shapes.set(
    ground,
    Rect(size=tile_size, offset=@math.Vec2D::zero()),
  )
  @collision.collision_layers.set(ground, terrain_collision_layer)
}
