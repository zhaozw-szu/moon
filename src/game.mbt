///|
/// 游戏状态结构体（只含角色控制相关字段）
struct GameState {
  player : @system.Entity
  mut player_state : PlayerState
  mut direction : Direction2
  mut jump_key_released : Bool
  mut mouse_left_released : Bool

}

///|
// 初始化全局游戏状态
let game_state : GameState = {
  player: @system.Entity::new(),
  player_state: PlayerState::Idle,
  direction: Direction2::Right,
  jump_key_released: true,
  mouse_left_released: true,
}