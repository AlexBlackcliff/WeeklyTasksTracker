--Data.lua

---@class WeeklyTasksTrackerAddon
local wttAddon = select(2, ...)

---@class WeeklyTasksTrackerData
local Data = {}
wttAddon.Data = Data

local Utils = wttAddon.Utils
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
        name = "Arathi",
        taskType = "single",
        quests = {76588}
    },
    {
        name = "Azj-Kahet",
        taskType = "single",
        quests = {80670, 80671, 80672}
    },
    {
        name = "Delve Keys",
        taskType = "count",
        quests = {84736, 84737, 84738, 84739}
    },
    {
        name = "Dungeon",
        taskType = "single",
        quests = {83436, 83469, 83465, 83459, 83443, 83458, 83432}
    },
    {
        name = "Gundargaz",
        taskType = "single",
        quests = {83333}
    },
    {
        name = "PvP",
        taskType = "single",
        quests = {80186, 80187, 80189, 80188, 80184, 80185}
    },
    {
        name = "Theatre",
        taskType = "single",
        quests = {83240}
    },
    {
        name = "Wax Orbs",
        taskType = "single",
        quests = {82946}
    },
    {
        name = "World Boss",
        taskType = "single",
        quests = {81624}
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

    --TODO REWORK
    --Tasks
    character.completed = {}
    Utils:ForEach(Data.weeklyTasks, function(task)
        if not task.quests then return end
        Utils:ForEach(task.quests, function(questID)
            if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                character.completed[questID] = true
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
            name = "Tasks",
            toggleHidden = false,
            columns = columns
        }
    }
    --Tasks
    Utils:ForEach(self.weeklyTasks, function(weeklyTask)
        local dataCells = {}
        Utils:ForEach(characters, function(character)
            if weeklyTask.taskType == "count" then
                local max = #weeklyTask.quests
                local count = 0
                Utils:ForEach(weeklyTask.quests, function (questID)
                    if character.completed[questID] then
                        count = count + 1
                    end
                end)
                _G.table.insert(dataCells, {
                    cellType = "text",
                    value = string.format("%s / %s", count, max)
                })
            end
            if weeklyTask.taskType == "single" then
                local completed = false
                Utils:ForEach(weeklyTask.quests, function(questID)
                    if character.completed[questID] then
                        completed = true
                    end
                end)
                _G.table.insert(dataCells, {
                    cellType = "check",
                    value = completed
                })
            end
        end)
        local dataTask = {
            name = weeklyTask.name,
            toggleHidden = true,
            columns = dataCells
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

