local data_util = require("data_util")

data:extend({
  {
    type = "simple-entity",
    name = data_util.mod_prefix .. "grappling-gun-player-collision",
    animations = {
      {
        direction_count = 1,
        filename = "__LinkedChest3__/graphics/blank.png",
        frame_count = 1,
        height = 1,
        line_length = 1,
        width = 1
      }
    },
    flags = {
      "not-on-map"
    },
    collision_mask = {
      layers = {player=true, item=true}
    },
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
  },
  {
    type = "explosion",
    name = data_util.mod_prefix .. "grappling-gun-trigger",
    animations = {
      {
        direction_count = 1,
        filename = "__LinkedChest3__/graphics/blank.png",
        frame_count = 1,
        height = 1,
        line_length = 1,
        width = 1
      }
    },
    flags = {
      "not-on-map"
    },
  },
  {
    type = "projectile",
    name = data_util.mod_prefix .. "grappling-gun-projectile",
    acceleration = 0,
    animation = {
      filename = "__LinkedChest3__/graphics/entity/grappling-gun/grapple-head.png",
      width = 58,
      frame_count = 1,
      height = 32,
      line_length = 1,
      priority = "high",
      shift = { 0, 0 },
      scale = 0.5
    },
    flags = {
      "not-on-map", "placeable-off-grid"
    },
  },
})
