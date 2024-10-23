Grapple = {}

-- constants
Grapple.range = 200
--Grapple.throw_speed = 4
--Grapple.pull_speed = 0.0
--Grapple.pull_speed_per_tick = 0.01 -- increase pull speed over time (for longer distances)

function Grapple.destroy(tick_task)
  tick_task.valid = false
  
  if tick_task.projectile and tick_task.projectile.valid then
    tick_task.projectile.destroy()
  end
end

function Grapple.on_trigger_created_entity(event)
  if event.entity.name == "grappling-gun-trigger" then
    local v_b = {x=0,y=0} -- 上次移速
    if event.source and event.source.valid then
      

      local tick_task = new_tick_task("grappling-gun")
      tick_task.v_b = v_b
      tick_task.surface = event.entity.surface
      tick_task.character = event.source
      tick_task.instigator_force = event.source.force

      local vector = util.vectors_delta(event.source.position, event.entity.position)
      if Util.vector_length(vector) > Grapple.range then
        vector = Util.vector_set_length(vector, Grapple.range)
      end
      local target_position = Util.vectors_add(event.source.position, vector)
      local safe_position = tick_task.surface.find_non_colliding_position (
        "grappling-gun-player-collision", target_position, Grapple.range / 4, 1, true
      )
      tick_task.target_position = safe_position or target_position
      tick_task.safe_position = safe_position -- may be nil

      tick_task.projectile = tick_task.surface.create_entity{
        name = "grappling-gun-projectile",
        position = event.source.position,
        target = Util.vectors_add(tick_task.target_position, vector), -- aim further away
        speed = 0,
      }
      rendering.draw_line{
        color = {r=50,g=50,b=50,a=1},
        width = 2,
        gap_length = 0.1,
        dash_length = 0.1,
        from = {entity=tick_task.projectile, offset = {0, -1}},
        to = {entity=tick_task.character, offset = {0, -1}},
        surface = tick_task.projectile.surface
      }
      rendering.draw_line{
        color = {r=0,g=0,b=0,a=1},
        width = 1,
        from = {entity=tick_task.projectile, offset = {0, -1}},
        to = {entity=tick_task.character, offset = {0, -1}},
        surface = tick_task.projectile.surface
      }
    end
  end
end
Event.addListener(defines.events.on_trigger_created_entity, Grapple.on_trigger_created_entity)

function Grapple.tick_task_grappling_gun(tick_task)
  if tick_task.projectile and tick_task.projectile.valid and tick_task.character and tick_task.character.valid
    and tick_task.projectile.surface == tick_task.character.surface then

    if tick_task.pull then
      if tick_task.character.stickers then
        for _, sticker in pairs(tick_task.character.stickers) do sticker.destroy() end
      end
      if not tick_task.tick then tick_task.tick = game.tick end
      local v1 = {x = tick_task.safe_position.x - tick_task.character.position.x, y = tick_task.safe_position.y - tick_task.character.position.y}
      local v1_l = math.sqrt(v1.x * v1.x + v1.y*v1.y)  -- 和安全位置的距离

      local k = (settings.global["pull_speed_per_tick"].value*0.01+v1_l*settings.global["length_v"].value*0.0001)

      v1.x = v1.x/v1_l*k;
      v1.y = v1.y/v1_l*k;

      local sj = settings.global["shuaijian"].value / 10000
      tick_task.v_b.x = sj*tick_task.v_b.x + v1.x
      tick_task.v_b.y = sj*tick_task.v_b.y + v1.y

      --local pull_speed = Grapple.pull_speed + (game.tick - tick_task.tick) * Grapple.pull_speed_per_tick
      --local last_length = tick_task.last_length or Util.vectors_delta_length(tick_task.character.position, tick_task.target_position)
      local p2 = {x = tick_task.character.position.x + tick_task.v_b.x,y = tick_task.character.position.y + tick_task.v_b.y} -- 目标位置
      local v2 = {x = math.abs(p2.x - tick_task.safe_position.x),y = math.abs(p2.y - tick_task.safe_position.y)}
      if  math.sqrt(v2.x*v2.x + v2.y*v2.y) > 2 and v1_l < settings.global["max-distance"].value then
        --local new_vector = Util.vector_set_length(line_vector, last_length - pull_speed)
        --tick_task.character.teleport(Util.vectors_add(tick_task.safe_position, new_vector))
        tick_task.character.teleport(p2)
        --tick_task.last_length = last_length - pull_speed

        if not tick_task.character.valid then return Grapple.destroy(tick_task) end -- movement can cause invalid
      else
        tick_task.character.teleport(tick_task.safe_position)
        if tick_task.character and tick_task.character.valid then
          tick_task.character.destructible = true
        end
        Grapple.destroy(tick_task)
      end
    else
      local v = math.sqrt(tick_task.v_b.x*tick_task.v_b.x  + tick_task.v_b.y*tick_task.v_b.y)
      tick_task.projectile.teleport(Util.move_to(tick_task.projectile.position, tick_task.target_position, settings.global["throw-speed"].value*0.1 + 0.1*settings.global["throw-speed-a"].value*v))
      tick_task.projectile.surface.create_trivial_smoke{name="light-smoke", position = Util.vectors_add(tick_task.projectile.position,{x=0,y=-1})}
      if not tick_task.character.valid then return  Grapple.destroy(tick_task) end -- movement can cause invalid
      if Util.vectors_delta_length(tick_task.projectile.position, tick_task.target_position) < 0.01 then
        if tick_task.safe_position then
          tick_task.pull = true
          if global.tick_tasks then
            for _, tick_task2 in pairs(global.tick_tasks) do
              if tick_task2.type == "grappling-gun" and tick_task2.character == tick_task.character then
                if tick_task2.id < tick_task.id then
                  tick_task.v_b = tick_task2.v_b
                  Grapple.destroy(tick_task2)
                end
              end
            end
          end

          if settings.global["wudi"].value then
            tick_task.character.destructible = false
          end
          tick_task.last_length = Util.vectors_delta_length(tick_task.character.position, tick_task.target_position)
          tick_task.projectile.surface.create_entity{name="explosion-hit", position = Util.vectors_add(tick_task.projectile.position,{x=0,y=0})}
        else
          Grapple.destroy(tick_task)
        end
      end
    end

  else
    Grapple.destroy(tick_task)
  end

end

return Grapple
