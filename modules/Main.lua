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

    BaseManager = import("AdvancedBaseManager.lua").AdvancedBaseManager,
    BaseManagers = import("AdvancedBaseManager.lua"),

    PlayersManager = import("PlayersManager.lua").PlayersManager,

    RequireIn = import("ObjectiveBuilder.lua").RequireIn,
    ObjectiveBuilder = import("ObjectiveBuilder.lua").ObjectiveBuilder,
    ObjectiveManager = import("ObjectiveManager.lua").ObjectiveManager,

    PlatoonBuilder = import("PlatoonBuilder.lua").PlatoonBuilder,
    PlatoonLoader = import("PlatoonLoader.lua").PlatoonLoader,

    OpAIBuilder = import("OpAIBuilder.lua").OpAIBuilder,

    BuildConditions = import("BuildConditions.lua"),

    UnitsController = import("UnitsController.lua").UnitsController,
    PlatoonController = import("PlatoonController.lua").PlatoonController,

    Game = import("GameManager.lua"),

    PlatoonAI = {
        Land = "/mods/Oxygen/modules/PlatoonAIs/Land.lua",
        Missiles = "/mods/Oxygen/modules/PlatoonAIs/Missiles.lua",
        Air = "",
        Naval = "",
    },

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
