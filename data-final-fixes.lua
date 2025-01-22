
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


-- 特斯拉附带激光伤害
local old = data.raw.beam["chain-tesla-turret-beam-start"].action.action_delivery.target_effects
data.raw.beam["chain-tesla-turret-beam-start"].action.action_delivery.target_effect = table.insert(old, {type = "damage", damage = {amount = 120, type = "laser"}})

local old2 = data.raw.beam["chain-tesla-turret-beam-bounce"].action.action_delivery.target_effects
data.raw.beam["chain-tesla-turret-beam-bounce"].action.action_delivery.target_effect = table.insert(old2, {type = "damage", damage = {amount = 120, type = "laser"}})

