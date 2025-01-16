local utility = require("utility")
local refining_recipes = require("refining-graph")

--- @type RefiningGraph
local g = {
    item_resolve_stack = {},
    items_resolved = {},
    recipes_skipped = {},
    recipes_visited = {}
}

utility.print_if_debug("[#1] Mod list:\n"..serpent.block(mods))

utility.print_if_debug("[#2] Autosetting complexity to science packs")

-- Assign default 5 second refining time to new science packs
for _, item in pairs(data.raw["tool"]) do
    if item.refine_complexity == nil then
        utility.print_if_debug("Triggered for "..item.name)
        item.refine_complexity = utility.refine_time(5)
    end
end

utility.print_if_debug("[#3] Grabbing preset refine props")

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

utility.print_if_debug("[#4] Autosetting complexity from supported obtainables")

-- Assign base complexity to items that can come from these prototypes:
for _, resource in pairs(data.raw["resource"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 0.5) -- 1s -> 0.5 complexity
    utility.print_if_debug("Triggered for resource "..resource.name)
end
for _, resource in pairs(data.raw["fish"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 7500) -- 0.4s for 5x raw fish -> 600 complexity
    utility.print_if_debug("Triggered for fish "..resource.name)
end
for _, resource in pairs(data.raw["unit"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 1125) -- Bogus multiplier, support for Maraxsis
    utility.print_if_debug("Triggered for unit "..resource.name)
end
for _, resource in pairs(data.raw["asteroid-chunk"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 25) -- Default 2 complexity for modded asteroid chunks
    utility.print_if_debug("Triggered for asteroid-chunk "..resource.name)
end
for _, resource in pairs(data.raw["plant"]) do
    refining_recipes.set_complexity_from_minable(g, resource.name, resource.minable, 200) -- 0.5s for 50x fruit -> 2 complexity
    utility.print_if_debug("Triggered for plant "..resource.name)
end

utility.print_if_debug("[#5] Autosetting complexity from generator recipes")

-- Recipes that generate products out of thin air
-- such as egg breeding in captive spawner, 10s for 5 -> 600 complexity
for _, recipe in pairs(data.raw["recipe"]) do
    local has_no_ingredients = recipe.ingredients == nil or #recipe.ingredients == 0
    local has_results = recipe.results ~= nil and #recipe.results > 0
    if has_no_ingredients and has_results and recipe.energy_required ~= nil then
        refining_recipes.set_complexity_from_recipe(g, recipe, 300)
    end
end

utility.print_if_debug("[#6] Autosetting complexity from smelting recipes")

-- Vanilla ore 0.5 -> plate 1 complexity
for _, recipe in pairs(data.raw["recipe"]) do
    if
        utility.recipe_has_basics(recipe)
        and recipe.category == "smelting"
        and #utility.recipe_ingredients(recipe, "item") == 1
        and #utility.recipe_ingredients(recipe, "fluid") == 0
    then
        local multiplier = 2 * (1 / 3.2)

        -- Has the ingredient already been given complexity?
        local ingredient = recipe.ingredients[1]
        local item_graphed = g.items_resolved[ingredient.name]
        if ingredient.type == "item" and item_graphed ~= nil and item_graphed.complexity ~= nil then
            multiplier = multiplier * item_graphed.complexity
        end

        refining_recipes.set_complexity_from_recipe(g, recipe, multiplier)
    end
end

-- TODO: Fluid-only recipe bases should be considered in graphing step
-- so that item-based recipes for the same item also contribute
utility.print_if_debug("[#7] Autosetting complexity from fluid-only recipes")

for _, recipe in pairs(data.raw["recipe"]) do
    if
        utility.recipe_has_basics(recipe)
        and #utility.recipe_ingredients(recipe, "item") == 0
        and #utility.recipe_ingredients(recipe, "fluid") > 0
    then
        refining_recipes.set_complexity_from_recipe(g, recipe, 1)
    end
end

utility.print_if_debug("[#8] Autocalculating complexity for other items")

-- Let it rip!
for _, recipe in pairs(data.raw["recipe"]) do
    if recipe.results ~= nil then
        for i = 1, #recipe.results do
            refining_recipes.memoize_item(g, recipe.results[i].name)
        end
    end
end

utility.print_if_debug("[#9] Generating refining recipes")

for item_name in pairs(g.items_resolved) do
    refining_recipes.create_refining_recipe(g, item_name)
end

utility.print_if_debug("[#10] Done")
