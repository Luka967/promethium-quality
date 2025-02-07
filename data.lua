local utility = require("utility")

local modifiers = utility.get_startup_settings()

utility.print_if_debug("[#1] Startup settings")
for key, value in pairs(modifiers) do
    utility.print_if_debug(key.."="..serpent.line(value))
end

utility.print_if_debug("[#2.1] Mod list:\n"..serpent.block(mods))

utility.print_if_debug("[#2.2] Loading prototypes")

require("prototype.entity")
require("prototype.item")
require("prototype.fluid")
require("prototype.recipe")
require("prototype.technology")

utility.print_if_debug("[#2.3] Loading compatibility changes")

require("prototype.compat.load")

utility.print_if_debug("[#2.4] Done")
