local data_util = require("data_util")

data:extend({
  {
    type = "recipe",
    name = data_util.mod_prefix .. "grappling-gun",
    results = {{type="item", name=data_util.mod_prefix .. "grappling-gun", amount=1}},
    enabled = true,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "copper-plate", amount = 1}
    },
    requester_paste_multiplier = 1,
  },
  {
    type = "recipe",
    name = data_util.mod_prefix .. "grappling-gun-ammo",
    results = {{type="item", name=data_util.mod_prefix .. "grappling-gun-ammo", amount=1}},
    enabled = true,
    energy_required = 0.5,
    ingredients = {
      {type = "item", name = "copper-plate", amount = 1}
    },
    requester_paste_multiplier = 10,
  },
})
