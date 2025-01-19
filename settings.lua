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
    maximum_value = 500,
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
    type = "int-setting",
    name = "refining-default-science-pack-time",
    setting_type = "startup",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 20,
    order = "be"
}})
