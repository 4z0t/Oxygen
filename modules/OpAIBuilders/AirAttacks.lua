---@alias AirAttacksChildType
--- | 'Interceptors'
--- | 'LightGunships'
--- | 'Bombers'
--- |
--- | 'TorpedoBombers'
--- | 'GuidedMissiles'
--- | 'Gunships'
--- | 'CombatFighters'
--- |
--- | 'StratBombers'
--- | 'AirSuperiority'
--- | 'HeavyGunships'
--- | 'HeavyTorpedoBombers'



local IOpAIBuilder = import("BasicOpAIBuilder.lua").IOpAIBuilder

---@class AirAttacksOpAIBuilder : IOpAIBuilder
AirAttacksOpAIBuilder = Class(IOpAIBuilder)
{
    Type = 'AirAttacks',
    ---Sets quantity of children for OpAI
    ---@param self AirAttacksOpAIBuilder
    ---@param childrenType AirAttacksChildType|AirAttacksChildType[]
    ---@param quantity integer
    ---@return AirAttacksOpAIBuilder
    Quantity = function(self, childrenType, quantity)
        return IOpAIBuilder.Quantity(self, childrenType, quantity)
    end,

    ---Enables children of OpAI
    ---@param self AirAttacksOpAIBuilder
    ---@param childrenType AirAttacksChildType
    ---@return AirAttacksOpAIBuilder
    EnableChild = function(self, childrenType)
        return IOpAIBuilder.EnableChild(self, childrenType)
    end,

    ---Disables children of OpAI
    ---@param self AirAttacksOpAIBuilder
    ---@param childrenType AirAttacksChildType
    ---@return AirAttacksOpAIBuilder
    DisableChild = function(self, childrenType)
        return IOpAIBuilder.DisableChild(self, childrenType)
    end,

    ---Removes children of OpAI
    ---@param self AirAttacksOpAIBuilder
    ---@param childrenType AirAttacksChildType|AirAttacksChildType[]
    ---@return AirAttacksOpAIBuilder
    RemoveChildren = function(self, childrenType)
        return IOpAIBuilder.RemoveChildren(self, childrenType)
    end,
}
