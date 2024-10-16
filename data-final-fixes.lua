data.raw["recipe"]["red-wire"].enabled = true
data.raw["recipe"]["red-wire"].ingredients = {{"copper-plate", 1}}

data.raw["recipe"]["empty-barrel"].ingredients = {{"copper-plate", 1}}

local OemLinkedChest = util.table.deepcopy(data.raw["linked-container"]["linked-chest"])
OemLinkedChest.gui_mode = "all" -- all, none, adminss


data:extend({
    {   -- 虚拟化技术
        type = "technology",
        name = "virtual",
        icon = "__LinkedChest3__/graphics/icons/TokenBrandedVra.png",
        icon_size = 128,
        effects =
        {
        },
        prerequisites = {},
        unit =
        {
        count = settings.startup["vitual-research"].value,
        ingredients =
        {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1},
        },
        time = 120
        },
        upgrade = true,
        order = "i-g-f"
    }
})


------------------------------------------------------- 真实聚变修改 -------------------------------------------------------
-- 真实聚变
if mods["RealisticFusionPower"]then
    -- 更改插件孔
    if data.raw["furnace"] then
        data.raw["furnace"]["electric-furnace"].module_specification = {module_slots = 3} -- 电炉
    end

    -- 反物质处理器速度
    data.raw["assembling-machine"]["rfp-antimatter-processor"].crafting_speed = 20

    -- 气体混合仪
    data.raw["assembling-machine"]["rfp-gas-mixer"].crafting_speed = 20
end


------------------------------------------------------- 上帝插件修改 -------------------------------------------------------
-- 有上帝插件和真实聚变
if mods["Advanced_Sky_Modules"] and mods["RealisticFusionPower"]then

    -- 上帝插件
    data.raw.module["pure-productivity-module-6"].category = "productivity"
    data.raw.module["pure-productivity-module-6"].tier = 3
    data.raw.module["pure-speed-module-6"].category = "productivity"
    data.raw.module["pure-speed-module-6"].tier = 3
    data.raw.module["god-module"].category = "productivity"
    data.raw.module["god-module"].tier = 4

    data:extend({
        {   -- 虚拟化技术
            type = "technology",
            name = "virtual",
            icon = "__LinkedChest3__/graphics/icons/TokenBrandedVra.png",
            icon_size = 128,
            effects =
            {
            },
            prerequisites = {"rfp-antimatter-reactor"},
            unit =
            {
            count = settings.startup["vitual-research"].value,
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
            prerequisites = {"virtual"},
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
        },{-- 白瓶配方
            type = "recipe",
            name = "space-science-pack",    -- 白瓶
            enabled = true,
            energy_required = 10,
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

    -- 反物质发电科技
    data.raw.technology["rfp-antimatter-reactor"].prerequisites = {"rfp-particle-deceleration-efficiency-3", "rfp-particle-acceleration-efficiency-3"}

    -- 氢气
    data.raw.recipe["rfp-water-electrolysis"].ingredients = {{type = "fluid", name = "water", amount = 2000}}
    data.raw.recipe["rfp-water-electrolysis"].results = {{type = "fluid", name = rfp_fluids["hydrogen"], amount = 100}}

    -- 氢电离
    data.raw.recipe["rfp-hydrogen-ionization"].energy_required = 37
    data.raw.recipe["rfp-hydrogen-ionization"].ingredients = {{type = "fluid", name = rfp_fluids["hydrogen"], amount = 100}}
    data.raw.recipe["rfp-hydrogen-ionization"].results = {{type = "fluid", name = rfp_fluids["electrons"], amount = 100}, {type = "fluid", name = rfp_fluids["protons"], amount = 100}}

    -- 重水
    data.raw.recipe["rfp-water-purification"].energy_required = 1
    data.raw.recipe["rfp-water-purification"].ingredients = {{type = "fluid", name = "water", amount = 2000}}
    data.raw.recipe["rfp-water-purification"].results = {{type = "fluid", name = rfp_fluids["heavy-water"], amount = 1500}}

    -- 氘
    data.raw.recipe["rfp-electrolysis"].ingredients = {{type = "fluid", name = rfp_fluids["heavy-water"], amount = 1500}}
    data.raw.recipe["rfp-electrolysis"].results = {{type = "fluid", name = rfp_fluids["deuterium"], amount = 800}}

    -- 氘等离子
    data.raw.recipe["rfp-d-d-heating-0"].ingredients = {{type = "fluid", name = rfp_fluids["deuterium"], amount = 200}}
    data.raw.recipe["rfp-d-d-heating-0"].results = {{type = "fluid", name = rfp_fluids["d-d-plasma"], amount = 200}}

    -- 氚-He3
    data.raw.recipe["rfp-d-d-fusion-0-0"].ingredients = {{type = "fluid", name = rfp_fluids["d-d-plasma"], amount = 400}}
    data.raw.recipe["rfp-d-d-fusion-0-0"].results = {{type = "fluid", name = rfp_fluids["reactor-energy-mj"], amount = 0},{type = "fluid", name = rfp_fluids["helium-3"], amount = 200}, {type = "fluid", name = rfp_fluids["tritium"], amount = 200}}

    -- 氚->He3
    data.raw.recipe["rfp-tritium-decay"].energy_required = 0.5

    -- 氢->正负电子
    data.raw.recipe["rfp-hydrogen-ionization"].energy_required = 1

    -- 氘He3混合气体
    data.raw.recipe["rfp-d-he3-mixing"].ingredients = {{type = "fluid", name = rfp_fluids["deuterium"], amount = 10}, {type = "fluid", name = rfp_fluids["helium-3"], amount = 10}}
    data.raw.recipe["rfp-d-he3-mixing"].results = {{type = "fluid", name = rfp_fluids["d-he3-mix"], amount = 10}}

    -- 聚变子弹
    data.raw.recipe["rfw-fusion-rounds-magazine"].energy_required = 1
    data.raw.recipe["rfw-fusion-rounds-magazine"].ingredients = {{"battery", 20}, {"advanced-circuit", 20}, {"low-density-structure", 20}, {"piercing-rounds-magazine", 20}, {type = "fluid", name = rfp_fluids["d-he3-mix"], amount = 10}}
    data.raw.recipe["rfw-fusion-rounds-magazine"].results = {{"rfw-fusion-rounds-magazine", 20}}

    -- 氘-He3混合气体
    data.raw.recipe["rfp-d-he3-heating-0"].ingredients = {{type = "fluid", name = rfp_fluids["deuterium"], amount = 10}, {type = "fluid", name = rfp_fluids["helium-3"], amount = 10}}
    data.raw.recipe["rfp-d-he3-heating-0"].results = {{type = "fluid", name = rfp_fluids["d-he3-mix"], amount = 10}}

    -- 氘-He3等离子体
    data.raw.recipe["rfp-d-he3-heating-0"].energy_required = 0.5
    data.raw.recipe["rfp-d-he3-heating-0"].ingredients = {{type = "fluid", name = rfp_fluids["d-he3-mix"], amount = 100}}
    data.raw.recipe["rfp-d-he3-heating-0"].results = {{type = "fluid", name = rfp_fluids["d-he3-plasma"], amount = 100}}
end


------------------------------------------------------- 战斗相关修改 -------------------------------------------------------
-- 有大怪兽和聚变武器
if mods["Big-Monsters"] and mods["RealisticFusionWeaponry"] then
    local function change_range(name)
        local attack_parameters = data.raw.unit[name].attack_parameters
        local range = attack_parameters.range
        if range >= 60 then
            range = 30
        elseif range >= 30 then
            range = range/2
        end

        attack_parameters.range = range
    end


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
        if (type_name == "physical") then per1 = per*0.1 end
        if (type_name == "explosion") then per2 = per*0.1 end
        if (type_name == "laser") then per3 = per*0.1 end
        if (type_name == "fire") then per5 = per*0.1 end
        if (type_name == "electric") then 
            per1 = per*0.5
            per2 = per*0.5
            per3 = per*0.5
            per5 = per*0.5
            per4 = per*0.1
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
            change_range(name2)
        end
    end
    
    local function resistance2(name, count, type_name)
        for i = 1,count do
            local name2 = name..i
            data.raw.unit[name2].resistances = weakness(type_name, i, count, 1)
            change_range(name2)
        end
    end
    
    local name2 = 'tc_fake_human_ultimate_boss_cannon_20'
    data.raw.unit[name2].resistances = weakness('', 90, 0)
    change_range(name2)
    
    local fireOrelectric = 'laser'
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
                            damage = { amount = 30 , type = "physical"}
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
                        },
                        {
                        type = "damage",
                        damage = {amount = 100, type = "explosion"}
                        },
                    }
                }
            }
        }
    }


    -- 炮塔修正
    data.raw["ammo-turret"]["gun-turret"].max_health = 10000
    data.raw["ammo-turret"]["gun-turret"].prepare_range = 64
    data.raw["ammo-turret"]["gun-turret"].range = 60
    data.raw["ammo-turret"]["gun-turret"].attack_parameters = {
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
        range = 60,
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

    data.raw["electric-turret"]["laser-turret"].max_health = 40000
    data.raw["electric-turret"]["laser-turret"].prepare_range = 64
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
    
    -- 增加{type="fluid", name=rfp_fluids["antihydrogen"], amount=1},
    
    data.raw["recipe"]["laser-turret"].category = rfp_categories["antimatter-processing"]
    data.raw["recipe"]["laser-turret"].ingredients[#(data.raw["recipe"]["laser-turret"].ingredients)+1] = {type="fluid", name=rfp_fluids["antihydrogen"], amount=1}
    
    data.raw["electric-turret"]["laser-turret"].attack_parameters = {
        type = "beam",
        cooldown = 40,
        range = 60,
        source_direction_count = 64,
        source_offset = {0, -3.423489 / 4},
        damage_modifier = 1000,
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
            max_length = 60,
            duration = 30,
            source_offset = {0, -1.31439 }
        }
        }
        }
    }

    -- 聚变武器制造机器更改
    data.raw.recipe["rfw-fusion-rounds-magazine"].category = rfp_categories["gas-mixing"]     -- 聚变子弹
    data.raw.recipe["rfw-fusion-cannon-shell"].category = rfp_categories["gas-mixing"]     -- 聚变加农
    data.raw.recipe["rfw-small-fusion-rocket"].category = rfp_categories["gas-mixing"]     -- 聚变小火箭
    data.raw.recipe["rfw-fusion-bomb"].category = rfp_categories["gas-mixing"]     -- 聚变火箭


    -- 个人模块修改
    data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].attack_parameters.range = 60
    data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].attack_parameters.damage_modifier = 200
    data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].attack_parameters.ammo_type.action.action_delivery.max_length = 80
    data.raw["active-defense-equipment"]["personal-laser-defense-equipment"].shape = {
    width = 1,
    height = 8,
    type = "full"
    }


    -- 反物质子弹
    data.raw.recipe["rfw-antimatter-rounds-magazine"].result_count = 6

    data:extend({
        { -- 聚变子弹
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
                                damage = {amount = 1000, type = "physical"}
                            },
                            {
                                type = "damage",
                                damage = {amount = 1000, type = "explosion"}
                            },
                            {
                                type = "damage",
                                damage = {amount = 1000, type = "laser"}
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
                    damage = {amount = 10000, type = "physical"}
                    },
                    {
                    type = "damage",
                    damage = {amount = 10000, type = "explosion"}
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
        },
    })
end


------------------------------------------------------- 原版修改 -------------------------------------------------------

-- 爪子
if settings.startup["fast-claw"].value then
    data.raw.inserter["burner-inserter"].rotation_speed = 1
    data.raw.inserter["burner-inserter"].extension_speed = 5
    data.raw.inserter["burner-inserter"].stack_size_bonus = 1
    data.raw.inserter["inserter"].rotation_speed = 1
    data.raw.inserter["inserter"].extension_speed = 10
    data.raw.inserter["inserter"].stack_size_bonus = 1
    data.raw.inserter["fast-inserter"].rotation_speed = 1
    data.raw.inserter["fast-inserter"].extension_speed = 10
    data.raw.inserter["fast-inserter"].stack_size_bonus = 50
    data.raw.inserter["filter-inserter"].rotation_speed = 1
    data.raw.inserter["filter-inserter"].extension_speed = 10
    data.raw.inserter["filter-inserter"].stack_size_bonus = 50
    data.raw.inserter["stack-inserter"].rotation_speed = 1
    data.raw.inserter["stack-inserter"].extension_speed = 10
    data.raw.inserter["stack-inserter"].stack_size_bonus = 100
    data.raw.inserter["stack-filter-inserter"].rotation_speed = 1
    data.raw.inserter["stack-filter-inserter"].extension_speed = 10
    data.raw.inserter["stack-filter-inserter"].stack_size_bonus = 100
end

-- 实验室
data.raw.lab["lab"].researching_speed = 50
if data.raw.lab["quantum-lab"] then
    data.raw.lab["quantum-lab"].researching_speed = 100
    data.raw.lab["quantum-lab"].inputs[8] = data.raw.lab["lab"].inputs[7]
    data.raw.lab["lab"].inputs[7] = nil
end
data.raw["lab"]["lab"].module_specification = {module_slots = 3} -- 实验室
data.raw.radar.radar.max_distance_of_nearby_sector_revealed = 8         -- 雷达


-- 电杆
data.raw["electric-pole"]["medium-electric-pole"].collision_box = {{-0, -0}, {0, 0}}
data.raw["electric-pole"]["medium-electric-pole"].maximum_wire_distance = 64
data.raw["electric-pole"]["medium-electric-pole"].supply_area_distance= 64



-- 无限科技消耗更改 
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

-- 堆叠修改
data.raw["item"]["rocket-fuel"].stack_size = 200
data.raw["item"]["low-density-structure"].stack_size = 200
data.raw["item"]["rocket-control-unit"].stack_size = 200
data.raw["item"]["satellite"].stack_size = 10


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


-- 蓄电池
data.raw.accumulator.accumulator.energy_source =
{
    type = "electric",
    buffer_capacity = "100TJ",
    usage_priority = "tertiary",
    input_flow_limit = "10TW",
    output_flow_limit = "10TW"
}

-- 虚拟化操作
data:extend
{ 
    {
        type = "selection-tool",
        name = "virtual",
        icon = "__LinkedChest3__/graphics/icons/TokenBrandedVra.png",
        icon_size = 128,
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
    },
    {
        type = "selection-tool",
        name = "showvirtual",
        icon = "__LinkedChest3__/graphics/icons/TokenBrandedVra.png",
        icon_size = 128,
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
        name = "showvirtual",
        localised_name = "select-units",
        key_sequence = "ALT + F",
        consuming = "game-only",
        item_to_spawn = "showvirtual",
        action = "spawn-item"
    }
}