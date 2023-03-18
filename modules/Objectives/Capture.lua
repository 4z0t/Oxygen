local IObjective = import("IObjective.lua").IObjective
local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local ObjectiveArrow = import("/lua/objectivearrow.lua").ObjectiveArrow
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")

local KillObjective = import("Kill.lua").KillObjective


---@class CaptureObjective : KillObjective
---@field UnitCapturedTrigger UnitCapturedNewTrigger
---@field Required integer
---@field CapturedUnits Unit[]
CaptureObjective = Class(KillObjective)
{
    Icon = "Capture",

    ---@param self CaptureObjective
    OnCreate = function(self)
        KillObjective.OnCreate(self)

        self.Required = self.Args.NumRequired or self.Total
        self.CapturedUnits = {}
        self.UnitCapturedTrigger = Oxygen.Triggers.UnitCapturedNewTrigger(
            function(unit, captor)
                self:OnUnitCaptured(unit, captor)
            end
        )
    end,

    ---@param self CaptureObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)
        KillObjective.PostCreate(self, args)

        self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Required))
    end,

    ---@param self CaptureObjective
    ---@param unit Unit
    AddTriggers = function(self, unit)
        KillObjective.AddTriggers(self, unit)
        self.UnitCapturedTrigger:Add { unit }
    end,

    ---@param self CaptureObjective
    ---@param unit Unit
    ---@param captor Unit
    OnUnitCaptured = function(self, unit, captor)
        table.insert(self.CapturedUnits, unit)

        if not self.Active then return end

        self.Count = self.Count + 1

        self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Required))
        self:OnProgress(self.Count, self.Required)

        if self.Count >= self.Required then
            self:Success(self.CapturedUnits)
        end
    end,

    ---@param self CaptureObjective
    ---@param unit Unit
    OnUnitKilled = function(self, unit)
        if not self.Active then return end

        self.Total = self.Total - 1

        if self.Total < self.Required then
            self:Fail()
        end
    end


}
