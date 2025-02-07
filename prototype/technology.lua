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
        ingredients = table.deepcopy(data.raw["technology"]["research-productivity"].unit.ingredients)
    }
}})
