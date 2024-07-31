---@meta game

---Factorio 游戏对象
game = {}

---@param message string
game.print = function(message) end

---@type table<string, LuaPlayer>
game.players = {}


---@type table<string, LuaForce>
game.forces = {}

---@type number
game.tick = 0
