-- 创建功能函数
Util = require("scripts/util") util = Util
Event = require('scripts/event')
Grapple = require('scripts/grapple')
require('scripts/virtual')

-- 初始化团队的常驻关联箱
local mod_gui = require('__core__/lualib/mod-gui')
local translations = {}
local AddID = {}

function mycreatelinkbox(force)
    local surface
    if game.surfaces.linkroom then
        surface = game.surfaces.linkroom
    else
        local map_gen_settings = {
            ['width'] = 5096,
            ['height'] = 16,
            ['water'] = 0,
            ['starting_area'] = 1,
            ['cliff_settings'] = {cliff_elevation_interval = 0, cliff_elevation_0 = 0},
            ['default_enable_all_autoplace_controls'] = true,
            ['autoplace_settings'] = {
                ['entity'] = {treat_missing_as_default = false},
                ['tile'] = {treat_missing_as_default = true},
                ['decorative'] = {treat_missing_as_default = false}
            }
        }
        surface = game.create_surface("linkroom", map_gen_settings)
    end
    global.glk[force] = surface.create_entity{name = 'Oem-linked-chest', position = {global.glkn,0}, force = force}
    global.glk[force].destructible = false
    global.glk[force].minable = false

end


function myinitteam(force)
    global.force_item[force] = {}       -- 初始化团队物资
    mycreatelinkbox(force)              -- 初始化团队的常驻关联箱

    global.name2id[force] = {}          -- 初始化团队的name->id
    global.TC[force] = {}               -- 初始化团队常量预算器
    global.Ti[force] = 0               -- 初始化团队的常量计算器id
    global.randomId[force] = {}               -- 随机linkiId

    global.virtual[force] = {}          -- 初始化团队的虚拟物品
end


-- 游戏初始化
function init_link()
    global.players_Linked = {}          -- 玩家的关联箱筛选
    global.force_item = {}              -- 团队库存
    global.player_item_group = {}       -- 玩家共享物品的位置
    global.name2id = {}                 -- 团队的name->id
    global.TC = {}                      -- 团队常量预算器
    global.Ti = {}                      -- 团队的常量计算器id
    global.glk = {}                     -- 团队的常驻关联箱
    global.glkn = 0                     -- 团队的常驻关联箱位置
	global.translation = {}
    global.randomId = {}                -- 随机linkiId
    global.virtual = {}                 -- 团队的虚拟物品

    -- Force初始化
    for _, f in pairs(game.forces) do
        myinitteam(f.name)
        global.glkn = global.glkn + 1
    end     
end


-- 增删mod时更新name2id
function up_name2id()
    if global.players_Linked == nil then global.players_Linked = {} end

    local t = {};

    for _, item in pairs(game.item_prototypes) do
        t[item.name] = 1
    end

    for _, f in pairs(game.forces) do
        if global.name2id[f.name] ~= nil then
            for name,id in pairs(global.name2id[f.name]) do
                -- 如果武平列表中没有
                if t[name] == nil then
                    global.name2id[f.name][name] = nil
                    global.force_item[f.name][name] = nil
                    game.print(f.name.."团队的"..name.."已移除")
                end
            end
        end
    end
end

-- 清除player
function clear_player()
    local force = "player"
    global.force_item[force] = {}       -- 初始化团队物资\
    if global.glk[force] == nil or global.glk[force].valid == false then
        if global.glkn == nil then global.glkn = 1 end
        global.glkn  = global.glkn + 1
        mycreatelinkbox(force)              -- 初始化团队的常驻关联箱
        global.glk[force].destructible = false
        global.glk[force].minable = false
    end

    if global.name2id[force] == nil then global.name2id[force] = {} end            -- 初始化团队的name->id

    for name, id in pairs(global.name2id[force]) do
		global.glk[force].link_id = id
		global.glk[force].clear_items_inside()
	end
    
    -- 清理物品
    global.glk[force].link_id = 0
    global.glk[force].clear_items_inside()
    for id,_ in pairs(global.randomId[force]) do
        global.glk[force].link_id = id
        global.glk[force].clear_items_inside()
    end
    global.randomId[force] = {}               -- 随机linkiId

    global.name2id[force] = {}          -- 初始化团队的name->id
    global.TC[force] = {}               -- 初始化团队常量预算器
    global.Ti[force] = 0               -- 初始化团队的常量计算器id
    global.virtual[force] = {}          -- 初始化团队的虚拟物品

    game.print(force..'团队初始化完成')
end

-- 团队创立
function on_force_creat(event)
    local force = event.force.name
    global.force_item[force] = {}       -- 初始化团队物资
    if global.glk[force] == nil or global.glk[force].valid == false then
        if global.glkn == nil then global.glkn = 1 end
        global.glkn  = global.glkn + 1
        mycreatelinkbox(force)              -- 初始化团队的常驻关联箱
        global.glk[force].destructible = false
        global.glk[force].minable = false
    end

    if global.name2id[force] == nil then global.name2id[force] = {} end            -- 初始化团队的name->id

    for name, id in pairs(global.name2id[force]) do
		global.glk[force].link_id = id
		global.glk[force].clear_items_inside()
	end
    
    global.name2id[force] = {}          -- 初始化团队的name->id
    global.TC[force] = {}               -- 初始化团队常量预算器
    global.Ti[force] = 0               -- 初始化团队的常量计算器id

    game.print(force..'团队初始化完成')
end


-- 玩家加入游戏
function on_player_join(event)
    local player = game.players[event.player_index]
    local force = player.force.name
    local name = player.name

    global.players_Linked[name] = {}
    global.player_item_group[name] = 'logistics'           -- 初始化玩家共享物品的位置


    -- 重新绘制
    if player.gui.relative['force_items_main'] then
        player.gui.relative['force_items_main'].destroy()
    end

    -- 修复大饼团队关联箱子错位
    if global.glk[force] and global.glk[force].force.name ~= force then
        global.glk[force].force = player.force
    end

    -- player.print("温馨提示:\n"..
    -- "1、共享区同队通用，鼠标点击共享区图标，左键拿一个，右键拿一个堆叠，Ctrl+右键拿十个堆叠。\n"..
    -- "2、点击关联箱库存左上角设置筛选，设置相同筛选的关联箱库存同步。\n"..
    -- "3、关联箱的筛选设置可以通过Ctrl+v复制。\n"..
    -- "4、关联箱库存中，设置筛选的物品少于1行,会自动从共享区补充到5行。\n"..
    -- "5、关联箱库存中，设置筛选的物品多于5行,会自动把多余1行的部分存到共享区。\n"..
    -- "6、关联箱设置限容可控制无限缓存，建议副产品和基础材料设置为无限缓存，其他不无限缓存。\n"..
    -- "7、关联箱模组支持自动设置筛选，需要先设置配方，然后放好爪子，最后放关联箱。\n"..
    -- "8、多输出的配方输出用筛选爪子(也会自动设置。\n"..
    -- "9、关联箱库存输出常量运算器可以输出库存数量信号。\n"..
    -- "10、物流请求会自动虫共享区拿东西，需要开关背包刷新。")
    -- 模组物品总数量
    local item_count = 0
    for name, item in pairs(game.item_prototypes) do
        item_count = item_count + 1
    end
    global.ITEM_COUNT = item_count    -- 初始化物品总数量
    player.print("物品总数量:"..item_count)

    if global.CURR_INDEX == nil then global.CURR_INDEX = 0 end

    if global.NAME_TALBE == nil then
        global.NAME_TALBE = {} 
        local index = 0
        for name, item in pairs(game.item_prototypes) do
            global.NAME_TALBE[index] = name
            index = index + 1
        end
    end


end

function virtual_remove_force_item(force,name,count)
    if global.force_item[force][name] == nil then global.force_item[force][name] = {count = 0} end
    global.force_item[force][name].count = global.force_item[force][name].count - count
end

function add_force_item(force,name,count)
    if global.force_item[force][name] == nil then global.force_item[force][name] = {count = 0} end
    global.force_item[force][name].count = global.force_item[force][name].count + count
end

function virtual_get_force_item_count(force,name)
    if global.force_item[force] and global.force_item[force][name] ~= nil then
        return global.force_item[force][name].count
    else
        return 0
    end
end

function name2id(force,name)
    if global.name2id[force][name] == nil then
        local id = 0
        local n = 0
        for i=1,#name do
            n = string.byte(string.sub(name,i,i))
            id = id * n
            id = id + n
            id = id%2^32
        end
        global.name2id[force][name] = id
        return id
    else
        return global.name2id[force][name]
    end
end

function get_force_item_count(force,name)
    local n = 0
    if global.force_item[force] and global.force_item[force][name] ~= nil then
        n = global.force_item[force][name].count
    else
        return 0
    end
    global.glk[force].link_id = name2id(force,name)
    n = n + global.glk[force].get_item_count(name)
    return n
end


function remove_force_item(player,name,count)
    Message_output_onallplayer('' .. player.name .. ' 取走[item=' .. name .. '] ' .. count,player)
    local force = player.force.name
    if global.force_item[force][name].count >= count then
        global.force_item[force][name].count = global.force_item[force][name].count - count
        count = 0
        return
    else
        count = count - global.force_item[force][name].count
        global.force_item[force][name].count = 0
    end

    global.glk[force].link_id = name2id(force,name)
    global.glk[force].remove_item({name = name, count = count})
end

--*通知消息
function Message_output_onallplayer(text,py)
	for _, player in pairs(game.connected_players) do
        if player.force.name == py.force.name then
		    player.surface.create_entity({name = 'flying-text', position = player.position, text = text , color = {255, 0, 0}})
        end
	end
end

--清理地图中立箱子 山地要塞常用功能
function chest_item_inst_Everybody_items_count(player, chest)
    local force = player.force.name
	for name, count in pairs(chest.get_contents()) do
        if global.force_item[force][name] == nil then global.force_item[force][name] = {count = 0} end
        add_force_item(force,name,count)
		chest.remove({name = name, count = count})
        name2id(force,name)
        Message_output_onallplayer('' .. player.name .. ' 放入 [item=' .. name .. '] ' .. count,player)
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
    local bt =
        frames.add {
        type = 'sprite-button',
        sprite = 'item/' .. item_name,
        number = num,
        name = 'force_item_' .. item_name,
        tooltip = game.item_prototypes[item_name].localised_name,
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

--刷新势力物品栏数量
function item_group_main_tab_updata_count(player,item_group_name)
    item_group_main_tab_updata(player,item_group_name)
    --[[
	local out_item = 'force_item_'
	for key, item in pairs(game.item_prototypes) do
		if item_group_name == item.group.name then
			local out_item_name = out_item .. item.name
            if tk(player.gui.relative['force_items_main']['item_group_main']['item_group_main_tab'],out_item_name) then
                player.gui.relative['force_items_main']['item_group_main']['item_group_main_tab'][out_item_name].number = get_force_item_count(player.force.name,item.name)
            end
		end
	end
    ]]--
end


-- 创建复原窗口
function draw_force_items_main_restore(player)
	local panel = player.gui.relative
	if panel['restore_button'] and panel['restore_button'].valid then
		-- panel['force_items_main'].caption ='玩家:[' .. player.name .. ']打开的' .. player.force.name .. '的共享区.'
		return
	end

	local restore_button = panel.add {
    	type = "sprite-button",
		name = "restore_button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		style = "frame_action_button",
    -- caption ='玩家:[' .. player.name .. ']打开的' .. player.force.name .. '的共享区.',
    -- caption ={ player.name,player.force.name},
		direction = 'vertical',
		anchor = {
			gui = defines.relative_gui_type.controller_gui,
			position = defines.relative_gui_position.left
		} -- right left
	}
	restore_button.visible = false
end

--刷新势力物品栏
function item_group_main_tab_updata(player,item_group_name)
    global.player_item_group[player.name] = item_group_name
    draw_force_items_main_for_player(player)
	local item_group_main_tab = player.gui.relative['force_items_main']['scroll_pane']['item_group_main']['item_group_main_tab']
	
	item_group_main_tab.clear()
	local group_name = 'emy'
	local subgroup_number = 0
	local subgroup_name = 'emy'
	local group_number = 0
    local num = 0

	fill_request_items(player)

	for _, item in pairs(game.item_prototypes) do
		if player.gui.relative['force_items_main']['frame_header']['filter']  then -- 如果有搜索框
			local localised_name = translations.get(player,item.localised_name) -- 获取所有物品的本地化名称
			if localised_name and string.find(localised_name,player.gui.relative['force_items_main']['frame_header']['filter'].text) then -- 如果搜索框有物品的本地化名称中的字符
			else
				goto continue -- 没有就直接结束
			end
		end
        num = get_force_item_count(player.force.name,item.name)
		if num > 0 and item_group_name == item.group.name then
			if subgroup_name ~= item.subgroup.name and subgroup_number > 0 then
				if item.group.name ~= group_name then
					group_name = item.group.name
					group_number = group_number +1
					if group_number == 2 then return end
				end
				subgroup_name = item.subgroup.name
				local yu = 10 - subgroup_number % 10 
				if yu ~= 10 then
					add_empty_button(yu,item_group_main_tab)
					subgroup_number = 0
				end
			end
            
			add_item_button(player,item_group_main_tab,item.name,num)
			subgroup_number = subgroup_number + 1
			subgroup_name = item.subgroup.name
		end
		::continue::
	end
end


--势力物品 创建主窗口
function draw_force_items_main_for_player(player)
	draw_force_items_main_restore(player)
    local panel = player.gui.relative
    
	if panel['force_items_main'] and panel['force_items_main'].valid and panel['force_items_main']['frame_header'] then
        --panel['force_items_main'].caption ='玩家:[' .. player.name .. ']打开的' .. player.force.name .. '的共享区.'
		return
	end

	----------------------------------------------------------
	if panel['force_items_main'] then
		panel['force_items_main'].destroy()
	end
	local force_items_main = panel.add {
		type = 'frame',
		--caption ='玩家:[' .. player.name .. ']打开的' .. player.force.name .. '的共享区.',
		--caption ={ player.name,player.force.name},
		direction = 'vertical',
		name = 'force_items_main',
		anchor = {gui = defines.relative_gui_type.controller_gui, position = defines.relative_gui_position.left},--right left
	}
	force_items_main.style.maximal_height = 920
	force_items_main.style.minimal_height = 620



    ------------------------------------------------------
	local frame_header = force_items_main.add{
		type = "flow",
		direction = "horizontal",
		name = "frame_header",
		
	}
	frame_header.add{
		type = "label",
		name = "frame_caption",
		style = "frame_title",
		caption = '玩家:[' .. player.name .. ']打开的' .. player.force.name .. '的共享区.',
	}

	frame_header.add {
		type = "empty-widget",
		name = "filler"
	}
	frame_header.add {
		type = "textfield",
		name = "filter"
	}

	frame_header.add{
		type = "sprite-button",
		name = "close_button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		style = "frame_action_button",
		-- onChanged = function(self, event)
		-- 	local player = _(self.gui.player)
		-- 	controller.destroyGUI(player)
		-- 	controller.buildButton(player)
		-- end,
	}
	frame_header.style.vertically_stretchable = false
	frame_header['filter'].style.horizontally_stretchable = true
	frame_header['filter'].style.right_margin = 8
	frame_header['filter'].style.size ={60,24}
	frame_header['filler'].style.horizontally_stretchable = true
	frame_header['filler'].style.right_margin = 8

    --------------------------------------------------


	local scroll_pane = force_items_main.add{
		name = "scroll_pane",
		type = "scroll-pane",
		vertical_scroll_policy = "auto-and-reserve-space",
	}
	scroll_pane.style.minimal_width= 450
	scroll_pane.style.vertically_stretchable = true
	scroll_pane.style.vertically_squashable = true
    
	--for _,name in pairs(force_items_main.children_names) do 
	--end
	local item_groups_table = scroll_pane.add{
		type = "table",name = 'item_groups_table', 
		style = 'filter_group_table', 
		direction = "vertical",
		column_count = 6
	}
		local item_group_name = ''
		local item_groups = ''
		for name, item in pairs(game.item_prototypes) do
			item_group_name = item.group.name
			if item_groups ~= item_group_name and item_group_name~= "other" then
				item_groups = item_group_name
                if item_groups_table == nil then return end
                local bt =
                    item_groups_table.add {
                    type = 'sprite-button',
                    sprite = 'item-group/' .. item_group_name,
                    name = 'item_groups_table_' .. item_group_name,
                    tooltip = ({'item-group-name.' .. item_group_name}),
                }
                bt.enabled = true
                bt.focus()
                bt.style = 'filter_group_button_tab'
			end
		end
    local item_group_main = scroll_pane.add{type = "scroll-pane",name = 'item_group_main'}
	item_group_main.add{type = "table",name = 'item_group_main_tab', direction = "vertical",column_count = 10, style = 'filter_slot_table'}
	------------------------------------------------------------------------
	item_group_main_tab_updata(player,'logistics')

end


--势力物品 窗口点击事件
function force_items_main_gui_click(event)
    if not event then
        return
    end
    if not event.element then
        return
    end
    if not event.element.valid then
        return
    end
    if not event.element.name then
        return
    end
    local player = game.players[event.player_index]
    local element_name = event.element.name
    local gui_name1 = 'item_groups_table_'
    local gui_name2 = string.sub(element_name,0, #gui_name1)

	if player.gui.relative['force_items_main'] and player.gui.relative['force_items_main']['frame_header'] and event.element == player.gui.relative['force_items_main']['frame_header']['close_button'] then
		player.gui.relative['force_items_main'].visible = false
		player.gui.relative['restore_button'].visible = true
	elseif event.element == player.gui.relative['restore_button'] then
	player.gui.relative['force_items_main'].visible = true
	player.gui.relative['restore_button'].visible = false
	end


    if gui_name2 == gui_name1 then
        local item_group_name = string.sub(element_name, #gui_name1 + 1 )
        item_group_main_tab_updata(player,item_group_name)
    end

    local out_item = 'force_item_'--
    if string.sub(event.element.name, 0, #out_item) == out_item and player.character and player.character.valid then
        local item_name = string.sub(event.element.name, #out_item + 1, #event.element.name)
        local prototypes = game.item_prototypes
        local item_count = get_force_item_count(player.force.name,item_name)
        if event.button == defines.mouse_button_type.left and item_count >= 1 then
            local number = player.insert({name = item_name, count = 1})
            if number > 0 then
                remove_force_item(player,item_name,1)
            else
                player.print({'','背包已满，无法插入',{'item-name.'..item_name}})
            end
        elseif event.button == defines.mouse_button_type.right and item_count >= prototypes[item_name].stack_size then 
            local number = 0
            local num =  prototypes[item_name].stack_size
            if event.control then
                num =  num*10
                if item_count < num then num = item_count end
            end

            number = player.insert({name = item_name, count = num})
            if number > 0 then
                remove_force_item(player,item_name,number)
            end
            if number < num then
                player.print({'','背包已满，无法插入',{'item-name.'..item_name}})
            end
        elseif item_count < prototypes[item_name].stack_size and item_count >=1 then
            local number = player.insert({name = item_name, count = item_count})
            if number > 0 then
                remove_force_item(player,item_name,number)
            end
            if number < item_count then
                player.print({'','背包已满，无法插入',{'item-name.'..item_name}})
            end
        elseif item_count == 0 then
            --player.print('公共区[item=' .. item_name .. '] 为0',{r = 255,g = 0,b = 255})
            Message_output_onallplayer('关联箱中[item=' .. item_name .. '] 为0',player)
        end
        player.gui.relative['force_items_main']['scroll_pane']['item_group_main']['item_group_main_tab']['force_item_'..item_name].number = get_force_item_count(player.force.name,item_name)
        --item_group_main_tab_updata_count(player, global.player_item_group[player.name])
    end
end



--点击GUI界面on_gui_click
function on_gui_click(event)
    if not event then
        return
    end
    if not event.element then
        return
    end
    if not event.element.valid then
        return
    end
    if not event.element.name then
        return
    end
    force_items_main_gui_click(event)--调用势力物品界面点击事件
end



--GUI筛选按钮 变动时事件
function on_gui_elem_changed(event)
	local gui_name = 'set-item-LinkedPassword-'
	local element = event.element
	-- local parent = element.parent
	local player = game.players[event.player_index]
    local force = player.force.name
	if string.sub(element.name, 0, #gui_name) == gui_name then
		local number = 0
		for key, item in pairs(game.item_prototypes) do
			if item.name == element.elem_value then
                if global.force_item[force][item.name] == nil then global.force_item[force][item.name] = {count = 0} end
                number = name2id(force,item.name)
				global.players_Linked[player.name].Linked.link_id = number
                game.print({"",'['..force..']'..player.name.."手动设置关联ID:"..number.."->",{item.localised_name[1]}},{r = 0, g = 0.75, b = 0.0})
                return
            end
		end
	end
end
--GUI筛选按钮 变动时事件触发
-- 关闭gui
function on_gui_closed(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then
		return
	end
    local character = player.character
    if character and character.valid then
        local player_trash = player.get_inventory(defines.inventory.character_trash)
        if player_trash and player_trash.valid then
            if not player_trash.is_empty() then
                chest_item_inst_Everybody_items_count(player, player_trash)--玩家回收区物品插入势力物品清单
            end
        end
    end
    
    --关联箱GUI界面
    if event.gui_type == defines.gui_type.entity then
        local entity = event.entity
        if entity.type == 'linked-container' then
            AddID[player.name] = nil
        end
    end
end

--打开GUI界面on_gui_opened
function on_gui_opened(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then
		return
	end


	if event.gui_type == defines.gui_type.controller then
		draw_force_items_main_for_player(player)
	end

    
    --关联箱GUI界面
    if event.gui_type == defines.gui_type.entity then
        local entity = event.entity
        if entity.type == 'linked-container' then
            AddID[player.name] = entity
            local gui_name = 'LinkedPassword-'
            local anchor = {gui = defines.relative_gui_type.linked_container_gui, position = defines.relative_gui_position.top}
            local panel = player.gui.relative
            local frame = panel["set-linked-container-password"]
            if not frame then
                frame = panel.add {
                    type = 'frame',
                    name = "set-linked-container-password",
                    style = mod_gui.frame_style,
                    direction = 'horizontal',
                    --caption = '设置关联箱密码',
                    anchor = anchor,
                }
                global.players_Linked[player.name].Linked = entity
                
                local number = 0
                local link_id = 0
                link_id = global.players_Linked[player.name].Linked.link_id

                frame.add{type="label", caption="设置关联箱筛选",tooltip = "设置关联箱指定物品"}
                local field = frame.add{type = "choose-elem-button",name = 'set-item-' .. gui_name .. entity.unit_number, direction = "horizontal", style = "confirm_button", elem_type = 'item',  tooltip = "设置关联箱指定存放物品物品"}
                
                for key, item in pairs(game.item_prototypes) do
                    local number = global.name2id[player.force.name][item.name] 
                    if number == link_id then
                        field.elem_value = item.name
                        break
                    end
                end
            else
                global.players_Linked[player.name].Linked = entity
                frame.clear()
                
                local number = 0
                local link_id = 0
                link_id = global.players_Linked[player.name].Linked.link_id

                frame.add{type="label", caption="设置关联箱筛选",tooltip = "设置关联箱指定物品"}
                local field = frame.add{type = "choose-elem-button",name = 'set-item-' .. gui_name .. entity.unit_number, direction = "horizontal", style = "confirm_button", elem_type = 'item',  tooltip = "设置关联箱指定存放物品物品"}
                
                for key, item in pairs(game.item_prototypes) do
                    number = name2id(player.force.name,item.name)
                    if number == link_id then
                        field.elem_value = item.name
                        break
                    end
                end
            end
        end
    end
    item_group_main_tab_updata_count(player, global.player_item_group[player.name])
end
--打开GUI界面on_gui_opened



-- 同步数据
function tongbu(event)
    -- 遍历AddID
    for key,entity in pairs(AddID) do
        if entity.valid then
            global.randomId[entity.force.name][entity.link_id] = true
        end
    end
    local tick = game.tick
    if tick % settings.global["update-frequency"].value == 3 then
        for force in pairs(game.forces) do
            -- 同步关联库存输出
            if global.TC[force] ~= nil then
                for key,cc in pairs(global.TC[force]) do
                    if cc.valid then
                        local cb = cc.get_or_create_control_behavior()
                        for i=1,cb.signals_count do
                            local sig = cb.get_signal(i)
                            if ((sig ~= nil) and (sig.signal ~= nil) and (sig.signal.type == "item")) then
                                sig.count = get_force_item_count(force,sig.signal.name)
                                cb.set_signal(i,sig)
                            end
                        end
                    else
                        global.TC[force][key] = nil
                        game.print(key..'关联网络信号输出['..key..']已被移除')
                    end
                end
            end
        end
    end

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


    if global.CURR_INDEX == nil or global.ITEM_COUNT == nil or global.NAME_TALBE == nil then return end --如果没有初始化完成，不执行

    local prototypes = game.item_prototypes
    local count = 0
    local count2 = 0
    local num = 0
    local num2 = 0

    for force in pairs(game.forces) do
        for index = global.CURR_INDEX,global.CURR_INDEX + settings.global["update-num"].value do
            index = index % global.ITEM_COUNT
            local name = global.NAME_TALBE[index]
            local id = global.name2id[force][name]
            if id then
                global.glk[force].link_id = id
                count = global.glk[force].get_item_count(name)
                num = settings.global["row_num"].value*10*prototypes[name].stack_size
                if count <  num then
                    if global.force_item[force][name] ~= nil then
                        count2 = global.force_item[force][name].count
                        if count2 > 0 then
                            num2 = count2
                            num = settings.startup["linkSize"].value*prototypes[name].stack_size - num - count
                            if count2 > num then count2 = num end
                            if count2 > 0 then
                                count = global.glk[force].insert({name = name,count = count2})
                                global.force_item[force][name].count = num2 - count
                            end
                        end
                    else
                        global.force_item[force][name] = {count = 0}
                    end
                elseif count > settings.startup["linkSize"].value*prototypes[name].stack_size - num then
                    num2 = global.glk[force].remove_item({name = name,count = count})
                    num = global.glk[force].insert({name = name,count = num})
                    if global.force_item[force][name] == nil then global.force_item[force][name] = {count = 0} end
                    add_force_item(force,name,num2-num)
                end
            end
        end
    end
    global.CURR_INDEX = global.CURR_INDEX + settings.global["update-num"].value

end




function set_link(event)
    local entity = event.created_entity
    local force = entity.force
    if entity and entity.valid and (entity.name == "Oem-linked-chest") then
        if entity.link_id == 0 then
            auto_set_link(entity)
        end
        if entity.link_id == 0 then
            local link_id = math.random(2^32 - 1)
            while link_id < 10000 do link_id = math.random(2^32 - 1) end
            entity.link_id = link_id
            
            local inv = force.get_linked_inventory(entity.prototype, link_id)
            if not inv.is_empty() then inv.clear() end
        end
        global.randomId[force.name][entity.link_id] = true   -- 添加到随机表
    -- elseif entity and entity.valid and (entity.name == "LinkedChestCount") then
    --     global.Ti[force.name] = global.Ti[force.name] + 1
    --     global.TC[force.name][global.Ti[force.name]] = entity 
    --     if event.player_index then
    --         local player = game.get_player(event.player_index) -- 获取玩家控制器
    --         game.print('['..player.force.name..']'..player.name.."关联网络信号输出["..global.Ti[force.name]..']已放置',{r = 0.75, g = 0.0, b = 0})
    --     end
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
		for _,insert in pairs(inserts) do
			filter = insert.inserter_filter_mode
			if filter.type == "whitelist" and #filter.filter_item ~= 0 then-- 如果有连接着机器的筛选机械臂且设置了白名单，linkchest链接的物品设置为白名单的第一个有效值
				linked_chest.link_id = name2id(linked_chest.force.name, game.item_prototypes[filter.filter_item[1]].name)
				return nil


			elseif filter.type == "whitelist" and #filter.filter_item == 0 then-- 如果有连接着机器的筛选机械臂且未设置了白名单，白名单的第一个槽位设置为linkchest链接的物品
				inserts = {insert}-- 优先筛选机械臂
				local machine = insert.machine
				local parts = {}
				parts = get_short_parts(machine,pickup_or_drop)
				if #parts ~= 0 then
					linked_chest.link_id = name2id(linked_chest.force.name, game.item_prototypes[parts[1].name].name)
					insert["entity"].set_filter(1,game.item_prototypes[parts[1].name].name)
					return nil
				end


			elseif filter.type == "blacklist" and #filter.filter_item ~= 0 then-- 如果有连接着机器的筛选机械臂且设置了黑名单，黑名单的第一个槽位设置为缺少的物品减黑名单的物品
				inserts = {insert}-- 优先筛选机械臂
				local machine = insert.machine
				local parts = {}
				parts = get_short_parts(machine,pickup_or_drop)
				parts = table.remove_by_values( parts,filter.filter_item)
				if #parts ~= 0 then
					linked_chest.link_id = name2id(linked_chest.force.name, game.item_prototypes[parts[1].name].name)
					return nil
				end
			end
		end

		local machine = inserts[1].machine
		local parts = {}
		parts = get_short_parts(machine,pickup_or_drop)
		if #parts ~= 0 then
			linked_chest.link_id = name2id(linked_chest.force.name, game.item_prototypes[parts[1].name].name)
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
			if (pickup_pos.x == pos.x and pickup_pos.y == pos.y and drop_target and drop_target.prototype.crafting_speed) then
				machine_target = drop_target
			end
		elseif pickup_or_drop == "drop" then
			if ((pos.x-0.5 <= drop_pos.x and drop_pos.x <= pos.x+0.5) and (pos.y-0.5 <= drop_pos.y and drop_pos.y <= pos.y+0.5) and pickup_target and pickup_target.prototype.crafting_speed) then
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



function get_short_parts(machine,pickup_or_drop)
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
				local number = name2id(machine.force.name, game.item_prototypes[item.name].name)
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






function on_gui_text_changed(event)
    local element = event.element
    local player = game.players[event.player_index]
    if player.gui.relative['force_items_main'] and element == player.gui.relative['force_items_main']['frame_header']['filter'] then
        item_group_main_tab_updata_count(player, global.player_item_group[player.name])
    end
end


function translations.get(player,localised_string)
	if global.translation then
		if global.translation[localised_string[1]] then
			return global.translation[localised_string[1]]
		else
			player.request_translation(localised_string)
		end
	else
		global.translation = {}
	end
end

function on_string_translated(event)
	local request_string = event.localised_string[1]
	local result = event.result
	if request_string then
		global.translation[request_string] = result
	end
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





function fill_request_items(player)
    if player.character == nil then return end
	local request_count = player.character.request_slot_count  -- 玩家的请求区存且有请求则继续
	if not request_count or request_count == 0 then
		return
	end

	local force = player.force.name
	local request_items = {}
	local player_inventory = player.character.get_main_inventory()
	

    
    for i=1,request_count,1 do
        if player.character.get_request_slot(i) then
            table.insert(request_items,{
                    name = player.character.get_request_slot(i).name,
                    short_count = player.character.get_request_slot(i).count
            })
        end
    end
	for _,item in pairs(request_items) do
		local inventory_count=player_inventory.get_item_count(item.name)
		item.short_count=item.short_count-inventory_count
		if item.short_count <0 then item.short_count =0 end
	end

	for _,item in pairs(request_items) do
		if item.short_count>0 then
			local force_count = get_force_item_count(force, item.name)
			if force_count > 0 then
				if force_count > item.short_count then
					if try_insert(player_inventory,item.name,item.short_count) then remove_force_item(player, item.name, item.short_count) end
				else
					if try_insert(player_inventory,item.name,force_count) then remove_force_item(player, item.name, force_count) end
			
				end
			end
		end
	end
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
Event.addListener(defines.events.on_force_friends_changed,clear_player)

Event.addListener(defines.events.on_built_entity,set_link)    -- 玩家建造物品
Event.addListener(defines.events.on_robot_built_entity,set_link)  -- 机器人建造物品
Event.addListener(defines.events.on_gui_elem_changed, on_gui_elem_changed)
Event.addListener(defines.events.on_gui_opened, on_gui_opened)
Event.addListener(defines.events.on_gui_closed, on_gui_closed)
Event.addListener(defines.events.on_gui_click, on_gui_click)
Event.addListener(defines.events.on_tick, tongbu)


Event.addListener(defines.events.on_gui_text_changed, on_gui_text_changed)
Event.addListener(defines.events.on_string_translated, on_string_translated)