
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

-- 虚拟化
local function virtual(event, isAdd)
    if event.item ~= "virtual" then return end

    local player = game.players[event.player_index]
    local force = player.force

    -- 检测虚拟化科技是否研究完成
    if (not force.technologies["virtual"].researched) and settings.global["virtual-lock"].value then
        player.print("[technology=virtual]未研究完成")
        return
    end

    local record = {}
    for _, entity in pairs(event.entities) do
        -- 如果是组装机
        if entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "lab" or entity.type == "boiler" then 
            local recipe
            local typename = "recipe"
            local speed = 1
            local productivity_bonus =  1
            local prototype = entity.prototype
            local energy = prototype.max_energy_usage
            local electric_drain = 0
            if entity.electric_drain ~= nil then        -- 最小能耗
                electric_drain = entity.electric_drain
            end
            if entity.type == "lab" then
                recipe = {name = "virtual-lab", des = "[item="..entity.name}
                typename = "lab"
                productivity_bonus = entity.productivity_bonus + 1
                speed = entity.prototype.researching_speed*(entity.speed_bonus - force.laboratory_speed_modifier + 1) * (force.laboratory_speed_modifier + 1)
                energy = (energy + electric_drain) * (1 + entity.consumption_bonus)
            elseif entity.type == "boiler" then     -- 锅炉
                typename = "boiler"
                input = entity.fluidbox.get_locked_fluid(1)
                output = entity.fluidbox.get_locked_fluid(2)
                output_heat_capacity = game.fluid_prototypes[output].heat_capacity
                speed = energy / output_heat_capacity / (prototype.target_temperature - game.fluid_prototypes[input].default_temperature) * 60
                recipe = {
                    name = "virtual-"..entity.name,
                    ingredients = {{name=input, amount=1}},
                    products = {{name=output, amount=1}},
                    des = "[fluid="..input.."]->[fluid="..output
                }
            else
                local recipe2 = entity.get_recipe()
                if recipe2 ~= nil then
                    speed = entity.crafting_speed
                    productivity_bonus = entity.productivity_bonus + 1
                    energy = (energy + electric_drain) * (1 + entity.consumption_bonus)
                    recipe = {
                        name = recipe2.name,
                        ingredients = recipe2.ingredients,
                        products = recipe2.products,
                        des = "[recipe="..recipe2.name,
                        energy = recipe2.energy
                    }
                end
            end
            if recipe ~= nil then
                local vinfo
                local last_count = 0
                local last_speed = 0
                local last_productivity_bonus = 0
                local last_energy = 0
                if global.virtual[force.name][recipe.name] == nil then
                    vinfo = {
                        typename = typename,
                        -- 机器数量
                        count = 1,
                        -- 配方
                        recipe = recipe,
                        -- 制作速度
                        speed = speed,
                        -- 产能
                        productivity_bonus  = productivity_bonus,
                        -- 能耗
                        energy = energy,
                        -- tick
                        tick = game.tick,
                        -- 更新帧
                        update_tick = game.tick,
                    }
                    if recipe.name ~= "virtual-lab" then
                        vinfo.update_tick = game.tick + 10 + math.random()*10
                    end
                    if isAdd then
                        global.virtual[force.name][recipe.name] = vinfo
                    else
                        vinfo.count = 0
                        vinfo.speed = 0
                        vinfo.productivity_bonus = 0
                        vinfo.energy = 0
                    end
                else
                    vinfo = global.virtual[force.name][recipe.name]

                    last_count = vinfo.count
                    last_speed = vinfo.speed
                    last_productivity_bonus = vinfo.productivity_bonus
                    last_energy = vinfo.energy

                    if (isAdd) then -- 加机器
                        vinfo.productivity_bonus  = (vinfo.productivity_bonus * vinfo.speed + (productivity_bonus) * speed) / (vinfo.speed + speed)
                        vinfo.count = vinfo.count + 1
                        vinfo.speed = vinfo.speed + speed
                        vinfo.energy = vinfo.energy + energy
                    else        -- 减机器
                        vinfo.count = vinfo.count - 1
                        vinfo.speed = vinfo.speed * vinfo.count / last_count
                        vinfo.energy = vinfo.energy * vinfo.count / last_count
                        if vinfo.count == 0 then
                            global.virtual[force.name][recipe.name] = nil
                            vinfo.productivity_bonus = 0
                        end
                    end
                end
                energy = vinfo.energy * 60
                last_energy = last_energy * 60
                -- 单位
                local unit
                energy, unit = unitformal(energy)
                local productivity_bonus = math.floor(vinfo.productivity_bonus*100+0.5)/100

                if record[recipe.name] == nil then
                    local last_unit
                    last_energy, last_unit = unitformal(last_energy)
                    last_productivity_bonus = math.floor(last_productivity_bonus*100+0.5)/100

                    record[recipe.name] = {
                        typename = typename,
                        des = recipe.des,
                        name = recipe.name,
                        last_count = last_count,
                        count = vinfo.count,
                        last_speed = last_speed,
                        speed = vinfo.speed,
                        last_productivity_bonus = last_productivity_bonus,
                        productivity_bonus = productivity_bonus,
                        last_energy = last_energy..last_unit,
                        energy = energy..unit
                    }
                else
                    record[recipe.name].count = vinfo.count
                    record[recipe.name].speed = vinfo.speed
                    record[recipe.name].productivity_bonus = productivity_bonus
                    record[recipe.name].energy = energy..unit
                end

                -- 创建一个爆炸
                if isAdd then
                    entity.surface.create_entity({name = 'big-explosion', position = entity.position})
                    entity.destroy()
                end
            end
        end
    end
    
    for _, v in pairs(record) do
        local sub_str = "]机器数量:"..v.last_count.."->"..v.count.." 总速度:"..v.last_speed.."->"..v.speed.." 平均产能:"..v.last_productivity_bonus.."->"..v.productivity_bonus.." 总能耗:"..v.last_energy.."->"..v.energy
        force.print("[technology=virtual]"..player.name..v.des..sub_str)
    end
end

-- 查看配方虚拟化信息
local function player_show_selected_area(event)
    if event.item ~= "showvirtual" then return end

    local player = game.players[event.player_index]
    local force = player.force

    local record = {}
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
                        player.print("[technology=virtual]".."[item=lab]未虚拟化")
                    else
                        player.print("[technology=virtual]".."[recipe="..recipe.name.."]未虚拟化")
                    end
                else
                    energy = vinfo.energy * 60
                    -- 单位
                    local unit
                    energy, unit = unitformal(energy)
                    local productivity_bonus = math.floor(vinfo.productivity_bonus * 100 + 0.5) / 100
                    local sub_str = "]机器数量:"..vinfo.count.." 总速度:"..vinfo.speed.." 平均产能:"..productivity_bonus.." 总能耗:"..energy..unit.."W"
                    record[recipe.name] = v.recipe.des..sub_str
                end
            end
        end
    end
    for _, v in pairs(record) do
        player.print("[technology=virtual]"..v)
    end
end

local function player_selected_area(event)
    virtual(event, true)
    player_show_selected_area(event)
end

-- 取消虚拟化
local function player_alt_selected_area(event)
    virtual(event, false)
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

                    local last_status = ""
                    if global.virtual_limit[force.name][name_str] == nil then
                        last_status = "不限容"
                    else
                        local fnum, unit = unitformal(global.virtual_limit[force.name][name_str])
                        last_status = fnum..unit
                    end

                    local status = ""
                    if num == nil then
                        force.print("[technology=virtual]"..player.name.."查看虚拟限容"..show_str..":"..last_status)
                    elseif num > 0 then
                        local fnum, unit = unitformal(num)
                        status = fnum..unit
                        global.virtual_limit[force.name][name_str] = num
                        force.print("[technology=virtual]"..player.name.."修改虚拟限容"..show_str..":"..last_status.."->"..status)
                    else
                        status = "不限容"
                        global.virtual_limit[force.name][name_str] = nil
                        force.print("[technology=virtual]"..player.name.."修改虚拟限容"..show_str..":"..last_status.."->"..status)
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

-- 从蓄电池中扣除能量
local function remove_accumulator_energy(force, need_energy)
    local used_energy = 0
    
    local index = global.virtual_energy_index[force.name]
    local have_accumulator = false
    for i = #global.virtual_energy[force.name], 1, -1 do
        local accumulator = global.virtual_energy[force.name][index]

        if accumulator then
            if accumulator.valid then
                have_accumulator = true
                if accumulator.energy > 0 then
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
            else
                table.remove(global.virtual_energy[force.name], index)
            end
        end
        index = index - 1
        if index < 1 then
            index = #global.virtual_energy[force.name]
        end
    end
    global.virtual_energy_index[force.name] = index

    if used_energy == 0 then
        if have_accumulator then
            force.print("[technology=virtual]".."[item=accumulator]未供电,虚拟化无法运行!")
        else
            force.print("[technology=virtual]".."[item=accumulator]没有放置,虚拟化无法运行!")
        end
    end

    return used_energy
end

-- 产出or研究
local function do_the_deed(force, vinfo, ingredients, count)
    local products = vinfo.recipe.products

    for _, ingredient in pairs(ingredients) do
        local ingredient_name = ingredient.name
        local ingredient_amount = ingredient.amount
        -- 移除原料
        virtual_remove_force_item(force.name, ingredient_name, ingredient_amount * count)

        -- 增加消耗记录
        if game.item_prototypes[ingredient_name] ~= nil then
            force.item_production_statistics.on_flow(ingredient_name, -ingredient_amount * count)
        elseif game.fluid_prototypes[ingredient_name] ~= nil then
            force.fluid_production_statistics.on_flow(ingredient_name, -ingredient_amount * count)
        end
    end

    -- 生产/研究
    if vinfo.recipe.name == "virtual-lab" then
        local current_research = force.current_research
        if current_research ~= nil then
            local add_count = count * vinfo.productivity_bonus
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
            end

            local add_count = expected_value
            if add_count > 0 then
                local product_name = product.name
                add_force_item(force.name, product_name, add_count)
                
                -- 添加生产记录
                if game.item_prototypes[product_name] ~= nil then
                    force.item_production_statistics.on_flow(product_name, add_count)
                elseif game.fluid_prototypes[product_name] ~= nil then
                    force.fluid_production_statistics.on_flow(product_name, add_count)
                end
            end
        end
    end
end

local function tick()
    for _, force in pairs(game.forces) do
        if global.virtual[force.name] ~= nil then
            for recipe_name, vinfo in pairs(global.virtual[force.name]) do
                if game.tick > vinfo.update_tick then
                    local ingredients = vinfo.recipe.ingredients
                    local products = vinfo.recipe.products
                    local count = vinfo.speed * (game.tick - vinfo.tick ) / 60
                    local ingredients
                    if (recipe_name == "virtual-lab") then
                        local current_research = force.current_research
                        if current_research ~= nil then
                            ingredients = current_research.research_unit_ingredients
                            count = count / current_research.research_unit_energy * 60
                        else
                            ingredients = {}
                        end
                    elseif vinfo.typename == "boiler" then
                        ingredients = vinfo.recipe.ingredients
                    else
                        ingredients = vinfo.recipe.ingredients
                        count = count / vinfo.recipe.energy
                    end

                    -- 检测限容
                    if recipe_name ~= "virtual-lab" then
                        for _, product in pairs(products) do
                            local limit = global.virtual_limit[force.name][product.name]
                            if limit ~= nil then
                                local expected_value = product.amount * count * vinfo.productivity_bonus   -- 期望值
                                if get_force_item_count(force.name, product.name) + expected_value > limit then
                                    local last_count = count;
                                    count = count * (limit - get_force_item_count(force.name, product.name)) / expected_value
                                end
                            end
                        end
                    end

                    if count > 0 then
                        -- 根据原料数量调整生产数量
                        for _, ingredient in pairs(ingredients) do
                            local ingredient_name = ingredient.name
                            local ingredient_amount = ingredient.amount
                            
                            if get_force_item_count(force.name, ingredient_name) < ingredient_amount * count then
                                count = count * get_force_item_count(force.name, ingredient_name) / (ingredient_amount * count)
                            end
                        end 
                    end

                    if count > 0 then
                        -- 根据能源消耗调整生产数量
                        local need_energy = vinfo.energy * (game.tick - vinfo.tick)
                        local used_energy = remove_accumulator_energy(force, need_energy)
                        if used_energy < vinfo.energy then  -- 能源不足
                            count = count * used_energy / vinfo.energy
                        end
                    end

                    if count > 0 then
                        -- 产出
                        do_the_deed(force, vinfo, ingredients, count)
                    end 

                    -- 更新tick
                    vinfo.tick = game.tick
                    if (recipe_name == "virtual-lab") then
                        vinfo.update_tick = game.tick
                    else
                        vinfo.update_tick = game.tick + 10 + math.random()*10
                    end
                end
            end
        end
    end
end

local function runtime_mod_setting_changed(event)
    for _, f in pairs(game.forces) do
        if settings.global["virtual-lock"].value then
            f.print("[technology=virtual]需要研究解锁")
        else
            f.print("[technology=virtual]不需要研究解锁")
        end
        f.technologies['virtual'].enabled = settings.global["virtual-lock"].value
    end
end

script.on_init(runtime_mod_setting_changed)
Event.addListener(defines.events.on_game_created_from_scenario,runtime_mod_setting_changed)
Event.addListener(defines.events.on_runtime_mod_setting_changed, runtime_mod_setting_changed)
Event.addListener(defines.events.on_player_selected_area, player_selected_area)     -- 玩家选择区域(虚拟化)
Event.addListener(defines.events.on_player_alt_selected_area, player_alt_selected_area)    -- 玩家反选区域(取消虚拟化)
Event.addListener(defines.events.on_built_entity,add_accumulator)    -- 玩家建造物品
Event.addListener(defines.events.on_robot_built_entity,add_accumulator)  -- 机器人建造物品
Event.addListener(defines.events.on_console_chat, set_virtual_limit) -- 设置虚拟制造限制
Event.addListener(defines.events.on_tick, tick)