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
KillObjective = Class(IObjective)
{

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
            if not unit.Dead then
                -- Mark the units unless MarkUnits == false
                if args.MarkUnits == nil or args.MarkUnits then
                    self.UnitMarkers.Add(ObjectiveArrow { AttachTo = unit })
                end
                if args.FlashVisible then
                    ObjectiveHandlers.FlashViz(self, unit)
                end
                -- CreateTriggers(unit, objective, true) -- Reclaiming is same as killing for our purposes
            else
                self:OnUnitKilled(unit)
            end
        end
    end,


    OnUnitKilled = function(self, unit)
        if not self.Active then return end
        --todo

    end,

    OnUnitGiven = function(self, unit, newUnit)
        if not self.Active then return end
        --todo
    end
}
