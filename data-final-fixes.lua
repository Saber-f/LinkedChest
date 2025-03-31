
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