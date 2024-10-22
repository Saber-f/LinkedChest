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
    global.players_Linked = {}          -- 玩家的关联箱筛选
    global.name2id = {}                 -- 团队的name->id
    global.linkboxs = {}                -- 所有的关联箱
    global.checkIndex = 1               -- 检查索引

    -- Force初始化
    for _, f in pairs(game.forces) do
        if f.name ~= "enemy" and f.name ~= "neutral" and f.name ~= nil then
            global.name2id[f.name] = {}          -- 初始化团队的name->id
        end
    end

    refreshBluePrint()
end


-- 增删mod时更新name2id
function up_name2id()
    if global.players_Linked == nil then
        init_link()
        return;
    end

    local t = {};

    for _, item in pairs(prototypes.item) do
        t[item.name] = 1
    end

    for _, item in pairs(prototypes.fluid) do
        t[item.name] = 1
    end

    for _, f in pairs(game.forces) do
        if f.name ~= "enemy" and f.name ~= "neutral" and f.name ~= nil then
            if global.name2id[f.name] ~= nil then
                for name,id in pairs(global.name2id[f.name]) do
                    -- 如果物品列表中没有
                    if t[name] == nil then
                        global.name2id[f.name][name] = nil
                        game.print(f.name.."团队的"..name.."已移除")
                    end
                end
            end
        end
    end
end

-- 团队创立
function on_force_creat(event)
    local force_name = event.force.name

    if global.name2id[force_name] == nil then global.name2id[force_name] = {} end            -- 初始化团队的name->id
    
    global.name2id[force_name] = {}          -- 初始化团队的name->id
end


-- 玩家加入游戏
function on_player_join(event)
    local player = game.players[event.player_index]
    local force = player.force.name
    local name = player.name

    if global.players_Linked == nil then 
        init_link()
    end
    global.players_Linked[name] = {}

    local item_count = 0
    for name, item in pairs(prototypes.item) do
        item_count = item_count + 1
    end
    global.ITEM_COUNT = item_count    -- 初始化物品总数量
    player.print("物品总数:"..item_count.."流体总数:"..(#prototypes.fluid).."配方总数:"..(#prototypes.recipe))

    if global.CURR_INDEX == nil then global.CURR_INDEX = 0 end

    if global.NAME_TALBE == nil then
        global.NAME_TALBE = {} 
        local index = 0
        for name, item in pairs(prototypes.item) do
            global.NAME_TALBE[index] = name
            index = index + 1
        end
    end
end


function name2id(force,name,surface)
    local id = 0
    if global.name2id == nil then
        global.name2id = {}
    end
    if global.name2id[force] == nil then
        global.name2id[force] = {}
    end
    if global.name2id[force][name] == nil then
        local n = 0
        for i=1,#name do
            n = string.byte(string.sub(name,i,i))
            id = id * n
            id = id + n
            id = id%2^26
        end
        global.name2id[force][name] = id
    else
        id = global.name2id[force][name]
    end
    id = id * 2^6 + surface.index
    return id
end



--*通知消息
function Message_output_onallplayer(text,py)
	for _, player in pairs(game.connected_players) do
        if player.force.name == py.force.name then
		    player.surface.create_entity({name = 'flying-text', position = player.position, text = text , color = {255, 0, 0}})
        end
	end
end

--势力物品创建空按钮
function add_empty_button(count,this_table)
	for s = 1,count,1 do
		local b = this_table.add {
			type = 'sprite-button',	
		}
		b.style = 'inventory_slot'
		b = nil
	end
end

--势力物品创建带有图标按钮
function add_item_button(player,frames,item_name,num)
	if frames == nil then return end
    local type = "item"
    local bt =
        frames.add {
        type = 'sprite-button',
        sprite = type..'/' .. item_name,
        number = num,
        name = 'force_item_' .. item_name,
        tooltip = prototypes[type][item_name].localised_name,
        column_count = 2
    }
    bt.enabled = true
    bt.focus()
    bt.style = 'inventory_slot'
end

function tk(tab,value)
    for k,v in pairs(tab) do
        if k == value then
            return true
        end
    end
    return false
end




--GUI筛选按钮 变动时事件
function on_gui_elem_changed(event)
	local gui_name_item = 'set-item-LinkedPassword-'
	local element = event.element
    if (not element) or (not element.valid) then
        return
    end
    local elem_value = element.elem_value
	-- local parent = element.parent
	local player = game.players[event.player_index]
    local force = player.force
	if string.sub(element.name, 0, #gui_name_item) == gui_name_item then
		local number = 0
		for key, item in pairs(prototypes.item) do
			if item.name == elem_value then
                local linkbox = global.players_Linked[player.name].Linked
                number = name2id(force.name,item.name, linkbox.surface)
				linkbox.link_id = number
                force.print({"",player.name.."手动设置关联ID:"..number.."->",{item.localised_name[1]}},{r = 0, g = 0.75, b = 0.0})
                return
            end
		end
    end
end


-- 设置关联箱筛选
local function set_link_show(player, frame, gui_name, entity)
    local number = 0
    local link_id = 0
    local linkbox = global.players_Linked[player.name].Linked
    link_id = linkbox.link_id

    frame.add{type="label", caption="设置关联箱筛选",tooltip = "设置关联箱指定物品"}
    local field = frame.add{type = "choose-elem-button",name = 'set-item-' .. gui_name .. entity.unit_number, direction = "horizontal", style = "confirm_button", elem_type = 'item',  tooltip = "设置关联箱指定存放物品"}
    
    for key, item in pairs(prototypes.item) do
        number = name2id(player.force.name,item.name, linkbox.surface)
        if number == link_id then
            field.elem_value = item.name
            break
        end
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
            if global.players_Linked == nil then
                global.players_Linked = {}
            end
            if global.players_Linked[player.name] == nil then
                global.players_Linked[player.name] = {}
            end
            global.players_Linked[player.name].Linked = entity
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
            global.players_Linked[player.name].Linked = entity
            frame.clear()
        end

        if gui_type == "linked-container" then
            set_link_show(player, frame, gui_name, entity)
        end
    end
end
--打开GUI界面on_gui_opened


-- 同步数据
function tongbu(event)
    -- 狗爪
    if global.tick_tasks then
        for _, tick_task in pairs(global.tick_tasks) do
        if tick_task.type == "grappling-gun" then
            Grapple.tick_task_grappling_gun(tick_task)
        else
            tick_task.valid = false
        end
        if not tick_task.valid then
            global.tick_tasks[tick_task.id] = nil
        end
        end
    end

    -- 检查关
    local is_circulate = false;
    if global.linkboxs == nil then
        global.linkboxs = {}
    end

    if global.checkIndex == nil then
        global.checkIndex = 1
    end

    for i = 1, settings.global["checkCount"].value, 1 do
        if global.checkIndex > #global.linkboxs then
            global.checkIndex = 1
            if is_circulate then
                break
            end
            is_circulate = true
        end

        local entity = global.linkboxs[global.checkIndex]

        if entity and entity.valid then
            local link_id = entity.link_id
            if entity.surface.index ~= link_id % 2^6 then
                local errorindex = link_id % 2^6;
                entity.link_id = link_id - link_id % 2^6 + entity.surface.index
                entity.force.print("警告！非法关联箱图层修改:"..entity.surface.index.."->"..errorindex.."(已修复)最后操作者:"..entity.last_user.name,{r=1,g=0,b=0})
            end
            global.checkIndex = global.checkIndex + 1
        else
            table.remove(global.linkboxs, global.checkIndex)
        end
    end
end


function set_link(event)
    local entity = event.entity
    if entity and entity.valid and (entity.name == "Oem-linked-chest") then
        if entity.link_id == 0 then
            auto_set_link(entity)
        end
        local link_id = entity.link_id - entity.link_id % 2^6 + entity.surface.index
        entity.link_id = link_id
        table.insert(global.linkboxs, entity)   -- 添加到关联箱列表
    end
end




----------------------------------------------------------------------------------------------------------


--------------------------------------------- 自动变动linkid ---------------------------------------------
-- 当手动放置联接箱时，检测周围3格内的爪子
-- ->找到抓取位置为联接箱位置的爪子
-- ->当爪子放置目标是CraftingMachine时
-- ->读取机器配方的原料表和机器大小+2范围内的抓取放置目标为机器、抓取目标为联接箱的爪子
-- ->读取爪子抓取的链接箱链接的物品并从原料表中减去
-- ->从剩下的原料表中选择第一个name2id，设置为联接箱的linkid
-- 若链接箱是放置目标则反过

function set_linkid(linked_chest,pickup_or_drop)-- pickup_or_drop:"pickup"从联接箱到机器，"drop"从机器到联接箱
	local inserts = get_valid_inserts_machines(linked_chest,pickup_or_drop)
	if #inserts > 0 then
        local surface = linked_chest.surface
		for _,insert in pairs(inserts) do
			filter = insert.inserter_filter_mode
			if filter.type == "whitelist" and #filter.filter_item ~= 0 then-- 如果有连接着机器的筛选机械臂且设置了白名单，linkchest链接的物品设置为白名单的第一个有效值
				linked_chest.link_id = name2id(linked_chest.force.name, prototypes.item[filter.filter_item[1]].name, surface)
				return nil


			elseif filter.type == "whitelist" and #filter.filter_item == 0 then-- 如果有连接着机器的筛选机械臂且未设置了白名单，白名单的第一个槽位设置为linkchest链接的物品
				inserts = {insert}-- 优先筛选机械臂
				local machine = insert.machine
				local parts = {}
				parts = get_short_parts(machine,pickup_or_drop, surface)
				if #parts ~= 0 then
					linked_chest.link_id = name2id(linked_chest.force.name, prototypes.item[parts[1].name].name, surface)
					insert["entity"].set_filter(1,prototypes.item[parts[1].name].name)
					return nil
				end


			elseif filter.type == "blacklist" and #filter.filter_item ~= 0 then-- 如果有连接着机器的筛选机械臂且设置了黑名单，黑名单的第一个槽位设置为缺少的物品减黑名单的物品
				inserts = {insert}-- 优先筛选机械臂
				local machine = insert.machine
				local parts = {}
				parts = get_short_parts(machine,pickup_or_drop, surface)
				parts = table.remove_by_values( parts,filter.filter_item)
				if #parts ~= 0 then
					linked_chest.link_id = name2id(linked_chest.force.name, prototypes.item[parts[1].name].name, surface)
					return nil
				end
			end
		end

		local machine = inserts[1].machine
		local parts = {}
		parts = get_short_parts(machine,pickup_or_drop, surface)
		if #parts ~= 0 then
			linked_chest.link_id = name2id(linked_chest.force.name, prototypes.item[parts[1].name].name, surface)
			return nil
		end
	end
	return 1
end

function auto_set_link(entity)
	if set_linkid(entity,"drop") then
		set_linkid(entity,"pickup")
	end
end



function get_valid_inserts_machines(entity,pickup_or_drop)
	local distance = 3
	local pos = entity.position
	local surface = entity.surface
	local search_area = {{pos.x - distance, pos.y - distance}, {pos.x + distance, pos.y + distance}}
	local Inserters = surface.find_entities_filtered {
		area = search_area,
		type = "inserter"
	}
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
			inserter = {["entity"]=Inserter,["inserter_filter_mode"] = {["type"] = nil,["filter_item"] = {}},["machine"] = machine_target}
			if Inserter.inserter_filter_mode == "whitelist" then
				inserter.inserter_filter_mode.type = "whitelist"
				for i=1,Inserter.filter_slot_count ,1 do
					table.insert(inserter.inserter_filter_mode.filter_item,Inserter.get_filter(i))
				end
			elseif Inserter.inserter_filter_mode == "blacklist" then
				inserter.inserter_filter_mode.type = "blacklist"
				for i=1,Inserter.filter_slot_count ,1 do
					table.insert(inserter.inserter_filter_mode.filter_item,Inserter.get_filter(i))
				end
			elseif Inserter.inserter_filter_mode == nil then
				inserter.inserter_filter_mode.type = "nil"
			end
			table.insert(inserts,inserter)
		end
	end
	return inserts
end



function get_short_parts(machine,pickup_or_drop, surface)
	local distance = 2
	local surface = machine.surface
	local box = machine.bounding_box
	local search_area = {{box.left_top.x - distance, box.left_top.y - distance}, {box.right_bottom.x + distance, box.right_bottom.y + distance}}-- left_top点在box的左下角
	local Inserters = surface.find_entities_filtered {area = search_area,type = "inserter"}
	local parts = {}
	local target_parts = nil

	if pickup_or_drop == "pickup" then
		target_parts = machine.get_recipe().ingredients
	elseif pickup_or_drop == "drop" then
		target_parts = machine.get_recipe().products
	end
	for _, part in pairs(target_parts) do
		if part.type ~= "fluid" then
			table.insert( parts,part)
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

		if pickup_target and drop_target then
		end
		if (machine_target and machine_target == machine and chest_target and chest_target.name == "Oem-linked-chest") then
			
			local link_id = chest_target.link_id
			for key, item in pairs(parts) do
				local number = name2id(machine.force.name, prototypes.item[item.name].name, surface)
				if number == link_id then
					table.remove(parts,key)
					break
				end
			end
		end
	end
	return parts
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
global.next_tick_task_id = global.next_tick_task_id or 1
local new_tick_task = {
    id = global.next_tick_task_id,
    valid = true,
    type = type,
    tick = game.tick
}
global.tick_tasks = global.tick_tasks or {}
global.tick_tasks[new_tick_task.id] = new_tick_task
global.next_tick_task_id = global.next_tick_task_id + 1
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
            if global.tick_tasks then
                for _, tick_task in pairs(global.tick_tasks) do
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
script.on_configuration_changed(up_name2id)
Event.addListener(defines.events.on_game_created_from_scenario,init_link)
Event.addListener(defines.events.on_force_created,on_force_creat)
Event.addListener(defines.events.on_player_joined_game,on_player_join)

Event.addListener(defines.events.on_built_entity,set_link)    -- 玩家建造物品
Event.addListener(defines.events.on_robot_built_entity,set_link)  -- 机器人建造物品
Event.addListener(defines.events.on_gui_elem_changed, on_gui_elem_changed)
Event.addListener(defines.events.on_gui_opened, on_gui_opened)
Event.addListener(defines.events.on_tick, tongbu)


Event.addListener(defines.events.on_runtime_mod_setting_changed , refreshBluePrint)
