local is_debugging = settings.startup["debug-refining-graph"].value
local function print_if_debug(s)
    if not is_debugging then return end
    log(s)
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

local function get_startup_settings()
    local debug_graph = not not settings.startup["promethium-chunk-spoil-time"].value
    local promethium_spoil_time = settings.startup["promethium-chunk-spoil-time"].value * hour
    local refine_hardness = settings.startup["refining-hardness"].value / 100
    local refine_lean = math.pow(0.9, settings.startup["refining-lean"].value / 100)
    local refine_multiplier = settings.startup["refining-time-multiplier"].value / 100
    local refine_time_max = settings.startup["refining-time-max"].value * 60
    local modded_science_pack_refine_time = settings.startup["refining-default-science-pack-time"].value * 1
    local refinery_allow_quality = settings.startup["refinery-allow-quality"]
    return {
        debug_graph = debug_graph,
        promethium_spoil_time = promethium_spoil_time,
        refine_hardness = refine_hardness,
        refine_lean = refine_lean,
        refine_multiplier = refine_multiplier,
        refine_time_max = refine_time_max,
        modded_science_pack_refine_time = modded_science_pack_refine_time,
        refinery_allow_quality = refinery_allow_quality
    }
end

--- Inverse function of complexity->refine time
--- @param s number
--- @param refine_lean number
local function refine_time(s, refine_lean)
    return math.pow(s, 1 / refine_lean) * 5 * 0.999 -- So that they round up properly
end

return {
    refine_time = refine_time,
    is_debugging = is_debugging,
    print_if_debug = print_if_debug,

    recipe_has_basics = recipe_has_basics,
    recipe_ingredients = recipe_ingredients,
    recipe_results = recipe_results,

    get_startup_settings = get_startup_settings
}
