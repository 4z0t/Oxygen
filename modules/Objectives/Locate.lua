local CountObjective = import("IObjective.lua").CountObjective
local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local ObjectiveArrow = import("/lua/objectivearrow.lua").ObjectiveArrow


---@class LocateObjective : CountObjective
---@field UnitLocatedTrigger PlayerIntelTrigger
---@field Located table<Unit, true>
LocateObjective = Class(CountObjective)
{
    Icon = "Locate",

    ---@param self LocateObjective
    OnCreate = function(self)
        CountObjective.OnCreate(self)
        self.Located = {}

        self.UnitLocatedTrigger = Oxygen.Triggers.PlayerIntelTrigger(
            function(unit)
                self:OnUnitLocated(unit)
            end
        )
    end,

    ---@param self LocateObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)
        assert(args.Units, self.Title .. " :Objective requires Units in Target specified!")

        for _, unit in args.Units do
            self.UnitLocatedTrigger:Add(unit)
        end

        self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Total))
    end,

    ---@param self LocateObjective
    ---@param unit Unit
    OnUnitLocated = function(self, unit)
        if not self.Active or self.Located[unit] then return end

        self.Located[unit] = true

        self.Count = self.Count + 1

        self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Total))
        self:OnProgress(self.Count, self.Total)

        if self.Count == self.Total then
            self:Success()
        end
    end
}
