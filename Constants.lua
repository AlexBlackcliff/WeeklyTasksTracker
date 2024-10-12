--Constants.lua
---@class WeeklyTasksTrackerAddon
local wttAddon = select(2, ...)

---@class WeeklyTasksTrackerConstants
local Constants = {}
wttAddon.Constants = Constants

Constants.MAX_WINDOW_WIDTH = 256
Constants.MIN_WINDOW_WIDTH = 136
Constants.TITLEBAR_HEIGHT = 18
Constants.ROW_HEGHT = 20
Constants.COLUMN_WIDTH = 120
Constants.LABEL_WIDTH = 80
Constants.CELL_PADDING = 8
Constants.FRAME_OFFSET = 3
Constants.BUTTON_SIZE = 18
Constants.BUTTON_PADDING = 8
