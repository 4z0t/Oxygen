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
    ---Initializes Runnable with passed thread function
    ---@param self Runnable
    ---@param threadFunc ThreadFunction
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

---@alias UnitCallback fun(unit: Unit):nil


---Adds callbacks to units
---@param units Unit[]
---@param callback UnitCallback
---@param callbackType string
local function AddUnitsCallback(units, callback, callbackType)
    for _, unit in units do
        unit:AddUnitCallback(callback, callbackType)
    end
end

---@class IUnitTrigger
---@field _callback UnitCallback
---@field _type string|string[]
IUnitTrigger = ClassSimple
{
    _type = false,
    ---comment
    ---@param self IUnitTrigger
    ---@param callback UnitCallback
    __init = function(self, callback)
        self._callback = callback
    end,



    ---Adds to units a trigger callback
    ---@param self IUnitTrigger
    ---@param units Unit[]
    Add = function(self, units)
        assert(self._type, "Not specified unit callback type!")

        if type(self._type) == "string" then
            AddUnitsCallback(units, self._callback, self._type)
            return
        end

        for _, t in self._type do
            AddUnitsCallback(units, self._callback, t)
        end
    end,

    ---Removes from units trigger callback
    ---@param self IUnitTrigger
    ---@param units Unit[]
    Remove = function(self, units)
        assert(self._type, "Not specified unit callback type!")

        for _, unit in units do
            unit:RemoveCallback(self._callback)
        end
    end

}


UnitStartCaptureTrigger = Class(IUnitTrigger) { _type = 'OnStartCapture' }
UnitStopCaptureTrigger = Class(IUnitTrigger) { _type = 'OnStopCapture' }
UnitStartBeingCapturedTrigger = Class(IUnitTrigger) { _type = 'OnStartBeingCaptured' }
UnitStopBeingCapturedTrigger = Class(IUnitTrigger) { _type = 'OnStopBeingCaptured' }
UnitFailedBeingCapturedTrigger = Class(IUnitTrigger) { _type = 'OnFailedBeingCaptured' }
UnitFailedCaptureTrigger = Class(IUnitTrigger) { _type = 'OnFailedCapture' }
UnitStopBeingBuiltTrigger = Class(IUnitTrigger) { _type = 'OnStopBeingBuilt' }
UnitGivenTrigger = Class(IUnitTrigger) { _type = 'OnGiven' }
UnitVeteranTrigger = Class(IUnitTrigger) { _type = 'OnVeteran' }
UnitFailedToBuildTrigger = Class(IUnitTrigger) { _type = 'OnFailedToBuild' }
UnitDeathTrigger = Class(IUnitTrigger) { _type = 'OnKilled' }
UnitDestroyedTrigger = Class(IUnitTrigger) { _type = { 'OnReclaimed', 'OnCaptured', 'OnKilled' } }



TriggerManager = ClassSimple
{

}
