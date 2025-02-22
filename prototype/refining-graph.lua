--- @class RefiningGraphResolvedItem
--- @field prototype data.ItemPrototype
--- @field complexity number|nil

--- @class RefiningGraph
--- @field items_resolved table<string, RefiningGraphResolvedItem> K-V pair of item name and its complexity
--- @field item_resolve_stack string[] List of items that required this item resolved
--- @field recipes_skipped table<string, boolean>
--- @field recipes_visited table<string, boolean>

local refining_util = require("refining-utility")
local utility = require("__promethium-quality__.utility")

local modifiers = utility.get_startup_settings()

--- @param g RefiningGraph
--- @param recipe data.RecipePrototype
--- @param target_item? string
local function can_visit_recipe(g, recipe, target_item)
    if g.recipes_skipped[recipe.name] ~= nil or g.recipes_visited[recipe.name] ~= nil
        then return false end
    if recipe.ingredients == nil or recipe.results == nil
        then return false end
    if recipe.category == "recycling-or-hand-crafting" or recipe.category == "recycling"
        then return false end
    local has_item_ingredient = false
    for i = 1, #recipe.ingredients do
        if recipe.ingredients[i].type == "item"
            then has_item_ingredient = true break end
    end
    if not has_item_ingredient
        then return false end
    for i = 1, #recipe.results do
        local product = recipe.results[i]
        if product.type == "item" and (target_item == nil or product.name == target_item)
            then return true end
    end
    return false
end
--- @param g RefiningGraph
--- @param recipe data.RecipePrototype
local function is_recipe_usable(g, recipe)
    for i = 1, #recipe.ingredients do
        local ingredient = recipe.ingredients[i]
        -- This can be nil if it was tried to be visited twice by some recipe loop
        local resolved_ingredient = g.items_resolved[ingredient.name]
        if ingredient.type == "item" and (resolved_ingredient == nil or resolved_ingredient.complexity == nil) then
            utility.print_if_debug("is_recipe_usable "..recipe.name.." skipped because ingredient "..ingredient.name.." is unusable")
            return false
        end
    end
    return true
end

--- @param g RefiningGraph
--- @param item_prototype data.ItemPrototype
--- @param complexity number|nil
local function set_item_complexity(g, item_prototype, complexity)
    if complexity == 0 then
        local item_str = item_prototype.type.."["..item_prototype.name.."]"
        local error_msg = "Bailed out while graphing refining time for items: complexity for "..item_str.." is somehow zero!"
        error_msg = error_msg.."\nPlease report this to the Promethium is Quality mod discussion and list what other mods you had enabled."
        error(error_msg)
    end
    if g.items_resolved[item_prototype.name] ~= nil
        then return end
    g.items_resolved[item_prototype.name] = {
        complexity = complexity,
        prototype = item_prototype
    }
    local complexity_str
    if complexity == nil
        then complexity_str = "[unreachable]"
        else complexity_str = complexity end
    utility.print_if_debug("set_item_complexity "..item_prototype.name.."="..complexity_str)
end

local memoize_item

--- @param g RefiningGraph
--- @param unspoiled_prototype data.ItemPrototype
--- @param item_name string
local function is_unspoiled_of(g, unspoiled_prototype, item_name)
    if unspoiled_prototype.spoil_result ~= item_name
        then return end
    memoize_item(g, unspoiled_prototype.name)
    local resolved = g.items_resolved[unspoiled_prototype.name]
    return resolved ~= nil and resolved.complexity ~= nil
end

local visit_recipe

--- @param g RefiningGraph
--- @param item_name string
memoize_item = function (g, item_name)
    if g.items_resolved[item_name] ~= nil
        then return end

    -- If we try memoize an item twice we'll lose knowledge of recipes already visited and available on the second pass
    for i = 1, #g.item_resolve_stack do
        if g.item_resolve_stack[i] == item_name
            then return end
    end

    local item_prototype, item_type = refining_util.get_prototype(item_name, "item")
    if item_prototype == nil
        then return end

    -- This can be used by mods
    if item_prototype.auto_refine == false then
        set_item_complexity(g, item_prototype, nil)
        item_prototype.auto_refine = nil
        return
    end
    if item_prototype.refine_complexity ~= nil then
        set_item_complexity(g, item_prototype, item_prototype.refine_complexity)
        item_prototype.refine_complexity = nil
        return
    end

    local complexity_multiplier = 1
    if item_type == "ammo" then complexity_multiplier = 6 end

    table.insert(g.item_resolve_stack, item_name)
    utility.print_if_debug("memoize_item "..item_name.." depth="..#g.item_resolve_stack.." multiplier="..complexity_multiplier)

    --- @type table<number, string>
    local available_recipes = {}
    for recipe_name, recipe in pairs(data.raw["recipe"]) do
        if can_visit_recipe(g, recipe, item_name) then
            visit_recipe(g, recipe)
            if is_recipe_usable(g, recipe) then
                table.insert(available_recipes, recipe_name)
            else
                g.recipes_skipped[recipe.name] = true
            end
        end
    end
    utility.print_if_debug("memoize_item "..item_name.." depth="..#g.item_resolve_stack.." #available_recipes="..#available_recipes)

    --- @type table<number, data.ItemPrototype>
    local unspoiled_sources = {}
    for type_name in pairs(defines.prototypes["item"]) do
        if data.raw[type_name] ~= nil then
            for _, unspoiled_prototype in pairs(data.raw[type_name]) do
                if is_unspoiled_of(g, unspoiled_prototype, item_name) then
                    table.insert(unspoiled_sources, unspoiled_prototype)
                end
            end
        end
    end
    utility.print_if_debug("memoize_item "..item_name.." depth="..#g.item_resolve_stack.." #unspoiled_sources="..#unspoiled_sources)

    local lowest_complexity = nil
    local lowest_ingredient_fluids = nil
    for i = 1, #unspoiled_sources do
        local unspoiled_complexity = g.items_resolved[unspoiled_sources[i].name].complexity
        lowest_ingredient_fluids = 0
        lowest_complexity = math.min(lowest_complexity or unspoiled_complexity, unspoiled_complexity)
    end
    for i = 1, #available_recipes do
        local recipe = data.raw["recipe"][available_recipes[i]]
        local recipe_result
        for i = 1, #recipe.results do
            local product = recipe.results[i]
            if product.type == "item" and product.name == item_name
                then recipe_result = product break end
        end
        local recipe_complexity = refining_util.compute_complexity(g, recipe.ingredients, recipe_result)

        local recipe_ingredient_fluids = #utility.recipe_ingredients(recipe, "fluid")
        if lowest_ingredient_fluids == nil or recipe_ingredient_fluids < lowest_ingredient_fluids then
            lowest_complexity = recipe_complexity
            lowest_ingredient_fluids = recipe_ingredient_fluids
        elseif recipe_ingredient_fluids == lowest_ingredient_fluids then
            lowest_complexity = math.min(lowest_complexity or recipe_complexity, recipe_complexity)
        end
    end

    if lowest_complexity ~= nil then
        lowest_complexity = lowest_complexity * complexity_multiplier
    end
    set_item_complexity(g, item_prototype, lowest_complexity)
    g.recipes_visited = {}
    table.remove(g.item_resolve_stack)
end

--- @param g RefiningGraph
--- @param recipe data.RecipePrototype
visit_recipe = function (g, recipe)
    if not can_visit_recipe(g, recipe)
        then return false end
    g.recipes_visited[recipe.name] = true
    utility.print_if_debug("visit_recipe "..recipe.name)

    for i = 1, #recipe.ingredients do
        local ingredient = recipe.ingredients[i]
        if ingredient.type == "item"
            then memoize_item(g, ingredient.name) end
    end
end

--- @param g RefiningGraph
--- @param products data.ProductPrototype[]
--- @param complexity number
local function set_complexity_from_products(g, products, complexity)
    for i = 1, #products do
        local product = products[i]
        if product.type == "item" then
            local item_prototype = refining_util.get_prototype(product.name, "item")
            if item_prototype ~= nil then
                set_item_complexity(g, item_prototype, refining_util.compute_complexity_totaled(complexity, product))
            end
        end
    end
end
--- @param g RefiningGraph
--- @param minable_name string
--- @param minable data.MinableProperties
--- @param multiplier number
local function set_complexity_from_minable(g, minable_name, minable, multiplier)
    if minable == nil
        then return end
    local complexity = minable.mining_time * multiplier
    utility.print_if_debug("set_complexity_from_minable "..minable_name.." complexity="..complexity)

    local product_list = minable.results or {{type = "item", name = minable.result, amount = minable.count or 1}}
    set_complexity_from_products(g, product_list, complexity)
end
--- @param g RefiningGraph
--- @param recipe data.RecipePrototype
--- @param multiplier number
local function set_complexity_from_recipe(g, recipe, multiplier)
    if recipe == nil
        then return end
    local complexity = recipe.energy_required * multiplier
    utility.print_if_debug("set_complexity_from_recipe "..recipe.name.." complexity="..complexity)
    set_complexity_from_products(g, recipe.results, complexity)
end

--- @param g RefiningGraph
--- @param item_name string
local function create_refining_recipe(g, item_name)
    local item_resolved = g.items_resolved[item_name]
    if item_resolved.complexity == nil
        then return end

    local final_time = modifiers.refine_hardness * item_resolved.complexity
    final_time = math.pow(final_time / 5, modifiers.refine_lean)
    final_time = final_time * modifiers.refine_multiplier
    if final_time <= 0.5 then
        final_time = math.ceil(final_time * 40) / 40    -- Under 0.5s: round up by .025
    elseif final_time <= 1 then
        final_time = math.ceil(final_time * 10) / 10    -- 0.5s -  1s: round up by .1
    elseif final_time <= 10 then
        final_time = math.ceil(final_time * 2) / 2      --   1s - 10s: round up by .5
    elseif final_time <= 30 then
        final_time = math.ceil(final_time)              --  10s - 30s: round up by 1
    elseif final_time <= 120 then
        final_time = math.ceil(final_time / 5) * 5      -- 30s - 120s: round up by 5
    else
        final_time = math.ceil(final_time / 10) * 10    -- Above 120s: round up by 10
    end
    if modifiers.refine_time_max ~= 0 then
        final_time = math.min(final_time, modifiers.refine_time_max * minute)
    end
    local fluid_requirement = math.min(final_time, 1200)
    utility.print_if_debug("create_refining_recipe "..item_name.." complexity "..item_resolved.complexity.." -> "..final_time.."s")

    local overload_multiplier
    if final_time <= 180 then
        overload_multiplier = 0
    else
        overload_multiplier = 1
    end

    local refine_recipe_name = item_name .. "-refining"
    data:extend({{
        type = "recipe",
        name = refine_recipe_name,
        localised_name = {"recipe-name.refining", refining_util.get_item_localised_name(item_name)},
        category = "refining",
        icon = nil,
        icons = refining_util.generate_refining_recipe_icon(item_resolved.prototype),
        energy_required = final_time,
        enabled = false,
        hidden = not utility.is_debugging,
        unlock_results = false,
        -- Quality mod, and by extension recycling recipes, should be loaded before this mod does.
        -- But in case game whacks load order, make sure these recipes don't get considered
        auto_recycle = false,
        ingredients = {
            {type = "fluid", name = "promethium-emulsion", amount = fluid_requirement},
            {type = "item", name = item_name, amount = 1}
        },
        results = {
            {type = "item", name = item_name, amount = 1}
        },
        overload_multiplier = overload_multiplier
    }})
    table.insert(data.raw["technology"]["refinery"].effects, {
        type = "unlock-recipe",
        recipe = refine_recipe_name
    })
end

return {
    set_complexity_from_products = set_complexity_from_products,
    set_complexity_from_minable = set_complexity_from_minable,
    set_complexity_from_recipe = set_complexity_from_recipe,
    memoize_item = memoize_item,
    create_refining_recipe = create_refining_recipe
}
