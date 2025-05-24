
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
data.raw.roboport.roboport.radar_range = 1
data.raw.roboport.roboport.logistics_radius = 42
data.raw.roboport.roboport.construction_radius = 42
data.raw.roboport.roboport.logistics_connection_distance = 42
data.raw["cargo-landing-pad"]["cargo-landing-pad"].radar_range = 1

-- 火箭弹初始速度
data.raw.ammo["rocket"].ammo_type.action.action_delivery.starting_speed = 0
data.raw.projectile["rocket"].acceleration = 0.4
data.raw.projectile["rocket"].turn_speed = 10
data.raw.ammo["explosive-rocket"].ammo_type.action.action_delivery.starting_speed = 0
data.raw.projectile["explosive-rocket"].acceleration = 0.4
data.raw.projectile["explosive-rocket"].turn_speed = 10

-- 修改炮塔
data.raw["ammo-turret"]["gun-turret"].rotation_speed = 0.04
data.raw["ammo-turret"]["gun-turret"].preparing_speed = 0.15
data.raw["ammo-turret"]["gun-turret"].folding_speed = 0.15

data.raw["electric-turret"]["laser-turret"].rotation_speed = 0.04
data.raw["electric-turret"]["laser-turret"].preparing_speed = 0.15
data.raw["electric-turret"]["laser-turret"].folding_speed = 0.15

data.raw["ammo-turret"]["rocket-turret"].rotation_speed = 0.03
data.raw["ammo-turret"]["rocket-turret"].preparing_speed = 0.1
data.raw["ammo-turret"]["rocket-turret"].folding_speed = 0.1

data.raw["ammo-turret"]["railgun-turret"].rotation_speed = 0.03
data.raw["ammo-turret"]["railgun-turret"].preparing_speed = 0.1
data.raw["ammo-turret"]["railgun-turret"].folding_speed = 0.1

local tesla_turret = data.raw["electric-turret"]["tesla-turret"]
tesla_turret.rotation_speed = 0.02
tesla_turret.preparing_speed = 0.1
tesla_turret.folding_speed = 0.1
tesla_turret.attack_parameters.cooldown = 60
tesla_turret.attack_parameters.source_offset = {0, -0.385}
local target_effects = tesla_turret.attack_parameters.ammo_type.action.action_delivery.target_effects
target_effects[2].action.action_delivery.max_length = 54
target_effects[2].action.action_delivery.source_offset = {0, -1.82}
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


data:extend({
    {
        type = "recipe",
        name = "pentapod-egg-recycling",
        enabled = true,
        hidden = true,
        hidden_in_factoriopedia = true,
        category = "recycling",
        energy_required = 6,
        ingredients =
        {
          {type="item", name="pentapod-egg", amount=1},
        },
        results = {
          {type="item", name="pentapod-egg", probability=0.25, amount = 1},
        }
      },
      {
        type = "recipe",
        name = "biter-spwaner-recycling",
        enabled = true,
        hidden = true,
        hidden_in_factoriopedia = true,
        category = "recycling",
        group = "storage",
        energy_required = 6,
        ingredients =
        {
          {type="item", name="biter-spwaner", amount=1},
        },
        results = {
          {type="item", name="biter-spwaner", probability=0.25, amount = 1},
        }
      },
      {
        type = "recipe",
        name = "promethium-asteroid-chunk-crushing",
        icon = "__space-age__/graphics/icons/promethium-asteroid-chunk.png",
        enabled = true,
        subgroup = "space-crushing",
        category = "crushing",
        energy_required = 2,
        ingredients =
        {
          {type="item", name="promethium-asteroid-chunk", amount=1},
        },
        results = {
        {type="item", name="tungsten-ore", amount = 10},
        {type="item", name="holmium-ore", amount = 10},
          {type="item", name="promethium-asteroid-chunk", probability=0.2, amount = 1},
        }
    }
})



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
    new_thruster.enabled = true
    new_thruster.minable.result = new_name
    new_thruster.max_performance = {
        fluid_volume = 1,
        fluid_usage = 2^(i-1),
        effectivity = 2^(i-1),
    }
    local new_item = util.table.deepcopy(data.raw.item.thruster)
    new_item.name = new_name
    new_item.place_result = new_name

    -- 新配方
    local new_recipe = util.table.deepcopy(data.raw.recipe.thruster)
    new_recipe.name = new_name
    new_recipe.enabled = true
    new_recipe.ingredients = {{type="item", name=old_name, amount=10}}
    new_recipe.results = {{type="item", name=new_name, amount=1}}

    -- 回收配方
    local new_repice_recycling = util.table.deepcopy(data.raw.recipe["thruster-recycling"])
    new_repice_recycling.name = new_name .. "-recycling"
    new_repice_recycling.ingredients = {{type="item", name=new_name, amount=1}}
    new_repice_recycling.results = {{type="item", name=old_name, amount_min=1, amount_max=7}}

    old_name = new_name
    data:extend({
        new_thruster,
        new_item,
        new_recipe,
        new_repice_recycling,
    })
end

-- 增加大容量液体罐 volume
old_name = "storage-tank"
for i = 2, 4 do
    local new_name = "storage-tank-" .. i
    local new_entity = util.table.deepcopy(data.raw["storage-tank"][old_name])
    new_entity.name = new_name
    new_entity.minable.result = new_name
    new_entity.fluid_box.volume = new_entity.fluid_box.volume * 4
    local new_item = util.table.deepcopy(data.raw.item["storage-tank"])
    new_item.name = new_name
    new_item.place_result = new_name

    -- 新配方
    local new_recipe = util.table.deepcopy(data.raw.recipe["storage-tank"])
    new_recipe.name = new_name
    new_recipe.enabled = true
    new_recipe.ingredients = {{type="item", name=old_name, amount=4}}
    new_recipe.results = {{type="item", name=new_name, amount=1}}

    -- 回收配方
    local new_repice_recycling = util.table.deepcopy(data.raw.recipe["storage-tank-recycling"])
    new_repice_recycling.name = new_name .. "-recycling"
    new_repice_recycling.enabled = true
    new_repice_recycling.ingredients = {{type="item", name=new_name, amount=1}}
    new_repice_recycling.results = {{type="item", name=old_name, amount_min=1, amount_max=3}}

    old_name = new_name
    data:extend({
        new_entity,
        new_item,
        new_recipe,
        new_repice_recycling,
    })
end

-- 增加弹药堆叠 stack_size
data.raw["ammo"]["rocket"].stack_size = 200
data.raw["ammo"]["explosive-rocket"].stack_size = 200
data.raw["ammo"]["railgun-ammo"].stack_size = 200

-- 增加机枪射程
data.raw["ammo-turret"]["gun-turret"].attack_parameters.range = 26
data.raw["electric-turret"]["laser-turret"].attack_parameters.range = 26
data.raw["electric-turret"]["tesla-turret"].attack_parameters.range = 36


-- 调整边缘-破碎陨石出现
data.raw['space-connection']['solar-system-edge-shattered-planet'].length = 5000000
local asteroid_spawn_definitions = data.raw['space-connection']['solar-system-edge-shattered-planet'].asteroid_spawn_definitions


-- 调整破碎陨石概率
data.raw['space-location']['shattered-planet'].asteroid_spawn_definitions = {};
data.raw['space-location']['solar-system-edge'].asteroid_spawn_definitions = {};

table.insert(data.raw['planet']["nauvis"].asteroid_spawn_definitions, {
    type = "asteroid-chunk",
    asteroid = "promethium-asteroid-chunk",
    probability = 0.0001,
    speed = 0.016
})

table.insert(data.raw['planet']["fulgora"].asteroid_spawn_definitions, {
    type = "asteroid-chunk",
    asteroid = "promethium-asteroid-chunk",
    probability = 0.0002,
    speed = 0.016
})

table.insert(data.raw['planet']["vulcanus"].asteroid_spawn_definitions, {
    type = "asteroid-chunk",
    asteroid = "promethium-asteroid-chunk",
    probability = 0.0002,
    speed = 0.016
})

table.insert(data.raw['planet']["gleba"].asteroid_spawn_definitions, {
    type = "asteroid-chunk",
    asteroid = "promethium-asteroid-chunk",
    probability = 0.0002,
    speed = 0.016
})

table.insert(data.raw['planet']["aquilo"].asteroid_spawn_definitions, {
    type = "asteroid-chunk",
    asteroid = "promethium-asteroid-chunk",
    probability = 0.0004,
    speed = 0.016
})

-- 碳
local p1 = {
    {0.2, 0.016},
    {0.4, 0.016},
    {0.400001, 0}
}

-- 金属
local p2 = {
    {0.2, 0.012},
    {0.200001, 0},
    {0.4, 0},
    {0.400001, 0.012},
    {0.6, 0.012},
    {0.600001, 0},
}

-- 冰
local p3 = {
    {0.2, 0.008},
    {0.200001, 0},
    {0.6, 0},
    {0.600001, 0.008},
    {0.8, 0.008},
    {0.800001, 0},
}

-- 红色
local p4 = {
    {0.38,0.001},
    {0.380001,0.005},
    {0.4, 0.005},
    {0.400001,0.001},
    {0.57,0.002},
    {0.570001,0.01},
    {0.6, 0.01},
    {0.600001,0.002},
    {0.76,0.004},
    {0.760001,0.02},
    {0.8, 0.02},
    {0.800001,0.004},
    {0.95,0.008},
    {0.950001,0.04},
    {1, 0.04}
}

local get_spawn_points = function(p)
    local spawn_points = {}
    for i = 1, #p do
        table.insert(spawn_points, {
            distance = p[i][1],
            probability = p[i][2],
            speed = 0.05,
        })
    end
    return spawn_points
end

asteroid_spawn_definitions[2].spawn_points = get_spawn_points(p1)  -- 碳
asteroid_spawn_definitions[1].spawn_points = get_spawn_points(p2)  -- 金属
asteroid_spawn_definitions[3].spawn_points = get_spawn_points(p3)  -- 冰
asteroid_spawn_definitions[4].spawn_points = get_spawn_points(p4)  -- 红色