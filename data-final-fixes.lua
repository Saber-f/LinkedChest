
data.raw["recipe"]["barrel"].ingredients = {
    {type = "item", name = "copper-plate", amount = 1}
}

local OemLinkedChest = util.table.deepcopy(data.raw["linked-container"]["linked-chest"])
OemLinkedChest.gui_mode = "all" -- all, none, adminss


for index, container in pairs(data.raw["linked-container"]) do
    container.inventory_type = "with_filters_and_bar"
end

-- 碰撞0.4
data.raw["linked-container"]["Oem-linked-chest"].collision_box = {{-0.15, -0.15}, {0.15, 0.15}}

-- 机器人平台雷达范围
data.raw.roboport.roboport.radar_range = 2
data.raw.roboport.roboport.logistics_radius = 64
data.raw.roboport.roboport.construction_radius = 64
data.raw.roboport.roboport.logistics_connection_distance = 64
data.raw["cargo-landing-pad"]["cargo-landing-pad"].radar_range = 2

-- 火箭弹初始速度
data.raw.ammo["rocket"].ammo_type.action.action_delivery.starting_speed = 1
data.raw.ammo["explosive-rocket"].ammo_type.action.action_delivery.starting_speed = 1


-- 中小型电击抗性100%->0%
--medium-metallic-asteroid
--asteroid

local size = {"small", "medium"}
local type = {"metallic", "carbonic", "oxide", "promethium"}
for _, size in pairs(size) do
    for _, type in pairs(type) do
        local name = size .. "-" .. type .. "-asteroid"
        local new_resistances = {}
        for _, resistance in pairs(data.raw["asteroid"][name].resistances) do
            if resistance.type == "electric" then
                table.insert(new_resistances, {
                    type = "electric",
                    percent = 1,
                })
            else
                table.insert(new_resistances, resistance)
            end
        end
        data.raw["asteroid"][name].resistances = new_resistances
    end
end

-- 增加电线杆范围
data.raw["electric-pole"]["small-electric-pole"].maximum_wire_distance = 16
data.raw["electric-pole"]["small-electric-pole"].supply_area_distance = 8
data.raw["electric-pole"]["medium-electric-pole"].maximum_wire_distance = 32
data.raw["electric-pole"]["medium-electric-pole"].supply_area_distance = 16
data.raw["electric-pole"]["substation"].maximum_wire_distance = 64
data.raw["electric-pole"]["substation"].supply_area_distance = 42


-- 增加大推力推进器
data.raw.thruster.thruster.max_performance = {
    fluid_volume = 1,
    fluid_usage = 1,
    effectivity = 1,
}

local old_name = "thruster"
for i = 2, 9 do
    local new_name = "thruster" .. i
    local new_thruster = util.table.deepcopy(data.raw.thruster.thruster)
    new_thruster.name = new_name
    new_thruster.max_performance = {
        fluid_volume = 1,
        fluid_usage = 2^(i-1),
        effectivity = 2^(i-1),
    }
    local new_item = util.table.deepcopy(data.raw.item.thruster)
    new_item.name = new_name
    new_item.place_result = new_name
    local new_recipe = util.table.deepcopy(data.raw.recipe.thruster)
    new_recipe.enabled = true
    new_recipe.name = new_name
    new_recipe.ingredients = {{type="item", name=old_name, amount=10}}
    new_recipe.results = {{type="item", name=new_name, amount=1}}
    old_name = new_name
    data:extend({
        new_thruster,
        new_item,
        new_recipe,
    })
end
