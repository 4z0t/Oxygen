local table = table

---@class StateMachineBase
---@field _currentState StateBase
---@field _states table<string, StateBase>
StateMachineBase = ClassSimple
{
    ---@param self StateMachineBase
    __init = function(self)
        self._states = {}
        self._currentState = nil
    end,

    ---@param self StateMachineBase
    MainThread = function(self, startState)

        self._currentState = self:ProduceState(startState)
        self._states[startState] = self._currentState

        local stateStack = {}

        local status, value

        while self:Condition() do
            status, value = self._currentState:Resume(value)

            if status == 'exit' then
                break
            elseif status == 'tick' then -- state requested waiting for certain amount of ticks
                WaitTicks(value)

            elseif status == 'continue' then
            elseif status == 'waitfor' then

            elseif status == 'next' then -- going to the next state
                self._currentState:Destroy()
                self._currentState = self:ProduceState(value)
                value = nil

            elseif status == 'return' then -- return the value for state that called us
                self._currentState:Destroy()
                self._currentState = table.remove(stateStack)

            elseif status == 'call' then -- calling other state for value
                table.insert(stateStack, self._currentState)
                self._currentState = self:ProduceState(value)
                value = nil
                
            end
        end

        self:Destroy()
    end,

    ---@param self StateMachineBase
    Condition = function(self)
        return true
    end,

    ---@param self StateMachineBase
    Run = function(self, startState)
        ForkThread(self.MainThread, self, startState)
    end,

    ---@param self StateMachineBase
    ---@param stateName string
    ProduceState = function(self, stateName)
        local stateClass = self.States[stateName]

        if not stateClass then
            error(stateName .. " does not present in states of state machine")
        end

        return stateClass()
    end,

    ---@param self StateMachineBase
    Destroy = function(self)
        for _, state in self._states do
            state:Destroy()
        end
        self._states = nil
    end,

    ---@type table<string, StateBase>
    States = {},
}
