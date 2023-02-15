local ForkThread = ForkThread
local KillThread = KillThread
local unpack = unpack
local assert = assert

---@alias ThreadFunction fun(...:any):nil

---@class Runnable
---@field private _threadFunc ThreadFunction
---@field private _activeThread thread|false
Runnable = ClassSimple
{
    __init = function(self, threadFunc)
        assert(type(threadFunc) == "function", "Function must be passed into constructor for Runnable")

        self._threadFunc = threadFunc
        self._activeThread = false
    end,

    ---Runs thread function that was passed into Runnable
    ---@param self Runnable
    ---@param ... any
    Run = function(self, ...)
        assert(not self._activeThread, "There is already running thread!")

        self._activeThread = ForkThread(self._threadFunc, unpack(arg))
    end,

    ---Stops execution of thread function that was passed into Runnable
    ---@param self Runnable
    Stop = function(self)
        assert(self._activeThread, "There is no runnig thread to be stopped!")

        KillThread(self._activeThread)
        self._activeThread = false
    end
}

---@class BasicTrigger : Runnable
BasicTrigger = Class(Runnable) {}







TriggerManager = ClassSimple
{

}
