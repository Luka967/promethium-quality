-- This is given via "something out of nothing" recipe and no-restrictions crafting machine posing as miner
-- Complexity does not adhere expected from ores

-- Ref: https://github.com/notnotmelon/maraxsis/blob/main/prototypes/mod-data/control-constants.lua#L57-L58
local sand_item_name = "sand"
if mods["Krastorio2-spaced-out"] or mods["Krastorio2"] then sand_item_name = "kr-sand" end

data.raw["item"][sand_item_name].refine_complexity = 2
