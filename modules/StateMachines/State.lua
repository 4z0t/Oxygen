local coroutine = coroutine

---@alias StateStatus
--- | 'exit'
--- | 'waitfor'
--- | 'continue'
--- | 'return'
--- | 'tick'
--- | 'call'
--- | 'next'
do
    local SuspendCurrentThread = SuspendCurrentThread
    local ForkThread = ForkThread
    local makeThread = function(f)
        local thread = ForkThread(function()
            return f(SuspendCurrentThread())
        end)
        coroutine.resume(thread)
        return thread
    end
    coroutine.create = makeThread
end

---@class StateBase
---@field _state thread | false
---@field _shared table
StateBase = ClassSimple
{
    ---@param self StateBase
    __init = function(self, shared)
        self._state = false
        self._shared = shared
    end,

    ---@param self StateBase
    ---@param arg any
    ---@return StateStatus
    ---@return any
    Resume = function(self, arg)
        local ok, status, value

        if not self._state then
            self._state = coroutine.create(self.Run)
            ok, status, value = coroutine.resume(self._state, self, self._shared)
        else
            ok, status, value = coroutine.resume(self._state, arg)
        end

        if ok then
            return status, value
        else
            WARN(status)
            self:Clear()
            return 'exit'
        end
    end,

    ---@param self StateBase
    Run = function(self)
        error("Not implemented method of StateBase.Run")
    end,

    ---@param self StateBase
    Return = function(self, value)
        return coroutine.yield('return', value)
    end,

    ---@param self StateBase
    Continue = function(self)
        return coroutine.yield('continue')
    end,

    ---@param self StateBase
    Tick = function(self, ticks)
        return coroutine.yield('tick', ticks or 1)
    end,

    ---@param self StateBase
    WaitFor = function(self, stateName)
        return coroutine.yield('waitfor', stateName)
    end,

    ---@param self StateBase
    Exit = function(self)
        return coroutine.yield('exit')
    end,

    ---@param self StateBase
    Next = function(self, stateName)
        return coroutine.yield('next', stateName)
    end,

    ---@param self StateBase
    Call = function(self, stateName)
        return coroutine.yield('call', stateName)
    end,

    ---@param self StateBase
    Clear = function(self)
        if self._state then
            KillThread(self._state)
            self._state = nil
        end
    end,

    ---@param self StateBase
    Destroy = function(self)
        self:Clear()
    end

}
