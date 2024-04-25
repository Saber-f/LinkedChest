-- data

data.raw["item"]["empty-barrel"].stack_size = 200

local OemLinkedChest = util.table.deepcopy(data.raw["linked-container"]["linked-chest"])
OemLinkedChest.name = "Oem-linked-chest"
OemLinkedChest.minable.result = "Oem-linked-chest"
OemLinkedChest.inventory_size = settings.startup["linkSize"].value
OemLinkedChest.gui_mode = "all" -- all, none, adminss

-- 连接信号线
OemLinkedChest.circuit_wire_connection_point = circuit_connector_definitions["chest"].points
OemLinkedChest.circuit_connector_sprites = circuit_connector_definitions["chest"].sprites
OemLinkedChest.circuit_wire_max_distance = default_circuit_wire_max_distance


data:extend({
  OemLinkedChest,
  {
    type = "item",
    name = "Oem-linked-chest",
    icon = "__LinkedChest3__/graphics/icons/linked-chest-icon.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "storage",
    order = "a[items]-a[Oem-linked-chest]",
    place_result = "Oem-linked-chest",
    stack_size = 100
  },
  {
    type = "recipe",
    name = "Oem-linked-chest",
    enabled = true,
    ingredients =
    {
      {"copper-plate", 1},
    },
    result = "Oem-linked-chest"
  },
})

--table.insert(data.raw["technology"]["automation"].effects, { type = "unlock-recipe", recipe = "Oem-linked-chest" } )
require("prototypes/entity/weapon-grappling")
require("prototypes/item/weapon-grappling")
require("prototypes/recipe/weapon-grappling")
require("prototypes/technology/weapon-grappling")

local LinkedChestCount = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
LinkedChestCount.name = "LinkedChestCount"
LinkedChestCount.minable.result = "LinkedChestCount"

data:extend({
  LinkedChestCount,
  {
    type = "item",
    name = "LinkedChestCount",
    icon = "__base__/graphics/icons/constant-combinator.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "circuit-network",
    place_result="LinkedChestCount",
    order = "a[combinators]-a[LinkedChestCount]",
    stack_size= 50
  },
  {
    type = "recipe",
    name = "LinkedChestCount",
    enabled = false,
    ingredients =
    {
      {"copper-plate", 1},
    },
    result = "LinkedChestCount"
  },
})

-- 新的库存输出

-- local LinkedChestCombinator = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
-- LinkedChestCombinator.name = "LinkedChestCombinator"
-- LinkedChestCombinator.minable.result = "LinkedChestCombinator"


-- data:extend({
-- 	 LinkedChestCombinator,
--   {
--     type = "item",
--     name = "LinkedChestCombinator",
--     icon = "__base__/graphics/icons/constant-Combinator.png",
--     icon_size = 64, icon_mipmaps = 4,
--     subgroup = "circuit-network",
--     place_result="LinkedChestCombinator",
--     order = "a[Combinators]-a[LinkedChestCombinator]",
--     stack_size= 50
--   },
--    {
--     type = "recipe",
--     name = "LinkedChestCombinator",
--     enabled = false,
--     ingredients =
--     {
--       {"copper-plate", 1},
--     },
--     result = "LinkedChestCombinator"
--   },

-- })