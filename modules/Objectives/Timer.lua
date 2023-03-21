local IObjective = import("IObjective.lua").IObjective
local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local ObjectiveArrow = import("/lua/objectivearrow.lua").ObjectiveArrow


---@class TimerObjective : IObjective
---@field TickingTimer TickingTimerTrigger
TimerObjective = Class(IObjective)
{
    ---@param self TimerObjective
    OnCreate = function(self)
        self.TickingTimer = Oxygen.Triggers.TickingTimerTrigger(
            self.OnExpired,
            function(secondsPassed)
                self:OnTick(secondsPassed)
            end
        )
    end,

    ---@param self TimerObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)
        assert(args.Timer, self.Title .. " :Objective requires Timer in Target specified!")

        self.Trash:Add(self.TickingTimer:Delay(args.Timer):Run(self))
    end,

    ---@param self TimerObjective
    OnExpired = function(self)
        self:ManualResult(self.Args.ExpireResult == 'complete')
        self:ResetSyncTimer()
    end,

    ---@param self TimerObjective
    ---@param secondsPassed integer
    OnTick = function(self, secondsPassed)
        self:_UpdateUI("timer", { Time = self.Args.Timer - secondsPassed })
    end,


    ---@param self TimerObjective
    ResetSyncTimer = function(self)
        Sync.ObjectiveTimer = 0
    end

}
