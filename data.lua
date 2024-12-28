require("sound-util")

------------------------------ Entities
local sounds = {
    refinery_pick = {
        filename = "__promethium-quality__/sound/item/refinery-pick.ogg",
        volume = 0.4, aggregation = {max_count = 1, remove = true}
    },
    refinery_move = {
        filename = "__promethium-quality__/sound/item/refinery-move.ogg",
        volume = 0.4, aggregation = {max_count = 1, remove = true}
    }
}
local refinery_pipe_pictures = {
    north = util.sprite_load("__promethium-quality__/graphics/entity/refinery/pipe-connections/north", {scale = 0.5}),
    south = util.sprite_load("__promethium-quality__/graphics/entity/refinery/pipe-connections/south", {scale = 0.5}),
    east = util.sprite_load("__promethium-quality__/graphics/entity/refinery/pipe-connections/east", {scale = 0.5}),
    west = util.sprite_load("__promethium-quality__/graphics/entity/refinery/pipe-connections/west", {scale = 0.5})
}

data:extend({{
    type = "furnace",
    name = "refinery",
    icon = "__promethium-quality__/graphics/icons/refinery.png",
    icon_size = 64,

    flags = {"placeable-neutral","placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "refinery"},
    max_health = 500,

    source_inventory_size = 1,
    custom_input_slot_tooltip_key = "refinery-input-slot-tooltip",
    cant_insert_at_source_message_key = "refinery-input-slot-restricted",
    result_inventory_size = 1,
    fluid_boxes = {{
        production_type = "input",
        pipe_picture = refinery_pipe_pictures,
        volume = 1200,
        pipe_connections = {{flow_direction = "input", direction = defines.direction.north, position = {0, -2}}},
        secondary_draw_orders = {north = -2}
    }},

    heating_energy = "100kW",
    energy_usage = "3.5MW",
    energy_source = {
        type = "electric",
        drain = "116.67kW",
        usage_priority = "secondary-input",
        emissions_per_minute = {
            pollution = 8,
            spores = 2
        }
    },
    module_slots = 3,
    allowed_effects = {"consumption", "speed", "pollution"},
    effect_receiver = {base_effect = {quality = 10}},

    crafting_categories = {"refining"},
    crafting_speed = 1,

    open_sound = sounds.refinery_pick,
    close_sound = sounds.refinery_move,
    working_sound = {
        sound = {filename = "__promethium-quality__/sound/entity/refinery/working-loop.ogg", volume = 0.9},
        sound_accents = {
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/plate-slide.ogg", volume = 0.4}, frame = 4, play_for_working_visualisation = "working", audible_distance_modifier = 0.4},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/plate-show-1.ogg", volume = 0.6}, frame = 12, play_for_working_visualisation = "working", audible_distance_modifier = 0.4},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/circuit-take.ogg", volume = 0.4}, frame = 20, play_for_working_visualisation = "working", audible_distance_modifier = 0.2},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/plate-show-2.ogg", volume = 0.6}, frame = 28, play_for_working_visualisation = "working", audible_distance_modifier = 0.4},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/weld-1.ogg", volume = 0.6}, frame = 39, play_for_working_visualisation = "working", audible_distance_modifier = 0.6},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/weld-2.ogg", volume = 0.6}, frame = 65, play_for_working_visualisation = "working", audible_distance_modifier = 0.6},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/circuit-drop.ogg", volume = 0.4}, frame = 66, play_for_working_visualisation = "working", audible_distance_modifier = 0.2},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/door-open.ogg", volume = 0.4}, frame = 68, play_for_working_visualisation = "working", audible_distance_modifier = 0.4},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/door-close.ogg", volume = 0.4}, frame = 96, play_for_working_visualisation = "working", audible_distance_modifier = 0.4},
        },
        max_sounds_per_type = 4,
        fade_in_ticks = 10,
        fade_out_ticks = 40
    },

    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    fast_replaceable_group = "refinery",

    icon_draw_specification = {shift = {0, 0.7}, scale = 1.25},
    icons_positioning = {
        {inventory_index = defines.inventory.furnace_modules, shift = {0, 1.5}}
    },
    perceived_performance = {
        minimum = 0.25,
        maximum = 3,
        performance_to_activity_rate = 6
    },
    graphics_set = {
        always_draw_idle_animation = true,
        idle_animation = {
            layers = {{
                filename = "__promethium-quality__/graphics/entity/refinery/refinery-shadow.png",
                priority = "high",
                width = 520,
                height = 500,
                frame_count = 1,
                line_length = 8,
                draw_as_shadow = true,
                scale = 0.5
            }}
        },
        states = {{
            name = "idle",
            duration = 1,
            next_active = "working",
            next_inactive = "idle"
        }, {
            name = "working",
            duration = 99,
            next_active = "working",
            next_inactive = "idle"
        }},
        working_visualisations = {{
            name = "working",
            always_draw = true,
            draw_in_states = {"working"},
            animation = {
                layers = {util.sprite_load("__promethium-quality__/graphics/entity/refinery/refinery-working", {
                    frame_count = 99,
                    animation_speed = 0.1,
                    scale = 0.5
                })}
            }
        }, {
            name = "working-lights",
            always_draw = true,
            draw_in_states = {"working"},
            animation = {
                layers = {util.sprite_load("__promethium-quality__/graphics/entity/refinery/refinery-working-lights", {
                    frame_count = 99,
                    animation_speed = 0.1,
                    draw_as_glow = true,
                    blend_mode = "additive",
                    scale = 0.5
                })}
            }
        }, {
            always_draw = true,
            draw_in_states = {"idle"},
            animation = {
                layers = {util.sprite_load("__promethium-quality__/graphics/entity/refinery/refinery-working", {
                    frame_count = 1,
                    scale = 0.5
                })}
            }
        }}
    },
    corpse = "big-remnants",
    dying_explosion = "massive-explosion",
}})

------------------------------ Items
data:extend({{
    type = "item",
    name = "refinery",
    place_result = "refinery",
    icon = "__promethium-quality__/graphics/icons/refinery.png",
    icon_size = 64,
    subgroup = "production-machine",
    order = "i[cryogenic-plant]",
    inventory_move_sound = sounds.refinery_move,
    pick_sound = sounds.refinery_pick,
    drop_sound = sounds.refinery_move,
    stack_size = 10,
    default_import_location = "aquilo",
    weight = 500 * kg
}})

-- Changes
data.raw["item"]["promethium-asteroid-chunk"].spoil_result = "oxide-asteroid-chunk"
data.raw["item"]["promethium-asteroid-chunk"].spoil_ticks = 2 * hour

------------------------------ Fluids
data:extend({{
    type = "fluid",
    name = "promethium-emulsion",
    icon = "__promethium-quality__/graphics/icons/promethium-emulsion.png",
    subgroup = "fluid",
    order = "b[new-fluid]-e[aquilo]-h[promethium-emulsion]",
    default_temperature = -200,
    heat_capacity = "0.01kW",
    base_color = {106, 18, 38},
    flow_color = {106, 18, 38},
    auto_barrel = false
}})

------------------------------ Recipes
data:extend({{
    type = "recipe-category",
    name = "refining"
}})

data:extend({{
    type = "item-subgroup",
    name = "promethium-processing",
    group = "space",
    order = "j"
}})
data:extend({{
    type = "recipe",
    name = "promethium-chunk-melting",
    icon = "__promethium-quality__/graphics/icons/promethium-chunk-melting.png",
    icon_size = 64,
    category = "chemistry",
    subgroup = "promethium-processing",
    order = "a",
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
    subgroup = "promethium-processing",
    order = "b",
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

------------------------------ Technology
data:extend({{
    type = "technology",
    name = "refinery",
    icon = "__promethium-quality__/graphics/icons/refinery-technology.png",
    icon_size = 128,
    effects = {{
        type = "unlock-recipe",
        recipe = "refinery"
    }, {
        type = "unlock-recipe",
        recipe = "promethium-chunk-melting"
    }, {
        type = "unlock-recipe",
        recipe = "promethium-chunk-submerging"
    }},
    prerequisites = {"promethium-science-pack"},
    unit = {
        count_formula = "10000",
        time = 120,
        ingredients = data.raw["technology"]["research-productivity"].unit.ingredients
    }
}})
-- Changes
data.raw["technology"]["epic-quality"].localised_name = {"changed-quality-name.epic-technology"}
data.raw["technology"]["legendary-quality"].localised_name = {"changed-quality-name.legendary-technology"}
