--Data.lua

---@class WeeklyTasksTrackerAddon
local wttAddon = select(2, ...)

---@class WeeklyTasksTrackerData
local Data = {}
wttAddon.Data = Data

local Utils = wttAddon.Utils
local R = wttAddon.R
local AceDB = LibStub("AceDB-3.0")


Data.databaseVersion = 1
Data.defaultDatabase = {
    ---@type WTT_Global
    global = {
        minimap = {
            minimapPosition = 250,
            hide = false,
            lock = false
        },
        characters = {},
        main = {
            hiddenRows = {},
            windowScale = 100
        }
    }
}

---@type WTT_Character
Data.defaultCharacter =
{
    enabled = true,
    lastUpdate = 0,
    GUID = "",
    name = "",
    realmName = "",
    level = 0,
    classID = 0,
    completed = {}
}



---@type WTT_Task[]
Data.weeklyTasks = {
    {
        name = R:GetString("arathi"),
        taskType = Enum.WTT_TaskType.Single,
        quests = {
            { id = 76586, name = R:GetString("spreading_the_light") }
        }
    },
    {
        name = "Azj-Kahet",
        taskType = Enum.WTT_TaskType.Single,
        quests = {
            { id = 80670, name = R:GetString("eyes_of_the_weaver") },
            { id = 80671, name = R:GetString("blade_of_the_general") },
            { id = 80672, name = R:GetString("hand_of_the_vizier") }
        }
    },
    {
        name = R:GetString("delve_keys"),
        taskType = Enum.WTT_TaskType.Count,
        quests = {
            { id = 84736, name = "" },
            { id = 84737, name = "" },
            { id = 84738, name = "" },
            { id = 84739, name = "" }
        }
    },
    {
        name = R:GetString("dungeon"),
        taskType = Enum.WTT_TaskType.Single,
        quests = {
            { id = 83436, name = R:GetString("cinderbew_meadery") },
            { id = 83469, name = R:GetString("city_of_threads") },
            { id = 83465, name = R:GetString("ara_kara_city_of_echoes") },
            { id = 83459, name = R:GetString("the_dawnbreaker") },
            { id = 83443, name = R:GetString("darkflame_cleft") },
            { id = 83458, name = R:GetString("priory_of_the_sacred_flame") },
            { id = 83432, name = R:GetString("the_rookery") },
            { id = 83432, name = R:GetString("the_stonevault") }
        }
    },
    {
        name = R:GetString("awakening_the_machine"),
        taskType = Enum.WTT_TaskType.Single,
        quests = {
            { id = 83333, name = R:GetString("gearing_up_for_trouble") }
        }
    },
    {
        name = R:GetString("pvp"),
        taskType = Enum.WTT_TaskType.Single,
        quests = {
            { id = 80186, name = R:GetString("preserving_in_war") },
            { id = 80187, name = R:GetString("preserving_in_skirmishes") },
            { id = 80189, name = R:GetString("preserving_teamwork") },
            { id = 80188, name = R:GetString("preserving_in_arenas") },
            { id = 80184, name = R:GetString("preserving_in_battle") },
            { id = 80185, name = R:GetString("preserving_solo") }
        }
    },
    {
        name = R:GetString("world_pvp"),
        taskType = Enum.WTT_TaskType.Single,
        quests = {
            { id = 81796, name = R:GetString("sparks_of_war_azj_kahet") },
            { id = 81795, name = R:GetString("sparks_of_war_hallowfall") },
            { id = 81793, name = R:GetString("sparks_of_war_isle_of_dorn") },
            { id = 81794, name = R:GetString("sparks_of_war_the_ringing_deeps") }
        }
    },
    {
        name = R:GetString("theatre"),
        taskType = Enum.WTT_TaskType.Single,
        quests = {
            { id = 83240, name = R:GetString("the_theater_troupe") }
        }
    },
    {
        name = R:GetString("wax_orbs"),
        taskType = Enum.WTT_TaskType.Single,
        quests = {
            { id = 82946, name = R:GetString("rollin_down_in_the_deeps") }
        }
    },
    {
        name = R:GetString("world_boss"),
        taskType = Enum.WTT_TaskType.Single,
        quests = {
            { id = 81624, name = R:GetString("orta_the_broken_mountain") },
            { id = 81630, name = R:GetString("activation_protocol") },
            { id = 82653, name = R:GetString("agregation_of_horrors") },
            { id = 81653, name = R:GetString("shurrai_atrocity_of_the_undersea") }
        }
    }
}

--Initiates database
function Data:InitDB()
    self.db = AceDB:New("WeeklyTasksTrackerDatabase", self.defaultDatabase, true)
end

--Handles database migrations
function Data:MigrateDB()
    if type(self.db.global.databaseVersion) ~= "number" then
        self.db.global.databaseVersion = self.databaseVersion
    end

    if self.db.global.databaseVersion < self.databaseVersion then
        self.db.global.databaseVersion = self.db.global.databaseVersion + 1
        self:MigrateDB()
    end
end

---Get character by GUID
---@param GUID WOWGUID?
---@return WTT_Character|nil
function Data:GetCharacter(GUID)
    if GUID == nil then
        GUID = UnitGUID("player")
    end

    if GUID == nil then
        return nil
    end

    --If character is not in DB
    if self.db.global.characters[GUID] == nil then
        --Add character to DB
        self.db.global.characters[GUID] = Utils:Copy(self.defaultCharacter)
    end

    self.db.global.characters[GUID].GUID = GUID

    return self.db.global.characters[GUID]
end

--Scan for character info and saves it into DB
function Data:ScanCharacter()
    local character = self:GetCharacter()
    if not character then return end

    local _, _, classID = UnitClass("player")

    character.name = UnitName("player")
    character.realmName = GetRealmName()
    character.level = UnitLevel("player")
    character.classID = classID
    character.lastUpdate = GetServerTime()

    --Tasks
    character.completed = {}
    Utils:ForEach(Data.weeklyTasks, function(task)
        if not task.quests then return end
        Utils:ForEach(task.quests, function(quest)
            if C_QuestLog.IsQuestFlaggedCompleted(quest.id) then
                character.completed[quest.id] = true
            end
        end)
    end)

    --Only track max level characters
    if character.level < 80 then
        --Remove character from DB
        self.db.global.characters[character.GUID] = nil
    end
end

---Get All Characters
---@param isUnfiltered boolean?
---@return WTT_Character[]
function Data:GetCharacters(isUnfiltered)
    local characters = Utils:Filter(self.db.global.characters, function(character) 
        local include = true
        if not isUnfiltered then
            if not character.enabled then
                include = false
            end
        end
        return include
    end)

    _G.table.sort(characters, function(a, b)
        if type(a.lastUpdate) == "number" and type(b.lastUpdate) == "number" then
            return a.lastUpdate > b.lastUpdate
        end
        return strcmputf8i(a.name, b.name) < 0
    end)

    return characters
end

---Obtains the table data
---@param isUnfiltered boolean?
---@return WTT_TableRow[]
function Data:GetTableData(isUnfiltered)
    local hidden = Data.db.global.main.hiddenRows
    local columns = {}
    local characters = Data:GetCharacters()
    Utils:ForEach(characters, function (character)
        local name = character.name
        local _, classFile = GetClassInfo(character.classID)
        local color = C_ClassColor.GetClassColor(classFile)
        if color then
            name = color:WrapTextInColorCode(name)
        end

        _G.table.insert(columns, {
            cellType = "text",
            value = name
        })
    end)
    local tasks = {
        {
            name = "",
            toggleHidden = false,
            columns = columns
        }
    }
    --Tasks
    Utils:ForEach(self.weeklyTasks, function(weeklyTask)
        local dataCells = {}
        Utils:ForEach(characters, function(character)
            if weeklyTask.taskType == Enum.WTT_TaskType.Count then
                local max = #weeklyTask.quests
                local count = 0
                Utils:ForEach(weeklyTask.quests, function (quest)
                    if character.completed[quest.id] then
                        count = count + 1
                    end
                end)
                _G.table.insert(dataCells, {
                    cellType = "text",
                    value = string.format("%s / %s", count, max)
                })
            end
            if weeklyTask.taskType == Enum.WTT_TaskType.Single then
                local completed = false
                Utils:ForEach(weeklyTask.quests, function(quest)
                    if character.completed[quest.id] then
                        completed = true
                    end
                end)
                _G.table.insert(dataCells, {
                    cellType = "check",
                    value = completed
                })
            end
            if weeklyTask.taskType == Enum.WTT_TaskType.Label then
                _G.table.insert(dataCells, {
                    cellType = "label",
                    value = ""
                })
            end
        end)
        local dataTask = {
            name = weeklyTask.name,
            toggleHidden = true,
            columns = dataCells,
            onEnter = function (frame)
                GameTooltip:SetOwner(frame, "ANCHOR_TOP")
                GameTooltip:SetText(weeklyTask.name)
                Utils:ForEach(weeklyTask.quests, function (q)
                    if q.name and q.name == "" then return end
                    local isActive = C_TaskQuest.IsActive(q.id) or C_QuestLog.IsOnQuest(q.id) or false
                    local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(q.id)
                    if isCompleted then
                        GameTooltip:AddLine(GREEN_FONT_COLOR:WrapTextInColorCode(q.name))
                        return
                    end
                    if isActive then
                        GameTooltip:AddLine(WHITE_FONT_COLOR:WrapTextInColorCode(q.name))
                    else
                        GameTooltip:AddLine(LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(q.name))
                    end
                end)
                GameTooltip:Show()
            end,
            onLeave = function ()
                GameTooltip:Hide()
            end,
        }
        _G.table.insert(tasks, dataTask)
    end)

    if isUnfiltered then
        return tasks
    end

    local filteredTasks = Utils:Filter(tasks, function (task)
        return not hidden[task.name]
    end)

    return filteredTasks
end

