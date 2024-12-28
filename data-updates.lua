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

--- Now there's a crash situation: as those complexities get graphed (what this procedure in practice does),
--- mods can introduce a circular dependecy. This usually happens because there's a way to obtain something in a way
--- so far not recognized right now, for example fish, which for vanilla are hardcoded values.
--- The goal until 1.0 is to iron these problems out while primarily keeping vanilla, and optionally modded refining times balanced enough.

for _, resource in pairs(data.raw["resource"]) do
    refining_recipes.assign_modded_base_complexity(ctx, resource)
end

for _, recipe in pairs(data.raw["recipe"]) do
    refining_recipes.mark_refinable_items(ctx, recipe, 1)
end

for item_name in pairs(ctx.complexity) do
    refining_recipes.create_refining_recipe(ctx, item_name)
end
