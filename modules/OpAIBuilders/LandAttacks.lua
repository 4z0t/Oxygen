---@alias LandAttacksChildType
--- | 'T3Transports'
--- | 'MobileMissilePlatforms'
--- | 'MobileShields'
--- | 'HeavyBots'
--- | 'MobileFlak'
--- | 'MobileHeavyArtillery'
--- | 'MobileStealth'
--- | 'SiegeBots'
--- | 'MobileBombs'
--- | 'RangeBots'
--- | 'LightArtillery'
--- | 'AmphibiousTanks'
--- | 'LightTanks'
--- | 'HeavyMobileAntiAir'
--- | 'MobileMissiles'
--- | 'HeavyTanks'
--- | 'MobileAntiAir'
--- | 'LightBots'
--- | 'T1Transports'
--- | 'T2Transports'



local IOpAIBuilder = import("BasicOpAIBuilder.lua").IOpAIBuilder

---@class LandAttacksOpAIBuilder : IOpAIBuilder
LandAttacksOpAIBuilder = Class(IOpAIBuilder)
{
    Type = "BasicLandAttack",
    ---Sets quantity of children for OpAI
    ---@param self LandAttacksOpAIBuilder
    ---@param childrenType LandAttacksChildType|LandAttacksChildType[]
    ---@param quantity integer
    ---@return LandAttacksOpAIBuilder
    Quantity = function(self, childrenType, quantity)
        return IOpAIBuilder.Quantity(self, childrenType, quantity)
    end,

    ---Enables children of OpAI
    ---@param self LandAttacksOpAIBuilder
    ---@param childrenType LandAttacksChildType
    ---@return LandAttacksOpAIBuilder
    EnableChild = function(self, childrenType)
        return IOpAIBuilder.EnableChild(self, childrenType)
    end,

    ---Disables children of OpAI
    ---@param self LandAttacksOpAIBuilder
    ---@param childrenType LandAttacksChildType
    ---@return LandAttacksOpAIBuilder
    DisableChild = function(self, childrenType)
        return IOpAIBuilder.DisableChild(self, childrenType)
    end,

    ---Removes children of OpAI
    ---@param self LandAttacksOpAIBuilder
    ---@param childrenType LandAttacksChildType|LandAttacksChildType[]
    ---@return LandAttacksOpAIBuilder
    RemoveChildren = function(self, childrenType)
        return IOpAIBuilder.RemoveChildren(self, childrenType)
    end,
}
