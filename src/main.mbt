const ZOOM : Double = 2.0
const VIEWPORT_WIDTH : Double = 480.0
const VIEWPORT_HEIGHT : Double = 320.0
const REAL_VIEWPORT_WIDTH : Double = VIEWPORT_WIDTH * ZOOM
const REAL_VIEWPORT_HEIGHT : Double = VIEWPORT_HEIGHT * ZOOM


fn main {
  @system.App::new(@canvas.CanvasBackend::new())
  .with_canvas_width(REAL_VIEWPORT_WIDTH)
  .with_canvas_height(REAL_VIEWPORT_HEIGHT)
  .with_image_smooth(false)
  .with_zoom(ZOOM)
  .with_fps(60)
  .add_plugin(@plugins.default_plugin)
  .add_system(game_start, schedule=Startup)
  .add_system(player_state_system)
  .add_system(player_collision_system)
  .add_system(@camera.camera_system)
  .run()
}

fn game_start(backend : &@system.Backend) -> Unit {
  generate_map(backend)
}


