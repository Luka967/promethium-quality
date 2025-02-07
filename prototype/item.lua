local utility = require("__promethium-quality__.utility")
local sounds = require("sounds")

local modifiers = utility.get_startup_settings()

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
if modifiers.promethium_spoil_time ~= 0 then
    data.raw["item"]["promethium-asteroid-chunk"].spoil_result = "oxide-asteroid-chunk"
    data.raw["item"]["promethium-asteroid-chunk"].spoil_ticks = modifiers.promethium_spoil_time
end
