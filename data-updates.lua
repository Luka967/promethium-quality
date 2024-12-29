local utility = require("utility")
local refining_recipes = require("refining-graph")

--- @type RefiningGraph
local g = {
    item_resolve_stack = {},
    items_resolved = {},
    recipes_skipped = {},
    recipes_visited = {}
}

print("Mod list: "..serpent.block(mods))
log("Grabbing preset refine props")

-- Predefined complexity goes first
local function grab_refine_props(type_name)
    if data.raw[type_name] == nil
        then return end
    for _, item_prototype in pairs(data.raw[type_name]) do
        if item_prototype.auto_refine ~= nil or item_prototype.refine_complexity ~= nil then
            refining_recipes.memoize_item(g, item_prototype.name)
        end
    end
end
for type_name in pairs(defines.prototypes["item"]) do
    grab_refine_props(type_name)
end

log("Setting complexity from supported obtainables")

-- Assign base complexity to items that can come from these prototypes:
for _, resource in pairs(data.raw["resource"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 0.5) -- 1s -> 0.5 complexity
end
for _, resource in pairs(data.raw["fish"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 7500) -- 0.4s for 5x raw fish -> 600 complexity
end
for _, resource in pairs(data.raw["unit"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 1125) -- Bogus multiplier, support for Maraxsis
end
for _, resource in pairs(data.raw["asteroid-chunk"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 25) -- Default 2 complexity for modded asteroid chunks
end
for _, resource in pairs(data.raw["plant"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 200) -- 0.5s for 50x fruit -> 2 complexity
end

log("Setting complexity to science packs")

-- Assign default 5 second refining time to new science packs
for _, item in pairs(data.raw["tool"]) do
    item.refine_complexity = item.refine_complexity or utility.refine_time(5)
end

log("Setting complexity from generator recipes")

-- Recipes that generate products out of thin air
-- such as egg breeding in captive spawner, 10s for 5 -> 600 complexity
for _, recipe in pairs(data.raw["recipe"]) do
    local has_no_ingredients = recipe.ingredients == nil or #recipe.ingredients == 0
    if has_no_ingredients and recipe.energy_required ~= nil then
        refining_recipes.set_complexity_from_recipe(g, recipe, 300)
    end
end

log("Setting complexity from smelting recipes")

-- Vanilla ore 0.5 -> plate 1 complexity
for _, recipe in pairs(data.raw["recipe"]) do
    if recipe.category == "smelting" and recipe.ingredients ~= nil and #recipe.ingredients == 1 then
        local multiplier = 1 / 3.2

        -- Has the ingredient already been given complexity?
        local ingredient_1 = recipe.ingredients[1]
        if ingredient_1.type == "item" and g.items_resolved[ingredient_1.name] ~= nil then
            multiplier = multiplier * g.items_resolved[ingredient_1.name].complexity
        end

        refining_recipes.set_complexity_from_recipe(g, recipe, multiplier)
    end
end

log("Autocalculating complexity for other items")

-- Let it rip!
for _, recipe in pairs(data.raw["recipe"]) do
    if recipe.results ~= nil then
        for i = 1, #recipe.results do
            refining_recipes.memoize_item(g, recipe.results[i].name)
        end
    end
end

log("Generating refining recipes")

for item_name in pairs(g.items_resolved) do
    refining_recipes.create_refining_recipe(g, item_name)
end

log("Done")
