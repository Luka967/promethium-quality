local refining_recipes = require("refining-recipes")

local ctx = {
    complexity = refining_recipes.base_complexity,
    memoizing_complexity = {},
    skipped_recipes = {}
}

for _, recipe in pairs(data.raw["recipe"]) do
    refining_recipes.mark_refinable_items(ctx, recipe, 1)
end

for item_name in pairs(ctx.complexity) do
    refining_recipes.create_refining_recipe(ctx, item_name)
end
