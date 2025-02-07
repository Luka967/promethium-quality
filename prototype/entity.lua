local sounds = require("sounds")
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
