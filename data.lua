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
    results = {{type="item", name="Oem-linked-chest", amount=10}}
  }
})

if not settings.startup["disableGrapplingHook"].value then
  require("prototypes/entity/weapon-grappling")
  require("prototypes/item/weapon-grappling")
  require("prototypes/recipe/weapon-grappling")
end
