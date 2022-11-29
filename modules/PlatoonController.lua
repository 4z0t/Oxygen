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

    ---Applies given function to units of platoon
    ---@param self PlatoonController
    ---@param fn fun(unit:Unit)
    ---@return PlatoonController
    ApplyToUnits = function(self, fn)
        for _, unit in self.platoon:GetPlatoonUnits() do
            fn(unit)
        end
        return self
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

    ---Returns the platoon
    ---@param self PlatoonController
    ---@return Platoon
    GetPlatoon = function(self)
        return self.platoon
    end,


    ---Creates platoon from unit group defined in map and uses it
    ---@param self PlatoonController
    ---@param armyName ArmyName
    ---@param unitGroup UnitGroup
    ---@param formation FormationType
    ---@return PlatoonController
    FromUnitGroup = function(self, armyName, unitGroup, formation)
        return self:Platoon(ScenarioUtils.CreateArmyGroupAsPlatoon(armyName, unitGroup, formation or 'NoFormation'))
    end,


    ---Creates platoon from given units of aiBrain
    ---@param self PlatoonController
    ---@param units Unit[]
    ---@param aiBrain AIBrain
    ---@param squad PlatoonSquads?
    ---@param formation FormationType?
    ---@return PlatoonController
    FromUnits = function(self, units, aiBrain, squad, formation)
        self.platoon = aiBrain:MakePlatoon("", "")
        aiBrain:AssignUnitsToPlatoon(self.platoon, units, squad or "None", formation or "NoFormation")
        return self
    end,









}
