local utility = {}

local is_debugging = settings.startup["debug-refining-graph"].value
function utility.print_if_debug(s)
    if not is_debugging then return end
    log(s)
end

---@param recipe data.RecipePrototype
function utility.recipe_has_basics(recipe)
    return recipe.ingredients ~= nil
        and recipe.results ~= nil
        and recipe.energy_required ~= nil
end

---@param recipe data.RecipePrototype
---@param type "fluid"|"item"
function utility.recipe_ingredients(recipe, type)
    if recipe.ingredients == nil
        then return {} end
    local ret = {}
    for i = 1, #recipe.ingredients do
        if recipe.ingredients[i].type == type then
            table.insert(ret, recipe.ingredients[i])
        end
    end
    return ret
end

---@param recipe data.RecipePrototype
---@param type "fluid"|"item"
function utility.recipe_results(recipe, type)
    if recipe.results == nil
        then return {} end
    local ret = {}
    for i = 1, #recipe.results do
        if recipe.results[i].type == type then
            table.insert(ret, recipe.ingredients[i])
        end
    end
    return ret
end

function utility.get_startup_settings()
    local debug_graph = not not settings.startup["debug-refining-graph"].value
    local refine_hardness = settings.startup["refining-hardness"].value / 100
    local refine_lean = math.pow(0.9, settings.startup["refining-lean"].value / 100)
    local refine_multiplier = settings.startup["refining-time-multiplier"].value / 100
    local refine_time_max = settings.startup["refining-time-max"].value * 60
    local modded_science_pack_refine_time = settings.startup["refining-default-science-pack-time"].value * 1
    local refinery_allow_quality = not not settings.startup["refinery-allow-quality"].value
    return {
        debug_graph = debug_graph,
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
function utility.refine_time(s, refine_lean)
    return math.pow(s, 1 / refine_lean) * 5 * 0.999 -- So that they round up properly
end

return utility
