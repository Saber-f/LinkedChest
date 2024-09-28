data:extend({
    {
        type = "bool-setting",
        name = "isTongBu",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "virtual-lock",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "int-setting",
        name = "update-frequency",
        setting_type = "runtime-global",
        default_value = 60,
        minimum_value = 3,
        maximum_value = 360000
    },
    {
        type = "int-setting",
        name = "max-distance",
        setting_type = "runtime-global",
        default_value = 1000,
        minimum_value = 10,
        maximum_value = 100000
    },{
        type = "int-setting",
        name = "throw-speed",
        setting_type = "runtime-global",
        default_value = 50,
        minimum_value = 1,
        maximum_value = 1000
    },{
        type = "int-setting",
        name = "throw-speed-a",
        setting_type = "runtime-global",
        default_value = 5,
        minimum_value = 0,
        maximum_value = 200
    },{
        type = "int-setting",
        name = "pull_speed_per_tick",
        setting_type = "runtime-global",
        default_value = 2,
        minimum_value = 1,
        maximum_value = 1000
    },{
        type = "int-setting",
        name = "length_v",
        setting_type = "runtime-global",
        default_value = 10,
        minimum_value = 0,
        maximum_value = 1000
    },{
        type = "bool-setting",
        name = "wudi",
        setting_type = "runtime-global",
        default_value = false
    },{
        type = "int-setting",
        name = "update-num",            -- 每帧更新数量
        setting_type = "runtime-global",
        default_value = 50,
        minimum_value = 1,
        maximum_value = 10000000000
    },{
        type = "int-setting",
        name = "row_num",            -- 多少行触发缓存
        setting_type = "runtime-global",
        default_value = 3,
        minimum_value = 1,
        maximum_value = 10000000000
    },{
        type = "int-setting",
        name = "linkSize",            -- 每帧更新数量
        setting_type = "startup",
        default_value = 120,
        minimum_value = 1,
        maximum_value = 100000
    },{
        type = "int-setting",
        name = "shuaijian",            -- 衰减
        setting_type = "runtime-global",
        default_value = 10000,
        minimum_value = 1,
        maximum_value = 100000
    },{ -- 上帝插件研究
    type = "int-setting",
    name = "god-research",
    setting_type = "startup",
    default_value = 100000,
    minimum_value = 1,
    maximum_value = 100000000,
    order = "p"
    },
    {  -- 超快爪子
        type = "bool-setting",
        name = "fast-claw",
        setting_type = "startup",
        default_value = true,
    }
})