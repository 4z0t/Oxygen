local IObjective = import("IObjective.lua").IObjective
local Triggers = import("TriggerManager.lua")
local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local ObjectiveArrow = import("/lua/objectivearrow.lua").ObjectiveArrow


CategoriesInAreaObjective = Class(IObjective)
{
    --Todo
}

---@class KillObjective : IObjective
---@field UnitDeathTrigger UnitDeathTrigger
---@field UnitGivenTrigger UnitGivenTrigger
---@field Killed integer
---@field Total integer
KillObjective = Class(IObjective)
{
    Icon = "Kill",

    ---@param self KillObjective
    OnCreate = function(self)

        self.Killed = 0
        self.Total = table.getn(self.Args.Units)

        self.UnitDeathTrigger = Triggers.UnitDeathTrigger(
            function(unit)
                self:OnUnitKilled(unit)
            end
        )

        self.UnitGivenTrigger = Triggers.UnitGivenTrigger(
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

        self.Killed = self.Killed + 1

        self:_UpdateUI('Progress', ("%s/%s"):format(self.Killed, self.Total))
        self:OnProgress(self.Killed, self.Total)

        if self.Killed == self.Total then
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



TimerObjective = Class(IObjective)
{
    --todo
}


ProtectObjective = Class(TimerObjective)
{
    --todo
}

CategoryStatCompareObjective = Class(IObjective)
{
    --todo
}

SpecificUnitsInAreaObjective = Class(IObjective)
{
    --todo
}

LocateObjective = Class(IObjective)
{

}
