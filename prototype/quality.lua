local utility = require("__promethium-quality__.utility") --- @module "utility"

for _, quality_proto in pairs(data.raw["quality"]) do
    quality_proto.previous_probability = quality_proto.next_probability
    utility.print_if_debug("Quality prototype "..quality_proto.name.." set previous_probability to "..(quality_proto.previous_probability or "<none>"))
end
