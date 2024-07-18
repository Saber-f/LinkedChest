
Event = require('scripts/event')



local function player_selected_area(event)
    if event.item ~= "virtual" then return end
    local player = game.players[event.player_index]
    local force = player.force
    for _, entity in pairs(event.entities) do
        -- 如果是组装机
        if entity.type == "assembling-machine" then 
            local recipe = entity.get_recipe()
            if recipe ~= nil then
                local vinfo
                local prototype = entity.prototype
                local energy = (prototype.energy_usage + entity.electric_drain) * (1 + entity.consumption_bonus)
                if global.virtual[force.name][recipe.name] == nil then
                    vinfo = {
                        -- 机器数量
                        count = 1,
                        -- 配方
                        recipe = recipe,
                        -- 制作速度
                        speed = entity.crafting_speed,
                        -- 产能
                        productivity_bonus  = entity.productivity_bonus + 1,
                        -- 能耗
                        energy = energy,
                        -- tick
                        tick = game.tick
                    }
                    global.virtual[force.name][recipe.name] = vinfo
                else
                    vinfo = global.virtual[force.name][recipe.name]
                    vinfo.productivity_bonus  = (vinfo.productivity_bonus*vinfo.speed + (entity.productivity_bonus + 1)*en) / vinfo.count
                    vinfo.count = vinfo.count + 1
                    vinfo.speed = vinfo.speed + entity.crafting_speed
                    vinfo.energy = vinfo.energy + energy
                end
                energy = vinfo.energy * 60
                -- 单位
                local unit = {"W", "KW", "MW", "GW", "TW", "PW", "EW", "ZW", "YW"}
                for i = 1, #unit do
                    if energy < 1000 then
                        unit = unit[i]
                        energy = math.floor(energy * 100) / 100
                        break
                    end
                    energy = energy / 1000
                end
    
                player.print("[recipe="..recipe.name.."]机器数量:"..vinfo.count.." 总速度:"..vinfo.speed.." 平均产能:+"..vinfo.productivity_bonus.." 总能耗:"..energy..unit)
                -- 创建一个爆炸
                entity.surface.create_entity({name = 'big-explosion', position = entity.position})
                entity.destroy()
            end
        end
    end
end



local function player_alt_selected_area(event)
    -- if event.item ~= "virtual" then return end
    -- local player = game.players[event.player_index]
    -- local force = player.force
    -- for _, entity in pairs(event.entities) do
    --     -- 如果是组装机
    --     if entity.type == "assembling-machine" then 
    --         local recipe = entity.get_recipe()
    --         if recipe ~= nil then

    --         end
    --     end
    -- end
end

-- 添加蓄电池为虚拟机器供能
local add_accumulator(evnet)
    local entity = event.created_entity
    if (entity.name ~= "accumulator") return end
    local force = entity.force
    if global.virtual[force.name] == nil then
        global.virtual[force.name] = {}
    end
    if global.virtual[force.name]["virtual-energy"] == nil then
        global.virtual[force.name]["virtual-energy"] = []
    end
    table.insert(global.virtual[force.name]["virtual-energy"], entity)
    -- 按postion排序, 从下到上，从左到右
    table.sort(global.virtual[force.name]["virtual-energy"], function(a, b)
        if a.position.y == b.position.y then
            return a.position.x < b.position.x
        end
        return a.position.y < b.position.y
    end)
end

local function tick()
    for _, force in pairs(game.forces) do
        for recipe_name, vinfo in pairs(global.virtual[force.name]) do
            if game.tick - vinfo.tick >= 15 then
                local ingredients = vinfo.recipe.ingredients
                local products = vinfo.recipe.products
                local count = vinfo.speed * (game.tick - vinfo.tick ) / 60 / vinfo.recipe.energy
                local count_copy = count
                if count > 1 then
                    -- 根据原料数量调整生产数量
                    for _, ingredient in pairs(ingredients) do
                        local ingredient_name = ingredient.name
                        local ingredient_amount = ingredient.amount
                        if virtual_get_force_item_count(force.name, ingredient_name) < ingredient_amount * count then
                            count = count * virtual_get_force_item_count(force.name, ingredient_name) / (ingredient_amount * count)
                        end
                    end
                end

                if count > 1 then
                    -- 生产
                    count = math.floor(count)
                    for _, ingredient in pairs(ingredients) do
                        local ingredient_name = ingredient.name
                        local ingredient_amount = ingredient.amount
                        virtual_remove_force_item(force.name, ingredient_name, ingredient_amount * count)
                    end
                    for _, product in pairs(products) do
                        local product_name = product.name
                        local product_amount = product.amount
                        local add_count = math.round(product_amount * count * vinfo.productivity_bonus)
                        add_force_item(force.name, product_name, add_count)
                    end
                    vinfo.tick = vinfo.tick + (game.tick - vinfo.tick) * count / count_copy
                end   
            end
        end
    end
end


Event.addListener(defines.events.on_player_selected_area, player_selected_area)
Event.addListener(defines.events.on_player_alt_selected_area, player_alt_selected_area)
Event.addListener(defines.events.on_built_entity,add_accumulator)    -- 玩家建造物品
Event.addListener(defines.events.on_robot_built_entity,add_accumulator)  -- 机器人建造物品
Event.addListener(defines.events.on_tick, tick)