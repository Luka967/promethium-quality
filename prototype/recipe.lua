data:extend({{
    type = "recipe-category",
    name = "refining"
}})

data:extend({{
    type = "recipe",
    name = "promethium-chunk-melting",
    icon = "__promethium-quality__/graphics/icons/promethium-chunk-melting.png",
    icon_size = 64,
    category = "chemistry",
    subgroup = "space-processing",
    order = "e",
    energy_required = 60,
    enabled = false,
    ingredients = {
        {type = "fluid", name = "lubricant", amount = 600},
        {type = "item", name = "promethium-asteroid-chunk", amount = 1},
    },
    results = {
        {type = "fluid", name = "promethium-emulsion", amount = 600}
    },
    allow_productivity = true,
    crafting_machine_tint =
    {
        primary = {227, 32, 76, 128},
        secondary = {163, 83, 101, 128},
        tertiary = {110, 59, 71, 128},
        quaternary = {106, 18, 38, 128}
    }
}})
data:extend({{
    type = "recipe",
    name = "promethium-chunk-submerging",
    icon = "__promethium-quality__/graphics/icons/promethium-chunk-submerging.png",
    icon_size = 64,
    category = "cryogenics",
    subgroup = "space-processing",
    order = "f",
    energy_required = 30,
    enabled = false,
    ingredients = {
        {type = "fluid", name = "ammonia", amount = 600},
        {type = "item", name = "promethium-asteroid-chunk", amount = 1},
    },
    results = {
        {type = "fluid", name = "promethium-emulsion", amount = 600}
    },
    allow_productivity = true,
    crafting_machine_tint =
    {
        primary = {227, 32, 76, 128},
        secondary = {163, 83, 101, 128},
        tertiary = {110, 59, 71, 128},
        quaternary = {106, 18, 38, 128}
    }
}})

data:extend({{
    type = "recipe",
    name = "refinery",
    icon = "__promethium-quality__/graphics/icons/refinery.png",
    icon_size = 64,
    category = "cryogenics",
    energy_required = 15,
    enabled = false,
    ingredients = {
        {type = "item", name = "tungsten-plate", amount = 100},
        {type = "item", name = "superconductor", amount = 100},
        {type = "item", name = "quantum-processor", amount = 50},
        {type = "item", name = "promethium-asteroid-chunk", amount = 10},
        {type = "fluid", name = "fluoroketone-cold", amount = 200}
    },
    results = {
        {type = "item", name = "refinery", amount = 1}
    }
}})
