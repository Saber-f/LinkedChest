
Event = require('scripts/event')



local function player_selected_area(event)
    if event.item ~= "virtual" then return end
    for _, entity in pairs(event.entities) do

        if entity.type == "" then
            local recipe = entity.get_recipe()
            game.print("recipe: " .. recipe.name)
            for _, ingredient in pairs(recipe.ingredients) do
                game.print("ingredient: " .. ingredient.name)
            end
            for k, product in pairs(recipe.products) do
                game.print("product: "..k)
                for k, v in pairs(product) do
                    game.print(k .. ": " .. v)
                end
            end
        end
    end
end



local function player_alt_selected_area(event)
    if event.item ~= "virtual" then return end
end


Event.addListener(defines.events.on_player_selected_area, player_selected_area)
Event.addListener(defines.events.on_player_alt_selected_area, player_alt_selected_area)