local is_debugging = settings.startup["debug-refining-graph"].value
local function print_if_debug(s)
    if not is_debugging then return end
    log(s)
end

--- Inverse function of complexity->refine time
--- @param s number
local function refine_time(s)
    return math.pow(s, 1 / 0.9) * 5 * 0.999 -- So that they round up properly
end

---@param recipe data.RecipePrototype
local function recipe_has_basics(recipe)
    return recipe.ingredients ~= nil
        and recipe.results ~= nil
        and recipe.energy_required ~= nil
end

---@param recipe data.RecipePrototype
---@param type "fluid"|"item"
local function recipe_ingredients(recipe, type)
    if recipe.ingredients == nil
        then return {} end
    local ret = {}
    for i = 1, #recipe.ingredients do
        if recipe.ingredients[i].type == type
            then ret[#ret+1] = recipe.ingredients[i] end
    end
    return ret
end

---@param recipe data.RecipePrototype
---@param type "fluid"|"item"
local function recipe_results(recipe, type)
    if recipe.results == nil
        then return {} end
    local ret = {}
    for i = 1, #recipe.results do
        if recipe.results[i].type == type
            then ret[#ret+1] = recipe.results[i] end
    end
    return ret
end

return {
    refine_time = refine_time,
    is_debugging = is_debugging,
    print_if_debug = print_if_debug,

    recipe_has_basics = recipe_has_basics,
    recipe_ingredients = recipe_ingredients,
    recipe_results = recipe_results
}
