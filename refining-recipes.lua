local is_debugging = false
function print_if_debug(s)
    if not is_debugging then return end
    print(s)
end

--- @class RefineRecipesContext
--- @field complexity table<string, number|"skip">
--- @field memoizing_complexity table<string, number>
--- @field impossible_recipes table<string, boolean>
--- @field visited_recipes table<string, boolean>

--- @type table<string, number|"skip">
local base_complexity = {
    -- Ores or starting material
    ["stone-brick"] = 0.5,
    ["wood"] = "skip", -- Refining wood products is useless
    ["ice"] = 10,
    ["coal"] = 5,
    ["stone"] = 0.5,
    ["carbon"] = 2,
    ["sulfur"] = 60, -- Make explosives expensive
    ["calcite"] = 2,
    ["iron-ore"] = 0.5,
    ["copper-ore"] = 0.5,
    ["uranium-ore"] = "skip", -- Force legendary kovarex enrichment
    ["tungsten-ore"] = 1,
    ["holmium-ore"] = 1,
    ["lithium"] = 10,
    ["scrap"] = "skip", -- Must, to disregard scrap recycling recipe. Ore washing is equally impossible

    -- Processed starting material
    ["iron-plate"] = 1,
    ["steel-plate"] = 5,
    ["copper-plate"] = 1,
    ["copper-cable"] = 0.5,
    ["tungsten-plate"] = 4,
    ["holmium-plate"] = 2,
    ["lithium-plate"] = 20,
    ["carbon-fiber"] = 5,

    -- Uranium
    ["uranium-235"] = "skip", -- Force player to do legendary kovarex enrichment
    ["uranium-238"] = 120, -- If struggling to get legendary uranium-238

    -- Ammo / combat
    -- Artificially increase to make them purposely not viable on platforms (need feedback!)
    ["firearm-magazine"] = 30,
    ["shotgun-shell"] = 30,
    ["cannon-shell"] = 120,
    ["explosive-cannon-shell"] = 180,
    ["rocket"] = 120,
    ["flamethrower-ammo"] = 30,
    ["railgun-ammo"] = 120,
    ["tesla-ammo"] = 60,
    ["land-mine"] = 120,
    ["artillery-shell"] = 180,
    ["stone-wall"] = 120,
    ["grenade"] = 30,
    ["cluster-grenade"] = 120,

    -- Organic
    ["yumako"] = 2,
    ["jellynut"] = 2,
    ["raw-fish"] = 90,
    ["pentapod-egg"] = 30,
    ["biter-egg"] = 180,
    ["spoilage"] = 10,
    ["iron-bacteria"] = "skip", -- Just refine ores bro
    ["copper-bacteria"] = "skip",

    -- Asteroid chunks
    ["metallic-asteroid-chunk"] = 20,
    ["carbonic-asteroid-chunk"] = 10,
    ["oxide-asteroid-chunk"] = 5,
    ["promethium-asteroid-chunk"] = 30,

    -- Tiles used in recipes
    ["concrete"] = 5,
    ["refined-concrete"] = 10,

    -- Items for which quality is useless or should be impossible
    ["barrel"] = "skip",
    ["rocket-part"] = "skip",
    ["cliff-explosives"] = "skip",
    ["fast-transport-belt"] = "skip", -- Transport belt itself is needed for recipes. Kill memoization chain in the next step
    ["underground-belt"] = "skip",
    ["splitter"] = "skip",
    ["rail-signal"] = "skip",
    ["rail-chain-signal"] = "skip",
    ["locomotive"] = "skip",
    ["cargo-wagon"] = "skip",
    ["fluid-wagon"] = "skip",
    ["train-stop"] = "skip",
    ["rail-ramp"] = "skip",
    ["rail-support"] = "skip",
    -- Landfill is not here to allow refining biochamber
    ["hazard-concrete"] = "skip",
    ["refined-hazard-concrete"] = "skip",
    ["space-platform-foundation"] = "skip",
    ["artificial-yumako-soil"] = "skip",
    ["artificial-jellynut-soil"] = "skip",
    ["overgrowth-yumako-soil"] = "skip",
    ["overgrowth-jellynut-soil"] = "skip",
    ["ice-platform"] = "skip",
    ["foundation"] = "skip",
    ["rocket-fuel"] = "skip", -- By default rocket fuel should have no refining recipe, but Gleba's biochemical one gets picked up

    -- Science packs
    -- Put hard values for ratios sake. Reduce by a bit to round up to proper value
    ["automation-science-pack"]         = math.pow(1    , 1.1111111) * 5 - 0.01,
    ["logistic-science-pack"]           = math.pow(2    , 1.1111111) * 5 - 0.01,
    ["military-science-pack"]           = math.pow(2.5  , 1.1111111) * 5 - 0.01,
    ["chemical-science-pack"]           = math.pow(4    , 1.1111111) * 5 - 0.01,
    ["production-science-pack"]         = math.pow(8    , 1.1111111) * 5 - 0.01,
    ["utility-science-pack"]            = math.pow(10   , 1.1111111) * 5 - 0.01,
    ["space-science-pack"]              = math.pow(0.2  , 1.1111111) * 5 - 0.001,
    ["metallurgic-science-pack"]        = math.pow(5    , 1.1111111) * 5 - 0.01,
    ["agricultural-science-pack"]       = math.pow(5    , 1.1111111) * 5 - 0.01,
    ["electromagnetic-science-pack"]    = math.pow(5    , 1.1111111) * 5 - 0.01,
    ["cryogenic-science-pack"]          = math.pow(10   , 1.1111111) * 5 - 0.01,
    ["promethium-science-pack"]         = math.pow(20   , 1.1111111) * 5 - 0.01
}

-- Ripped out of recycling recipe generation
-- Thank you factorio devs >.<
local function get_prototype(name, base_prototype)
    for type_name in pairs(defines.prototypes[base_prototype]) do
        local prototypes = data.raw[type_name]
        if prototypes and prototypes[name] then
            return prototypes[name]
        end
    end
end
local function generate_refining_recipe_icon(item)
    local icons = table.deepcopy(item.icons or {{icon = item.icon, icon_size = item.icon_size or defines.default_icon_size}})
    for _, icon in ipairs(icons) do
        icon.scale = (0.5 * defines.default_icon_size / (item.icon_size or defines.default_icon_size)) * 0.8
        if icon.shift ~= nil then
            icon.shift = util.mul_shift(icon.shift, 0.8)
        end
    end
    icons[#icons+1] = {
        icon = "__promethium-quality__/graphics/icons/refining.png"
    }
    return icons
end
local function get_item_localised_name(name)
    local item = get_prototype(name, "item")
    if not item then return end
    if item.localised_name then
        return item.localised_name
    end
    local prototype
    local type_name = "item"
    if item.place_result then
        prototype = get_prototype(item.place_result, "entity")
        type_name = "entity"
    elseif item.place_as_equipment_result then
        prototype = get_prototype(item.place_as_equipment_result, "equipment")
        type_name = "equipment"
    elseif item.place_as_tile then
        -- Tiles with variations don't have a localised name
        local tile_prototype = data.raw.tile[item.place_as_tile.result]
        if tile_prototype and tile_prototype.localised_name then
            prototype = tile_prototype
            type_name = "tile"
        end
    end
    return prototype and prototype.localised_name or {type_name.."-name."..name}
end

--- @param ctx RefineRecipesContext
--- @param recipe data.RecipePrototype
local function is_suitable_recipe(ctx, recipe)
    if ctx.impossible_recipes[recipe.name] ~= nil
        then return false end
    if recipe.ingredients == nil or #recipe.ingredients == 0
        then return false end
    if recipe.category == "recycling"
        then return false end
    for i = 1, #recipe.ingredients do
        if recipe.ingredients[i].type == "item"
            then return true end
    end
    return false
end
--- @param ctx RefineRecipesContext
--- @param recipe data.RecipePrototype
--- @param item_name string|nil
local function is_craft_recipe_for(ctx, recipe, item_name)
    if not is_suitable_recipe(ctx, recipe)
        then return false end
    for i = 1, #recipe.ingredients do
        local ingredient = recipe.ingredients[i]
        if ingredient.type == "item" and ingredient.name == item_name then
            return false
        end
    end
    for i = 1, #recipe.results do
        local result = recipe.results[i]
        if result.type == "item" and result.name == item_name then
            return true
        end
    end
    return false
end

--- @param ctx RefineRecipesContext
local function advance_memoization_step(ctx)
    for item_name, final_complexity in pairs(ctx.memoizing_complexity) do
        ctx.complexity[item_name] = final_complexity
    end
    for item_name in pairs(ctx.memoizing_complexity) do
        ctx.memoizing_complexity[item_name] = nil
    end
    for recipe_name in pairs(ctx.visited_recipes) do
        ctx.visited_recipes[recipe_name] = nil
    end
end

--- @param ctx RefineRecipesContext
--- @param resource data.ResourceEntityPrototype
local function assign_modded_base_complexity(ctx, resource)
    local base_complexity = resource.minable.mining_time / 2

    if resource.minable.result ~= nil then
        if get_prototype(resource.minable.result, "item") == nil
            then return end
        set_complexity_for(ctx, {
            type = "item",
            name = resource.minable.result,
            amount = resource.minable.count or 1
        }, base_complexity)
        return
    end
    for i = 1, #resource.minable.results do
        set_complexity_for(ctx, resource.minable.results[i], base_complexity)
    end

    advance_memoization_step(ctx)
end
--- @param ctx RefineRecipesContext
--- @param ingredient data.IngredientPrototype
--- @param depth number
local function memoize_complexity_for(ctx, ingredient, depth)
    print_if_debug("depth="..depth.." memoize_complexity_for "..ingredient.name)
    if ingredient.type ~= "item"
        then return end
    if ctx.complexity[ingredient.name] ~= nil
        then return end
    local suitable_recipes = 0
    for _, recipe in pairs(data.raw["recipe"]) do
        if is_craft_recipe_for(ctx, recipe, ingredient.name) then
            suitable_recipes = suitable_recipes + 1
            mark_refinable_items(ctx, recipe, depth + 1)
        end
    end
end
--- @param ctx RefineRecipesContext
--- @param result data.ProductPrototype
--- @param total number
function set_complexity_for(ctx, result, total)
    if result.type ~= "item"
        then return end
    if get_prototype(result.name, "item") == nil
        then return end
    if ctx.complexity[result.name] ~= nil
        then return end
    total = total / (result.amount or result.amount_min or 1)
    if ctx.memoizing_complexity[result.name] ~= nil and ctx.memoizing_complexity[result.name] <= total
        then return end
    print_if_debug("set_complexity_for "..result.name.." "..total)
    ctx.memoizing_complexity[result.name] = total
end

--- @param ctx RefineRecipesContext
--- @param recipe data.RecipePrototype
--- @param depth number
function mark_refinable_items(ctx, recipe, depth)
    if not is_suitable_recipe(ctx, recipe) then
        ctx.impossible_recipes[recipe.name] = true
        return
    end
    if ctx.visited_recipes[recipe.name] ~= nil then
        local attempted_recipes = {}
        for recipe_name in pairs(ctx.visited_recipes)
            do attempted_recipes[#attempted_recipes+1] = recipe_name end
        local attempted_recipes_str = table.concat(attempted_recipes, ", ")
        local error_msg = "There is a circular dependency between recipes ["..attempted_recipes_str.."], triggered by ["..recipe.name.."], which has no way of resolving."
        error_msg = error_msg.."\nMost likely the mod isn't aware of a modded raw resource, and as such is unable to autogenerate refining recipes for the production chain."
        error_msg = error_msg.."\nPlease report this crash along with all mods that add new content or change recipes, so that they can be properly supported"
        error(error_msg)
    end
    ctx.visited_recipes[recipe.name] = true

    print_if_debug("depth="..depth.." mark_refinable_items "..recipe.name)

    local total_complexity = 0
    for i = 1, #recipe.ingredients do
        local ingredient = recipe.ingredients[i]
        if ingredient.type == "item" then
            memoize_complexity_for(ctx, ingredient, depth)

            if ctx.complexity[ingredient.name] == nil then
                print_if_debug("recipe "..recipe.name.." won't be used to make refining because "..ingredient.name.." complexity is nil")
                ctx.impossible_recipes[recipe.name] = true
                return
            end
            if ctx.complexity[ingredient.name] == "skip" then
                print_if_debug("recipe "..recipe.name.." won't be used to make refining because "..ingredient.name.." cannot be refined")
                ctx.impossible_recipes[recipe.name] = true
                return
            end
            total_complexity = total_complexity + ingredient.amount * ctx.complexity[ingredient.name]
        end
    end
    for i = 1, #recipe.results do
        set_complexity_for(ctx, recipe.results[i], total_complexity)
    end

    advance_memoization_step(ctx)
end

--- @param ctx RefineRecipesContext
--- @param item_name string
function create_refining_recipe(ctx, item_name)
    local final_time = ctx.complexity[item_name]
    if final_time == "skip" or final_time == nil
        then return end
    final_time = math.pow(final_time / 5, 0.9)
    if final_time < 1 then
        final_time = math.ceil(final_time * 10) / 10    --  0s -  1s: round up by .1
    elseif final_time <= 10 then
        final_time = math.ceil(final_time * 2) / 2      --  1s - 10s: round up by .5
    elseif final_time <= 30 then
        final_time = math.ceil(final_time)              -- 10s - 30s: round up by 1
    else
        final_time = math.ceil(final_time / 5) * 5      -- Above 30s: round up by 5
    end
    local fluid_requirement = math.min(final_time, 1200)
    print_if_debug("final refine recipe for "..item_name.." has "..ctx.complexity[item_name].." complexity -> "..final_time.."s craft time")

    local refine_recipe_name = item_name .. "-refining"
    data:extend({{
        type = "recipe",
        name = refine_recipe_name,
        localised_name = {"recipe-name.refining", get_item_localised_name(item_name)},
        category = "refining",
        icon = nil,
        icons = generate_refining_recipe_icon(get_prototype(item_name, "item")),
        energy_required = final_time,
        enabled = false,
        hidden = true,
        unlock_results = false,
        ingredients = {
            {type = "fluid", name = "promethium-emulsion", amount = fluid_requirement},
            {type = "item", name = item_name, amount = 1}
        },
        results = {
            {type = "item", name = item_name, amount = 1}
        }
    }})
    table.insert(data.raw["technology"]["refinery"].effects, {
        type = "unlock-recipe",
        recipe = refine_recipe_name
    })
end

return {
    base_complexity = base_complexity,
    assign_modded_base_complexity = assign_modded_base_complexity,

    mark_refinable_items = mark_refinable_items,
    create_refining_recipe = create_refining_recipe
}
