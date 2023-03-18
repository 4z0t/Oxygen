local IObjective = import("IObjective.lua").IObjective
local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local ObjectiveArrow = import("/lua/objectivearrow.lua").ObjectiveArrow


---@class KillObjective : IObjective
---@field UnitDeathTrigger UnitDeathTrigger
---@field UnitGivenTrigger UnitGivenTrigger
---@field Count integer
---@field Total integer
KillObjective = Class(IObjective)
{
    Icon = "Kill",

    ---@param self KillObjective
    OnCreate = function(self)

        self.Count = 0
        self.Total = table.getn(self.Args.Units)

        self.UnitDeathTrigger = Oxygen.Triggers.UnitDeathTrigger(
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
        self.UnitDeathTrigger:Add(unit)
        self.UnitGivenTrigger:Add(unit)
    end,

    ---@param self KillObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)

        for _, unit in args.Units do
            self:AddObjectiveUnit(args, unit)
        end

        self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Total))
    end,

    AddObjectiveUnit = function(self, args, unit)
        if not unit.Dead then
            -- Mark the units unless MarkUnits == false
            if args.MarkUnits == nil or args.MarkUnits then
                self.UnitMarkers.Add(ObjectiveArrow { AttachTo = unit })
            end
            if args.FlashVisible then
                ObjectiveHandlers.FlashViz(self, unit)
            end
            self:AddTriggers(unit)
        else
            self:OnUnitKilled(unit)
        end
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

        self:AddObjectiveUnit(self.Args, newUnit)
    end
}
