
Event = require('scripts/event')


local units = {"", "K", "M", "G", "T", "P", "E", "Z", "Y"}

-- 单位转换
local function unitformal(v)
    local unit
    for i = 1, #units do
        if v < 1000 then
            unit = units[i]
            v = math.floor(v * 100) / 100
            break
        end
        v = v / 1000
    end
    return v, unit
end

local function player_selected_area(event)
    if event.item ~= "virtual" then return end

    local player = game.players[event.player_index]
    local force = player.force

    -- 检测虚拟化科技是否研究完成
    if not force.technologies["virtual"].researched then
        player.print("[technology=virtual]未研究完成")
        return
    end


    for _, entity in pairs(event.entities) do
        -- 如果是组装机
        if entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "lab" then 
            local recipe
            local speed
            if entity.type == "lab" then
                recipe = {name = "virtual-lab"}
                speed = entity.prototype.researching_speed*(entity.speed_bonus - force.laboratory_speed_modifier + 1) * (force.laboratory_speed_modifier + 1)
            else
                recipe = entity.get_recipe()
                speed = entity.crafting_speed
            end
            if recipe ~= nil and entity.electric_drain ~= nil then
                local vinfo
                local prototype = entity.prototype
                local energy = (prototype.energy_usage + entity.electric_drain) * (1 + entity.consumption_bonus)
                local last_count = 0
                local last_speed = 0
                local last_productivity_bonus = 0
                local last_energy = 0
                if global.virtual[force.name][recipe.name] == nil then
                    vinfo = {
                        -- 机器数量
                        count = 1,
                        -- 配方
                        recipe = recipe,
                        -- 制作速度
                        speed = speed,
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

                    last_count = vinfo.count
                    last_speed = vinfo.speed
                    last_productivity_bonus = vinfo.productivity_bonus
                    last_energy = vinfo.energy

                    vinfo.productivity_bonus  = (vinfo.productivity_bonus * vinfo.speed + (entity.productivity_bonus + 1) * speed) / (vinfo.speed + speed)
                    vinfo.count = vinfo.count + 1
                    vinfo.speed = vinfo.speed + speed
                    vinfo.energy = vinfo.energy + energy
                end
                energy = vinfo.energy * 60
                last_energy = last_energy * 60
                -- 单位
                local unit
                energy, unit = unitformal(energy)
                local last_unit
                last_energy, last_unit = unitformal(last_energy)
                
                last_productivity_bonus = math.floor(last_productivity_bonus*100+0.5)/100
                local productivity_bonus = math.floor(vinfo.productivity_bonus*100+0.5)/100

                local sub_str = "]机器数量:"..last_count.."->"..vinfo.count.." 总速度:"..last_speed.."->"..vinfo.speed.." 平均产能:"..last_productivity_bonus.."->"..productivity_bonus.." 总能耗:"..last_energy..last_unit.."W->"..energy..unit.."W"

                if entity.type == "lab" then
                    force.print(player.name.."[item=lab"..sub_str)
                else
                    force.print(player.name.."[recipe="..recipe.name..sub_str)
                end
                -- 创建一个爆炸
                entity.surface.create_entity({name = 'big-explosion', position = entity.position})
                entity.destroy()
            end
        end
    end
end

-- 查看配方细腻化信息
local function player_alt_selected_area(event)
    if event.item ~= "virtual" then return end

    local player = game.players[event.player_index]
    local force = player.force

    for _, entity in pairs(event.entities) do
        -- 如果是组装机
        if entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "lab" then 
            local recipe
            if entity.type == "lab" then
                recipe = {name = "virtual-lab"}
            else
                recipe = entity.get_recipe()
            end
            if recipe ~= nil and entity.electric_drain ~= nil then

                vinfo = global.virtual[force.name][recipe.name]
                if vinfo == nil then
                    if entity.type == "lab" then
                        player.print("[item=lab]未虚拟化")
                    else
                        player.print("[recipe="..recipe.name.."]未虚拟化")
                    end
                else
                    energy = vinfo.energy * 60
                    -- 单位
                    local unit
                    energy, unit = unitformal(energy)
                        local productivity_bonus = math.floor(vinfo.productivity_bonus * 100 + 0.5) / 100
                    local sub_str = "]机器数量:"..vinfo.count.." 总速度:"..vinfo.speed.." 平均产能:"..productivity_bonus.." 总能耗:"..energy..unit.."W"

                    if entity.type == "lab" then
                        player.print("[item=lab"..sub_str)
                    else
                        player.print("[recipe="..recipe.name..sub_str)
                    end
                end
            end
        end
    end
end


-- 添加蓄电池为虚拟机器供能
local function add_accumulator(event)
    local entity = event.created_entity
    if (entity.name ~= "accumulator") then return end
    local force = entity.force
    if global.virtual_energy[force.name] == nil then
        global.virtual_energy[force.name] = {}
    end
    table.insert(global.virtual_energy[force.name], entity)

    local new_virtual_energy = {}
    for _, accumulator in pairs(global.virtual_energy[force.name]) do
        if accumulator.valid then
            table.insert(new_virtual_energy, accumulator)
        end
    end
    global.virtual_energy[force.name] = new_virtual_energy

    -- 按postion排序, 从下到上，从左到右
    table.sort(global.virtual_energy[force.name], function(a, b)
        if a.position.y == b.position.y then
            return a.position.x < b.position.x
        end
        return a.position.y > b.position.y
    end)

end

-- 设置虚拟制造先容
local function set_virtual_limit(event)
    local player = game.players[event.player_index]
    local force = player.force
    local name_str = ""
    local show_str = ""
    local num_str = ""
    local num_mode = true
    local name_mode = false
    local type_str = ""
    local reset_num = false
    local type_mode = false

    -- 解析
    for i = 1,#event.message do
        local char = string.sub(event.message, i, i)
        if num_mode then
            if char >= '0' and char <= '9' then
                if reset_num then
                    num_str = ""
                    reset_num = false
                end
                num_str = num_str..char
            elseif char == "[" then
                num_mode = false
                type_mode = true
                show_str = show_str..char
            end
        else
            if char == "]" then     -- 一个结束
                if (type_str == "item" and game.item_prototypes[name_str] ~= nil)  or (type_str == "fluid" and game.fluid_prototypes[name_str] ~= nil) then
                    show_str = show_str..char
                    local num = tonumber(num_str)
                    if num == nil then return end
                    local fnum, unit = unitformal(num)
                    if num > 0 then
                        global.virtual_limit[force.name][name_str] = num
                        force.print(player.name.."设置了虚拟制造限容"..show_str.."<="..fnum..unit)
                    else
                        global.virtual_limit[force.name][name_str] = nil
                        force.print(player.name.."取消了虚拟制造限容"..show_str)
                    end
                end

                type_str = ""
                name_str = ""
                show_str = ""
                name_mode = false
                num_mode = true
                reset_num = true
            else
                if char == "=" then
                    type_mode = false
                end

                if type_mode then
                    type_str = type_str..char
                end
                
                if name_mode then
                    name_str = name_str..char
                end
                
                if char == "=" then
                    name_mode = true
                end

                show_str = show_str..char
            end
        end
    end
end

local function tick()
    for _, force in pairs(game.forces) do
        if global.virtual[force.name] ~= nil then
            for recipe_name, vinfo in pairs(global.virtual[force.name]) do
                if game.tick - vinfo.tick >= 10 then
                    local ingredients = vinfo.recipe.ingredients
                    local products = vinfo.recipe.products
                    local count = vinfo.speed * (game.tick - vinfo.tick ) / 60
                    local count_copy = count
                    local ingredients
                    if (recipe_name == "virtual-lab") then
                        local current_research = force.current_research
                        if current_research ~= nil then
                            ingredients = current_research.research_unit_ingredients
                            count = count / current_research.research_unit_energy
                        else
                            ingredients = {}
                        end
                    else
                        ingredients = vinfo.recipe.ingredients
                        count = count / vinfo.recipe.energy
                    end

                    -- 检测限容
                    if recipe_name ~= "virtual-lab" then
                        local limit = global.virtual_limit[force.name][recipe_name]
                        for _, product in pairs(products) do
                            if global.virtual_limit[force.name][product.name] ~= nil then
                                local expected_value = product.amount * count * vinfo.productivity_bonus   -- 期望值
                                if virtual_get_force_item_count(force.name, product.name) + expected_value > limit then
                                    count = count * (limit - virtual_get_force_item_count(force.name, product.name)) / expected_value
                                end
                            end
                        end
                    end

                    if count >= 1 then
                        -- 根据原料数量调整生产数量
                        for _, ingredient in pairs(ingredients) do
                            local ingredient_name = ingredient.name
                            local ingredient_amount = ingredient.amount
                            if virtual_get_force_item_count(force.name, ingredient_name) < ingredient_amount * count then
                                count = count * virtual_get_force_item_count(force.name, ingredient_name) / (ingredient_amount * count)
                            end
                        end 
                    end

                    if count >= 1 then
                        -- 根据能源消耗调整生产数量
                        local need_energy = vinfo.energy * (game.tick - vinfo.tick)
                        local used_energy = 0
                        for _, accumulator in pairs(global.virtual_energy[force.name]) do
                            if accumulator.valid and accumulator.energy > 0 then
                                local energy = accumulator.energy
                                if energy > need_energy then
                                    accumulator.energy = energy - need_energy
                                    used_energy = used_energy + need_energy
                                    break
                                else
                                    accumulator.energy = 0
                                    used_energy = used_energy + energy
                                    need_energy = need_energy - energy
                                end
                            end
                        end
                        if used_energy < vinfo.energy then  -- 能源不足
                            count = math.floor(count * used_energy / vinfo.energy + 0.5)
                        end
                    end

                    if count >= 1 then
                        count = math.floor(count)
                        for _, ingredient in pairs(ingredients) do
                            local ingredient_name = ingredient.name
                            local ingredient_amount = ingredient.amount
                            -- 移除原料
                            virtual_remove_force_item(force.name, ingredient_name, ingredient_amount * count)

                            -- 增加消耗记录
                            if game.item_prototypes[ingredient_name] ~= nil then
                                force.item_production_statistics.set_output_count(ingredient_name, ingredient_amount * count)
                            elseif game.fluid_prototypes[ingredient_name] ~= nil then
                                force.fluid_production_statistics.set_output_count(ingredient_name, ingredient_amount * count)
                            end
                        end

                        -- 生产/研究
                        if recipe_name == "virtual-lab" then
                            local current_research = force.current_research
                            if current_research ~= nil then
                                local add_count = math.floor(count * vinfo.productivity_bonus + 0.5)
                                local add_progress = add_count / current_research.research_unit_count
                                -- 增加研究进度
                                local progress = force.research_progress + add_progress
                                if progress > 1 then
                                    progress = 1
                                end
                                force.research_progress = progress
                            end
                        else
                            for _, product in pairs(products) do
                                local expected_value = product.amount * count * vinfo.productivity_bonus   -- 期望值
                                if product.probability ~= nil then
                                    expected_value = expected_value * product.probability
                                    if expected_value < 1 then
                                        if math.random() < expected_value then
                                            expected_value = 1
                                        else
                                            expected_value = 0
                                        end
                                    end
                                end

                                if expected_value > 1 then
                                    local product_name = product.name
                                    local add_count = math.floor(expected_value + 0.5)
                                    add_force_item(force.name, product_name, add_count)
                                    
                                    -- 添加生产记录
                                    if game.item_prototypes[product_name] ~= nil then
                                        force.item_production_statistics.set_input_count(product_name, add_count)
                                    elseif game.fluid_prototypes[product_name] ~= nil then
                                        force.fluid_production_statistics.set_input_count(product_name, add_count)
                                    end
                                end
                            end
                        end
                        vinfo.tick = game.tick
                    end   
                end
            end
        end
    end
end


Event.addListener(defines.events.on_player_selected_area, player_selected_area)
Event.addListener(defines.events.on_player_alt_selected_area, player_alt_selected_area)
Event.addListener(defines.events.on_built_entity,add_accumulator)    -- 玩家建造物品
Event.addListener(defines.events.on_robot_built_entity,add_accumulator)  -- 机器人建造物品
Event.addListener(defines.events.on_console_chat, set_virtual_limit) -- 设置虚拟制造限制
Event.addListener(defines.events.on_tick, tick)