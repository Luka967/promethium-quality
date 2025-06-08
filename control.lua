local highest_quality_prototype_id
do
    local cur = prototypes.quality["normal"]
    while cur.next ~= nil do
        cur = cur.next
    end
    highest_quality_prototype_id = cur.name
end

--- @param entity LuaEntity
local function is_inserter(entity)
    return entity.type == "inserter" or (entity.type == "entity-ghost" and entity.ghost_type == "inserter")
end

--- @param entity LuaEntity
local function is_refinery(entity)
    return entity.name == "refinery" or (entity.type == "entity-ghost" and entity.ghost_name == "refinery")
end

--- @param inserter_entity LuaEntity
local function is_drop_target_refinery(inserter_entity)
    if inserter_entity.drop_target ~= nil and not is_refinery(inserter_entity.drop_target)
        then return end
    local entities_at_drop_spot = inserter_entity.surface.find_entities_filtered({
        position = inserter_entity.drop_position,
        limit = 1
    })
    return #entities_at_drop_spot > 0 and is_refinery(entities_at_drop_spot[1])
end

--- @param inserter_entity LuaEntity
local function attempt_set_filter(inserter_entity)
    if inserter_entity.use_filters
        then return end

    if not is_drop_target_refinery(inserter_entity)
        then return end

    inserter_entity.use_filters = true
    inserter_entity.inserter_filter_mode = "blacklist"
    inserter_entity.set_filter(1, {quality = highest_quality_prototype_id})
end

local function do_try()
    if storage.autofilter_at_tick > game.tick
        then return end

    for _, arg in ipairs(storage.autofilter_entries) do
        attempt_set_filter(table.unpack(arg))
    end

    storage.autofilter_at_tick = nil
    storage.autofilter_entries = nil
    script.on_event(defines.events.on_tick, nil)
end
local function start_try()
    storage.autofilter_at_tick = game.tick + 1
    if storage.autofilter_entries ~= nil
        then return end
    storage.autofilter_entries = {}
    script.on_event(defines.events.on_tick, do_try)
end

--- @param refinery_entity LuaEntity
local function add_nearby_inserters_to_try(refinery_entity)
    local rect = refinery_entity.selection_box
    local inserters_nearby = refinery_entity.surface.find_entities_filtered({
        area = {
            left_top = {x = rect.left_top.x - 2.5, y = rect.left_top.y - 2.5},
            right_bottom = {x = rect.right_bottom.x + 2.5, y = rect.right_bottom.y + 2.5}
        },
        type = {"inserter"},
        ghost_type = {"inserter"}
    })

    start_try()
    for _, candidate_inserter in ipairs(inserters_nearby) do
        table.insert(storage.autofilter_entries, {candidate_inserter, refinery_entity})
    end
end

--- @param event EventData.on_built_entity
local function handle_build(event)
    if event.entity.last_user == nil
        then return end

    local player_settings = settings.get_player_settings(event.entity.last_user)
    if not player_settings["refinery-auto-set-input-filter"].value
        then return end

    local entity = event.entity
    if is_refinery(entity) then
        add_nearby_inserters_to_try(entity)
    elseif is_inserter(entity) then
        start_try()
        table.insert(storage.autofilter_entries, {entity})
    end
end

script.on_event(defines.events.on_built_entity, handle_build)
