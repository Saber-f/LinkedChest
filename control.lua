-- 创建功能函数
Util = require("scripts/util") util = Util
local Event = require('scripts/event')
local Grapple = require('scripts/grapple')
if global == nil then
    global = {}
end

-- 初始化团队的常驻关联箱
local mod_gui = require('__core__/lualib/mod-gui')


function myinitteam(force)
end


-- 刷新蓝图权限
local function refreshBluePrint()
    local canBluePrint = settings.global["canBluePrint"].value
    game.permissions.get_group("Default").set_allows_action(defines.input_action.grab_blueprint_record, canBluePrint)
	game.permissions.get_group("Default").set_allows_action(defines.input_action.import_blueprint_string, canBluePrint)
	game.permissions.get_group("Default").set_allows_action(defines.input_action.import_blueprint, canBluePrint)
    game.permissions.get_group('Default').set_allows_action(defines.input_action.open_blueprint_library_gui, canBluePrint)
    game.permissions.get_group('Default').set_allows_action(defines.input_action.import_blueprint_string, canBluePrint)
    game.permissions.get_group('Default').set_allows_action(defines.input_action.activate_paste, canBluePrint)
end

-- 游戏初始化
function init_link()
    storage.players_Linked = {}          -- 玩家的关联箱筛选
    storage.name2id = {}                 -- name->id, id->{type, name, quality}
    storage.linkboxs = {}                -- 所有的关联箱
    storage.checkIndex = 1               -- 检查索引
    refreshBluePrint()
end

-- 玩家加入游戏
function on_player_join(event)
    local player = game.players[event.player_index]
    local name = player.name

    if storage.players_Linked == nil then 
        init_link()
    end
    storage.players_Linked[name] = {}
end

local function name2id(type,name,quality,surface)
    local type_str = type or ""
    local quality_str = quality or ""
    local id = 0
    if storage.name2id == nil then
        storage.name2id = {}
    end

    -- 兼容旧设置
    if quality_str == "normal" then
        quality_str = ""
    end

    local full_name = type_str .. name  .. quality_str
    if storage.name2id[full_name] == nil then
        local n = 0
        for i=1,#full_name do
            n = string.byte(string.sub(full_name,i,i))
            id = id * n
            id = id + n
            id = id%2^26
        end
        storage.name2id[full_name] = id
        storage.name2id[id] = {type = type, name = name, quality = quality}
    else
        id = storage.name2id[full_name]
    end
    local index = 1
    if settings.global["checkCount"].value > 0 then
        index = surface.index
    end
    id = id * 2^6 + index
    return id
end

--GUI筛选按钮 变动时事件
local function on_gui_elem_changed(event)
	local gui_name_item = 'set-item-LinkedPassword-'
	local element = event.element
    if (not element) or (not element.valid) then
        return
    end
    local elem_value = element.elem_value
    
	if not string.sub(element.name, 0, #gui_name_item) == gui_name_item then
        return
    end

	local player = game.players[event.player_index]

    if storage.players_Linked == nil or storage.players_Linked[player.name] == nil or elem_value == nil then
        return
    end
    local linkbox = storage.players_Linked[player.name].Linked
    local number = name2id(elem_value.type,elem_value.name, elem_value.quality, linkbox.surface)
    linkbox.link_id = number
end


-- 设置关联箱筛选
local function set_link_show(player, frame, gui_name, entity)
    local link_id = 0
    local linkbox = storage.players_Linked[player.name].Linked
    link_id = linkbox.link_id

    frame.add{type="label", caption="设置关联箱筛选",tooltip = "设置关联箱指定物品"}
    local field = frame.add{type = "choose-elem-button",name = 'set-item-' .. gui_name .. entity.unit_number, direction = "horizontal", style = "confirm_button", elem_type = 'signal',  tooltip = "设置关联箱指定存放物品"}
    local surface = linkbox.surface
    local index = 1
    if settings.global["checkCount"].value > 0 then
        index = surface.index
    end
    link_id = (link_id-index) / 2^6 -- 还原
    
    if (storage.name2id) then
        field.elem_value = storage.name2id[link_id]
    end
end


--打开GUI界面on_gui_opened
function on_gui_opened(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then
		return
	end

    
    --关联箱GUI界面
    if event.gui_type == defines.gui_type.entity then
        local entity = event.entity
        local gui_type = ""
        local name = ""
        local anchor = {}
        if entity.type == 'linked-container' then
            name = "set-linked-container-password"
            gui_type = "linked-container"
            if storage.players_Linked == nil then
                storage.players_Linked = {}
            end
            if storage.players_Linked[player.name] == nil then
                storage.players_Linked[player.name] = {}
            end
            storage.players_Linked[player.name].Linked = entity
            anchor = {gui = defines.relative_gui_type.linked_container_gui, position = defines.relative_gui_position.top}
        else
            return
        end

        local gui_name = 'LinkedPassword-'
        local panel = player.gui.relative


        local frame = panel[name]
        if not frame then
            frame = panel.add {
                type = 'frame',
                name = name,
                style = mod_gui.frame_style,
                direction = 'horizontal',
                --caption = '设置关联箱密码',
                anchor = anchor,
            }
        else
            storage.players_Linked[player.name].Linked = entity
            frame.clear()
        end

        if gui_type == "linked-container" then
            set_link_show(player, frame, gui_name, entity)
        end
    end
end
--打开GUI界面on_gui_opened

-- 检查跨图层关联
local function check_linkbox(checkCount)
    local is_circulate = false;
    if storage.linkboxs == nil then
        storage.linkboxs = {}
    end

    if storage.checkIndex == nil then
        storage.checkIndex = 1
    end

    for i = 1, checkCount, 1 do
        if storage.checkIndex > #storage.linkboxs then
            storage.checkIndex = 1
            if is_circulate then
                break
            end
            is_circulate = true
        end

        local entity = storage.linkboxs[storage.checkIndex]

        if entity and entity.valid then
            local link_id = entity.link_id
            if entity.surface.index ~= link_id % 2^6 then
                local errorindex = link_id % 2^6;
                entity.link_id = link_id - link_id % 2^6 + entity.surface.index
                entity.force.print("警告！非法关联箱图层修改:"..entity.surface.index.."->"..errorindex.."(已修复)最后操作者:"..entity.last_user.name,{r=1,g=0,b=0})
            end
            storage.checkIndex = storage.checkIndex + 1
        else
            table.remove(storage.linkboxs, storage.checkIndex)
        end
    end
end


-- 同步数据
function tongbu(event)
    -- 狗爪
    if not settings.startup["disableGrapplingHook"].value and storage.tick_tasks then
        for _, tick_task in pairs(storage.tick_tasks) do
        if tick_task.type == "grappling-gun" then
            Grapple.tick_task_grappling_gun(tick_task)
        else
            tick_task.valid = false
        end
        if not tick_task.valid then
            storage.tick_tasks[tick_task.id] = nil
        end
        end
    end

    -- 检查跨图层关联
    local checkCount = settings.global["checkCount"].value
    if checkCount > 0 then
        check_linkbox(checkCount)
    end


    -- 检查爪子白名单
    if storage.set_linkid_by_inserts then
        local new_set_linkid_by_inserts = {}
        for key, info in pairs(storage.set_linkid_by_inserts) do
            if info.time < game.tick then
                set_linkid_by_inserts(info.entity)
            else
                table.insert(new_set_linkid_by_inserts, info)
            end
        end
        storage.set_linkid_by_inserts = new_set_linkid_by_inserts
    end
end



local function set_link(event)
    local entity = event.entity
    if entity and entity.valid and (entity.name == "Oem-linked-chest") then
        if entity.link_id == 0 then
            auto_set_link(entity)
        end
        if (settings.global["checkCount"].value > 0) then
            local link_id = entity.link_id - entity.link_id % 2^6 + entity.surface.index
            entity.link_id = link_id
        end
        local checkCount = settings.global["checkCount"].value
        if checkCount > 0 then
            if storage.linkboxs == nil then
                storage.linkboxs = {}
            end
            table.insert(storage.linkboxs, entity)   -- 添加到关联箱列表
        else
            storage.linkboxs = {}
        end
    end
end




----------------------------------------------------------------------------------------------------------


--------------------------------------------- 自动变动linkid ---------------------------------------------
-- 获取附近的爪子
local function get_near_inserts(entity)
    local distance = 3
    local pos = entity.position
    local surface = entity.surface
    local search_area = {{pos.x - distance, pos.y - distance}, {pos.x + distance, pos.y + distance}}
    local Inserters = surface.find_entities_filtered {area = search_area,type = "inserter"}
    return Inserters
end


-- 获取有效的爪子
local function get_valid_inserts_machines(entity,pickup_or_drop)
    local Inserters = get_near_inserts(entity)
    local pos = entity.position
	local inserts = {}
	for _, Inserter in pairs(Inserters) do
		
		local pickup_pos = Inserter.pickup_position
		local drop_pos = Inserter.drop_position
		local pickup_target = Inserter.pickup_target
		local drop_target = Inserter.drop_target
		local machine_target = nil
		if(pickup_or_drop == "pickup") then
			if (pickup_pos.x == pos.x and pickup_pos.y == pos.y and drop_target and drop_target.prototype.get_crafting_speed()) then
				machine_target = drop_target
			end
		elseif pickup_or_drop == "drop" then
			if ((pos.x-0.5 <= drop_pos.x and drop_pos.x <= pos.x+0.5) and (pos.y-0.5 <= drop_pos.y and drop_pos.y <= pos.y+0.5) and pickup_target and pickup_target.prototype.get_crafting_speed()) then
				machine_target = pickup_target
			end
		end

		if(machine_target and machine_target.get_recipe()) then
			local inserter = {["entity"]=Inserter,["machine"] = machine_target}
			table.insert(inserts,inserter)
		end
	end
	return inserts
end

-- 获取剩余原料或者产品
local function get_short_parts(machine,pickup_or_drop)
	local distance = 2
	local surface = machine.surface
	local box = machine.bounding_box
	local search_area = {{box.left_top.x - distance, box.left_top.y - distance}, {box.right_bottom.x + distance, box.right_bottom.y + distance}}-- left_top点在box的左下角
	local Inserters = surface.find_entities_filtered {area = search_area,type = "inserter"}
	local parts = {}

    local recipe, quality_prototype = machine.get_recipe()
	if pickup_or_drop == "pickup" then
        for _, part in pairs(recipe.ingredients) do
            if part.type ~= "fluid" then
                table.insert(parts, {name = part.name, quality = quality_prototype.name})
            end
        end
	elseif pickup_or_drop == "drop" then
        for _, part in pairs(recipe.products) do
            if part.type ~= "fluid" then
                table.insert(parts, {name = part.name, quality = quality_prototype.name})
            end
        end
	end

    -- 根据周围的爪子移除parts里的元素
	for _,Inserter in pairs(Inserters) do
		local pickup_target = Inserter.pickup_target
		local drop_target = Inserter.drop_target
		local machine_target = nil
		local chest_target = nil

		if pickup_or_drop == "pickup" then
			machine_target = drop_target
			chest_target = pickup_target
		elseif pickup_or_drop == "drop" then
			machine_target = pickup_target
			chest_target = drop_target
		end

		if (machine_target and machine_target == machine and chest_target and chest_target.name == "Oem-linked-chest") then
			local link_id = chest_target.link_id
			for key, item in pairs(parts) do
				local number = name2id(nil, item.name, item.quality, surface)
				if number == link_id then
					table.remove(parts,key)
					break
				end
			end
		end
	end
	return parts
end

-- 根据配方自动设置关联箱linkeid
local function set_linkid(linked_chest,pickup_or_drop)-- pickup_or_drop:"pickup"从联接箱到机器，"drop"从机器到联接箱
	local inserts = get_valid_inserts_machines(linked_chest,pickup_or_drop)
	if #inserts > 0 then
        local surface = linked_chest.surface
		for _,insert in pairs(inserts) do
            insert.entity.inserter_filter_mode = "whitelist"
            insert.entity.use_filters = true
            local machine = insert.machine
            local parts = get_short_parts(machine,pickup_or_drop)
            if #parts ~= 0 then
                linked_chest.link_id = name2id(nil, parts[1].name, parts[1].quality, surface)
                insert.entity.set_filter(1, {name = parts[1].name, quality = parts[1].quality})
            else
                insert.entity.use_filters = false
            end
		end
	end
	return 1
end

-- 根据爪子白名单设置关联箱linkid
function set_linkid_by_inserts(linked_chest)
    game.print("set_linkid_by_inserts")
    local Inserters = get_near_inserts(linked_chest)
    local drop_target = nil
    local pickup_target = nil
    game.print("Inserters:"..#Inserters)
    for _, inserter in pairs(Inserters) do
        if inserter.inserter_filter_mode == "whitelist"  and inserter.use_filters and inserter.get_filter(1) then
            game.print("inserter.drop_target")
            game.print(inserter.drop_target)
            game.print("inserter.pickup_target")
            game.print(inserter.pickup_target)
            if inserter.drop_target == linked_chest then
                game.print("drop_target")
                drop_target = inserter
            end
            if inserter.pickup_target == linked_chest then
                game.print("pickup_target")
                pickup_target = inserter
            end
        end
    end

    local surface = linked_chest.surface
    if drop_target then  -- 如果向关联箱放东西
        linked_chest.link_id = name2id(nil, drop_target.get_filter(1).name, drop_target.get_filter(1).quality, surface)
        return nil
    end

    if pickup_target then  -- 如果从关联箱取东西
        linked_chest.link_id = name2id(nil, pickup_target.get_filter(1).name, pickup_target.get_filter(1).quality, surface)
        return nil
    end

    return 1
end


-- 自动设置关联箱linkid
function auto_set_link(entity)
	if not set_linkid(entity,"drop") then return end
	if not set_linkid(entity,"pickup") then return end

    -- 根据爪子白名单设置关联箱linkid
    if storage.set_linkid_by_inserts == nil then
        storage.set_linkid_by_inserts = {}
    end
    table.insert(storage.set_linkid_by_inserts, {entity = entity, time = game.tick})
end

function table.remove_by_values(t, values)
	newt = {}
	for tkey, tvalue in pairs(t) do
		local same = nil
		for key, value in pairs(values) do
			if tvalue.name == value then
				same = 1
			end
		end
		if not same then
			table.insert(newt,tvalue)
		end
	end
	return newt
end

--------------------------------------------------------------------------------------------------------------



--------------------------------------------- 自动补充物流需求区 ---------------------------------------------

function try_insert(inventory, item_name,item_count)
	if inventory.can_insert({name=item_name, count=item_count}) then
		inventory.insert({name=item_name, count=item_count})
		return 0
	end
	return nil
end

----------------------------------------------------狗爪-----------------------------------------------------------

function new_tick_task(type)
storage.next_tick_task_id = storage.next_tick_task_id or 1
local new_tick_task = {
    id = storage.next_tick_task_id,
    valid = true,
    type = type,
    tick = game.tick
}
storage.tick_tasks = storage.tick_tasks or {}
storage.tick_tasks[new_tick_task.id] = new_tick_task
storage.next_tick_task_id = storage.next_tick_task_id + 1
return new_tick_task
end


remote.add_interface(
"grappling-gun",
{
    on_character_swapped = function(data)
        --[[{
            new_unit_number = new.unit_number,
            old_unit_number = old.unit_number,
            new_character = new,
            old_character = old
            }]]
        if data.new_character and data.new_character.valid and data.old_character and data.old_character.valid then
            if storage.tick_tasks then
                for _, tick_task in pairs(storage.tick_tasks) do
                    if tick_task.type == "grappling-gun" then
                        if tick_task.character and tick_task.character.valid and tick_task.character == data.old_character then
                            tick_task.character = data.new_character
                        end
                    end
                end
            end
        end
    end,
}
)
---------------------------------------------------------------------------------------------------------------


-- 注册事件
script.on_init(init_link)
Event.addListener(defines.events.on_game_created_from_scenario,init_link)
Event.addListener(defines.events.on_player_joined_game,on_player_join)

Event.addListener(defines.events.on_space_platform_built_entity,set_link)    -- 太空平台建造物品
Event.addListener(defines.events.on_built_entity,set_link)    -- 玩家建造物品
Event.addListener(defines.events.on_robot_built_entity,set_link)    -- 机器人建造物品
Event.addListener(defines.events.on_gui_elem_changed, on_gui_elem_changed)
Event.addListener(defines.events.on_gui_opened, on_gui_opened)
Event.addListener(defines.events.on_tick, tongbu)


Event.addListener(defines.events.on_runtime_mod_setting_changed , refreshBluePrint)
