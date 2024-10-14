---@class WTT_Global
---@field minimap {minimapPos: number, hide: boolean, lock: boolean}
---@field characters table<string, WTT_Character>
---@field main WTT_Main

---@class WTT_Main
---@field hiddenRows table<string, boolean>
---@field windowScale integer

---@class WTT_DataRow
---@field name string
---@field width integer
---@field align "LEFT" | "CENTER" | "RIGHT" | nil
---@field onEnter function?
---@field onLeave function?
---@field cell fun(character: WTT_Character): WTT_TableCell

---@class WTT_Character
---@field GUID string|WOWGUID
---@field name string
---@field realmName string
---@field level integer
---@field classID integer
---@field enabled boolean
---@field lastUpdate number
---@field completed table

---@class WTT_Task
---@field name string
---@field taskType Enum.WTT_TaskType
---@field quests WTT_Quest[]

---@class WTT_Quest
---@field id integer
---@field name string

---@class WTT_Table
---@field rows WTT_TableRow[]

---@class WTT_TableRow
---@field name string
---@field toggleHidden boolean
---@field columns WTT_TableCell[]
---@field onEnter function?
---@field onLeave function?

---@class WTT_TableCell
---@field cellType string
---@field value string|boolean


---@enum Enum.WTT_TaskType
Enum.WTT_TaskType = {
    Single = "Single",
    Multi = "Multi",
    Count = "Count",
    Label = "Label"
}