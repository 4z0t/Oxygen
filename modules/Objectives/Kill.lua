local CountObjective = import("IObjective.lua").CountObjective
local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local ObjectiveArrow = import("/lua/objectivearrow.lua").ObjectiveArrow


---@class KillObjective : CountObjective
---@field UnitDeathTrigger UnitDestroyedTrigger
---@field UnitGivenTrigger UnitGivenTrigger
KillObjective = Class(CountObjective)
{
    Icon = "Kill",

    ---@param self KillObjective
    OnCreate = function(self)
        CountObjective.OnCreate(self)

        self.UnitDeathTrigger = Oxygen.Triggers.UnitDestroyedTrigger(
            function(unit)
                self:OnUnitKilled(unit)
            end
        )

        self.UnitGivenTrigger = Oxygen.Triggers.UnitGivenTrigger(
            function(oldUnit, newUnit)
                self:OnUnitGiven(oldUnit, newUnit)
            end
        )
    end,

    ---@param self KillObjective
    ---@param unit Unit
    AddTriggers = function(self, unit)
        self.UnitDeathTrigger:Add { unit }
        self.UnitGivenTrigger:Add { unit }
    end,

    ---@param self KillObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)
        assert(args.Units, self.Title .. " :Objective requires Units in Target specified!")

        for _, unit in args.Units do
            self:AddObjectiveUnit(args, unit)
        end

        self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Total))
    end,

    AddObjectiveUnit = function(self, args, unit)
        if not unit.Dead then
            -- Mark the units unless MarkUnits == false
            if args.MarkUnits == nil or args.MarkUnits then
                self.UnitMarkers:Add(ObjectiveArrow { AttachTo = unit })
            end
            if args.FlashVisible then
                ObjectiveHandlers.FlashViz(self, unit)
            end
            self:AddTriggers(unit)
        else
            self:OnUnitKilled(unit)
        end
    end,

    ---Removes unit from list of objective units
    ---@param self KillObjective
    ---@param unit Unit
    RemoveObjectiveUnit = function(self, unit)
        if not unit then return end

        local units = self.Args.Units
        local index

        for i, v in units do
            if v == unit then
                index = i
                break
            end
        end

        if index then
            table.remove(units, index)
        end
    end,

    --Replaces old unit on new one in objective list
    ---@param self KillObjective
    ---@param oldUnit Unit
    ---@param newUnit Unit
    ReplaceObjectiveUnit = function(self, oldUnit, newUnit)
        self:RemoveObjectiveUnit(oldUnit)
        table.insert(self.Args.Units, newUnit)
    end,

    ---@param self KillObjective
    ---@param unit Unit
    OnUnitKilled = function(self, unit)
        if not self.Active then return end

        self.Count = self.Count + 1

        self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Total))
        self:OnProgress(self.Count, self.Total)

        if self.Count == self.Total then
            self:Success(unit)
        end
    end,

    ---@param self KillObjective
    ---@param unit Unit
    ---@param newUnit Unit
    OnUnitGiven = function(self, unit, newUnit)
        if not self.Active then return end

        self:ReplaceObjectiveUnit(unit, newUnit)
        self:AddUnitTarget(newUnit)
        self:AddObjectiveUnit(self.Args, newUnit)
    end
}
