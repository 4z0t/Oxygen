---@alias EngineerAttacksChildType
--- | 'T3Transports'
--- | 'T2Transports'
--- | 'T1Transports'
--- | 'T3Engineers'
--- | 'T2Engineers'
--- | 'CombatEngineers'
--- | 'T1Engineers'
--- | 'MobileShields'




local IOpAIBuilder = import("BasicOpAIBuilder.lua").IOpAIBuilder

---@class EngineerAttacksOpAIBuilder : IOpAIBuilder
EngineerAttacksOpAIBuilder = Class(IOpAIBuilder)
{
    Type = 'EngineerAttack',
    ---Sets quantity of children for OpAI
    ---@param self EngineerAttacksOpAIBuilder
    ---@param childrenType EngineerAttacksChildType|EngineerAttacksChildType[]
    ---@param quantity integer
    ---@return EngineerAttacksOpAIBuilder
    Quantity = function(self, childrenType, quantity)
        return IOpAIBuilder.Quantity(self, childrenType, quantity)
    end,

    ---Enables children of OpAI
    ---@param self EngineerAttacksOpAIBuilder
    ---@param childrenType EngineerAttacksChildType
    ---@return EngineerAttacksOpAIBuilder
    EnableChild = function(self, childrenType)
        return IOpAIBuilder.EnableChild(self, childrenType)
    end,

    ---Disables children of OpAI
    ---@param self EngineerAttacksOpAIBuilder
    ---@param childrenType EngineerAttacksChildType
    ---@return EngineerAttacksOpAIBuilder
    DisableChild = function(self, childrenType)
        return IOpAIBuilder.DisableChild(self, childrenType)
    end,

    ---Removes children of OpAI
    ---@param self EngineerAttacksOpAIBuilder
    ---@param childrenType EngineerAttacksChildType|EngineerAttacksChildType[]
    ---@return EngineerAttacksOpAIBuilder
    RemoveChildren = function(self, childrenType)
        return IOpAIBuilder.RemoveChildren(self, childrenType)
    end,
}
