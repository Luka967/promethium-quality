local refining_recipes = require("refining-recipes")

--- @type RefineRecipesContext
local ctx = {
    complexity = refining_recipes.base_complexity,
    memoizing_complexity = {},
    impossible_recipes = {},
    visited_recipes = {}
}

--- Generating a refining recipe for one item is done by a three-step procedure:
---
--- 1. Search all recipes for target item as result -> 2. Ensure complexities of ingredients is available ┬─> 3. Set complexity of target item
--- ^                                                                                                     |
--- └─────────────────────────────────────────────────────────────────────────────────────────────────────┘
--- While searching for one item, it's considered a memoization step, during which all recipes that result into item are considered,
--- but only the one with lowest complexity is taken further. In practice this means that a refining recipe takes the path of least resistance.
---
--- This procedure itself is then executed on every recipe with no target item, instead setting complexity to all results of all applicable recipes.

--- Now there's a crash situation: as those complexities get graphed, mods can introduce a circular dependecy.
--- This usually happens because there's something obtainable in a way that we don't recognize right now,
--- for example items derived only from fluid ingredients, which for vanilla are hardcoded values.
--- If there happen to be at least 2 recipes that eventually rotate to the same unspecified item, a circular dependency arises.
--- The goal until 1.0 is to iron these problems out while primarily keeping vanilla, and optionally modded refining times balanced enough.

for _, resource in pairs(data.raw["resource"]) do
    refining_recipes.set_complexity_from_minable(ctx, resource.minable, 0.5) -- 1 mining time -> 0.5 complexity
end
for _, resource in pairs(data.raw["fish"]) do
    refining_recipes.set_complexity_from_minable(ctx, resource.minable, 1125) -- 0.4 mining time of Nauvis fish, output 5 -> 90 complexity
end
for _, resource in pairs(data.raw["unit"]) do
    refining_recipes.set_complexity_from_minable(ctx, resource.minable, 1125) -- Bogus multiplier, support for Maraxsis
end
for _, resource in pairs(data.raw["asteroid-chunk"]) do
    refining_recipes.set_complexity_from_minable(ctx, resource.minable, 25) -- Default 2 complexity for modded asteroid chunks
end
for _, resource in pairs(data.raw["plant"]) do
    refining_recipes.set_complexity_from_minable(ctx, resource.minable, 200) -- 0.5 mining time of Gleba trees, output 50 -> 2 complexity
end
refining_recipes.advance_memoization_step(ctx)

for _, recipe in pairs(data.raw["recipe"]) do
    refining_recipes.mark_refinable_items(ctx, recipe, 1)
end

for item_name in pairs(ctx.complexity) do
    refining_recipes.create_refining_recipe(ctx, item_name)
end
