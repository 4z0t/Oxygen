local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local useActionInFunc = {
    ["CategoryStatCompare"] = true,
    ["UnitStatCompare"] = true,
    ["ArmyStatCompare"] = true,
    ["CategoriesInArea"] = true,
    ["Basic"] = true,
}

---@class ObjectiveManager
---@field _objectives table<string, ObjectiveTable>
---@field _activeObjectives table<string, Objective>
---@overload fun():ObjectiveManager
ObjectiveManager = ClassSimple
{

    ---Inits ObjectiveManager with table of given objectives
    ---@param self ObjectiveManager
    ---@param objectives table<string, ObjectiveTable>
    ---@return ObjectiveManager
    Init = function(self, objectives)
        self._objectives = {}
        self._activeObjectives = {}
        for _, obj in objectives do
            self._objectives[obj.name] = obj
        end
        return self
    end,
    Add = function(self, obj)
        return self
    end,

    _Validate = function(self)

    end,

    ---Starts objective(s) by its(their) name(s)
    ---@param self ObjectiveManager
    ---@param id string | string []
    Start = function(self, id)
        if type(id) == "string" then
            local obj = self._objectives[id]
            ForkThread(self._Start, self, obj)
        elseif type(id) == "table" then
            for _, i in id do
                self:Start(i)
            end
        end
    end,

    ---Internal start objective function
    ---@param self ObjectiveManager
    ---@param objTable ObjectiveTable
    _Start = function(self, objTable)
        if self._activeObjectives[objTable.name] ~= nil then return end
        --objTable.onStartFunc may interrupt objective creation with WaitSeconds,
        --so, we make it true for some time in order to detect and prevent attempt
        --of second creation due to timed expansion for instance
        self._activeObjectives[objTable.name] = true

        if objTable.startDelay then
            WaitSeconds(objTable.startDelay)
        end
        local target = objTable.onStartFunc()
        if target then
            target = table.merged(objTable.target, target)
        else
            target = objTable.target
        end
        if objTable.delay then
            WaitSeconds(objTable.delay)
        end
        ---@type Objective
        local obj
        if useActionInFunc[objTable.func] then
            obj = Objectives[objTable.func](
                objTable.type,
                objTable.complete,
                objTable.title,
                objTable.description,
                objTable.action,
                target
            )
        else
            obj = Objectives[objTable.func](
                objTable.type,
                objTable.complete,
                objTable.title,
                objTable.description,
                target
            )
        end
        do
            local onSuccessFunc = objTable.onSuccessFunc
            local onFailFunc = objTable.onFailFunc
            local nextObj = objTable.next
            obj:AddResultCallback(
                function(success)
                    if success then
                        ForkThread(onSuccessFunc)
                        if nextObj then
                            ForkThread(self.Start, self, nextObj)
                        end
                    else
                        if onFailFunc then
                            ForkThread(onFailFunc)
                        end
                    end
                end
            )
        end
        if objTable.onProgressFunc then
            obj:AddProgressCallback(objTable.onProgressFunc)
        end
        self._activeObjectives[objTable.name] = obj
    end,

    ---Checks if all assigned objectives of given type are complete
    ---@param self ObjectiveManager
    ---@param objType ObjectiveType
    ---@return boolean
    CheckComplete = function(self, objType)
        for name, objTable in self._objectives do
            if objTable.type == objType then
                if not Objectives.IsComplete(self._activeObjectives[name]) then
                    return false
                end
            end
        end
        return true
    end,

    ---Ends game with given success state, callback and safety to given units
    ---@param self ObjectiveManager
    ---@param success boolean
    ---@param callback fun()?
    ---@param safety boolean?
    ---@param units Unit[]?
    EndGame = function(self, success, callback, safety, units)

        if safety then
            ScenarioFramework.EndOperationSafety(units)
        end
        if callback then
            callback()
        end

        ScenarioFramework.EndOperation(
            success,
            self:CheckComplete('primary'),
            self:CheckComplete('secondary'),
            self:CheckComplete('Bonus')
        )
    end
}
