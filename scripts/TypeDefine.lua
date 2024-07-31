-- 类型说明文件


--- Called after a player selects an area with a selection-tool item.
--- https://lua-api.factorio.com/latest/events.html#on_player_selected_area
--- @class on_player_selected_area
--- @field player_index uint The player doing the selection.
--- @field surface LuaSurface The surface selected.
--- @field area BoundingBox The area selected.
--- @field item string The item used to select the area.
--- @field entities array[LuaEntity] The entities selected.
--- @field tiles array[LuaTile] The tiles selected.
--- @field name defines.events Identifier of the event
--- @field tick uint Tick the event was generated.

--- Called when LuaGuiElement is clicked.
--- https://lua-api.factorio.com/latest/events.html#on_gui_click
--- @class on_gui_click
--- @field element LuaGuiElement The clicked element.
--- @field player_index uint The player who did the clicking.
--- @field button defines.mouse_button_type The mouse button used if any.
--- @field cursor_display_location GuiLocation The display location of the player's cursor.
--- @field alt boolean If alt was pressed.
--- @field control boolean If control was pressed.
--- @field shift boolean If shift was pressed.
--- @field name defines.events Identifier of the event.
--- @field tick uint Tick the event was generated.

--- A player in the game. Pay attention that a player may or may not have a character, which is the LuaEntity of the little guy running around the world doing things.
--- https://lua-api.factorio.com/latest/classes/LuaPlayer.html
--- @class LuaPlayer
--- @field name string The name of the player.
--- @field force LuaForce The force of the player.
--- @field print(string) void Prints the given string to the chat of every player in the force.

--- LuaForce encapsulates data local to each "force" or "faction" of the game. Default forces are player, enemy and neutral. Players and mods can create additional forces (up to 64 total).
--- https://lua-api.factorio.com/latest/classes/LuaForce.html
--- @class LuaForce
--- @field name string The name of the force.
--- @field print(string) void Prints the given string to the chat of every player in the force.
--- @field technologies table[string, LuaTechnology] A table of technologies indexed by their name.
--- @field current_research LuaTechnology The technology currently being researched by the force.

--- LuaTechnology encapsulates data about a technology in the game.
--- https://lua-api.factorio.com/latest/classes/LuaTechnology.html
--- @class LuaTechnology
--- @field name string The name of the technology.
--- @field research_unit_ingredients table[Ingredient] A table of the ingredients required to research the technology, indexed by the name of the item.
--- @field research_unit_energy number Amount of energy required to finish a unit of research.