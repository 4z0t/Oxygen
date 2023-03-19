local EntityCategoryContains = EntityCategoryContains
local CountObjective = import("IObjective.lua").CountObjective
local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local ObjectiveArrow = import("/lua/objectivearrow.lua").ObjectiveArrow
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")

local KillObjective = import("Kill.lua").KillObjective

---@class SpecificUnitsInAreaObjective : KillObjective
---@field Required integer
---@field Rect Rectangle
SpecificUnitsInAreaObjective = Class(KillObjective)
{
    Icon = "Move",

    ---@param self SpecificUnitsInAreaObjective
    OnCreate = function(self)
        KillObjective.OnCreate(self)

        self.Required = self.Args.NumRequired
    end,

    ---@param self SpecificUnitsInAreaObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)
        KillObjective.PostCreate(self, args)

        local rect = ScenarioUtils.AreaToRect(args.Area)
        local w = rect.x1 - rect.x0
        local h = rect.y1 - rect.y0
        local x = rect.x0 + (w / 2.0)
        local z = rect.y0 + (h / 2.0)
        self.Rect = rect

        if args.MarkArea then
            self.Decals:Add(ObjectiveHandlers.CreateObjectiveDecal(x, z, w, h))
        end

        self.Trash:Add(ForkThread(self.WatchAreaThread, self))

        if args.ShowProgress then
            self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Required))
        end
    end,


    ---@param self SpecificUnitsInAreaObjective
    WatchAreaThread = function(self)
        local rect = self.Rect
        local args = self.Args
        local units = args.Units

        while self.Active do
            local cnt = 0
            for _, unit in units do
                if not unit.Dead and ScenarioUtils.InRect(unit:GetPosition(), rect) then
                    cnt = cnt + 1
                end
            end

            if cnt ~= args.Count then
                args.Count = cnt

                if args.ShowProgress then
                    self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Required))
                end
                self:OnProgress(self.Count, self.Required)
            end

            if cnt >= self.Required then
                self:Success()
                return
            end
            WaitTicks(5)
        end
    end,


    ---@param self SpecificUnitsInAreaObjective
    ---@param unit Unit
    OnUnitKilled = function(self, unit)
        if not self.Active then return end

        self.Total = self.Total - 1

        if self.Args.ShowProgress then
            self:_UpdateUI('Progress', ("%s/%s"):format(self.Count, self.Required))
        end
        self:OnProgress(self.Count, self.Required)

        if self.Total < self.Required then
            self:Fail()
        end
    end

}
