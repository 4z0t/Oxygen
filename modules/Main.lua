if not table.random then
    function table.random(array)
        return array[Random(1, table.getn(array))]
    end
end

---@type FileName
local mapFolder


---Oxygen is Framework for creating coop missions for Supreme Commander FAF.
---Less code -- more Oxygen
_G.Oxygen = {
    Utils = import("Utils.lua"),

    DifficultyValue = import("DifficultyValue.lua"),

    Cinematics = import("AdvancedCinematics.lua"),

    UnitNames = import("UnitNames.lua"),

    AdvancedBaseManager = import("BaseManager/__Init__.lua").BaseManagers.AdvancedBaseManager,
    BaseManagers = import("BaseManager/__Init__.lua").BaseManagers,
    BaseManager = import("BaseManager/__Init__.lua"),

    PlayersManager = import("PlayersManager.lua").PlayersManager,

    RequireIn = import("ObjectiveBuilder.lua").RequireIn,
    ObjectiveBuilder = import("ObjectiveBuilder.lua").ObjectiveBuilder,
    ObjectiveManager = import("ObjectiveManager.lua").ObjectiveManager,

    PlatoonBuilder = import("PlatoonBuilder.lua").PlatoonBuilder,
    PlatoonLoader = import("PlatoonLoader.lua").PlatoonLoader,
    ---@deprecated
    OpAIBuilder = import("OpAIBuilder.lua").OpAIBuilder,

    OpAIBuilders =
    {
        NavalAttacks = import("OpAIBuilders/NavalAttacks.lua").NavalAttacksOpAIBuilder,
        AirAttacks = import("OpAIBuilders/AirAttacks.lua").AirAttacksOpAIBuilder,
        LandAttacks = import("OpAIBuilders/LandAttacks.lua").LandAttacksOpAIBuilder,
        EngineerAttacks = import("OpAIBuilders/EngineerAttacks.lua").EngineerAttacksOpAIBuilder,
    },

    BuildConditions = import("BuildConditions.lua"),

    UnitsController = import("UnitsController.lua").UnitsController,
    PlatoonController = import("PlatoonController.lua").PlatoonController,

    Game = import("GameManager.lua"),

    DifficultyValues = import("DifficultyValue.lua").values,
    Misc = import("Misc.lua"),


    Triggers = import("TriggerManager.lua"),

    Objective =
    {
        Kill = import("Objectives/Kill.lua").KillObjective,
        Capture = import("Objectives/Capture.lua").CaptureObjective,
        CategoriesInArea = import("Objectives/CategoriesInArea.lua").CategoriesInAreaObjective,
    },


    PlatoonAI = {
        Land = "/mods/Oxygen/modules/PlatoonAIs/Land.lua",
        Missiles = "/mods/Oxygen/modules/PlatoonAIs/Missiles.lua",
        Air = "/mods/Oxygen/modules/PlatoonAIs/Air.lua",
        Naval = "/mods/Oxygen/modules/PlatoonAIs/Naval.lua",
        Economy = "/mods/Oxygen/modules/PlatoonAIs/Economy.lua",
        Common = "/mods/Oxygen/modules/PlatoonAIs/Common.lua",
        Expansion = "/mods/Oxygen/modules/PlatoonAIs/Expansion.lua",
    },

    ---Use this table for intellisence support:
    ---```lua
    ---Oxygen.Brains.Aeon = ArmyBrains[2]
    ---...
    ---```
    ---@type table<string, AIBrain>
    Brains = {},

    ---adds scenario folder path to given path of file, if nil returns scenario folder
    ---@param path? string
    ---@return FileName
    ScenarioFolder = function(path)
        mapFolder = mapFolder or ScenarioInfo.script:gsub("[^/]*%.lua$", "")
        return mapFolder .. (path or "")
    end
}
