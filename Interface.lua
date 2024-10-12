---@type string
local addonName = select(1, ...)
---@class WeeklyTasksTrackerAddon
local wttAddon = select(2, ...)

---@class WeeklyTasksTrackerInterface
local UI = {}
wttAddon.UI =  UI

local Constants = wttAddon.Constants
local Utils = wttAddon.Utils
local R = wttAddon.R

function UI:CreateMainWindow(name, events)
    local frame = CreateFrame("Frame", name, UIParent)
    frame:SetSize(500, 500)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(1)
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetPoint("CENTER")
    frame:SetUserPlaced(true)
    frame:RegisterForDrag("LeftButton")
    frame:EnableMouse(true)
    frame:Hide()

    UI:SetBorder(frame, {
        bgFile = R:GetRes("bg_void"),
        tile = true,
        tileSize = 128,
        edgeFile = R:GetRes("border_gold")
    })

    frame.titlebar = CreateFrame("Frame", "$parentTitlebar", frame)
    frame.titlebar:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.titlebar:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    frame.titlebar:SetHeight(Constants.TITLEBAR_HEIGHT)
    frame.titlebar:RegisterForDrag("LeftButton")
    frame.titlebar:EnableMouse(true)
    frame.titlebar:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame.titlebar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    UI:SetBorder(frame.titlebar, {
        bgFile = R:GetRes("bg_dark_stone"),
        tile = true,
        tileSize = 32,
        edgeFile = R:GetRes("border_dark_stone")
    })
    UI:SetTitle(frame.titlebar.border, addonName)

    UI:SetButtons(frame.titlebar, events)

    --Frame Logo
    UI:SetIcon(frame.titlebar.border, R:GetRes("ic_logo_framed"), {
        position = "LEFT",
        offsetX = -16,
        offsetY = -4,
        size = 48
    })

    return frame
end

function UI:SetButtons(parent, events)
    local parentName = parent:GetName()
    do --Close Button
        if not parent.closeButton then
            parent.closeButton = CreateFrame("Button", parentName.."CloseButton", parent)
        end
        parent.closeButton:SetSize(Constants.BUTTON_SIZE, Constants.BUTTON_SIZE)
        parent.closeButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT")
        parent.closeButton:SetScript("OnClick", function ()
            events.onCloseButtonClickEvent()
        end)
        parent.closeButton:SetScript("OnEnter", function ()
            parent.closeButton.icon:SetTexture(R:GetRes("ic_close_high"))
        end)
        parent.closeButton:SetScript("OnLeave", function ()
            parent.closeButton.icon:SetTexture(R:GetRes("ic_close_low"))
        end)

        UI:SetIcon(parent.closeButton, R:GetRes("ic_close_low"))

        UI:SetBorder(parent.closeButton, {
            edgeFile = R:GetRes("border_button"),
            edgeSize = 14,
        })
    end
    do --Settings Button
        if not parent.settingsButton then
            parent.settingsButton = CreateFrame("DropdownButton", parentName.."SettingsButton", parent)
        end
        parent.settingsButton:SetSize(Constants.BUTTON_SIZE, Constants.BUTTON_SIZE)
        parent.settingsButton:SetPoint("RIGHT", parent.closeButton, "LEFT", -Constants.BUTTON_PADDING, 0)
        parent.settingsButton:SetScript("OnEnter", function()
            parent.settingsButton.icon:SetTexture(R:GetRes("ic_settings_high"))
        end)
        parent.settingsButton:SetScript("OnLeave", function()
            parent.settingsButton.icon:SetTexture(R:GetRes("ic_settings_low"))
        end)
        parent.settingsButton:SetupMenu(events.onDropdownSettings)
        UI:SetIcon(parent.settingsButton, R:GetRes("ic_settings_low"))
        UI:SetBorder(parent.settingsButton, {
            edgeFile = R:GetRes("border_button"),
            edgeSize = 14
        })
    end
    do --Filter
        if not parent.filterButton then
            parent.filterButton = CreateFrame("DropdownButton", parentName.."FilterButton", parent)
        end
        parent.filterButton:SetSize(Constants.BUTTON_SIZE, Constants.BUTTON_SIZE)
        parent.filterButton:SetPoint("RIGHT", parent.settingsButton, "LEFT", -Constants.BUTTON_PADDING, 0)
        parent.filterButton:SetScript("OnEnter", function()
            parent.filterButton.icon:SetTexture(R:GetRes("ic_filter_high"))
        end)
        parent.filterButton:SetScript("OnLeave", function()
            parent.filterButton.icon:SetTexture(R:GetRes("ic_filter_low"))
        end)
        parent.filterButton:SetupMenu(events.onDropdownFilter)
        UI:SetIcon(parent.filterButton, R:GetRes("ic_filter_low"))
        UI:SetBorder(parent.filterButton, {
            edgeFile = R:GetRes("border_button"),
            edgeSize = 14
        })
    end
    do --Characters
        if not parent.characterButton then
            parent.characterButton = CreateFrame("DropdownButton", parentName.."FilterButton", parent)
        end
        parent.characterButton:SetSize(Constants.BUTTON_SIZE, Constants.BUTTON_SIZE)
        parent.characterButton:SetPoint("RIGHT", parent.filterButton, "LEFT", -Constants.BUTTON_PADDING, 0)
        parent.characterButton:SetScript("OnEnter", function()
            parent.characterButton.icon:SetTexture(R:GetRes("ic_character_high"))
        end)
        parent.characterButton:SetScript("OnLeave", function()
            parent.characterButton.icon:SetTexture(R:GetRes("ic_character_low"))
        end)
        parent.characterButton:SetupMenu(events.onDropdownCharacters)
        UI:SetIcon(parent.characterButton, R:GetRes("ic_character_low"))
        UI:SetBorder(parent.characterButton, {
            edgeFile = R:GetRes("border_button"),
            edgeSize = 14
        })
    end
end

function UI:SetBorder(parent, config)
    local offset = Constants.FRAME_OFFSET
    local backdrop = CreateFromMixins({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    }, config or {})
    if not parent.border then
        parent.border = CreateFrame("Frame", "$parentBorder", parent, "BackdropTemplate")
    end
    parent.border:SetPoint("TOPLEFT", parent, "TOPLEFT", -offset, offset)
    parent.border:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", offset, -offset)
    parent.border:SetBackdrop(backdrop)
    parent.border:Show()
end


function UI:SetTitle(parent, text)
    if not parent.title then
        parent.title = parent:CreateFontString("$parentText", "OVERLAY")
    end
    parent.title:SetFontObject("GameFontNormal")
    parent.title:SetPoint("LEFT", parent, "LEFT", 36, 0)
    parent.title:SetJustifyH("CENTER")
    parent.title:SetJustifyV("MIDDLE")
    parent.title:SetText(text)
end

function UI:SetIcon(parent, iconRes, config)

    local settings = CreateFromMixins({
        position = "CENTER",
        offsetX = 0,
        offsetY = 0,
        size = Constants.BUTTON_SIZE
    }, config or {})

    if not parent.icon then
        parent.icon = parent:CreateTexture("$parentIcon", "ARTWORK")
    end
    parent.icon:SetPoint(settings.position, parent, settings.position, settings.offsetX, settings.offsetY)
    parent.icon:SetSize(settings.size, settings.size)
    parent.icon:SetTexture(iconRes)
end


function UI:CreateTable(config)
    local tableFrame = CreateFrame("Frame", addonName.."Table")
    tableFrame.config = CreateFromMixins(
        {
            header = {
                enabled = true,
                sticky = false,
                height = Constants.ROW_HEGHT
            },
            label = {
                width = Constants.LABEL_WIDTH
            },
            rows = {
                height = Constants.ROW_HEGHT,
                striped = true
            },
            columns = {
                width = Constants.COLUMN_WIDTH,
                striped = false
            },
            cells = {
                padding = Constants.CELL_PADDING
            },
            data = {}
        },
        config or {}
    )
    tableFrame.rows = {}
    tableFrame.data = tableFrame.config.data

    function tableFrame:SetData(data)
        self.data = data
        self:RenderTable()
    end

    function tableFrame:RenderTable()
        local offsetY = Constants.CELL_PADDING
        local offsetX = 0

        Utils:ForEach(self.rows, function (rowFrame) rowFrame:Hide() end)
        Utils:ForEach(self.data, function(row, rowIndex)
            local rowFrame = tableFrame.rows[rowIndex]
            local rowHeight = tableFrame.config.rows.height
            local labelWidth = tableFrame.config.label.width
            
            --tableFrame.config.cells.padding
            if not rowFrame then
                rowFrame = CreateFrame("Button", "$parentRow"..rowIndex, tableFrame)
                rowFrame.columns = {}
                tableFrame.rows[rowIndex] = rowFrame
            end
            rowFrame:SetPoint("TOPLEFT", tableFrame, "TOPLEFT", 0, -offsetY)
            rowFrame:SetPoint("TOPRIGHT", tableFrame, "TOPRIGHT", 0, -offsetY)
            rowFrame.data = row
            rowFrame:SetHeight(rowHeight)

            rowFrame:SetScript("OnEnter", function() UI:SetHighlight(rowFrame, true) end)
            rowFrame:SetScript("OnLeave", function() UI:SetHighlight(rowFrame, false) end)
            rowFrame:Show()
            
            offsetX = 0
            Utils:ForEach(rowFrame.columns, function(columnFrame) columnFrame:Hide() end)
            do -- Labels
                local labelFrame = rowFrame.columns[0]
                if not labelFrame then
                    labelFrame = CreateFrame("Button", "$parentLabel", rowFrame)
                    --labelFrame.text = labelFrame:CreateFontString("$parentText", "OVERLAY")
                    --labelFrame.text:SetFontObject("GameFontNormalSmall")
                    rowFrame.columns[0] = labelFrame
                end

                labelFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", offsetX, 0)
                labelFrame:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", offsetX, 0)
                labelFrame:SetWidth(labelWidth)

                labelFrame:SetScript("OnEnter", function() UI:SetHighlight(rowFrame, true) end)
                labelFrame:SetScript("OnLeave", function() UI:SetHighlight(rowFrame, false) end)

                UI:SetText(labelFrame, row.name, {
                    alignment = "LEFT",
                    paddingH = 8,
                    paddingV = 2
                })

                labelFrame:Show()
            end

            offsetX = labelWidth

            Utils:ForEach(row.columns, function(column, columnIndex)
                local columnWidth = tableFrame.config.columns.width
                local columnFrame = rowFrame.columns[columnIndex]

                columnFrame = nil

                if not columnFrame then
                    columnFrame = CreateFrame("Button", "$parentCol"..columnIndex, rowFrame)
                    rowFrame.columns[columnIndex] = columnFrame
                end

                columnFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", offsetX, 0)
                columnFrame:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", offsetX, 0)
                columnFrame:SetWidth(columnWidth)

                columnFrame:SetScript("OnEnter", function() UI:SetHighlight(rowFrame, true) end)
                columnFrame:SetScript("OnLeave", function() UI:SetHighlight(rowFrame, false) end)

                local case = {
                    ["text"] = function()
                        UI:SetText(columnFrame, column.value, {
                            alignment = "CENTER",
                            paddingH = 8,
                            paddingV = 2
                        })
                    end,
                    ["check"] = function()
                        if column.value then
                            UI:SetIcon(columnFrame, R:GetRes("ic_checkbox_checked"), {size = 16})
                        else
                            UI:SetIcon(columnFrame, R:GetRes("ic_checkbox"), {size = 16})
                        end
                    end
                }

                case[column.cellType]()

                columnFrame:Show()

                offsetX = offsetX + columnWidth
            end)
            offsetY = offsetY + rowHeight
        end)

    end

    tableFrame:RenderTable()
    return tableFrame
end

function UI:SetHighlight(parent, enabled)
    if not parent.bg then
        parent.bg = parent:CreateTexture("Background", "BACKGROUND")
        parent.bg:SetTexture(R:GetRes("bg_white_8x64"))
        parent.bg:SetAllPoints()
    end

    if enabled then
        parent.bg:SetVertexColor(0.961, 0.792, 0.071, 0.2)
    else
        parent.bg:SetVertexColor(0, 0, 0, 0)
    end
end

function UI:SetText(parent, text, config)
    local settings = CreateFromMixins({
        alignment = "CENTER",
        paddingH = 0,
        paddingV = 0
    },
    config or {})
    if not parent.text then
        parent.text = parent:CreateFontString("$parentText", "OVERLAY")
        parent.text:SetFontObject("GameFontNormalSmall")
    end

    parent.text:SetJustifyH(settings.alignment)
    parent.text:SetPoint("TOPLEFT", parent, "TOPLEFT", settings.paddingH, -settings.paddingV)
    parent.text:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -settings.paddingH, settings.paddingV)
    parent.text:SetText(tostring(text))
end