---@class WeeklyTasksTrackerAddon
local wttAddon = select(2, ...)

---@class WeeklyTasksTrackerRes
local R = {}
wttAddon.R = R

R.ResourceFolder = "Interface\\AddOns\\WeeklyTasksTracker\\Resources\\"

---Gets te localized text
---@param name string
---@return string
function R:GetString(name)
    return name
end

---Gets the resource string
---@param name string
---@return string
function R:GetRes(name)
    return self.ResourceFolder..name
end