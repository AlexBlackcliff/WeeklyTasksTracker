--Core.lua
---@type string
local addonName = select(1, ...)
---@class WeeklyTasksTrackerAddon
local wttAddon = select(2, ...)

local Core = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")
wttAddon.Core = Core

local R = wttAddon.R
local Data = wttAddon.Data
local Main = wttAddon.Main
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")


function Core:Render()
    Main:Render()
end

function Core:OnInitialize()
    Data:InitDB()
    Data:MigrateDB()
    self:RegisterChatCommand("wtt", function()
        Main:ToggleWindow()
    end)

    local WTTLDB = LibDataBroker:NewDataObject(addonName, {
        label = addonName,
        type = "launcher",
        icon = R:GetRes("ic_main_logo"),
        OnClick = function()
            Main:ToggleWindow()
        end,
        OnTooltipShow = function(tooltip)
            tooltip:SetText(addonName, 1, 1, 1)
        end
    })
    LibDBIcon:Register(addonName, WTTLDB, Data.db.global.minimap)
    LibDBIcon:AddButtonToCompartment(addonName)

    self:Render()
end

function Core:OnEnable()
    self:RegisterBucketEvent(
        {
            "QUEST_COMPLETE",
            "QUEST_TURNED_IN"
        },
        3,
        function ()
            Data:ScanCharacter()
            self:Render()
        end
    )
    Data:ScanCharacter()
    self:Render()
end

function Core:OnDisable()
    self:UnregisterAllBuckets()
end