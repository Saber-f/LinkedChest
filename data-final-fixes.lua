data.raw["recipe"]["red-wire"].enabled = true
data.raw["recipe"]["red-wire"].ingredients = {{"copper-plate", 1}}

data.raw["recipe"]["empty-barrel"].ingredients = {{"copper-plate", 1}}

local OemLinkedChest = util.table.deepcopy(data.raw["linked-container"]["linked-chest"])
OemLinkedChest.gui_mode = "all" -- all, none, adminss



--[[Technology]]--
data:extend({
    {-- 上帝插件科技
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
        --   {"automation-science-pack", 1},
        --   {"logistic-science-pack", 1},
        --   {"chemical-science-pack", 1},
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
                    }
                }
            }
        }
    }
}


-- 炮塔修正
data.raw["ammo-turret"]["gun-turret"].attack_parameters.cooldown = 30
data.raw["ammo-turret"]["gun-turret"].attack_parameters.range = 120
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
  range = 130,
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
        max_length = 130,
        duration = 30,
        source_offset = {0, -1.31439 }
      }
    }
  }
}
data.raw["electric-turret"]["laser-turret"].collision_box = {{ -1.7, -1.7}, {1.7, 1.7}}
data.raw["electric-turret"]["laser-turret"].selection_box = {{ -2, -2}, {2, 2}}

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
data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].attack_parameters.range = 100
data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].attack_parameters.damage_modifier = 2000
data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].attack_parameters.ammo_type.action.action_delivery.max_length = 80
data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].shape = {
  width = 1,
  height = 8,
  type = "full"
}

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
data.raw.radar.radar.max_distance_of_nearby_sector_revealed = 8

-- 无线科技消耗更改
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