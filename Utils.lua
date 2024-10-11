--Utils.lua
---@class WeeklyTasksTrackerAddon
local wttAddon = select(2, ...)

---@class WeeklyTasksTrackerUtils
local Utils = {}
wttAddon.Utils = Utils

function Utils:Copy(tbl, cache)
    local copy = {}
    cache = cache or {}
    cache[tbl] = copy
    self:ForEach(tbl, function(value, index)
        if type(value) == "table" then
            copy[index] = cache[value] or self:Copy(value, cache)
        else
            copy[index] = value
        end
    end)
    return copy
end

function Utils:ForEach(t, callback)
    assert(t, "Argument1 is not of type 'table'.")
    for index, value in pairs(t) do
        callback(value, index)
    end
    return t
end

function Utils:Filter(t, callback)
    local filter = {}
    for index, value in pairs(t) do
        if callback(value, index) then
            _G.table.insert(filter, value)
        end
    end
    return filter
end