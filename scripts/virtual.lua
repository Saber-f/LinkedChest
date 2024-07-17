
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
                local energy = (prototype.energy_usage+prototype.electric_energy_source_prototype.drain) * (1+entity.consumption_bonus)
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
                    vinfo.count = vinfo.count + 1
                    vinfo.speed = vinfo.speed + entity.crafting_speed
                    vinfo.productivity_bonus  = (vinfo.productivity_bonus*(vinfo.count - 1) + entity.productivity_bonus + 1) / vinfo.count
                    vinfo.energy = vinfo.energy + energy
                end
                energy = vinfo.energy * 60
                -- 单位
                local unit = "W"
                if energy > 1000 then
                    energy = energy / 1000
                    unit = "KW"
                end
                if energy > 1000 then
                    energy = energy / 1000
                    unit = "MW"
                end
                if energy > 1000 then
                    energy = energy / 1000
                    unit = "GW"
                end
                if energy > 1000 then
                    energy = energy / 1000
                    unit = "TW"
                end
                if energy > 1000 then
                    energy = energy / 1000
                    unit = "PW"
                end
                energy = math.floor(energy * 100) / 100
    
                player.print("[recipe="..recipe.name.."]机器数量:"..vinfo.count.." 速度:"..vinfo.speed.." 产能:"..vinfo.productivity_bonus.." 能耗:"..energy..unit)
                entity.destroy()
            end
        end
    end
end



local function player_alt_selected_area(event)
    if event.item ~= "virtual" then return end
end

local function tick()
    for _, force in pairs(game.forces) do
        for recipe_name, vinfo in pairs(global.virtual[force.name]) do
            if game.tick - vinfo.tick >= 15 then
                local ingredients = vinfo.recipe.ingredients
                local products = vinfo.recipe.products
                local count = vinfo.speed * (game.tick - vinfo.tick ) / 60 / vinfo.recipe.energy
                if count > 1 then
                    for _, ingredient in pairs(ingredients) do
                        local ingredient_name = ingredient.name
                        local ingredient_amount = ingredient.amount
                        if virtual_get_force_item_count(force.name, ingredient_name) < ingredient_amount * count then
                            count = virtual_get_force_item_count(force.name, ingredient_name) / ingredient_amount
                        end
                    end
                end

                if count > 1 then
                    count = math.floor(count)
                    for _, ingredient in pairs(ingredients) do
                        local ingredient_name = ingredient.name
                        local ingredient_amount = ingredient.amount
                        virtual_remove_force_item(force.name, ingredient_name, ingredient_amount * count)
                    end
                    for _, product in pairs(products) do
                        local product_name = product.name
                        local product_amount = product.amount
                        add_force_item(force.name, product_name, product_amount * count)
                    end
                    vinfo.tick = game.tick
                end   
            end
        end
    end
end


Event.addListener(defines.events.on_player_selected_area, player_selected_area)
Event.addListener(defines.events.on_player_alt_selected_area, player_alt_selected_area)
Event.addListener(defines.events.on_tick, tick)