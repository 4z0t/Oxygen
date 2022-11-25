---Oxygen is Framework for creating coop missions for Supreme Commander FAF.
---Less code -- more Oxygen
_G.Oxygen = {
    Utils = import("Utils.lua"),

    DifficultyValue = import("DifficultyValue.lua"),

    Cinematics = import("AdvancedCinematics.lua"),

    UnitNames = import("UnitNames.lua"),

    BaseManager = import("AdvancedBaseManager.lua").AdvancedBaseManager,

    PlayersManager = import("PlayersManager.lua").PlayersManager,

    RequireIn = import("ObjectiveBuilder.lua").RequireIn,
    ObjectiveBuilder = import("ObjectiveBuilder.lua").ObjectiveBuilder,
    ObjectiveManager = import("ObjectiveManager.lua").ObjectiveManager,

    PlatoonBuilder = import("PlatoonBuilder.lua").PlatoonBuilder,
    PlatoonLoader = import("PlatoonLoader.lua").PlatoonLoader,

    OpAIBuilder = import("OpAIBuilder.lua").OpAIBuilder,

    BuildConditions = import("BuildConditions.lua")
}
