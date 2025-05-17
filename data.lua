-- data

data.raw["item"]["barrel"].stack_size = 200

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
      {type="item", name ="copper-plate", amount = 1},
    },
    results = {{type="item", name="Oem-linked-chest", amount=1}}
  },
  {
    type = "recipe",
    name = "jellynut-seed-recipe",
    icon = "__space-age__/graphics/icons/jellynut-seed.png",
    enabled = true,
    energy_required = 300,
    ingredients =
    {
      {type="item", name ="stone", amount = 1000},
    },
    results = {{type="item", name="jellynut-seed", amount=1}}
  },
  {
    type = "recipe",
    name = "yumako-seed-recipe",
    icon = "__space-age__/graphics/icons/yumako-seed.png",
    enabled = true,
    energy_required = 300,
    ingredients =
    {
      {type="item", name ="stone", amount = 1000},
    },
    results = {{type="item", name="yumako-seed", amount=1}}
  },
  {
    type = "recipe",
    name = "tree-seed-recipe",
    icon = "__space-age__/graphics/icons/tree-seed.png",
    enabled = true,
    energy_required = 300,
    ingredients =
    {
      {type="item", name ="stone", amount = 1000},
    },
    results = {{type="item", name="tree-seed", amount=1}}
  },
  {
    type = "recipe",
    name = "pentapod-egg-recipe",
    enabled = true,
    energy_required = 60,
    ingredients =
    {
      {type="item", name ="stone", amount = 500},
    },
    results = {
      {type="item", name="pentapod-egg", amount=1},
    }
  },
  {
    type = "item",
    name = "biter-spwaner",
    icon = "__base__/graphics/icons/biter-spawner.png",
    subgroup = "storage",
    order = "a[items]-a[Oem-linked-chest]",
    place_result = "biter-spawner",
    stack_size = 10
  },
  {
    type = "recipe",
    name = "spwaner-recipe",
    enabled = true,
    group = "storage",
    energy_required = 60,
    ingredients =
    {
      {type="item", name ="stone", amount = 500},
    },
    results = {
      {type="item", name="biter-spwaner", amount=1},
    }
  }
})


if not settings.startup["disableGrapplingHook"].value then
  require("prototypes/entity/weapon-grappling")
  require("prototypes/item/weapon-grappling")
  require("prototypes/recipe/weapon-grappling")
end
