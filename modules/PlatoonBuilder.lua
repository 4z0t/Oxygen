local Utils = import("Utils.lua")


---@class PlatoonTemplateName : string
---@class PlatoonTemplatePlan : string
---@class UnitId : string

---@alias OrderType 'Attack'|

---@alias PlatoonType 'Air' | 'Land' | 'Sea' | "Gate" | "Any"


---@alias FormationType
--- | 'GrowthFormation'
--- | "AttackFormation"
--- | "NoFormation"

---@alias PlatoonPlan 'NoPlan'|

---@class PlatoonTemplateEntry
---@field [1] UnitId
---@field [2] integer
---@field [3] integer @ quantity
---@field [4] OrderType
---@field [5] FormationType

---@alias StructureType
--- |
--- |
--- |
--- | 'T3Artillery'
--- | 'T2Artillery'
--- | 'T2ShieldDefense'
--- | 'T3AADefense'
--- | 'T2GroundDefense'

---@class ConstructionTable
---@field BaseTemplate UnitGroup
---@field BuildClose boolean
---@field BuildStructures StructureType[]

---@class PlatoonDataTable
---@field PatrolChains MarkerChain[]?
---@field PatrolChain MarkerChain?
---@field AttackChain MarkerChain?
---@field LandingChain MarkerChain?
---@field MovePath MarkerChain?
---@field TransportReturn Marker?
---@field LandingList MarkerChain?
---@field LocationChain MarkerChain?
---@field MoveRoute MarkerChain?
---@field CategoryList EntityCategory[]?
---@field Location Marker?
---@field High boolean?
---@field Construction ConstructionTable
---@field MaintainBaseTemplate UnitGroup


---@class PlatoonTemplateTable
---@field [1] PlatoonTemplateName
---@field [2] PlatoonPlan
---@field [3] PlatoonTemplateEntry
---@field [4] PlatoonTemplateEntry?
---@field [5] PlatoonTemplateEntry?
---....

---@class PlatoonAIFunctionTable
---@field [1] FileName
---@field [2] FunctionName


---@class PlatoonTable
---@field public BuilderName string
---@field public PlatoonTemplate PlatoonTemplateTable
---@field public InstanceCount integer
---@field public Priority number
---@field public PlatoonType PlatoonType
---@field public RequiresConstruction boolean
---@field public LocationType UnitGroup
---@field public PlatoonAIFunction PlatoonAIFunctionTable
---@field public PlatoonData PlatoonDataTable
---@field public BuildConditions BuildCondition?
---@field public BuildTimeOut integer

-- Platoon Spec
-- {
--       PlatoonBuildCallbacks = {FunctionsToCallBack when the platoon starts to build}
--       PlatoonAddFunctions = {<other threads to be forked on this platoon>}
--       PlatoonData = {
--           Construction = {
--               BaseTemplate = basetemplates, must contain templates for all 3 factions it will be viewed by faction index,
--               BuildingTemplate = building templates, contain templates for all 3 factions it will be viewed by faction index,
--               BuildClose = true/false do I follow the table order or do build the best spot near me?
--               BuildRelative = true/false are the build coordinates relative to the starting location or absolute coords?,
--               BuildStructures = {List of structure types and the order to build them.}
--          }
--      }
--  },


---@class PlatoonBuilder
---@field _useFunction PlatoonAIFunctionTable
---@field _useType PlatoonType
---@field _useLocation UnitGroup
---@field _useData PlatoonDataTable
---@field _name string
---@field _template PlatoonTemplateTable
---@field _instanceCount integer
---@field _priority number
---@field _type PlatoonType
---@field _requiresconstruction boolean
---@field _location UnitGroup
---@field _function PlatoonAIFunctionTable
---@field _data PlatoonDataTable
---@field _conditions BuildCondition
---@field _buildTimeout integer
PlatoonBuilder = ClassSimple
{
    ---Uses given UnitGroup for all new Platoons
    ---@param location UnitGroup
    ---@return PlatoonBuilder
    UseLocation = function(self, location)
        self._useLocation = location
        return self
    end,

    ---Uses given FileName and FunctionName for all new Platoons
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return PlatoonBuilder
    UseAIFunction = function(self, fileName, functionName)
        self._useFunction = { fileName, functionName }
        return self
    end,

    ---Uses given PlatoonType for all new Platoons
    ---@param platoonType PlatoonType
    ---@return PlatoonBuilder
    UseType = function(self, platoonType)
        self._useType = platoonType
        return self
    end,

    ---Uses given PlatoonDataTable for all new Platoons
    ---@param self PlatoonBuilder
    ---@param data PlatoonDataTable
    ---@return PlatoonBuilder
    UseData = function(self, data)
        self._useData = data
        return self
    end,

    _Clear = function(self)
        self._name = nil
        self._conditions = nil
        self._location = nil
        self._priority = nil
        self._template = nil
        self._type = nil
        self._function = nil
        self._instanceCount = nil
        self._data = nil
        self._buildTimeout = nil
    end,

    ---Starts creation of new Platoon
    ---@param self PlatoonBuilder
    ---@param name string
    ---@return PlatoonBuilder
    New = function(self, name)
        self:_Clear()
        self._name = name
        return self
    end,

    ---Starts creation of new land Platoon with default
    ---PlatoonTemplate with NoPlan
    ---InstanceCount = 1
    ---RequiresConstruction = true
    ---@param self PlatoonBuilder
    ---@param name string
    ---@return PlatoonBuilder
    NewDefault = function(self, name)
        self:New(name)
        self._instanceCount = 1
        self._template = {
            name .. 'template',
            'NoPlan',
        }
        self._type = 'Land'
        return self
    end,

    ---comment
    ---@param self PlatoonBuilder
    ---@param data PlatoonDataTable
    ---@return PlatoonBuilder
    Data = function(self, data)
        self._data = data
        return self
    end,

    ---comment
    ---@param self PlatoonBuilder
    ---@param priority number
    ---@return PlatoonBuilder
    Priority = function(self, priority)
        self._priority = priority
        return self
    end,
    ---comment
    ---@param self PlatoonBuilder
    ---@param location UnitGroup
    ---@return PlatoonBuilder
    Location = function(self, location)
        self._location = location
        return self
    end,
    ---comment
    ---@param self PlatoonBuilder
    ---@param pType PlatoonType
    ---@return PlatoonBuilder
    Type = function(self, pType)
        self._type = pType
        return self
    end,

    ---comment
    ---@param self PlatoonBuilder
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return PlatoonBuilder
    AIFunction = function(self, fileName, functionName)
        self._function = { fileName, functionName }
        return self
    end,
    ---comment
    ---@param self PlatoonBuilder
    ---@param count integer
    ---@return PlatoonBuilder
    InstanceCount = function(self, count)
        self._instanceCount = count
        return self
    end,

    ---Adds new unit into template
    ---@param self PlatoonBuilder
    ---@param unitId UnitId
    ---@param quantity integer
    ---@param orderType OrderType
    ---@param formationType FormationType
    ---@return PlatoonBuilder
    AddUnit = function(self, unitId, quantity, orderType, formationType)
        if self._template == nil then
            error "PlatoonTemplate wasnt initialized"
        end
        table.insert(self._template, { unitId, 1, quantity, orderType, formationType })
        return self
    end,

    ---Adds default unit into template with OrderType as Attack and FormationType as GrowthFormation
    ---@param self PlatoonBuilder
    ---@param unitId UnitId
    ---@param quantity integer?
    ---@return PlatoonBuilder
    AddUnitDefault = function(self, unitId, quantity)
        if quantity == 0 then
            return self
        end
        return self:AddUnit(unitId, quantity or 1, 'Attack', 'GrowthFormation')
    end,

    ---
    ---@param self PlatoonBuilder
    ---@param condition {[1]: FileName,[2]: FunctionName, [3]:any }
    ---@return PlatoonBuilder
    AddCondition = function(self, condition)
        if not self._conditions then
            self._conditions = {}
        end
        table.insert(self._conditions, condition)
        return self
    end,

    ---Adds build condition depending on human army having given category
    ---
    ---``` lua
    ---:AddHumansCategoryCondition(categories.LAND * categories.MOBILE, ">=", 20)
    ---```
    ---@param self PlatoonBuilder
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return PlatoonBuilder
    AddHumansCategoryCondition = function(self, category, compareOp, value)
        return self:AddArmyCategoryCondition("HumanPlayers", category, compareOp, value)
    end,

    ---@param self PlatoonBuilder
    ---@param army ArmyName
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return PlatoonBuilder
    AddArmyCategoryCondition = function(self, army, category, compareOp, value)
        return self:AddArmiesCategoryCondition({ army }, category, compareOp, value)
    end,

    ---@param self PlatoonBuilder
    ---@param armies ArmyName[]
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return PlatoonBuilder
    AddArmiesCategoryCondition = function(self, armies, category, compareOp, value)
        return self:AddCondition
        {
            '/lua/editor/otherarmyunitcountbuildconditions.lua',
            "BrainsCompareNumCategory",
            { 'default_brain', armies, value, category, compareOp }
        }
    end,

    ---comment
    ---@param self PlatoonBuilder
    ---@param time integer
    ---@return PlatoonBuilder
    BuildTimeOut = function(self, time)
        self._buildTimeout = time
        return self
    end,

    _Verify = function(self)
        if self._name ~= nil and
            self._location ~= nil and
            self._priority ~= nil and
            self._template ~= nil and
            self._type ~= nil and
            self._function ~= nil and
            self._instanceCount ~= nil and
            self._data ~= nil
        then
            return
        end
        error(debug.traceback "Incomplete Platoon")
    end,

    ---comment
    ---@param self PlatoonBuilder
    ---@return PlatoonTable
    Create = function(self)
        ---@type PlatoonTable
        local result = {

            BuilderName          = self._name,
            BuildConditions      = self._conditions,
            LocationType         = self._location or self._useLocation,
            Priority             = self._priority,
            PlatoonTemplate      = self._template,
            PlatoonType          = self._type or self._useType,
            PlatoonAIFunction    = self._function or self._useFunction,
            InstanceCount        = self._instanceCount,
            PlatoonData          = self._data or self._useData,
            RequiresConstruction = true,
            BuildTimeOut         = self._buildTimeout

        }
        return result
    end
}
