local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')



---@class PlatoonController
---@field platoon Platoon
PlatoonController = ClassSimple
{

    ---Initializes the platoon controller
    ---@param self PlatoonController
    ---@param platoon Platoon?
    __init = function(self, platoon)
        if platoon then
            self:Platoon(platoon)
        end
    end,

    ---Assigns platoon to be used by the controller
    ---@param self PlatoonController
    ---@param platoon Platoon
    ---@return PlatoonController
    Platoon = function(self, platoon)
        assert(platoon ~= nil, "platoon cant be nil!")
        self.platoon = platoon
        return self
    end,


    ---Creates platoon from unit group defined in map and uses it
    ---@param self PlatoonController
    ---@param armyName ArmyName
    ---@param unitGroup UnitGroup
    ---@param formation FormationType
    ---@return PlatoonController
    FromUnitGroup = function(self, armyName, unitGroup, formation)
        formation = formation or 'NoFormation'
        self:Platoon(ScenarioUtils.CreateArmyGroupAsPlatoon(armyName, unitGroup, formation))
        return self
    end,

    





}
