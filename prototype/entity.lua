local sounds = require("sounds")
local refinery_pipe_pictures = {
    north = util.sprite_load("__promethium-quality__/graphics/entity/refinery/pipe-connections/north", {scale = 0.5}),
    south = util.sprite_load("__promethium-quality__/graphics/entity/refinery/pipe-connections/south", {scale = 0.5}),
    east = util.sprite_load("__promethium-quality__/graphics/entity/refinery/pipe-connections/east", {scale = 0.5}),
    west = util.sprite_load("__promethium-quality__/graphics/entity/refinery/pipe-connections/west", {scale = 0.5})
}

local utility = require("__promethium-quality__.utility")
local modifiers = utility.get_startup_settings()

local refinery_allowed_effects = {"consumption", "speed", "pollution"}
if modifiers.refinery_allow_quality then
    refinery_allowed_effects[4] = "quality"
end

--- @param filenames string[]
--- @param blend_mode data.BlendMode
--- @param other? data.Animation
local function create_sprite_layer(filenames, blend_mode, other)
    local file_count = 0
    for i, filename_partial in ipairs(filenames) do
        file_count = file_count + 1
        filenames[i] = "__promethium-quality__/graphics/entity/refinery/"..filename_partial
    end
    other = other or {}
    --- @type data.Animation
    local ret = {
        priority = "high",
        scale = 0.5,
        blend_mode = blend_mode,
        width = 320,
        height = 320,
        shift = util.by_pixel_hr(0, 0)
    }
    if file_count == 1 then
        ret.filename = filenames[1]
    else
        ret.filenames = filenames
        ret.line_length = 8
        ret.lines_per_file = 8
        ret.frame_count = 100
    end
    for key, value in pairs(other) do
        ret[key] = value
    end
    return ret
end

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
        filter = "promethium-emulsion",
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
    allowed_effects = refinery_allowed_effects,
    effect_receiver = {base_effect = {quality = 10}},

    crafting_categories = {"refining"},
    crafting_speed = 1,
    circuit_wire_max_distance = furnace_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions.create_vector(universal_connector_template, {
        {variation = 27, main_offset = util.by_pixel(55, 50), shadow_offset = util.by_pixel(0, 0), show_shadow = false},
        {variation = 27, main_offset = util.by_pixel(55, 50), shadow_offset = util.by_pixel(0, 0), show_shadow = false},
        {variation = 27, main_offset = util.by_pixel(55, 50), shadow_offset = util.by_pixel(0, 0), show_shadow = false},
        {variation = 27, main_offset = util.by_pixel(55, 50), shadow_offset = util.by_pixel(0, 0), show_shadow = false},
    }),

    open_sound = sounds.refinery_pick,
    close_sound = sounds.refinery_move,
    working_sound = {
        sound = {filename = "__promethium-quality__/sound/entity/refinery/working-loop.ogg", volume = 0.9},
        sound_accents = {
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/plate-slide.ogg", audible_distance_modifier = 0.4, volume = 0.4}, frame = 4, play_for_working_visualisation = "working"},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/plate-show-1.ogg", audible_distance_modifier = 0.4, volume = 0.6}, frame = 12, play_for_working_visualisation = "working"},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/circuit-take.ogg", audible_distance_modifier = 0.2, volume = 0.4}, frame = 20, play_for_working_visualisation = "working"},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/plate-show-2.ogg", audible_distance_modifier = 0.4, volume = 0.6}, frame = 28, play_for_working_visualisation = "working"},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/weld-1.ogg", audible_distance_modifier = 0.6, volume = 0.6}, frame = 39, play_for_working_visualisation = "working"},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/weld-2.ogg", audible_distance_modifier = 0.6, volume = 0.6}, frame = 65, play_for_working_visualisation = "working"},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/circuit-drop.ogg", audible_distance_modifier = 0.2, volume = 0.4}, frame = 66, play_for_working_visualisation = "working"},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/door-open.ogg", audible_distance_modifier = 0.4, volume = 0.4}, frame = 68, play_for_working_visualisation = "working"},
            {sound = {filename = "__promethium-quality__/sound/entity/refinery/door-close.ogg", audible_distance_modifier = 0.4, volume = 0.4}, frame = 96, play_for_working_visualisation = "working"},
        },
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
            layers = {
                create_sprite_layer({
                    "refinery-shadow.png"
                }, "normal", {
                    width = 520,
                    height = 500,
                    draw_as_shadow = true
                })
            }
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
                layers = {
                    create_sprite_layer({
                        "refinery-working-1.png",
                        "refinery-working-2.png"
                    }, "normal"),
                    create_sprite_layer({
                        "refinery-lights-heat-1.png",
                        "refinery-lights-heat-2.png"
                    }, "additive", {draw_as_glow = true}),
                    create_sprite_layer({
                        "refinery-lights-arc-1.png",
                        "refinery-lights-arc-2.png"
                    }, "additive", {draw_as_glow = true}),
                    create_sprite_layer({
                        "refinery-lights-indicator-1.png",
                        "refinery-lights-indicator-2.png"
                    }, "additive", {draw_as_glow = true})
                }
            }
        }, {
            always_draw = true,
            draw_in_states = {"idle"},
            animation = {
                layers = {
                    create_sprite_layer({
                        "refinery-shadow.png"
                    }, "normal", {
                        width = 520,
                        height = 500,
                        draw_as_shadow = true
                    }),
                    create_sprite_layer({
                        "refinery-working-1.png"
                    }, "normal")
                }
            }
        }}
    },
    corpse = "big-remnants",
    dying_explosion = "massive-explosion"
}})
