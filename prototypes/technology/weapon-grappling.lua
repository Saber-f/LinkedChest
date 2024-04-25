local data_util = require("data_util")

data:extend({
  {
    type = "technology",
    name = data_util.mod_prefix .. "grappling-gun",
    effects = {
     { type = "unlock-recipe",  recipe = data_util.mod_prefix .. "grappling-gun" },
     { type = "unlock-recipe",  recipe = data_util.mod_prefix .. "grappling-gun-ammo" },
    },
    icon = "__LinkedChest3__/graphics/technology/grappling-gun.png",
    icon_size = 128,
    order = "e-g",
    prerequisites = {
      "steel-processing",
    },
    unit = {
     count = 100,
     time = 10,
     ingredients = {
       { "automation-science-pack", 1 },
     }
    },
  },
})
