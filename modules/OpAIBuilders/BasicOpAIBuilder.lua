local BC = import("BuildConditions.lua")

---@class OpAIData
---@field MasterPlatoonFunction PlatoonAIFunctionTable
---@field PlatoonData PlatoonDataTable
---@field Priority number

---@class OpAITable
---@field unitGroup UnitGroup
---@field type OpAIType
---@field name string
---@field data OpAIData
---@field quantity table<string,integer>
---@field lock table<LockType, LockData>
---@field formation FormationType
---@field childrenState table<string, boolean>
---@field remove string|string[]
---@field buildConditions BuildCondition[]
---@field reactive boolean


---@alias OpAIType
--- | "BasicLandAttack"
--- | 'AirAttacks'
--- | 'EngineerAttack'
--- | 'NavalAttacks'


---@alias LockType
--- | 'DeathRatio'
--- | 'DeathTimer'
--- | 'None'

---@class LockData
---@field Ratio number?
---@field LockTimer integer?


---@class IOpAIBuilder
---@field Type OpAIType
---@field _name string
---@field _type OpAIName
---@field _data PlatoonDataTable
---@field _quantity table<string,integer>
---@field _lock table<LockType, LockData>
---@field _formation FormationType
---@field _childrenState table<string, boolean>
---@field _remove string|string[]
---@field _buildConditions BuildCondition[]
---@field _function PlatoonAIFunctionTable
---@field _priority  number
IOpAIBuilder = ClassSimple
{
    ---Clears builder
    ---@param self IOpAIBuilder
    _Clear = function(self)
        self._data = nil
        self._quantity = {}
        self._lock = {}
        self._formation = nil
        self._childrenState = {}
        self._remove = nil
        self._buildConditions = {}
        self._name = nil
        self._function = nil
        self._priority = nil
    end,

    ---Starts creation of new OpAI for use in Platoon loader
    ---@param self IOpAIBuilder
    ---@param name string
    ---@return IOpAIBuilder
    New = function(self, name)
        self:_Clear()
        self._name = name
        return self
    end,


    ---Sets data of OpAI
    ---@param self IOpAIBuilder
    ---@param data PlatoonDataTable
    ---@return IOpAIBuilder
    Data = function(self, data)
        self._data = data
        return self
    end,

    ---comment
    ---@param self IOpAIBuilder
    ---@param priority number
    ---@return IOpAIBuilder
    Priority = function(self, priority)
        self._priority = priority
        return self
    end,

    ---comment
    ---@param self IOpAIBuilder
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return IOpAIBuilder
    AIFunction = function(self, fileName, functionName)
        self._function = { fileName, functionName }
        return self
    end,


    ---Adds build condition to OpAI
    ---@param self IOpAIBuilder
    ---@param condition BuildCondition
    ---@return IOpAIBuilder
    AddCondition = function(self, condition)
        table.insert(self._buildConditions, condition)
        return self
    end,

    ---Sets build condition depending on human army having given category
    ---
    ---``` lua
    ---:AddHumansCategoryCondition(categories.LAND * categories.MOBILE, ">=", 20)
    ---```
    ---@param self IOpAIBuilder
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return IOpAIBuilder
    AddHumansCategoryCondition = function(self, category, compareOp, value)
        return self:AddCondition(
            BC.HumansCategoryCondition(category, compareOp, value)
        )
    end,


    ---Sets quantity of children for OpAI
    ---@param self IOpAIBuilder
    ---@param childrenType string
    ---@param quantity integer
    ---@return IOpAIBuilder
    Quantity = function(self, childrenType, quantity)
        self._quantity[childrenType] = quantity
        return self
    end,

    ---Enables children of OpAI
    ---@param self IOpAIBuilder
    ---@param childrenType string
    ---@return IOpAIBuilder
    EnableChild = function(self, childrenType)
        self._childrenState[childrenType] = true
        return self
    end,

    ---Disables children of OpAI
    ---@param self IOpAIBuilder
    ---@param childrenType string
    ---@return IOpAIBuilder
    DisableChild = function(self, childrenType)
        self._childrenState[childrenType] = false
        return self
    end,

    ---Removes children of OpAI
    ---@param self IOpAIBuilder
    ---@param childrenType string|string[]
    ---@return IOpAIBuilder
    RemoveChildren = function(self, childrenType)
        self._remove = childrenType
        return self
    end,

    ---Sets formation of OpAI
    ---@param self IOpAIBuilder
    ---@param formation FormationType
    ---@return IOpAIBuilder
    Formation = function(self, formation)
        self._formation = formation
        return self
    end,

    ---Sets locking style of OpAI
    ---@param self IOpAIBuilder
    ---@param lockType LockType
    ---@param lockData LockData?
    ---@return IOpAIBuilder
    LockingStyle = function(self, lockType, lockData)
        self._lock[lockType] = lockData or false
        return self
    end,

    ---completes creation of OpAI for use in platoon builder
    ---@param self IOpAIBuilder
    ---@return OpAITable
    Create = function(self)

        return {
            name = self._name,
            type = self.Type,
            data = {
                MasterPlatoonFunction = self._function,
                PlatoonData = self._data,
                Priority = self._priority
            },
            quantity = self._quantity,
            lock = self._lock,
            formation = self._formation,
            childrenState = self._childrenState,
            remove = self._remove,
            buildConditions = self._buildConditions
        }
    end,


}
