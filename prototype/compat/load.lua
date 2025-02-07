local utility = require("__promethium-quality__.utility")

require("base")
utility.print_if_debug("    -> Loaded base")

local mods_with_changes = {
    maraxsis = "maraxsis"
}

for mod_key, load_path in pairs(mods_with_changes) do
    if mods[mod_key] then
        require(load_path)
        utility.print_if_debug("    -> Loaded "..mod_key)
    end
end
