local OSM = Oxygen.StateMachine

---@class StatePlatoon : StateBase
---@field _platoon Platoon
---@field _aiBrain AIBrain
local StatePlatoon = Class(OSM.State)
{
    ---@param self StatePlatoon
    ---@param shared table
    ---@param platoon Platoon
    __init = function(self, shared, platoon)
        OSM.State.__init(self, shared)
        self._platoon = platoon
        self._aiBrain = platoon:GetBrain()
    end,
}

---@class NukeStateMachine : StateMachineBase
---@field _aiBrain AIBrain
---@field _platoon Platoon
local NukeStateMachine = Class(OSM.StateMachine)
{
    ---@param self NukeStateMachine
    ---@param platoon Platoon
    __init = function(self, platoon)
        OSM.StateMachine.__init(self)
        self._platoon = platoon
        self._aiBrain = platoon:GetBrain()
    end,

    ---@param self NukeStateMachine
    Condition = function(self)
        return self._aiBrain:PlatoonExists(self._platoon)
    end,

    ---@param self NukeStateMachine
    ---@param stateName string
    ---@return StateBase
    ProduceState = function(self, stateName)
        local stateClass = self.States[stateName]

        if not stateClass then
            error(stateName .. " does not present in states of state machine")
        end

        return stateClass(self.shared, self._platoon)
    end,

    ---@param self NukeStateMachine
    Destroy = function(self)
        OSM.StateMachine.Destroy(self)
        self._platoon:PlatoonDisband()
        self._platoon = nil
    end,

    States = {

        Main = Class(StatePlatoon)
        {
            ---@param self StatePlatoon
            ---@param shared table
            Run = function(self, shared)
                LOG "entered Main state"
                local platoonUnits = self._platoon:GetPlatoonUnits()
                local unit
                for k, v in platoonUnits do
                    if EntityCategoryContains(categories.SILO * categories.NUKE, v) then
                        unit = v
                        break
                    end
                end

                if not unit then
                    self:Exit()
                end
                unit:SetAutoMode(true)
                shared.unit = unit
                self:Next "Load"
            end,
        },

        Load = Class(StatePlatoon)
        {
            ---@param self StatePlatoon
            ---@param shared table
            Run = function(self, shared)
                LOG "entered Load state"
                ---@type Unit
                local unit = shared.unit
                while unit:GetNukeSiloAmmoCount() < 1 do
                    self:Tick(110)
                end
                self:Next "Launch"
            end,
        },

        Launch = Class(StatePlatoon)
        {
            ---@param self StatePlatoon
            ---@param shared table
            Run = function(self, shared)
                LOG "entered Launch state"
                ---@type Unit
                local unit = shared.unit
                local aiBrain = self._aiBrain
                while true do
                    local nukePos = import("/lua/ai/aibehaviors.lua").GetHighestThreatClusterLocation(aiBrain, unit)
                    if nukePos then
                        IssueNuke({ unit }, nukePos)
                        self:Tick(120)
                        IssueToUnitClearCommands(unit)
                        break
                    end
                    self:Tick(10)
                end
                self:Next "Load"
            end,
        },
    }
}




---Starts platoon NukeAI detaching it from base manager for other nukes to avoid instance count limitaion
---@param platoon Platoon
function PlatoonNukeAI(platoon)
    LOG("started nuke AI")

    ---@type AIBrain
    local aiBrain = platoon:GetBrain()
    local nukes = platoon:GetPlatoonUnits()
    aiBrain:DisbandPlatoon(platoon)

    ---@type Platoon
    platoon = aiBrain:MakePlatoon('', '')
    aiBrain:AssignUnitsToPlatoon(platoon, nukes, "Attack", "None")
    NukeStateMachine(platoon):Run "Main"
    --platoon:ForkAIThread(platoon.NukeAI)

    -- TODO
    -- ---@type AIBrain
    -- local aiBrain = platoon:GetBrain()
    -- local data = platoon.PlatoonData
    -- ---@type AdvancedBaseManager
    -- local bManager = aiBrain.BaseManagers[data.BaseName]
    -- if not bManager then return false end


    -- IssueGuard(bManager.ConstructionEngineers, platoon:GetPlatoonUnits()[1])

end

--[[

    UI_Lua local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') end  ForkThread(function()print(coroutine.resume(coroutine.create(t))) end)
    UI_Lua local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') end  print(coroutine.resume(coroutine.create(t)))
    UI_Lua local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') end  print(ResumeThread(coroutine.create(t)))
    UI_Lua local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') end  print(type(coroutine.create(t)))
    UI_Lua local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') end  print(type(ForkThread(t)))
    UI_Lua local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') end  print(coroutine.resume(ForkThread(t)))
    UI_Lua local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') end  print(ForkThread(t))
    UI_Lua local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') end  print(coroutine.status(ForkThread(t)))

    UI_Lua local yield = function(...) coroutine.yield(unpack(arg)) SuspendCurrentThread() end local t = function() LOG ('a') yield(1,2,3) LOG ('b') yield('f',5,6) LOG('c') end  local th = ForkThread(t) print(coroutine.resume(th)) 
    UI_Lua local yield = function(...) coroutine.yield(unpack(arg)) SuspendCurrentThread() end local t = function() LOG ('a') yield(1,2,3) LOG ('b') yield('f',5,6) LOG('c') end  local th = ForkThread(t) print(coroutine.resume(th)) print(coroutine.resume(th)) print(coroutine.resume(th))
    UI_Lua local yield = function(...) coroutine.yield(unpack(arg)) SuspendCurrentThread() end local resume = function(thread, ...) local res =  {coroutine.resume(thread, unpack(arg))} coroutine.resume(thread) return unpack(res) end local t = function() LOG ('a') yield(1,2,3) LOG ('b') yield('f',5,6) LOG('c') end  local th = ForkThread(t) print(resume(th)) print(resume(th)) print(resume(th))
    UI_Lua local yield = function(...) coroutine.yield(unpack(arg)) SuspendCurrentThread() end local resume = function(thread, ...) local res =  {coroutine.resume(thread, unpack(arg))} coroutine.resume(thread) return unpack(res) end local t = function() LOG ('a') yield(1,2,3) LOG ('b') yield('f',5,6) LOG('c') end  local th = ForkThread(t) print(resume(th))

    UI_Lua local makeThread = function(f) local thread = ForkThread(function() SuspendCurrentThread() f() end ) coroutine.resume(thread) return thread end local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') coroutine.yield('f',5,6) LOG('c') end  local th = makeThread(t) print(coroutine.resume(th))
    UI_Lua local makeThread = function(f) local thread = ForkThread(function() SuspendCurrentThread() f() end ) coroutine.resume(thread) return thread end local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') coroutine.yield('f',5,6) LOG('c') end  local th = makeThread(t) print(coroutine.resume(th)) print(coroutine.resume(th))
    UI_Lua local makeThread = function(f) local thread = ForkThread(function() SuspendCurrentThread() f() end ) coroutine.resume(thread) return thread end local t = function() LOG ('a') coroutine.yield(1,2,3) LOG ('b') coroutine.yield('f',5,6) LOG('c') end  local th = makeThread(t) print(coroutine.resume(th)) print(coroutine.resume(th)) print(coroutine.resume(th))
    UI_Lua local makeThread = function(f) local thread = ForkThread(function() SuspendCurrentThread() f() end ) coroutine.resume(thread) return thread end local t = function(a) LOG(a) LOG (coroutine.yield(1,2,3)) LOG (coroutine.yield('f',5,6)) end  local th = makeThread(t) 
    UI_Lua local makeThread = function(f) local thread = ForkThread(function() SuspendCurrentThread() f() end ) coroutine.resume(thread) return thread end local t = function(a) LOG(a) LOG (coroutine.yield(1,2,3)) LOG (coroutine.yield('f',5,6)) end  local th = makeThread(t) print(coroutine.resume(th, 'a')) print(coroutine.resume(th, 'b')) print(coroutine.resume(th, 'c'))

    UI_Lua local makeThread = function(f, ...) local thread = ForkThread(function() return f(SuspendCurrentThread()) end ) coroutine.resume(thread, unpack(arg)) return thread end local t = function(...) reprsl(arg) LOG (coroutine.yield(1,2,3)) LOG (coroutine.yield('f',5,6)) end  local th = makeThread(t) print(coroutine.resume(th, 'a', 'b', 'c')) print(coroutine.resume(th, 'b')) print(coroutine.resume(th, 'c'))
    ]]