---@alias NavalAttacksChildType
--- | 'Battleships'
--- | 'Destroyers'
--- | 'Cruisers'
--- | 'Frigate'
--- | 'Submarines'
--- | 'Frigates'
--- | 'T2Submarines'
--- | 'UtilityBoats'
--- | 'Carriers'
--- | 'NukeSubmarines'
--- | 'AABoats'
--- | 'MissileShips'
--- | 'T3Submarines'
--- | 'TorpedoBoats'
--- | 'BattleCruisers'




local IOpAIBuilder = import("BasicOpAIBuilder.lua").IOpAIBuilder

---@class NavalAttacksOpAIBuilder : IOpAIBuilder
NavalAttacksOpAIBuilder = Class(IOpAIBuilder)
{
    Type = 'NavalAttacks',
    ---Sets quantity of children for OpAI
    ---@param self NavalAttacksOpAIBuilder
    ---@param childrenType NavalAttacksChildType|NavalAttacksChildType[]
    ---@param quantity integer
    ---@return NavalAttacksOpAIBuilder
    Quantity = function(self, childrenType, quantity)
        return IOpAIBuilder.Quantity(self, childrenType, quantity)
    end,

    ---Enables children of OpAI
    ---@param self NavalAttacksOpAIBuilder
    ---@param childrenType NavalAttacksChildType
    ---@return NavalAttacksOpAIBuilder
    EnableChild = function(self, childrenType)
        return IOpAIBuilder.EnableChild(self, childrenType)
    end,

    ---Disables children of OpAI
    ---@param self NavalAttacksOpAIBuilder
    ---@param childrenType NavalAttacksChildType
    ---@return NavalAttacksOpAIBuilder
    DisableChild = function(self, childrenType)
        return IOpAIBuilder.DisableChild(self, childrenType)
    end,

    ---Removes children of OpAI
    ---@param self NavalAttacksOpAIBuilder
    ---@param childrenType NavalAttacksChildType|NavalAttacksChildType[]
    ---@return NavalAttacksOpAIBuilder
    RemoveChildren = function(self, childrenType)
        return IOpAIBuilder.RemoveChildren(self, childrenType)
    end,
}
