data.raw["recipe"]["red-wire"].enabled = true
data.raw["recipe"]["red-wire"].ingredients = {{"copper-plate", 1}}

data.raw["recipe"]["empty-barrel"].ingredients = {{"copper-plate", 1}}

local OemLinkedChest = util.table.deepcopy(data.raw["linked-container"]["linked-chest"])
OemLinkedChest.gui_mode = "all" -- all, none, adminss


if data.raw.recipe["rfw-fusion-rounds-magazine"] then

--[[Technology]]--
data:extend({
    {   -- 虚拟化技术
        type = "technology",
        name = "virtual",
        icon = "__LinkedChest3__/graphics/icons/TokenBrandedVra.png",
        icon_size = 64, icon_mipmaps = 4,
        effects =
        {
        },
        prerequisites = {"god-module"},
        unit =
        {
        count = settings.startup["god-research"].value * 10,
        ingredients =
        {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1},
            {"rfp-antimatter-science-pack", 1},
        },
        time = 120
        },
        upgrade = true,
        order = "i-g-f"
    },{ -- 上帝插件科技
        type = "technology",
        name = "god-module",
        icon = "__Advanced_Sky_Modules__/graphics/icons/modules/god-module.png",
        icon_size = 32,
        effects =
        {
        {
            type = "unlock-recipe",
            recipe = "god-module"
        }
        },
        prerequisites = {"pure-productivity-module-6","effectivity-module-6","pure-speed-module-6","rfp-antimatter-reactor"},
        unit =
        {
        count = settings.startup["god-research"].value,
        ingredients =
        {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1},
            {"rfp-antimatter-science-pack", 1},
        },
        time = 120
        },
        upgrade = true,
        order = "i-g-f"
    },{--上帝插件配方
        type = "recipe",
        name = "god-module",
        energy_required = 30,
        category = rfp_categories["antimatter-processing"],
        ingredients =
        {
            {"pure-productivity-module-6", 1},
                {"pure-speed-module-6", 1},
                {type="fluid", name=rfp_fluids["antihydrogen"], amount=10},
            },
        result = "god-module",
        result_count = 1,
        enabled = false
    },{ -- 聚变子弹
            type = "ammo",
            name = "rfw-fusion-rounds-magazine",
            icon = "__RealisticFusionWeaponry__/graphics/icons/fusion-rounds-magazine.png",
            icon_size = 64, icon_mipmaps = 4,
            ammo_type = {
                category = "bullet",
                action =
                {
                    type = "direct",
                    action_delivery =
                    {
                        {
                            type = "instant",
                            source_effects =
                            {
                                {
                                    type = "create-explosion",
                                    entity_name = "explosion-gunshot"
                                }
                            },
                            target_effects =
                            {
                                {
                                    type = "damage",
                                    damage = {amount = 2000, type = "physical"}
                                },
                                {
                                    type = "damage",
                                    damage = {amount = 4000, type = "explosion"}
                                },
                            }
                        },
                    }
                }
            },
            magazine_size = 10,
            subgroup = "ammo",
            order = "a[basic-clips]-e[fusion-rounds-magazine]",
            stack_size = 100
	},{ -- 反物质子弹
		type = "ammo",
		name = "rfw-antimatter-rounds-magazine",
		icon = "__RealisticFusionWeaponry__/graphics/icons/antimatter-rounds-magazine.png",
		icon_size = 64, icon_mipmaps = 4,
		ammo_type = {
			category = "bullet",
			action =
			{
				{
					type = "direct",
					action_delivery =
					{
						{
							type = "instant",
							source_effects =
							{
								{
								type = "create-explosion",
								entity_name = "explosion-gunshot"
								}
							},
							target_effects =
							{
                {
                  type = "damage",
                  damage = {amount = 80000, type = "physical"}
                },
                {
                  type = "damage",
                  damage = {amount = 160000, type = "explosion"}
                },
              }
						}
					}
				}
			},
		},
		magazine_size = 10,
		subgroup = "ammo",
		order = "a[basic-clips]-f[antimatter-rounds-magazine]",
		stack_size = 100
	},{-- 氘He3混合气体
        type = "recipe",
        name = "rfp-d-he3-mixing",
        category = rfp_categories["gas-mixing"],
        icon = "__RealisticFusionPower__/graphics/icons/d-he3-mix.png",
        icon_size = 256,
        hide_from_player_crafting = true,
		energy_required = 1,
        allow_productivity = true,
		ingredients = {{type = "fluid", name = rfp_fluids["deuterium"], amount = 10}, {type = "fluid", name = rfp_fluids["helium-3"], amount = 10},},
        results = {{type = "fluid", name = rfp_fluids["d-he3-mix"], amount = 1000}},
    },{-- 白瓶配方
        type = "recipe",
        name = "space-science-pack",    -- 白瓶
        enabled = true,
        energy_required = 21,
        ingredients =
        {
            {"rocket-fuel", 100},
            {"rocket-control-unit", 100},
            {"low-density-structure", 100},
            {"satellite", 1}
        },
        result_count = 10,
        result = "space-science-pack"
    },
})


-- 子弹伤害调整
data.raw.ammo["firearm-magazine"].ammo_type.action = {      -- 黄子弹
    {
        type = "direct",
        action_delivery =
        {
            {
                type = "instant",
                source_effects =
                {
                    {
                        type = "create-explosion",
                        entity_name = "explosion-gunshot"
                    }
                },
                target_effects =
                {
                    {
                        type = "damage",
                        damage = { amount = 10 , type = "physical"}
                    }
                }
            }
        }
    }
}
data.raw.ammo["piercing-rounds-magazine"].ammo_type.action = {      -- 红子弹
    {
        type = "direct",
        action_delivery =
        {
            {
                type = "instant",
                source_effects =
                {
                    {
                        type = "create-explosion",
                        entity_name = "explosion-gunshot"
                    }
                },
                target_effects =
                {
                    {
                        type = "damage",
                        damage = { amount = 25 , type = "physical"}
                    }
                }
            }
        }
    }
}
if data.raw.ammo["chromium-magazine"] then
    data.raw.ammo["chromium-magazine"].ammo_type.action = {      -- 铬子弹
        {
            type = "direct",
            action_delivery =
            {
                {
                    type = "instant",
                    source_effects =
                    {
                        {
                            type = "create-explosion",
                            entity_name = "explosion-gunshot"
                        }
                    },
                    target_effects =
                    {
                        {
                            type = "damage",
                            damage = { amount = 50 , type = "physical"}
                        }
                    }
                }
            }
        }
    }
end
data.raw.ammo["uranium-rounds-magazine"].ammo_type.action = {      -- 绿子弹
    {
        type = "direct",
        action_delivery =
        {
            {
                type = "instant",
                source_effects =
                {
                    {
                        type = "create-explosion",
                        entity_name = "explosion-gunshot"
                    }
                },
                target_effects =
                {
                    {
                        type = "damage",
                        damage = { amount = 100 , type = "physical"}
                    },
                    {
                      type = "damage",
                      damage = {amount = 200, type = "explosion"}
                    },
                }
            }
        }
    }
}


-- 炮塔修正
data.raw["ammo-turret"]["gun-turret"].max_health = 10000
data.raw["ammo-turret"]["gun-turret"].prepare_range = 124
data.raw["ammo-turret"]["gun-turret"].range = 120
data.raw["ammo-turret"]["gun-turret"].attack_parameters =
{
    type = "projectile",
    ammo_category = "bullet",
    cooldown = 30,
    projectile_creation_distance = 1.39375,
    projectile_center = {0, -0.0875}, -- same as gun_turret_attack shift
    shell_particle =
    {
    name = "shell-particle",
    direction_deviation = 0.1,
    speed = 0.1,
    speed_deviation = 0.03,
    center = {-0.0625, 0},
    creation_distance = -1.925,
    starting_frame_speed = 0.2,
    starting_frame_speed_deviation = 0.1
    },
    range = 120,
    sound = {
        switch_vibration_data =
        {
          filename = "__base__/sound/car-metal-impact.bnvib"
        },
        game_controller_vibration_data =
        {
          low_frequency_vibration_intensity = 0.9,
          duration = 150
        },
        variations =
        {
          {
            filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.5
          },
          {
            filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.5
          },
          {
            filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.5
          },
          {
            filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.5
          },
          {
            filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.5
          }
        }
      }
}
if data.raw["electric-turret"]["arc-turret"] then
    data.raw["electric-turret"]["arc-turret"].prepare_range = 124
    data.raw["electric-turret"]["arc-turret"].attack_parameters.range = 120
end
data.raw["electric-turret"]["laser-turret"].max_health = 40000
data.raw["electric-turret"]["laser-turret"].prepare_range = 124
data.raw["electric-turret"]["laser-turret"].collision_box = {{ -1.7, -1.7}, {1.7, 1.7}}
data.raw["electric-turret"]["laser-turret"].selection_box = {{ -2, -2}, {2, 2}}
data.raw["electric-turret"]["laser-turret"].energy_source =
{
  type = "electric",
  buffer_capacity = "4GJ",
  input_flow_limit = "50GW",
  drain = "120MW",
  usage_priority = "primary-input"
}
data.raw["electric-turret"]["laser-turret"].attack_parameters =
{
  type = "beam",
  cooldown = 40,
  range = 120,
  source_direction_count = 64,
  source_offset = {0, -3.423489 / 4},
  damage_modifier = 10000,
  ammo_type =
  {
    category = "laser",
    energy_consumption = "4GJ",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "beam",
        beam = "laser-beam",
        max_length = 120,
        duration = 30,
        source_offset = {0, -1.31439 }
      }
    }
  }
}

-- photon-turret
if data.raw["electric-turret"]["photon-turret"] then
    data.raw["electric-turret"]["photon-turret"].prepare_range = 124
    data.raw["electric-turret"]["photon-turret"].collision_box = {{ -1.7, -1.7}, {1.7, 1.7}}
    data.raw["electric-turret"]["photon-turret"].selection_box = {{ -2, -2}, {2, 2}}
    data.raw["electric-turret"]["photon-turret"].energy_source = {
    type = "electric",
    buffer_capacity = "40GJ",
    input_flow_limit = "500GW",
    drain = "1.2GW",
    usage_priority = "primary-input"
    }
    data.raw["electric-turret"]["photon-turret"].attack_parameters = {
        ammo_type = {
            action = {
                action_delivery = {
                    projectile = "photon-torpedo",
                    type = "projectile",
                    starting_speed = 1,
                    max_range = 120,
                    min_range = 12,
                    direction_deviation = 0,
                    source_effects = {
                        entity_name = "photon-muzzle",
                        type = "create-explosion"
                    },
                },
                type = "direct",
            },
            category = "photon-torpedo",
            energy_consumption = "40GJ",
            target_type = "entity",
        },
        cooldown = 120,
        range = 120,
        min_range = 12,
        turn_range = 1/3,
        projectile_center = {0,0},
        projectile_creation_distance = 1.75,
        lead_target_for_projectile_speed = 1,
        sound = {
            filename = string.format("%s/%s.ogg", DIR.sound_path, "new-photon"),
            volume = 0.75,
            min_speed = 0.975,
            max_speed = 1.025,
        },
        type = "projectile"
    }
    data.raw.projectile["photon-torpedo"].action = {
        action_delivery = {
            target_effects = {
                {
                    entity_name = "photon-hit",
                    type = "create-entity"
                },
                {
                    entity_name = "photon-shock",
                    type = "create-entity"
                },
                {
                    damage = {
                        amount = 180000,
                        type = "laser"
                    },
                    type = "damage"
                },
                {
                    check_buildability = true,
                    entity_name = "small-scorchmark",
                    type = "create-entity"
                },
                {
                    action = {
                        action_delivery = {
                            target_effects = {
                                {
                                    damage = {
                                        amount = 240000,
                                        type = "fire"
                                    },
                                    type = "damage"
                                },
                                {
                                    entity_name = "explosion",
                                    type = "create-entity"
                                }
                            },
                            type = "instant"
                        },
                        radius = 4,
                        type = "area"
                    },
                    type = "nested-result"
                }
            },
            type = "instant"
        },
        type = "direct"
    }
end

-- 修改粘贴
data.raw.shortcut.paste.action = "copy"

-- 更改插件孔
data.raw["assembling-machine"]["rfp-gas-mixer"].module_specification = {module_slots = 3}   -- 混合仪
data.raw["assembling-machine"]["angels-electric-boiler"].module_specification = {module_slots = 3}  -- 锅炉
data.raw["assembling-machine"]["rfp-electrolyser"].module_specification = {module_slots = 3} -- 电解器
data.raw["furnace"]["electric-furnace"].module_specification = {module_slots = 3} -- 电炉
data.raw["lab"]["lab"].module_specification = {module_slots = 3} -- 实验室


-- 聚变武器制造机器更改
data.raw.recipe["rfw-fusion-rounds-magazine"].category = rfp_categories["gas-mixing"]     -- 聚变子弹
data.raw.recipe["rfw-fusion-cannon-shell"].category = rfp_categories["gas-mixing"]     -- 聚变加农
data.raw.recipe["rfw-small-fusion-rocket"].category = rfp_categories["gas-mixing"]     -- 聚变小火箭
data.raw.recipe["rfw-fusion-bomb"].category = rfp_categories["gas-mixing"]     -- 聚变火箭

-- 插件影响修改
data.raw["assembling-machine"]["angels-electric-boiler"].allowed_effects = {"consumption", "speed", "productivity", "pollution"}
data.raw["assembling-machine"]["rfp-gas-mixer"].allowed_effects = {"consumption", "speed", "productivity", "pollution"}
data.raw["assembling-machine"]["rfp-electrolyser"].allowed_effects = {"consumption", "speed", "productivity", "pollution"}
data.raw["assembling-machine"]["rfp-antimatter-processor"].crafting_speed = 20

-- 个人模块修改
data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].attack_parameters.range = 80
data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].attack_parameters.damage_modifier = 2000
data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].attack_parameters.ammo_type.action.action_delivery.max_length = 80
data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].shape = {
  width = 1,
  height = 8,
  type = "full"
}
if data.raw["active-defense-equipment"]["arc-turret-equipment"] then
    data.raw["active-defense-equipment"]["arc-turret-equipment"].attack_parameters.range = 80
    data.raw["active-defense-equipment"]["arc-turret-equipment"].shape = {
        width = 1,
        height = 8,
        type = "full"
    }
    data.raw["active-defense-equipment"]["arc-turret-equipment"].attack_parameters.ammo_type.action.action_delivery.max_length = 80
end

-- 反物质子弹
data.raw.recipe["rfw-antimatter-rounds-magazine"].result_count = 6

-- 蓄电池
data.raw.accumulator.accumulator.energy_source =
 {
   type = "electric",
   buffer_capacity = "50GJ",
   usage_priority = "tertiary",
   input_flow_limit = "3GW",
   output_flow_limit = "3GW"
 }


-- 爪子
data.raw.inserter["inserter"].rotation_speed = 1
data.raw.inserter["inserter"].extension_speed = 10
data.raw.inserter["inserter"].stack_size_bonus = 1
data.raw.inserter["fast-inserter"].rotation_speed = 1
data.raw.inserter["fast-inserter"].extension_speed = 10
data.raw.inserter["fast-inserter"].stack_size_bonus = 200
data.raw.inserter["filter-inserter"].rotation_speed = 1
data.raw.inserter["filter-inserter"].extension_speed = 10
data.raw.inserter["filter-inserter"].stack_size_bonus = 200

-- 实验室
data.raw.lab["lab"].researching_speed = 50
if data.raw.lab["quantum-lab"] then
    data.raw.lab["quantum-lab"].researching_speed = 100
    data.raw.lab["quantum-lab"].inputs[8] = data.raw.lab["lab"].inputs[7]
    data.raw.lab["lab"].inputs[7] = nil
end
data.raw.radar.radar.max_distance_of_nearby_sector_revealed = 8         -- 雷达


-- 电杆
data.raw["electric-pole"]["medium-electric-pole"].collision_box = {{-0, -0}, {0, 0}}
data.raw["electric-pole"]["medium-electric-pole"].maximum_wire_distance = 64
data.raw["electric-pole"]["medium-electric-pole"].supply_area_distance= 64



-- 无限科技消耗更改 
if data.raw.technology["ir-photon-turret-damage-4"] then
    data.raw.technology["ir-photon-turret-damage-4"].unit.count_formula = "(L-3)*20000"
end
data.raw.technology["follower-robot-count-7"].unit.count_formula = "2^(L-6)*1000"
data.raw.technology["physical-projectile-damage-7"].unit.count_formula = "(L-6)*20000"
data.raw.technology["energy-weapons-damage-7"].unit.count_formula = "(L-6)*20000"
data.raw.technology["worker-robots-speed-6"].unit.count_formula = "(L-5)*200000"
local effects = {
    {
        type = "ammo-damage",
        ammo_category = "bullet",
        modifier = 0.4
    },
    {
        type = "ammo-damage",
        ammo_category = "shotgun-shell",
        modifier = 0.4
    },
    {
        type = "ammo-damage",
        ammo_category = "cannon-shell",
        modifier = 1
    }
}
data.raw.technology["physical-projectile-damage-1"].effects = effects
data.raw.technology["physical-projectile-damage-2"].effects = effects
data.raw.technology["physical-projectile-damage-3"].effects = effects
data.raw.technology["physical-projectile-damage-4"].effects = effects
data.raw.technology["physical-projectile-damage-5"].effects = effects
data.raw.technology["physical-projectile-damage-6"].effects = effects
data.raw.technology["physical-projectile-damage-7"].effects = effects

data.raw["item"]["rocket-fuel"].stack_size = 200
data.raw["item"]["low-density-structure"].stack_size = 200
data.raw["item"]["rocket-control-unit"].stack_size = 200
data.raw["item"]["satellite"].stack_size = 10



local function weakness(type_name, i, count, ptype)
    local per = i
    if count > 0 then
        if ptype == 0 then
            per = 100 - 0.1*2^(count-i)
        else
            per = 95 - 5*(count-i)
        end
    end
    local per1 = per
    local per2 = per
    local per3 = per
    local per4 = per
    local per5 = per
    if (type_name == "physical") then per1 = (9 - count + i) * 1 end
    if (type_name == "explosion") then per2 = (9 - count + i) * 1 end
    if (type_name == "laser") then per3 = (9 - count + i) * 1 end
    if (type_name == "fire") then per5 = (9 - count + i) * 1 end
    if (type_name == "electric") then 
        per1 = per1*0.6
        per2 = per2*0.6
        per3 = per3*0.6
        per5 = per5*0.6
        per4 = (9 - count + i) * 1
    end
    return {
        {
            type = "physical",
            percent  = per1
        },
        {
            type = "explosion",
            percent  = per2
        },
        {
            type = "laser",
            percent  = per3
        },
        {
            type = "electric",
            percent  = per4
        },
        {
            type = "fire",
            percent  = per5
        }
    }
end

local function resistance(name, count, type_name)
    for i = 1,count do
        local name2 = name..i
        data.raw.unit[name2].resistances = weakness(type_name, i, count, 0)
    end
end

local function resistance2(name, count, type_name)
    for i = 1,count do
        local name2 = name..i
        data.raw.unit[name2].resistances = weakness(type_name, i, count, 1)
    end
end


data.raw.unit['tc_fake_human_ultimate_boss_cannon_20'].resistances = weakness('', 90, 0)

local fireOrelectric = 'electric'
if data.raw["electric-turret"]["photon-turret"] then
    fireOrelectric = 'fire'
end

resistance2('tc_fake_human_cluster_grenade_',10,'electric')
resistance2('tc_fake_human_cannon_',10,'electric')
resistance2('tc_fake_human_cannon_explosive_',10,'electric')
resistance2('tc_fake_human_machine_gunner_',10,'electric')
resistance2('tc_fake_human_melee_',10,'electric')
resistance2('tc_fake_human_pistol_gunner_',10,fireOrelectric)
resistance2('tc_fake_human_sniper_',10,fireOrelectric)
resistance2('tc_fake_human_laser_',10,'laser')
resistance2('tc_fake_human_electric_',10,'laser')
resistance2('tc_fake_human_erocket_',10,'explosion')
resistance2('tc_fake_human_rocket_',10,'explosion')
resistance2('tc_fake_human_grenade_',10,'physical')
resistance2('tc_fake_human_nuke_rocket_',10,'physical')


resistance('tc_fake_human_boss_machine_gunner_',10,'electric')
resistance('tc_fake_human_boss_pistol_gunner_',10,'electric')
resistance('tc_fake_human_boss_sniper_',10,'electric')
resistance('tc_fake_human_boss_laser_',10,'electric')
resistance('tc_fake_human_boss_electric_',10,'electric')
resistance('tc_fake_human_boss_erocket_',10,fireOrelectric)
resistance('tc_fake_human_boss_rocket_',10,fireOrelectric)
resistance('tc_fake_human_boss_grenade_',10,'laser')
resistance('tc_fake_human_boss_cluster_grenade_',10,'laser')
resistance('tc_fake_human_boss_cannon_explosive_',10,'explosion')
resistance('tc_fake_human_boss_nuke_rocket_',10,'explosion')
resistance('maf-boss-biter-',10,'physical')
resistance('maf-boss-acid-spitter-',10,'physical')


resistance('maf-giant-acid-spitter',5,'electric')
resistance('maf-giant-fire-spitter',5,'electric')
resistance('bm-motherbiterzilla',5,'electric')
resistance('biterzilla1',5,'electric')
resistance('biterzilla3',5,fireOrelectric)
resistance('biterzilla2',5,'laser')
resistance('maf-boss-biter-',5,'explosion')
resistance('maf-boss-acid-spitter-',5,'physical')
end

-- 火车修改
data.raw.locomotive.locomotive.max_speed = 5
data.raw.locomotive.locomotive.max_health = 10000
data.raw.locomotive.locomotive.max_power = "2MW"
data.raw.locomotive.locomotive.braking_force = 60       -- 制动
data.raw.locomotive.locomotive.friction_force = 0.01    -- 摩擦
data.raw.locomotive.locomotive.air_resistance = 0.001   -- 空气阻力
data.raw["cargo-wagon"]["cargo-wagon"].max_health = 6000
data.raw["cargo-wagon"]["cargo-wagon"].inventory_size = 160
data.raw["cargo-wagon"]["cargo-wagon"].max_speed = 5
data.raw["cargo-wagon"]["cargo-wagon"].friction_force = 0.01    -- 摩擦
data.raw["cargo-wagon"]["cargo-wagon"].air_resistance = 0.001   -- 空气阻力
data.raw["fluid-wagon"]["fluid-wagon"].max_health = 6000
data.raw["fluid-wagon"]["fluid-wagon"].capacity = 100000
data.raw["fluid-wagon"]["fluid-wagon"].max_speed = 5
data.raw["fluid-wagon"]["fluid-wagon"].friction_force = 0.01    -- 摩擦
data.raw["fluid-wagon"]["fluid-wagon"].air_resistance = 0.001   -- 空气阻力


-- 虚拟化操作
data:extend
{ 
    {
        type = "selection-tool",
        name = "virtual",
        icon = "__LinkedChest3__/graphics/icons/TokenBrandedVra.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"hidden", "not-stackable", "spawnable"},
        subgroup = "other",
        order = "e[automated-construction]-a[blueprint]",
        stack_size = 1,
        selection_color = { r = 0, g = 191, b = 255 },
        alt_selection_color = { r = 230, g = 230, b = 250 },
        selection_mode = {"blueprint"},
        alt_selection_mode = {"blueprint"},
        selection_cursor_box_type = "copy",
        alt_selection_cursor_box_type = "copy",
    },
    {
        type = "custom-input",
        name = "virtual",
        localised_name = "select-units",
        key_sequence = "SHIFT + F",
        consuming = "game-only",
        item_to_spawn = "virtual",
        action = "spawn-item"
    }
}