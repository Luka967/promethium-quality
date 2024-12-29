--- Inverse function of complexity->refine time
--- @param s number
local function refine_time(s)
    return math.pow(s, 1 / 0.9) * 5
end

return {
    refine_time = refine_time
}
