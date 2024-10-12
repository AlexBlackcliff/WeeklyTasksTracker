--Main.lua
---@type string
local addonName = select(1, ...)
---@class WeeklyTasksTrackerAddon
local wttAddon = select(2, ...)

---@class WeeklyTasksTrackerMain
local Main = {}
wttAddon.Main = Main

local UI = wttAddon.UI
local Data = wttAddon.Data
local Utils = wttAddon.Utils
local Constants = wttAddon.Constants
local LibDBIcon = LibStub("LibDBIcon-1.0")

function Main:ToggleWindow()
    if not self.window then return end
    if self.window:IsVisible() then
        self.window:Hide()
        PlaySound(680)
    else
        self.window:Show()
        PlaySound(679)
    end
    self:Render()
end

function Main:Render()
    local dataTable = Data:GetTableData()
    local tableWidth = 0
    local tableHeight = 0

    if not self.window then
        local frameName = addonName.."MainWindow"
        -- Creating MainWindow Frame
        self.window = UI:CreateMainWindow(frameName, {
            onCloseButtonClickEvent = function() self:ToggleWindow()  end,
            onDropdownSettings = function(_,rootMenu)
                rootMenu:CreateCheckbox(
                    "Show minimap button",
                    function() return not Data.db.global.minimap.hide end,
                    function ()
                        Data.db.global.minimap.hide = not Data.db.global.minimap.hide
                        LibDBIcon:Refresh(addonName, Data.db.global.minimap)
                    end
                )
             end,
            onDropdownFilter = function (_,rootMenu) 
                local hidden = Data.db.global.main.hiddenRows
                Utils:ForEach(Data:GetTableData(true), function(row)
                    if not row.toggleHidden then return end
                    rootMenu:CreateCheckbox(
                        row.name,
                        function ()
                            return not hidden[row.name]
                        end,
                        function(rowName)
                            hidden[rowName] = not hidden[rowName]
                            self:Render()
                        end,
                        row.name
                    )
                end)
            end,
            onDropdownCharacters = function (_,rootMenu)
                Utils:ForEach(Data:GetCharacters(true), function(character)
                    local name = character.name
                    if character.realmName then
                        name = character.name.."-"..character.realmName
                    end
                    if character.classID then
                        local _,classFile = GetClassInfo(character.classID)
                        if classFile then
                            local color = C_ClassColor.GetClassColor(classFile)
                            if color then
                                name = color:WrapTextInColorCode(name)
                            end
                        end
                    end

                    rootMenu:CreateCheckbox(
                        name,
                        function() return character.enabled or false end,
                        function()
                            character.enabled = not character.enabled
                            self:Render()
                        end
                    )
                end)
            end
        })
        self.window.table = UI:CreateTable({
            header = {
                enabled = true,
                height = Constants.ROW_HEGHT
            },
            rows = {
                height = Constants.ROW_HEGHT,
                striped = true
            }
        })
        self.window.table:SetParent(self.window)
        self.window.table:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -Constants.TITLEBAR_HEIGHT)
        self.window.table:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMRIGHT", 0, 0)
        _G.table.insert(UISpecialFrames, frameName)
    end


    --Set Table Width
    tableWidth = tableWidth + self.window.table.config.label.width
    Utils:ForEach(Data:GetCharacters(), function (character)
        tableWidth = tableWidth + self.window.table.config.columns.width
    end)

    --Hides the title if the table is too small
    if self.window.titlebar.border.title  then
        if tableWidth >= 280 then
            self.window.titlebar.border.title:SetText(addonName)
        else
            self.window.titlebar.border.title:SetText("")
        end
    end

    --Set Table Height
    tableHeight = tableHeight + Constants.CELL_PADDING
    Utils:ForEach(dataTable, function (row)
        tableHeight = tableHeight + self.window.table.config.rows.height
    end)
    tableHeight = tableHeight + Constants.CELL_PADDING

    --Set Table Data
    self.window.table:SetData(dataTable)

    self.window:SetWidth(_G.math.max(tableWidth, Constants.MIN_WINDOW_WIDTH))
    self.window:SetHeight(tableHeight + Constants.TITLEBAR_HEIGHT)
end