local function bearing(from, to)
  -- note y is reversed because Factorio's y is in screen coordinates 
  -- (increasing down) and this is in cartesian (increasing up)
  return math.atan2(to.x - from.x, from.y - to.y)
end

local function angle_diff(a, b)
  local res = a - b
  if res >= 0.5 then
    return res - 1
  elseif res < -0.5 then
    return res + 1
  else
    return res
  end
end

local function drive_direction(veh, player_idx, dir)
  game.players[player_idx].riding_state = {
    acceleration = game.players[player_idx].riding_state.acceleration,
    direction = dir
  }
  global.players[player_idx].prev_direction = dir
end

local function stop_control(player_idx)
  -- This function removes the item from the table, so shouldn't be called
  -- until after all the must-run-once items have run (e.g. replacing the
  -- used-up capsule). Also the on_tick loop should continue immediately after 
  -- calling this function.
  global.players[player_idx] = nil
end

local function stop_ticking()
  if global.ticking then
    script.on_event(defines.events.on_tick, nil)
    global.ticking = false
  end
end

local function tick_fn(event)
  for player_idx, commands in ipairs(global.players) do
    if commands.needs_new_remote then
      game.players[player_idx].cursor_stack.set_stack({name = "steering-remote"})
      commands.needs_new_remote = false
    end
    
    if commands.heading_target == nil then
      -- This case runs when the user uses a steering wheel capsule (which
      -- makes sense, I promise) when not in a vehicle, or in any other
      -- situation that might cause a command to not be entered. We still 
      -- have to wait until a tick to give them a new remote but then stop
      stop_control()
    else
      if game.players[player_idx].vehicle == nil then
        -- Clear command when user exits the vehicle
        stop_control(player_idx)
      elseif commands.prev_direction ~= nil and game.players[player_idx].riding_state.direction ~= commands.prev_direction then
        -- Clear command when the user steers in a different direction
        stop_control(player_idx)
      elseif game.players[player_idx].vehicle.speed == 0 then
        -- Clear command when vehicle stops
        stop_control(player_idx)
      else
        local veh = game.players[player_idx].vehicle
        local ori = veh.orientation
        -- For some reason the car's orientation switches to backwards when
        -- it's moving backwards, but the tank's doesn't, so I have to 
        -- switch it here
        if veh.prototype.tank_driving and veh.speed < 0 then
          ori = (ori + 0.5) % 1
        end
        local delta = angle_diff(commands.heading_target, ori)

        if delta < -veh.prototype.rotation_speed then
          drive_direction(veh, player_idx, defines.riding.direction.left)
        elseif delta > veh.prototype.rotation_speed then
          drive_direction(veh, player_idx, defines.riding.direction.right)
        else
          drive_direction(veh, player_idx, defines.riding.direction.straight)
          stop_control(player_idx)
        end
      end
    end
  end
  
  if #global.players == 0 then
    stop_ticking()
  end
end


local function start_ticking()
  if not global.ticking then
    script.on_event(defines.events.on_tick, tick_fn)
    global.ticking = true
  end
end
    

script.on_event(defines.events.on_player_used_capsule, function(event)
  if event.item.name ~= 'steering-remote' then
    return
  end
  
  if global.players == nil then
    global.players = {}
  end
  
  if global.players[event.player_index] == nil then
    global.players[event.player_index] = {}
  end
  
  -- Store the fact that the player needs a new steering-remote,
  -- because the only way I know to do that means the player loses
  -- theirs every time they click
  global.players[event.player_index].needs_new_remote = true
  
  -- If they're in a car, store the desired heading
  if game.players[event.player_index].vehicle ~= nil then
    local heading = bearing(game.players[event.player_index].vehicle.position, event.position)
    -- Convert to Factorio system
    if heading < 0 then
      heading = heading + 2*math.pi
    end
    heading = heading / (2*math.pi)
    
    global.players[event.player_index].heading_target = heading
  end
  
  start_ticking()
end)
script.on_init(function()
  global.ticking = false
  global.players = {}
end)

script.on_load(function()
  if global.ticking then
    -- Have to unset global.ticking, otherwise start_ticking thinks it
    -- doesn't have to do anything
    global.ticking = false
    start_ticking()
  end
end)