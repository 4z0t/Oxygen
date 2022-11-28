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
    ---@param units Unit[]
    __init = function(self, units)
        if units then
            self:Units(units)
        end
    end,

    ---Assignes units to units controller
    ---@param self UnitsController
    ---@param units Unit[]
    Units = function(self, units)
        self.units = units
    end,

    ---Assignes unit for units controller
    ---@param self UnitsController
    ---@param unit Unit
    Unit = function(self, unit)
        self.units = { unit }
    end,


    ---Orders units to move along the chain
    ---@param self UnitsController
    ---@param chain MarkerChain
    MoveChain = function(self, chain)
        ScenarioFramework.GroupMoveChain(self.units, chain)
    end,

    ---Orders units to patrol along the chain
    ---@param self UnitsController
    ---@param chain MarkerChain
    PatrolChain = function(self, chain)
        ScenarioFramework.GroupPatrolChain(self.units, chain)
    end,

    ---Orders units to attack-move along the chain
    ---@param self UnitsController
    ---@param chain MarkerChain
    AttackChain = function(self, chain)
        ScenarioFramework.GroupAttackChain(self.units, chain)
    end,

    ---Sets chains to be used for picking
    ---@param self UnitsController
    ---@param chains MarkerChain[]
    Chains = function(self, chains)
        self.chains = chains
    end,

    ---Returns random chain from set ones
    ---@param self UnitsController
    ---@return MarkerChain
    GetRandomChain = function(self)
        return ScenarioFramework.GetRandomEntry(self.chains)
    end,

    ---Orders units to attack-move along a random chain
    ---@param self UnitsController
    PickRandomAttackChain = function(self)
        self:AttackChain(self:GetRandomChain())
    end,

    ---Orders units to move along a random chain
    ---@param self UnitsController
    PickRandomMoveChain = function(self)
        self:MoveChain(self:GetRandomChain())
    end,

    ---Orders units to patrol along a random chain
    ---@param self UnitsController
    PickRandomPatrolChain = function(self)
        self:PatrolChain(self:GetRandomChain())
    end,

    ---Orders units to attack given unit
    ---@param self UnitsController
    ---@param unit Unit unit to attack
    AttackUnit = function(self, unit)
        IssueAttack(self.units, unit)
    end,

    ---Orders units to patrol along a random route based on a given chain
    ---@param self any
    ---@param chain any
    RandomPatrolRoute = function(self, chain)
        ScenarioFramework.GroupPatrolRoute(self.units,
            ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions(chain)))
    end,

    








}
