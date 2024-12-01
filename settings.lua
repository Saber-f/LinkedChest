data:extend({
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
        name = "linkSize",            -- 关联箱容量
        setting_type = "startup",
        default_value = 120,
        minimum_value = 1,
        maximum_value = 100000
    },{
        type = "int-setting",
        name = "shuaijian",            -- 飞行衰减
        setting_type = "runtime-global",
        default_value = 10000,
        minimum_value = 1,
        maximum_value = 100000
    },{  -- 跨图层关联箱每帧检测数量
        type = "int-setting",
        name = "checkCount",
        setting_type = "runtime-global",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 100000
    },{ -- 是否允许蓝图
        type = "bool-setting",
        name = "canBluePrint",
        setting_type = "runtime-global",
        default_value = true
    }
})