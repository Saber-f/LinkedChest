local Event = require('scripts/event')


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
    -- v保留三位小数
    v = math.floor(v * 1000+0.5) / 1000
    return v, unit
end

-- 获取循环依赖描述
--- @param force LuaForce
--- @param des string
local function get_cycle_description(force, des)
    local recipe_name = des:gsub("%[recipe=", "")
    des = ""
    if global.circulate_recipe[force.name].ingredient[recipe_name] ~= nil or global.circulate_recipe[force.name].product[recipe_name] ~= nil then
        des = "\n循环依赖:"
        if global.circulate_recipe[force.name].ingredient[recipe_name] ~= nil then
            des = des.."原料:"
            local ingredients = game.recipe_prototypes[recipe_name].ingredients
            for _,ingredient in pairs(ingredients) do
                if global.circulate_recipe[force.name].ingredient[recipe_name][ingredient.name] ~= nil then
                    local format_name = "[item="..ingredient.name.."]"
                    if game.fluid_prototypes[ingredient.name] ~= nil then
                        format_name = "[fluid="..ingredient.name.."]"
                    end
                    des = string.format("%s%s", des, format_name)
                    local min_limit = global.min_limit[force.name][ingredient.name]
                    if min_limit ~= nil then
                        local fnum, unit = unitformal(min_limit)
                        des = string.format("%s%s", des, "(下限:"..fnum..unit)
                        fnum, unit = unitformal(min_limit/2)
                        des = string.format("%s%s)", des, "->"..fnum..unit)
                    else
                        des = string.format("%s%s", des, "(下限:无)")
                    end
                end
            end
        end

        if global.circulate_recipe[force.name].product[recipe_name] ~= nil then
            des = des.." 产物:"
            local products = game.recipe_prototypes[recipe_name].products
            for _,product in pairs(products) do
                if global.circulate_recipe[force.name].product[recipe_name][product.name] ~= nil then
                    local format_name = "[item="..product.name.."]"
                    if game.fluid_prototypes[product.name] ~= nil then
                        format_name = "[fluid="..product.name.."]"
                    end
                    des = string.format("%s%s", des, format_name)
                    local limit = global.virtual_limit[force.name][product.name]
                    if limit ~= nil then
                        local fnum, unit = unitformal(limit)
                        des = string.format("%s%s", des, "(上限:"..fnum..unit)
                        fnum, unit = unitformal(limit*2)
                        des = string.format("%s%s)", des, "->"..fnum..unit)
                    else
                        des = string.format("%s%s", des, "(上限:无)")
                    end
                end
            end
        end
    end
    return des
end

-- 获取本地名称
local function get_format_name(name)
    local format_name = ""
    if game.item_prototypes[name] ~= nil then
        format_name = "[item="..name.."]"
    elseif game.fluid_prototypes[name] ~= nil then
        format_name = "[fluid="..name.."]"
    end
    return format_name
end

-- 获取翻译名称
local function get_local_name(name)
    local local_name = name
    if game.item_prototypes[name] ~= nil then
        local_name = game.item_prototypes[name].localised_name
    elseif game.fluid_prototypes[name] ~= nil then
        local_name = game.fluid_prototypes[name].localised_name
    end
    return local_name
end

-- 打印路径
local function print_path(path, head)
    local des = ""
    local current = head
    local record = {}
    while path[current] do
        des = des..get_format_name(current).."->"
        if record[current] then
            break
        end
        record[current] = true
        current = path[current]
    end
    des = des..get_format_name(current)
    return des

end

-- 安全打印
local function mylog(des)
    local log_des = {}
    for _, v in pairs(des) do
        table.insert(log_des, v)
        if #log_des > 20 then
            log(log_des)
            log_des = {"", "续行:"}
        end
    end
    if #log_des > 1 then
        log(log_des)
    end
end

-- 寻找有向图中的所有环
local function find_circulate_recipe(nodes, force)
    local visited = {}
    local result = {}
    local max_path = 0
    local N = 0
    global.circulate_recipe[force.name].ingredient = {}
    global.circulate_recipe[force.name].product = {}
    global.circulate_recipe[force.name].des = ""
    global.circulate_recipe[force.name].max_path = ""
    for node, _ in pairs(nodes) do
        if visited[node] == nil then
            visited[node] = {}
            local path = {}
            local last_path = {} -- 反向路径
            local current = node
            while true do
                local is_next = false
                for next, _ in pairs(nodes[current]) do
                    -- 没有走过
                    if visited[current][next] == nil and nodes[next] then
                        visited[current][next] = true   -- 标记走过
                        path[current] = next        -- 记录路径
                        table.insert(last_path, current)
                        -- local des1 = {""}
                        -- for _, v in pairs(last_path) do
                        --     table.insert(des1, get_local_name(v))
                        --     table.insert(des1, "->")
                        -- end
                        -- table.insert(des1, get_local_name(next))
                        -- mylog(des1)
                        current = next           -- 移动到下一个节点
                        -- 如果没有访问过，初始化
                        if visited[current] == nil then
                            visited[current] = {}
                        end
                        is_next = true
                        break
                    end
                end


                local is_circuleate = false
                if path[current] ~= nil then        -- 找到循环
                    local cirulate_path = {}
                    N = N + 1
                    -- local des = {"",N.."、找到循环:",get_local_name(current)};
                    local path_length = 1
                    local is_record = false
                    local current2 = current
                    while path[current2] ~= current do
                        -- table.insert(des, "=>")
                        -- table.insert(des, get_local_name(path[current2]))
                        path_length = path_length + 1
                        cirulate_path[current2] = path[current2]
                        local last = current2

                        current2 = path[current2]

                        local repices = nodes[last][current2]  -- [product][ingredient] = {recipe1, recipe2}
                        for _, recipe in pairs(repices) do
                            if global.circulate_recipe[force.name].ingredient[recipe] == nil then
                                global.circulate_recipe[force.name].ingredient[recipe] = {}
                            end
                            global.circulate_recipe[force.name].ingredient[recipe][current] = true

                            if global.circulate_recipe[force.name].product[recipe] == nil then
                                global.circulate_recipe[force.name].product[recipe] = {}
                            end
                            global.circulate_recipe[force.name].product[recipe][last] = true
                        end
                    end
                    -- table.insert(des, "->")
                    -- table.insert(des, get_local_name(path[current2]))
                    -- mylog(des)

                    cirulate_path[current2] = path[current2]
                    table.insert(result, cirulate_path) -- 记录循环路径
                    if (path_length > max_path) and (is_record or true) then
                        max_path = path_length
                    end


                    is_circuleate = true
                end


                -- 退回到上一个节点
                if (not is_next) or is_circuleate then
                    -- node作为起点已经无路可退
                    if #last_path == 0 then
                        break
                    end
                    -- local des1 = {""}
                    -- for _, v in pairs(last_path) do
                    --     table.insert(des1, get_local_name(v))
                    --     if v == last_path[#last_path] then
                    --         table.insert(des1, "<-")  
                    --     else
                    --         table.insert(des1, "->")
                    --     end
                    -- end
                    -- table.insert(des1, get_local_name(current))
                    -- mylog(des1)
                    current = last_path[#last_path]
                    table.remove(last_path)
                    path[current] = nil
                end
            end
        end
    end
    global.circulate_recipe[force.name].des = "循环依赖刷新共有"..#result.."个循环,最长的循环长度为:"..max_path
    force.print(global.circulate_recipe[force.name].des)
    log(global.circulate_recipe[force.name].des)
    return result
end
    

-- 更新循环配方
local function reresh_circulate_recipe(force)
    -- 区分配方V,E 原版225,595 PY3602,43128
    -- 不区分配方V,E 原版217,591(依赖) PY3602,27587 => 3594,27587(产出) => 3525,2490(依赖)
    local nodes = {}
    local V = 0
    local E = 0

    -- 循环排除
    local black_list = global.circulate_recipe[force.name].blacklist or {}
    -- black_list["ash"] = true
    -- black_list["empty-barrel"] = true
    -- black_list["cage"] = true

    for reicpe_name,vinfo in pairs(global.virtual[force.name]) do
        local reicpe = vinfo.recipe
        if reicpe and reicpe.ingredients and reicpe.products and #reicpe.ingredients > 0 and #reicpe.products > 0 then
            for _,product in pairs(reicpe.products) do
                if not black_list[product.name] then  -- 排除空桶
                    if nodes[product.name] == nil then
                        V = V + 1
                        nodes[product.name] = {}
                    end
                    for _,ingredient in pairs(reicpe.ingredients) do
                        if not black_list[ingredient.name] then
                            if nodes[product.name][ingredient.name] == nil then
                                E = E + 1
                                nodes[product.name][ingredient.name] = {}
                            end
                            table.insert(nodes[product.name][ingredient.name], reicpe_name)
                        end
                    end
                end
            end
        end
    end

    -- log("V:"..V.." E:"..E)
    find_circulate_recipe(nodes, force)
end

-- 虚拟化
--- @param event on_player_selected_area
--- @param isAdd boolean true: 添加虚拟化 false: 取消虚拟化
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
        if entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "lab" or entity.type == "boiler" or type == "generator" then 
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
                local input = entity.fluidbox.get_locked_fluid(1)
                local output = entity.fluidbox.get_locked_fluid(2)
                local output_heat_capacity = game.fluid_prototypes[output].heat_capacity
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
                if global.virtual[force.name][recipe.name] == nil or global.virtual[force.name][recipe.name].recipe == nil then
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
                        force.print("新配方虚拟化，重新计算循环依赖")
                        reresh_circulate_recipe(force)
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
                            force.print("删除配方虚拟化，重新计算循环依赖")
                            reresh_circulate_recipe(force)
                            global.virtual[force.name][recipe.name] = {last_player = player.name}
                            vinfo.productivity_bonus = 0
                        end
                    end
                end
                if player.name ~= vinfo.current_player then
                    vinfo.last_player = vinfo.current_player
                    vinfo.current_player = player.name
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
                record[recipe.name].last_player = vinfo.last_player or "无"

                -- 创建一个爆炸
                if isAdd then
                    entity.surface.create_entity({name = 'big-explosion', position = entity.position})
                    entity.destroy()
                end
            end
        end
    end
    
    for _, v in pairs(record) do
        local player_str = v.last_player.."->"..player.name
        local sub_str = "]机器数量:"..v.last_count.."->"..v.count.." 总速度:"..(math.floor(v.last_speed*1000+0.5)/1000).."->"..(math.floor(v.speed*1000+0.5)/1000).." 平均产能:"..v.last_productivity_bonus.."->"..v.productivity_bonus.." 总能耗:"..v.last_energy.."->"..v.energy
        force.print("[technology=virtual]"..player_str..v.des..sub_str..get_cycle_description(force, v.des))
    end
end

-- 获取配方信息
local function get_recipe_info(player, key)
    local force = player.force
    local vinfo = global.virtual[force.name][key]
    local player_str = ""
    if vinfo then 
        player_str = (vinfo.last_player or "无").."->"..(vinfo.current_player or "无")
    end
    if vinfo == nil or vinfo.recipe == nil then
        return player_str.."[recipe="..key.."]未虚拟化"
    else
        local recipe = vinfo.recipe
        local energy = vinfo.energy * 60
        -- 单位
        local unit
        energy, unit = unitformal(energy)
        local productivity_bonus = math.floor(vinfo.productivity_bonus * 100 + 0.5) / 100
        local sub_str = "]机器数量:"..vinfo.count.." 总速度:"..(math.floor(vinfo.speed*1000+0.5)/1000).." 平均产能:"..productivity_bonus.." 总能耗:"..energy..unit.."W"
        return player_str..vinfo.recipe.des..sub_str..get_cycle_description(force, vinfo.recipe.des)
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
        if entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "lab" or entity.type == "boiler" then 
            local key
            if entity.type == "lab" then
                key = "virtual-lab"
            elseif entity.type == "boiler" then     -- 锅炉
                key = "virtual-"..entity.name
            else
                local recipe2 = entity.get_recipe()
                if recipe2 ~= nil then
                    key = recipe2.name
                end
            end
            if key then
                local vinfo = global.virtual[force.name][key]
                if vinfo == nil then
                    if entity.type == "lab" then
                        player.print("[technology=virtual]".."[item=lab]未虚拟化")
                    elseif entity.type == "boiler" then
                        player.print("[technology=virtual]".."[item="..entity.name.."]未虚拟化")
                    else
                        player.print("[technology=virtual]".."[recipe="..key.."]未虚拟化")
                    end
                else
                    local recipe = vinfo.recipe
                    record[recipe.name] = get_recipe_info(player, key)
                end
            end
        end
    end
    for _, v in pairs(record) do
        player.print("[technology=virtual]"..v)
    end
end


-- 对玩家选中的区域进行操作
--- @param event on_player_selected_area
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

-- 显示库存信息
local function show_inventory_info(player, show_str, name, last_min, last_limit, recipes_info)
    -- 打印机器上限，库存
    local force = player.force
    local limit = global.virtual_limit[force.name][name]
    local count = get_force_item_count(force.name, name)
    local fnum, unit = unitformal(count)
    local limit_str = ""
    if limit == nil then
        limit_str = "无"
    else
        local fnum, unit = unitformal(limit)
        limit_str = fnum..unit
    end
    local last_player = "(无)"
    if global.virtual_limit_last_player[force.name][name] ~= nil then
        last_player = global.virtual_limit_last_player[force.name][name]
    end
    limit_str = limit_str..last_player

    -- 同样显示下限
    local limit2 = global.min_limit[force.name][name]
    local limit_str2 = ""
    if limit2 == nil then
        limit_str2 = "无"
    else
        local fnum, unit = unitformal(limit2)
        limit_str2 = fnum..unit
    end
    local last_player2 = "(无)"
    if global.min_limit_last_player[force.name][name] ~= nil then
        last_player2 = global.min_limit_last_player[force.name][name]
    end
    limit_str2 = limit_str2..last_player2

    if last_min ~= nil then
        force.print("[technology=virtual]"..show_str.."上限:"..limit_str.." 下限:"..last_min.."->"..limit_str2.." 库存:"..fnum..unit)
    elseif last_limit ~= nil then
        force.print("[technology=virtual]"..show_str.."上限:"..last_limit.."->"..limit_str.." 下限:"..limit_str2.. " 库存:"..fnum..unit)
    else
        if recipes_info ~= nil then
            local recipe_list = ""
            if recipes_info.is_show_recipe then
                recipe_list = recipes_info.recipe_list
            end
            force.print(recipes_info.index.."、"..show_str.."上限:"..limit_str.." 下限:"..limit_str2.." 库存:"..fnum..unit.." 产量不足,影响"..recipes_info.count.."个配方"..recipe_list)
        else
            player.print("[technology=virtual]"..show_str.."上限:"..limit_str.." 下限:"..limit_str2.." 库存:"..fnum..unit)
        end
    end

end

-- 设置限容
local function setLimit(player, show_str, name_str, num, isMin, isView)
    local last_status = ""
    local force = player.force

    local limit_table
    local last_player
    local isLimit = false -- 是否为上限
    if isView then
        show_inventory_info(player, show_str, name_str)
        return
    elseif isMin then
        limit_table = global.min_limit[force.name]
        last_player = global.min_limit_last_player[force.name][name_str]
        isLimit = false
    else
        limit_table = global.virtual_limit[force.name]
        last_player = global.virtual_limit_last_player[force.name][name_str]
        isLimit = true
    end
    
    if last_player == nil then last_player = "(无)" end

    if limit_table[name_str] == nil then
        last_status = "无"..last_player
    else
        local fnum, unit = unitformal(limit_table[name_str])
        last_status = fnum..unit..last_player
    end


    local status = ""
    if num == nil then
        status = "无"
        if isMin then
            global.min_limit_last_player[force.name][name_str] = "("..player.name..")"
            global.min_limit[force.name][name_str] = nil
        else
            global.virtual_limit_last_player[force.name][name_str] = "("..player.name..")"
            global.virtual_limit[force.name][name_str] = nil
        end
    elseif num >= 0 then
        local fnum, unit = unitformal(num)
        status = fnum..unit
        if isMin then
            global.min_limit_last_player[force.name][name_str] = "("..player.name..")"
            global.min_limit[force.name][name_str] = num
        else
            global.virtual_limit_last_player[force.name][name_str] = "("..player.name..")"
            global.virtual_limit[force.name][name_str] = num
        end
    else
        return
    end
    if isLimit then -- 如果是上限
        show_inventory_info(player, show_str, name_str, nil, last_status)
    else
        show_inventory_info(player, show_str, name_str, last_status, nil)
    end
end

-- 范围设置限容
--- @param player LuaPlayer
--- @param start string
--- @param target string
--- @param num number
--- @param isMin boolean
--- @param isView boolean
local function rangeSetLimit(player, start, target, num, isMin, isView)
    local prototypes = game.item_prototypes
    local item_fluid = "item"
    if prototypes[start] == nil then
        prototypes = game.fluid_prototypes
        item_fluid = "fluid"
    end
    if prototypes[start] == nil or prototypes[target] == nil then
        return
    end
    if (prototypes[start].group.name ~= prototypes[target].group.name) then
        return
    end

    local isStart = false
    for _, item in pairs(prototypes) do
        if item.name == target then
            break
        end

        if isStart then
            local name_str = item.name
            local show_str = "["..item_fluid.."="..item.name.."]"
            
            setLimit(player, show_str, name_str, num, isMin, isView)
        end

        if item.name == start then
            isStart = true
        end
    end
end

local function split_string(input_str, sep)
    local t = {}
    for str in string.gmatch(input_str, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- 缺什么
local function what_no_enough(player, is_show_recipe)
    local force = player.force
    local no_enough = global.no_enough[force.name]
    local fvirtual = global.virtual[force.name]
    if no_enough == nil then
        force.print("啥都不缺，所有配方全速生产，完美o(*￣▽￣*)ブ")
        return
    end
    local no_enough_list = {}
    local recipes_map = {}
    local no_recipes_count = 0
    for name, recipes in pairs(no_enough) do
        local count = 0
        local recipe_list = {}
        for recipe_name in pairs(recipes) do
            if fvirtual[recipe_name] then
                if recipe_name ~= "virtual-lab" or force.current_research ~= nil then
                    if recipes_map[recipe_name] == nil then
                        recipes_map[recipe_name] = true
                        no_recipes_count = no_recipes_count + 1
                    end
                    table.insert(recipe_list, recipe_name)
                    count = count + 1
                end
            end
        end
        if count > 0 then
            table.insert(no_enough_list, {name = name, recipes_count = count, recipe_list = recipe_list})
        end
    end
    if #no_enough_list == 0 then
        force.print("啥都不缺，所有配方全速生产，完美o(*￣▽￣*)ブ")
        return
    end

    -- 按recipes_count排序
    table.sort(no_enough_list, function(a, b)
        return a.recipes_count < b.recipes_count
    end)
    for i, item in pairs(no_enough_list) do
        local format_name = "[item="..item.name.."]"
        if game.fluid_prototypes[item.name] ~= nil then
            format_name = "[fluid="..item.name.."]"
        end
        local show_str = ""
        for _, recipe_name in pairs(item.recipe_list) do
            if recipe_name == "virtual-lab" then
                show_str = show_str.."[technology="..force.current_research.name.."]"
            else
                show_str = show_str.."[recipe="..recipe_name.."]"
            end
        end
        local recipes_info = {count = item.recipes_count, recipe_list = show_str, index = i, is_show_recipe = is_show_recipe}
        show_inventory_info(player, format_name, item.name, nil, nil, recipes_info)
    end
    force.print("[technology=virtual]共有"..#no_enough_list.."种物品产量不足,导致"..no_recipes_count.."个配方无法全速生产")
end

local wan_fa_shuo_ming = "1、按下SHIFT+F框选有配方的实体，转移到虚拟空间进行生产，[item=accumulator]提供电力。\n2、按下SHIFT+F后按住SHIFT取消该配方的虚拟化。\n3、按下ALT+F后框选查看配方虚拟化信息\n4、FNEI配方中点击物品文字标签打印库存和限容。\n5、FNEI配方中按住SHIFT点击物品文字标签将物品添加到快捷文本编辑框。\n6、FNEI配方中点击配方图标查看配方虚拟化信息。\n7、获取命令说明,聊天框输入:查看命令\n联机交流群:666437832如果问题可加群反馈"
local ming_ling_shuo_ming = "聊天框输入:\n1、上限(下限)1000[item=burner-inserter]-[item=stack-filter-inserter]=>设置物品上限或下限(循环依赖，原料的下限减半，产品上限翻倍)\n2、查看[item=burner-inserter]-[item=stack-filter-inserter]=>查看上限，下限和库存\n3、同步(取消同步)[item=burner-inserter]=>在关联箱库存同步禁用时手动开启(关闭)\n4、同步列表=>查看所有手动开启的同步物品\n5、循环排除(取消n5、循环排除)[item=empty-barrel]=>在计算循环循环依赖时排除\n6、循环排除列表=>查看计算循环依赖时所有排除的物品\n7、怎么玩(虚拟化)=>查看说明\8、缺啥(缺什么)=>查看所有产量不足的物品\n联机交流群:666437832如果问题可加群反馈"
-- 设置同步白名单
local function set_tongbu_white_list(event)
    local player = game.players[event.player_index]
    local force = player.force

    if string.find(event.message, "虚拟化") or string.find(event.message, "怎么玩") then
        force.print("你是在问虚拟化怎么玩吗？\n"..wan_fa_shuo_ming)
        return true
    elseif event.message == "已读不再提醒" then
        global.no_tip[player.name] = true
        player.print("提示已关闭")
        return true
    elseif event.message == "查看命令" then
        force.print(ming_ling_shuo_ming)
        return true
    elseif event.message == "缺啥" or event.message == "缺什么" then
        local is_show_recipe = true
        if string.find(event.message, "配方") then
            is_show_recipe = true
        end
        what_no_enough(player, is_show_recipe)
        return true
    end

    if event.message == "同步列表" then
        local whitelist = global.tongbu_white_list[force.name]
        if whitelist == nil then
            whitelist = {}
        end
        if #whitelist == 0 then
            player.print("同步列表为空")
            return true
        end
        for k, v in pairs(whitelist) do
            force.print("[item="..v.name.."]")
        end
        return true
    elseif event.message == "循环排除列表" then
        local blacklist = global.circulate_recipe[force.name].blacklist
        if blacklist == nil then
            blacklist = {}
        end
        local is_empty = true
        for k, v in pairs(blacklist) do
            is_empty = false
            force.print(get_format_name(k))
            -- log(get_format_name(k))
        end
        if is_empty then
            player.print("循环排除列表为空")
            -- log("循环排除列表为空")
        end
        return true
    elseif event.message == "查找循环" then
        return
    end

    -- 如果前两个字符是"同步"，则是同步白名单
    local is_add = true
    local is_black = false
    if string.find(event.message, "取消同步") then
        force.print(player.name.."从同步列表移除:")
        is_add = false
    elseif string.find(event.message, "同步") then
        force.print(player.name.."向同步列表添加:")
        is_add = true
    elseif string.find(event.message, "取消循环排除") then
        force.print(player.name.."从循环排除列表移除:")
        -- log(player.name.."从循环排除列表移除:")
        is_add = false
        is_black = true
    elseif string.find(event.message, "循环排除") then
        force.print(player.name.."向循环排除列表添加:")
        -- log(player.name.."向循环排除列表添加:")
        is_add = true
        is_black = true
    else
        return false
    end
    
    
    local target_list = global.tongbu_white_list[force.name]
    if is_black then
        if global.circulate_recipe[force.name].blacklist == nil then
            global.circulate_recipe[force.name].blacklist = {}
        end
        target_list = global.circulate_recipe[force.name].blacklist
    end
    -- 按[分割
    local items = split_string(event.message, "[")
    for _, item in pairs(items) do
        -- 取item=和]之间的字符串
        local item_name = string.match(item, "item=(.*)]")
        if item_name and game.item_prototypes[item_name] ~= nil then
            if is_add then
                if is_black then
                    target_list[item_name] = true
                else
                    table.insert(target_list, {name = item_name, update_tick = game.tick})
                end
            else
                if is_black then
                    target_list[item_name] = nil
                else
                    for i = #target_list, 1, -1 do
                        if target_list[i].name == item_name then
                            table.remove(target_list, i)
                            break
                        end
                    end
                end
            end
            force.print("[item="..item_name.."]")
            -- log("[item="..item_name.."]")
        end
        local fluid_name = string.match(item, "fluid=(.*)]")
        if fluid_name and game.fluid_prototypes[fluid_name] ~= nil then
            if is_add then
                target_list[fluid_name] = true
            else
                target_list[fluid_name] = nil
            end
            force.print("[fluid="..fluid_name.."]")
            -- log("[fluid="..fluid_name.."]")
        end
    end
    if is_black then
        reresh_circulate_recipe(force)
    end
    return true
end

-- 设置虚拟制造限容(聊天框输入事件)
local function set_virtual_limit(event)
    -- 服务器输入
    if event.player_index == nil then
        -- event.player_index = game.players.sabet.index
        return
    end
    if set_tongbu_white_list(event) then return end
    local player = game.players[event.player_index]
    local name_str = ""
    local show_str = ""
    local num_str = ""
    local num_mode = true
    local name_mode = false
    local type_str = ""
    local reset_num = false
    local type_mode = false
    
    local last_name = ""
    local isRange = false   -- 是否范围显示

    local isMin = false
    local isView = false    -- 是否查看
    if string.find(event.message, "下限") then
        isMin = true
    elseif string.find(event.message, "上限") then
        isMin = false
    elseif string.find(event.message, "查看") then
        isView = true
    else
        return
    end

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
            elseif char == "-" then
                isRange = true
            end
        else
            if char == "]" then     -- 一个结束
                if (type_str == "item" and game.item_prototypes[name_str] ~= nil)  or (type_str == "fluid" and game.fluid_prototypes[name_str] ~= nil) then
                    show_str = show_str..char
                    local num = tonumber(num_str)


                    if isRange then
                        rangeSetLimit(player, last_name, name_str, num, isMin, isView)
                        isRange = false
                    end
                    setLimit(player, show_str, name_str, num, isMin, isView)
                end

                last_name = name_str
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
            if (game.tick % 8 == 0) then
                force.print("[technology=virtual]".."[item=accumulator]供电不足,虚拟化无法全速运行!")
            end
        else
            if (game.tick % 4 == 0) then
                force.print("[technology=virtual]".."[item=accumulator]没有放置,虚拟化无法运行!")
            end
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
            local expected_value
            if product.amount_min and product.amount_max then
                expected_value = (product.amount_min + product.amount_max) / 2 * count * vinfo.productivity_bonus   -- 期望值
            else
                expected_value = product.amount * count * vinfo.productivity_bonus   -- 期望值
            end
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
    if game.tick % 300 == 0 then
        for _, player in pairs(game.connected_players) do
            if not global.no_tip[player.name] then
                player.print("玩法说明:\n"..wan_fa_shuo_ming)
                player.print("关闭提示,聊天框输入:已读不再提醒")
            end
        end
    end


    for _, force in pairs(game.forces) do
        if force.name ~= "enemy" and force.name ~= "neutral" and force.name ~= nil then
            if global.virtual[force.name] ~= nil then
                for recipe_name, vinfo in pairs(global.virtual[force.name]) do
                    if vinfo.recipe and game.tick > vinfo.update_tick then
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
                                    if global.circulate_recipe[force.name].product[recipe_name] ~= nil then
                                        if global.circulate_recipe[force.name].product[recipe_name][product.name] then
                                            limit = limit * 2
                                        end
                                    end

                                    local expected_value
                                    if product.amount_min and product.amount_max then
                                        expected_value = (product.amount_min + product.amount_max) / 2 * count * vinfo.productivity_bonus   -- 期望值
                                    else
                                        expected_value = product.amount * count * vinfo.productivity_bonus   -- 期望值
                                    end
                                    
                                    if product.probability ~= nil then
                                        expected_value = expected_value * product.probability
                                    end
                                    if get_force_item_count(force.name, product.name) + expected_value > limit then
                                        count = count * (limit - get_force_item_count(force.name, product.name)) / expected_value
                                        if count < 0 then
                                            count = 0
                                        end
                                    end
                                end
                            end
                        end

                        
                        -- 根据原料数量调整生产数量
                        local new_count = count
                        for _, ingredient in pairs(ingredients) do
                            local ingredient_name = ingredient.name
                            local ingredient_amount = ingredient.amount
                            local min_limit = 0
                            if global.min_limit[force.name][ingredient_name] ~= nil then
                                min_limit = global.min_limit[force.name][ingredient_name]
                            end
                            if global.circulate_recipe[force.name].ingredient[recipe_name] ~= nil then
                                if global.circulate_recipe[force.name].ingredient[recipe_name][ingredient_name] then
                                    min_limit = min_limit / 2
                                end
                            end
                            local curr_count = get_force_item_count(force.name, ingredient_name) - min_limit
                            if curr_count < 0 then
                                curr_count = 0
                            end
                            if curr_count < ingredient_amount * count then
                                local new_value = curr_count / ingredient_amount
                                if new_value < new_count then
                                    new_count = new_value
                                end
                                if global.no_enough[force.name][ingredient_name] == nil then
                                    global.no_enough[force.name][ingredient_name] = {}
                                end
                                global.no_enough[force.name][ingredient_name][recipe_name] = true
                            else
                                if global.no_enough[force.name][ingredient_name] ~= nil then
                                    global.no_enough[force.name][ingredient_name][recipe_name] = nil
                                end
                            end
                        end
                        count = new_count


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

    -- 同步白名单
    if not settings.global["isTongBu"].value then
        local prototypes = game.item_prototypes
        for _, force in pairs(game.forces) do
            if force.name ~= "enemy" and force.name ~= "neutral" and force.name ~= nil then
                if global.tongbu_white_list[force.name] ~= nil then
                    for _, item in pairs(global.tongbu_white_list[force.name]) do
                        if game.item_prototypes[item.name] ~= nil and item.update_tick < game.tick then
                            local name = item.name
                            local force_name = force.name
                            local id = global.name2id[force_name][name]
                            if id then
                                global.glk[force_name].link_id = id
                                local count = global.glk[force_name].get_item_count(name)
                                local num = settings.global["row_num"].value*10*prototypes[name].stack_size
                                if count <  num then
                                    if global.force_item[force_name][name] ~= nil then
                                        local count2 = math.floor(global.force_item[force_name][name].count)
                                        if count2 > 0 then
                                            local num2 = count2
                                            num = settings.startup["linkSize"].value*prototypes[name].stack_size - num - count
                                            if count2 > num then count2 = num end
                                            if count2 > 0 then
                                                count = global.glk[force_name].insert({name = name,count = count2})
                                                global.force_item[force_name][name].count = num2 - count
                                            end
                                        end
                                    else
                                        global.force_item[force_name][name] = {count = 0}
                                    end
                                elseif count > settings.startup["linkSize"].value*prototypes[name].stack_size - num then
                                    local num2 = global.glk[force_name].remove_item({name = name,count = count})
                                    num = global.glk[force_name].insert({name = name,count = num})
                                    if global.force_item[force_name][name] == nil then global.force_item[force_name][name] = {count = 0} end
                                    add_force_item(force_name,name,num2-num)
                                end
                            end
                            item.update_tick = game.tick + 10 + math.random()*5
                        end
                    end
                end
            end
        end
    end
end

-- 游戏设置更改
local function runtime_mod_setting_changed(event)
    for _, f in pairs(game.forces) do
        if f.name ~= "enemy" and f.name ~= "neutral" and f.name ~= nil then
            if f.technologies['virtual'].enabled ~= settings.global["virtual-lock"].value then
                if settings.global["virtual-lock"].value then
                    f.print("[technology=virtual]需要研究解锁")
                else
                    f.print("[technology=virtual]不需要研究解锁")
                end
                f.technologies['virtual'].enabled = settings.global["virtual-lock"].value
            end
        end
    end
end

-- 点击gui
--- @param event on_gui_click
local function gui_click(event)
    local ename = event.element.name
    local etype = event.element.type

    
    local player = game.players[event.player_index]

    -- 点击配方图标打印配方信息
    if ename == "fnei\trecipe\tselected-recipe" and etype == "choose-elem-button" then
        local recipe_name = event.element.elem_value
        local des = get_recipe_info(player, recipe_name)
        player.print("[technology=virtual]"..des)
    end


    local name = string.match(ename, "fnei\trecipe\t(.*)-label")
    if not name then
        return
    end
    local format_name = ""
    if game.item_prototypes[name] ~= nil then
        format_name = "[item="..name.."]"
    elseif game.fluid_prototypes[name] ~= nil then
        format_name = "[fluid="..name.."]"
    end
    if format_name == "" then
        return
    end

    -- 如果按下shift
    if event.shift then
        local elementp6 = event.element.parent.parent.parent.parent.parent.parent
        -- 如果没有，向elementp6下方添加一个文本编辑框，插入format_name

        -- 检查 elementp6 是否存在
        if elementp6 then
            -- 检查 elementp6 下方是否已经有文本编辑框
            local textfield_exists = false
            local textfield_child = nil
            for _, child in pairs(elementp6.children) do
                if child.type == "textfield" then
                    textfield_child = child
                    textfield_exists = true
                    break
                end
            end

            -- 如果没有文本编辑框，则添加一个新的文本编辑框，并插入 format_name
            if not textfield_exists then
                textfield_child = elementp6.add{type = "textfield", name = "format_name_textfield", text = format_name}
                -- 设为和父节点等宽
                textfield_child.style.minimal_width = 510
            else
                -- 如果已经有文本编辑框，并且不存在format_name，则插入format_name
                if not string.find(textfield_child.text, format_name,1, true) then
                    textfield_child.text = textfield_child.text..format_name
                end
            end
            -- 焦点设为文本编辑框
            textfield_child.focus()
            -- 光标移动到行首
            textfield_child.select(1, 0)
        end
        return
    end

    show_inventory_info(player, format_name, name)
end

-- 文本编辑框确认
local function gui_confirmed(event)
    if event.element.name == "format_name_textfield" then
        local event2 = {message=event.element.text, player_index=event.player_index}
        set_virtual_limit(event2)
    end
end
Event.addListener(defines.events.on_game_created_from_scenario,runtime_mod_setting_changed)
Event.addListener(defines.events.on_runtime_mod_setting_changed, runtime_mod_setting_changed)
Event.addListener(defines.events.on_player_selected_area, player_selected_area)     -- 玩家选择区域(虚拟化)
Event.addListener(defines.events.on_player_alt_selected_area, player_alt_selected_area)    -- 玩家反选区域(取消虚拟化)
Event.addListener(defines.events.on_built_entity,add_accumulator)    -- 玩家建造物品
Event.addListener(defines.events.on_robot_built_entity,add_accumulator)  -- 机器人建造物品
Event.addListener(defines.events.on_console_chat, set_virtual_limit) -- 设置虚拟制造限制
Event.addListener(defines.events.on_tick, tick)
Event.addListener(defines.events.on_gui_click, gui_click)
-- 注册textfield确认事件
Event.addListener(defines.events.on_gui_confirmed, gui_confirmed)