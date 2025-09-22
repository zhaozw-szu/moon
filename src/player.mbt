/// 从文件夹自动生成帧数组（适用于多张单帧图片，文件名递增）
fn frames_from_folder(
  folder_path : String,
  base_name : String,
  frame_count : Int,
  width : Double,
  height : Double,
) -> Array[@sprite.AnimationFrame] {
  let frames : Array[@sprite.AnimationFrame] = []
  for i in 1..=frame_count {
    let img_path = folder_path + "/" + base_name + i.to_string() + ".png"
    frames.push({
      sprite_path: img_path,
      size: @math.Vec2D(width, height),
      offset: @math.Vec2D(0, 0),
    })
  }
  frames
}

///|
// 动画定义
let player_idle_animation : @sprite.Animation = @sprite.Animation::new(
  frames_from_folder(
    "assets/Warrior/Individual Sprite/idle",
    "Warrior_Idle_",
    6,
    64.0,
    44.0,
  ),
  loop_=true,
  rate=0.2,
)

let player_attack_animation : @sprite.Animation = @sprite.Animation::new(
  frames_from_folder(
    "assets/Warrior/Individual Sprite/Attack",
    "Warrior_Attack_",
    12,
    64.0,
    44.0,
  ),
  loop_=false,
  rate=0.3, // 攻击动画速度加快
)

let player_dash_animation : @sprite.Animation = @sprite.Animation::new(
  frames_from_folder(
    "assets/Warrior/Individual Sprite/Dash",
    "Warrior_Dash_",
    7,
    64.0,
    44.0,
  ),
  loop_=false,
  rate=0.5, // 冲刺动画更快
)

let player_down_attack_animation : @sprite.Animation = @sprite.Animation::new(
  frames_from_folder(
    "assets/Warrior/Individual Sprite/Dash Attack",
    "Warrior_Dash-Attack_",
    10,
    64.0,
    44.0,
  ),
  loop_=false,
  rate=0.25,
)

let player_run_animation : @sprite.Animation = @sprite.Animation::new(
  frames_from_folder(
    "assets/Warrior/Individual Sprite/Run",
    "Warrior_Run_",
    8,
    64.0,
    44.0,
  ),
  loop_=true,
  rate=0.2,
)

let player_jump_animation : @sprite.Animation = @sprite.Animation::new(
  frames_from_folder(
    "assets/Warrior/Individual Sprite/Jump",
    "Warrior_Jump_",
    3,
    64.0,
    44.0,
  ),
  loop_=true,
  rate=0.2,
)

let player_fall_animation : @sprite.Animation = @sprite.Animation::new(
  frames_from_folder(
    "assets/Warrior/Individual Sprite/Fall",
    "Warrior_Fall_",
    3,
    64.0,
    44.0,
  ),
  loop_=true,
  rate=0.2,
)

let player_hit_animation : @sprite.Animation = @sprite.Animation::new(
  frames_from_folder(
    "assets/Warrior/Individual Sprite/Hurt-Effect",
    "Warrior_Hurt_",
    4,
    64.0,
    44.0,
  ),
  loop_=false,
  rate=0.2,
)


fn add_player(pos : @math.Vec2D) -> Unit {
  let player_sprite = @sprite.Sprite::from_animation(player_idle_animation, 20)
  @sprite.sprites.set(game_state.player, player_sprite)
  @velocity.velocities.set(game_state.player, @math.Vec2D::zero())
  @position.positions.set(game_state.player, pos)
  @collision.shapes.set(
    game_state.player,
    Rect(size=@math.Vec2D(24.0, 32.0), offset=@math.Vec2D(4.0, 0.0)),
  )
  @collision.collision_layers.set(game_state.player, player_collision_layer)
  @collision.colliders.set(
    game_state.player,
    @collision.Collider::new(
      @collision.CollisionMask::new([terrain_collision_layer, enemy_collision_layer,]),
    ),
  )
  @camera.attach_entity(game_state.player, @math.Vec2D(32.0, 32.0))
}


///|
// 角色朝向枚举
enum Direction2 {
  Left
  Right
} derive(Eq)

///|
// 玩家状态枚举（可根据你的实际 PlayerState 枚举定义）
enum PlayerState {
  Idle
  Jump
  Fall
  Hit
  Attack
  Dash
} derive(Show)




///|
const GRAVITY : Double = 0.5
const MAX_RUN_V : Double = 2.0
const JUMP_V : Double = 11.5
const MAX_FALL_V : Double = 15.5
const RUN_ACC : Double = 1.0
const BUMP_V : Double = JUMP_V / 2.0


fn player_collision_system(backend : &@system.Backend) -> Unit {
  let player_collisions = @collision.get_collision_infos(game_state.player)
  for collision in player_collisions {
    
  }
}




///|
fn player_state_system(backend : &@system.Backend) -> Unit {
  let velocity = @collision.real_velocities
    .get(game_state.player)
    .unwrap_or(@math.Vec2D::zero())
  let mut new_velocity_x = velocity.0[X]
  let mut new_velocity_y = velocity.0[Y]
  // 实时打印角色状态
  // println("PlayerState: " + game_state.player_state.to_string())
  let transform = match game_state.direction {
    Direction2::Left => @math.Transform::flip_x(64.0)
    Direction2::Right => @math.Transform::new()
  }
  if !(game_state.player_state is Hit) && !(game_state.player_state is Attack) && !(game_state.player_state is Dash) {
    if @system.is_pressed(@system.KeyA) {
      new_velocity_x -= RUN_ACC
      if new_velocity_x < -MAX_RUN_V {
        new_velocity_x = -MAX_RUN_V
      }
      game_state.direction = Direction2::Left
    } else if @system.is_pressed(@system.KeyD) {
      new_velocity_x += RUN_ACC
      if new_velocity_x > MAX_RUN_V {
        new_velocity_x = MAX_RUN_V
      }
      game_state.direction = Direction2::Right
    } else {
      new_velocity_x = 0.0
    }
    // 按空格进入Dash状态
    if @system.is_just_pressed(@system.Space) {
      game_state.player_state = PlayerState::Dash
      @sprite.play_animation(
        game_state.player,
        player_dash_animation,
        transform~,
      )
      // 冲刺速度更快，方向由当前方向决定
      if game_state.direction is Direction2::Left {
        new_velocity_x = -MAX_RUN_V * 2.0
      } else {
        new_velocity_x = MAX_RUN_V * 2.0
      }
    }
  }
  match game_state.player_state {
    Idle => {
      if velocity.0[X] == 0.0 {
        @sprite.play_animation(
          game_state.player,
          player_idle_animation,
          transform~,
        )
      } else {
        @sprite.play_animation(
          game_state.player,
          player_run_animation,
          transform~,
        )
      }
      if @system.is_pressed(@system.KeyW) &&
        @collision.is_on_floor(game_state.player) {
        new_velocity_y = -JUMP_V
        game_state.player_state = PlayerState::Jump
      }
      if @system.is_just_pressed(@system.KeyJ) {
        game_state.player_state = PlayerState::Attack
        @sprite.play_animation(
          game_state.player,
          player_attack_animation,
          transform~,
        )
        new_velocity_x = 0.0
      }
      if velocity.0[Y] > 0.0 {
        game_state.player_state = PlayerState::Fall
      }
    }
    Fall => {
      @sprite.play_animation(
        game_state.player,
        player_fall_animation,
        transform~,
      )
      if @collision.is_on_floor(game_state.player) {
        game_state.player_state = PlayerState::Idle
      }
    }
    Jump => {
      // 跳跃时可攻击，按J切换到攻击状态并播放攻击动画
      if @system.is_just_pressed(@system.KeyJ) {
        game_state.player_state = PlayerState::Attack
        @sprite.play_animation(
          game_state.player,
          player_attack_animation,
          transform~,
        )
      } else {
        @sprite.play_animation(
          game_state.player,
          player_jump_animation,
          transform~,
        )
      }
      if velocity.0[Y] > 0.0 {
        game_state.player_state = PlayerState::Fall
      }
    }
    Hit => {
      @sprite.play_animation(
        game_state.player,
        player_hit_animation,
        transform~,
      )
      if @collision.is_on_floor(game_state.player) {
        new_velocity_x = 0.0
      }
      if @sprite.is_animation_finished(game_state.player) {
        if @collision.is_on_floor(game_state.player) {
          game_state.player_state = PlayerState::Idle
        } else if velocity.0[Y] < 0.0 {
          game_state.player_state = PlayerState::Fall
        } else {
          game_state.player_state = PlayerState::Jump
        }
      }
    }
    Attack => {
      @sprite.play_animation(
        game_state.player,
        player_attack_animation,
        transform~,
      )
      // 攻击状态下移动速度惩罚加重为九成（仅剩一成速度），跳跃不会打断攻击，只播放攻击动画
      if @system.is_pressed(@system.KeyA) {
        new_velocity_x = -MAX_RUN_V * 0.1
        game_state.direction = Direction2::Left
      } else if @system.is_pressed(@system.KeyD) {
        new_velocity_x = MAX_RUN_V * 0.1
        game_state.direction = Direction2::Right
      } else {
        new_velocity_x = 0.0
      }
      // 攻击时允许跳跃产生垂直位移，但不切换动画，且跳跃会结束Dash状态
      if @system.is_pressed(@system.KeyW) && @collision.is_on_floor(game_state.player) {
        new_velocity_y = -JUMP_V
        if game_state.player_state is Dash {
          game_state.player_state = PlayerState::Jump
        }
      }
      // 重力和下落
      new_velocity_y += GRAVITY
      if new_velocity_y > MAX_FALL_V {
        new_velocity_y = MAX_FALL_V
      }
      // 攻击期间按空格不会Dash
      if @system.is_just_pressed(@system.Space) {
        if game_state.player_state is Dash {
          game_state.player_state = PlayerState::Idle
        }
      }
      if @sprite.is_animation_finished(game_state.player) {
        if @collision.is_on_floor(game_state.player) {
          game_state.player_state = PlayerState::Idle
        } else if new_velocity_y > 0.0 {
          game_state.player_state = PlayerState::Fall
        } else {
          game_state.player_state = PlayerState::Jump
        }
      }
    }
    Dash => {
      @sprite.play_animation(
        game_state.player,
        player_dash_animation,
        transform~,
      )
      // Dash期间只允许冲刺移动，速度更快，动画更快，距离更短
      let dash_speed = MAX_RUN_V * 3.0 // 冲刺速度提升
      if game_state.direction is Direction2::Left {
        new_velocity_x = -dash_speed
      } else {
        new_velocity_x = dash_speed
      }
      // Dash动画更快，距离更短（动画快结束）
      // 按W结束Dash状态
      if @system.is_pressed(@system.KeyW) && @collision.is_on_floor(game_state.player) {
        game_state.player_state = PlayerState::Jump
        new_velocity_y = -JUMP_V
      }
      // Dash期间按J直接切换到普通Attack
      if @system.is_just_pressed(@system.KeyJ) {
        game_state.player_state = PlayerState::Attack
        @sprite.play_animation(
          game_state.player,
          player_attack_animation,
          transform~,
        )
        // 攻击期间速度惩罚
        new_velocity_x = 0.0
      }
      // Dash动画播放完毕后回到Idle或Fall
      if @sprite.is_animation_finished(game_state.player) {
        if @collision.is_on_floor(game_state.player) {
          game_state.player_state = PlayerState::Idle
        } else {
          game_state.player_state = PlayerState::Fall
        }
      }
    }
  }
  new_velocity_y += GRAVITY
  if new_velocity_y > MAX_FALL_V {
    new_velocity_y = MAX_FALL_V
  }
  @velocity.velocities[game_state.player] = @math.Vec2D(
    new_velocity_x, new_velocity_y,
  )
}