data:extend({{
    type = "bool-setting",
    name = "debug-refining-graph",
    setting_type = "startup",
    default_value = false,
    order = "a"
}, {
    type = "double-setting",
    name = "promethium-chunk-spoil-time",
    setting_type = "startup",
    default_value = 2,
    minimum_value = 0,
    maximum_value = 6,
    order = "ba"
}, {
    type = "int-setting",
    name = "refining-hardness",
    setting_type = "startup",
    default_value = 100,
    minimum_value = 10,
    maximum_value = 500,
    order = "bb"
}, {
    type = "int-setting",
    name = "refining-lean",
    setting_type = "startup",
    default_value = 100,
    minimum_value = 10,
    maximum_value = 1000,
    order = "bc"
}, {
    type = "int-setting",
    name = "refining-time-multiplier",
    setting_type = "startup",
    default_value = 100,
    minimum_value = 1,
    maximum_value = 500,
    order = "bd"
}, {
    type = "double-setting",
    name = "refining-time-max",
    setting_type = "startup",
    default_value = 0,
    minimum_value = 0,
    maximum_value = 10,
    order = "be"
}, {
    type = "int-setting",
    name = "refining-default-science-pack-time",
    setting_type = "startup",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 20,
    order = "bf"
}, {
    type = "bool-setting",
    name = "refinery-allow-quality",
    setting_type = "startup",
    default_value = false,
    order = "bg"
}})
