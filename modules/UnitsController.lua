local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

---@class UnitsController
---@field units Unit[]
---@field chains MarkerChain[]
UnitsController = ClassSimple
{
    ---Initialize the units controller
    ---@param self UnitsController
    ---@param units Unit[]?
    __init = function(self, units)
        if units then
            self:Units(units)
        end
    end,

    ---Assignes units to units controller
    ---@param self UnitsController
    ---@param units Unit[]
    ---@return UnitsController
    Units = function(self, units)
        self.units = units
        return self
    end,

    ---Assignes unit for units controller
    ---@param self UnitsController
    ---@param unit Unit
    ---@return UnitsController
    Unit = function(self, unit)
        self.units = { unit }
        return self
    end,

    ---Creates unit for army defined on the map
    ---@param self UnitsController
    ---@param army ArmyName
    ---@param name UnitGroup
    ---@return UnitsController
    FromArmyUnit = function(self, army, name)
        self:Unit(ScenarioUtils.CreateArmyUnit(army, name))
        return self
    end,

    ---Applies given function to units
    ---@param self UnitsController
    ---@param fn fun(unit:Unit)
    ---@return UnitsController
    ApplyToUnits = function(self, fn)
        for _, unit in self.units do
            fn(unit)
        end
        return self
    end,

    ---Assignes units to units controller from given platoon
    ---@param self UnitsController
    ---@param platoon Platoon
    ---@return UnitsController
    FromPlatoon = function(self, platoon)
        return self:Units(platoon:GetPlatoonUnits())
    end,

    ---Orders units to move along the chain
    ---@param self UnitsController
    ---@param chain MarkerChain
    ---@return UnitsController
    MoveChain = function(self, chain)
        ScenarioFramework.GroupMoveChain(self.units, chain)
        return self
    end,

    ---Orders units to patrol along the chain
    ---@param self UnitsController
    ---@param chain MarkerChain
    ---@return UnitsController
    PatrolChain = function(self, chain)
        ScenarioFramework.GroupPatrolChain(self.units, chain)
        return self
    end,

    ---Orders units to attack-move along the chain
    ---@param self UnitsController
    ---@param chain MarkerChain
    ---@return UnitsController
    AttackChain = function(self, chain)
        ScenarioFramework.GroupAttackChain(self.units, chain)
        return self
    end,

    ---Sets chains to be used for picking
    ---@param self UnitsController
    ---@param chains MarkerChain[]
    ---@return UnitsController
    Chains = function(self, chains)
        self.chains = chains
        return self
    end,

    ---Returns random chain from set ones
    ---@param self UnitsController
    ---@return MarkerChain
    GetRandomChain = function(self)
        return ScenarioFramework.GetRandomEntry(self.chains)
    end,

    ---Orders units to attack-move along a random chain
    ---@param self UnitsController
    ---@return UnitsController
    PickRandomAttackChain = function(self)
        return self:AttackChain(self:GetRandomChain())
    end,

    ---Orders units to move along a random chain
    ---@param self UnitsController
    ---@return UnitsController
    PickRandomMoveChain = function(self)
        return self:MoveChain(self:GetRandomChain())
    end,

    ---Orders units to patrol along a random chain
    ---@param self UnitsController
    PickRandomPatrolChain = function(self)
        return self:PatrolChain(self:GetRandomChain())
    end,

    ---Orders units to attack given unit
    ---@param self UnitsController
    ---@param unit Unit unit to attack
    ---@return UnitsController
    AttackUnit = function(self, unit)
        IssueAttack(self.units, unit)
        return self
    end,

    ---Orders units to patrol along a random route based on a given chain
    ---@param self any
    ---@param chain any
    ---@return UnitsController
    PickRandomPatrolRoute = function(self, chain)
        ScenarioFramework.GroupPatrolRoute(self.units,
            ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions(chain)))
        return self
    end,

    ---Scatters units on different random routes based on a given chain
    ---@param self UnitsController
    ---@param chain MarkerChain
    ---@return UnitsController
    ScatterRandomPatrolRoute = function(self, chain)
        for _, unit in self.units do
            ScenarioFramework.GroupPatrolRoute({ unit },
                ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions(chain)))
        end
        return self
    end,


    ---Orders units to attack-move to given marker
    ---@param self UnitsController
    ---@param marker Marker
    ---@return UnitsController
    AttackMoveToMarker = function(self, marker)
        IssueAggressiveMove(self.units, ScenarioUtils.MarkerToPosition(marker))
        return self
    end,

    ---Orders units to reclaim given unit
    ---@param self UnitsController
    ---@param unit Unit
    ---@return UnitsController
    ReclaimUnit = function(self, unit)
        IssueReclaim(self.units, unit)
        return self
    end,















    ---Clears units controller
    ---@param self UnitsController
    Clear = function(self)
        self.units = nil
        self.chains = nil
    end
}
