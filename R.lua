---@class WeeklyTasksTrackerAddon
local wttAddon = select(2, ...)

---@class WeeklyTasksTrackerRes
local R = {}
wttAddon.R = R

R.ResourceFolder = "Interface\\AddOns\\WeeklyTasksTracker\\Resources\\"

local Locale = {
    enUS = {
        arathi = "Arathi",
        spreading_the_light = "Spreading the Light",
        eyes_of_the_weaver = "Eyes of the Weaver",
        blade_of_the_general = "Blade of the General",
        hand_of_the_vizier = "Hand of the Vizier",
        delve_keys = "Delve Keys",
        dungeon = "Dungeon",
        cinderbew_meadery = "Cinderbrew Meadery",
        city_of_threads = "City of Threads",
        ara_kara_city_of_echoes = "Ara-Kara, City of Echoes",
        the_dawnbreaker = "The Dawnbreaker",
        darkflame_cleft = "Darkflame Cleft",
        priory_of_the_sacred_flame = "Priory of the Sacred Flame",
        the_rookery = "The Rookery",
        the_stonevault = "The Stonevault",
        awakening_the_machine = "Awakening the Machine",
        gearing_up_for_trouble = "Gearing Up for Trouble",
        pvp = "PvP",
        preserving_in_war = "Preserving in War",
        preserving_in_skirmishes = "Preserving in Skirmishes",
        preserving_teamwork = "Preserving Teamwork",
        preserving_in_arenas = "Preserving in Arenas",
        preserving_in_battle = "Preserving in Battle",
        preserving_solo = "Preserving Solo",
        theatre = "Theatre",
        the_theater_troupe = "The Theatre Troupe",
        wax_orbs = "Globs of Wax",
        rollin_down_in_the_deeps = "Rollin' Down in the Deeps",
        world_boss = "World Boss",
        orta_the_broken_mountain = "Orta, The Broken Mountain",
        activation_protocol = "Activation Protocol",
        agregation_of_horrors = "Agregation of Horrors",
        shurrai_atrocity_of_the_undersea = "Shurrai, Atrocity of the Undersea",
        world_pvp = "Sparks (PvP)",
        sparks_of_war_azj_kahet = "Sparks of War: Azj-Kahet",
        sparks_of_war_hallowfall = "Sparks of War: Hallowfall",
        sparks_of_war_isle_of_dorn = "Sparks of War: Isle of Dorn",
        sparks_of_war_the_ringing_deeps = "Sparks of War: The Ringing Deeps"
    },
    esMX = {
        arathi = "Arathi",
        spreading_the_light = "Propagación de la Luz",
        eyes_of_the_weaver = "Eyes of the Weaver",
        blade_of_the_general = "Blade of the General",
        hand_of_the_vizier = "Hand of the Vizier",
        delve_keys = "Llaves de los Abismos",
        dungeon = "Calabozo",
        cinderbew_meadery = "Hidromielería Cinérea",
        city_of_threads = "Ciudad de los Hilos",
        ara_kara_city_of_echoes = "Ara-Kara, Ciudad de los Ecos",
        the_dawnbreaker = "El Rompealbas",
        darkflame_cleft = "Grieta Llama Oscura",
        priory_of_the_sacred_flame = "Priorato de la Llama Sagrada",
        the_rookery = "El Corvento",
        the_stonevault = "La Bóveda de Piedra",
        awakening_the_machine = "Despertar de la Máquina",
        gearing_up_for_trouble = "Gearing Up for Trouble",
        pvp = "JcJ",
        preserving_in_war = "Perseveración en la guerra",
        preserving_in_skirmishes = "Perseveración en refriegas",
        preserving_teamwork = "Perseveración en el trabajo en equipo",
        preserving_in_arenas = "Perseveración en la arena",
        preserving_in_battle = "Perseveración en la batalla",
        preserving_solo = "Perseveración en solitario",
        theatre = "Teatro",
        the_theater_troupe = "Troupe de Teatro",
        wax_orbs = "Orbes de Cera",
        rollin_down_in_the_deeps = "Rollin' Down in the Deeps",
        world_boss = "Jefe de Mundo",
        orta_the_broken_mountain = "Orta, The Broken Mountain",
        activation_protocol = "Activation Protocol",
        agregation_of_horrors = "Aglomeración de horrores",
        shurrai_atrocity_of_the_undersea = "Shurrai, Atrocity of the Undersea",
        world_pvp = "Chispas (JcJ)",
        sparks_of_war_azj_kahet = "Chispas de Guerra: Azj-Kahet",
        sparks_of_war_hallowfall = "Chispas de Guerra: Cristalia",
        sparks_of_war_isle_of_dorn = "Chispas de Guerra: Isla de Dorn",
        sparks_of_war_the_ringing_deeps = "Chispas de Guerra: Las Minas Resonantes"
    }
}

---Gets te localized text
---@param name string
---@return string
function R:GetString(name)
    if GetLocale() == "esMX" then
        return Locale.esMX[name]
    end
    return Locale.enUS[name]
end

---Gets the resource string
---@param name string
---@return string
function R:GetRes(name)
    return self.ResourceFolder..name
end