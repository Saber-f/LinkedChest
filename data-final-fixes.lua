
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
data.raw.ammo["rocket"].ammo_type.action.action_delivery.starting_speed = 1.5
data.raw.ammo["explosive-rocket"].ammo_type.action.action_delivery.starting_speed = 1.5

-- 修改炮塔
data.raw["ammo-turret"]["gun-turret"].rotation_speed = 0.04
data.raw["ammo-turret"]["gun-turret"].rotation_speed = 0.2
data.raw["ammo-turret"]["gun-turret"].rotation_speed = 0.2

data.raw["electric-turret"]["laser-turret"].rotation_speed = 0.04
data.raw["electric-turret"]["laser-turret"].rotation_speed = 0.2
data.raw["electric-turret"]["laser-turret"].rotation_speed = 0.2

local tesla_turret = data.raw["electric-turret"]["tesla-turret"]
tesla_turret.rotation_speed = 0.03
tesla_turret.rotation_speed = 0.15
tesla_turret.rotation_speed = 0.15
tesla_turret.attack_parameters.cooldown = 60
tesla_turret.collision_box = {{-1.2, -1.2 }, {1.2, 1.2}}
tesla_turret.selection_box = {{-1.5, -1.5 }, {1.5, 1.5}}
tesla_turret.energy_source.input_flow_limit = "13MW"
local layers_list = {
    tesla_turret.folded_animation.layers,
    tesla_turret.preparing_animation.layers,
    tesla_turret.prepared_animation.layers,
    tesla_turret.ending_attack_animation.layers,
    tesla_turret.folding_animation.layers,
    tesla_turret.energy_glow_animation.layers,
    tesla_turret.resource_indicator_animation.layers,
}
for _, visualisation in pairs(tesla_turret.graphics_set.base_visualisation) do
    table.insert(layers_list, visualisation.animation.layers)
end

for _, layers in pairs(layers_list) do
    for _, layer in pairs(layers) do
        layer.scale = layer.scale * 0.7
        layer.shift = {layer.shift[1] * 0.7, layer.shift[2] * 0.7}
    end
end

data.raw["ammo-turret"]["rocket-turret"].rotation_speed = 0.03
data.raw["ammo-turret"]["rocket-turret"].rotation_speed = 0.15
data.raw["ammo-turret"]["rocket-turret"].rotation_speed = 0.15

data.raw["ammo-turret"]["railgun-turret"].rotation_speed = 0.03
data.raw["ammo-turret"]["railgun-turret"].rotation_speed = 0.15
data.raw["ammo-turret"]["railgun-turret"].rotation_speed = 0.15


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
                    percent = 10,
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
    new_thruster.minable.result = new_name
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

-- 增加机枪射程
data.raw["ammo-turret"]["gun-turret"].attack_parameters.range = 26
data.raw["electric-turret"]["laser-turret"].attack_parameters.range = 26
data.raw["electric-turret"]["tesla-turret"].attack_parameters.range = 36


-- 调整边缘-破碎陨石出现
data.raw['space-connection']['solar-system-edge-shattered-planet'].length = 5000000
local asteroid_spawn_definitions = data.raw['space-connection']['solar-system-edge-shattered-planet'].asteroid_spawn_definitions

local spawn_points1 = {
    [1] = {
        distance = 0,
        probability = 0,
        speed = 0.05,
    },
    [2] = {
        distance = 0.2,
        probability = 0.03,
        speed = 0.05,
    },
    [3] = {
        distance = 0.201,
        probability = 0,
        speed = 0.05,
    },
    [4] = {
        distance = 0.4,
        probability = 0,
        speed = 0.05,
    },
    [5] = {
        distance = 0.401,
        probability = 0.03,
        speed = 0.05,
    },
    [6] = {
        distance = 0.6,
        probability = 0.03,
        speed = 0.05,
    },
    [7] = {
        distance = 0.601,
        probability = 0,
        speed = 0.05,
    },
    [8] = {
        distance = 1,
        probability = 0,
        speed = 0.05,
    }
}
local spawn_points2 = {
    [1] = {
        distance = 0,
        probability = 0,
        speed = 0.05,
    },
    [2] = {
        distance = 0.2,
        probability = 0.04,
        speed = 0.05,
    },
    [3] = {
        distance = 0.4,
        probability = 0.04,
        speed = 0.05,
    },
    [4] = {
        distance = 0.401,
        probability = 0,
        speed = 0.05,
    },
    [5] = {
        distance = 1,
        probability = 0,
        speed = 0.05,
    }
}
local spawn_points3 = {
    [1] = { 
        distance = 0,
        probability = 0,
        speed = 0.05,
    },
    [2] = {
        distance = 0.2,
        probability = 0.02,
        speed = 0.05,
    },
    [3] = {
        distance = 0.201,
        probability = 0,
        speed = 0.05,
    },
    [4] = {
        distance = 0.6,
        probability = 0,
        speed = 0.05,
    },
    [5] = {
        distance = 0.601,
        probability = 0.02,
        speed = 0.05,
    },
    [6] = {
        distance = 0.8,
        probability = 0.02,
        speed = 0.05,
    },
    [7] = {
        distance = 0.801,
        probability = 0,
        speed = 0.05,
    },
    [8] = {
        distance = 1,
        probability = 0,
        speed = 0.05,
    }
}
local spawn_points4 = {
    [1] = {
        distance = 0,
        probability = 0,
        speed = 0.05,
    },
    [2] = {
        distance = 0.5,
        probability = 0,
        speed = 0.05,
    },
    [3] = {
        distance = 0.95,
        probability = 0.02,
        speed = 0.05,
    },
    [4] = {
        distance = 0.951,
        probability = 0.5,
        speed = 0.05,
    },
    [5] = {
        distance = 0.999,
        probability = 0.5,
        speed = 0.05,
    },
    [6] = {
        distance = 1,
        probability = 0,
        speed = 0.05,
    }
}

asteroid_spawn_definitions[1].spawn_points = spawn_points1  -- 金属
asteroid_spawn_definitions[2].spawn_points = spawn_points2  -- 碳
asteroid_spawn_definitions[3].spawn_points = spawn_points3  -- 冰
asteroid_spawn_definitions[4].spawn_points = spawn_points4  -- 红色



