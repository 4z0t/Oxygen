local Utils = import("Utils.lua")
local BC = import("BuildConditions.lua")


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

---@class Transporting_PlatoonDataTable
---@field TransportReturn Marker? @Location for transports to return to (they will attack with land units if this isn't set)
---@field UseTransports boolean?
---@field TransportRoute  Marker[]?
---@field TransportChain MarkerChain?
---@field LandingLocation Marker


---@class StartBaseEngineerThread_PlatoonDataTable: Transporting_PlatoonDataTable



---@class LandAssaultWithTransports_PlatoonDataTable:Transporting_PlatoonDataTable
---@field TransportChain MarkerChain?
---@field AssaultChains MarkerChain[]?
---@field AttackChain MarkerChain?
---@field LandingChain MarkerChain?
---@field LandingList Marker[]? @List of possible locations for transports to unload units
---@field RandomPatrol boolean?
---@field PatrolChain MarkerChain?

---@class PlatoonDataTable : LandAssaultWithTransports_PlatoonDataTable, StartBaseEngineerThread_PlatoonDataTable
---@field PatrolChains MarkerChain[]?
---@field PatrolChain MarkerChain?
---@field LocationChain MarkerChain?
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


---@class PlatoonSpecTable
---@field public BuilderName string
---@field public PlatoonTemplate PlatoonTemplateTable
---@field public InstanceCount integer
---@field public Priority number
---@field public PlatoonType PlatoonType
---@field public RequiresConstruction boolean
---@field public LocationType UnitGroup
---@field public PlatoonBuildCallbacks PlatoonAIFunctionTable[] @Callbacks when platoon starts to build
---@field public PlatoonAddFunctions PlatoonAIFunctionTable[] @Callbacks when platoon is complete
---@field public PlatoonAIFunction PlatoonAIFunctionTable @ Main Platoon AI function
---@field public PlatoonData PlatoonDataTable
---@field public BuildConditions BuildCondition?
---@field public BuildTimeOut integer
---@field public Difficulty DifficultyLevel

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


---@class PlatoonTemplateBuilder
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
---@field _difficulty DifficultyLevel
PlatoonBuilder = ClassSimple
{
    ---Uses given UnitGroup for all new Platoons
    ---@param location UnitGroup
    ---@return PlatoonTemplateBuilder
    UseLocation = function(self, location)
        self._useLocation = location
        return self
    end,

    ---Uses given FileName and FunctionName for all new Platoons
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return PlatoonTemplateBuilder
    UseAIFunction = function(self, fileName, functionName)
        self._useFunction = { fileName, functionName }
        return self
    end,

    ---Uses given PlatoonType for all new Platoons
    ---@param platoonType PlatoonType
    ---@return PlatoonTemplateBuilder
    UseType = function(self, platoonType)
        self._useType = platoonType
        return self
    end,

    ---Uses given PlatoonDataTable for all new Platoons
    ---@param self PlatoonTemplateBuilder
    ---@param data PlatoonDataTable
    ---@return PlatoonTemplateBuilder
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
        self._difficulty = nil
    end,

    ---Starts creation of new Platoon
    ---@param self PlatoonTemplateBuilder
    ---@param name string
    ---@return PlatoonTemplateBuilder
    New = function(self, name)
        self:_Clear()
        self._name = name
        return self
    end,

    ---Starts creation of new land Platoon with default
    ---PlatoonTemplate with NoPlan
    ---InstanceCount = 1
    ---RequiresConstruction = true
    ---@param self PlatoonTemplateBuilder
    ---@param name string
    ---@return PlatoonTemplateBuilder
    NewDefault = function(self, name)
        self:New(name)
        self._instanceCount = 1
        self._template = {
            name .. 'template',
            'NoPlan',
        }
        self._type = self._useType or 'Land'
        return self
    end,

    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param data PlatoonDataTable
    ---@return PlatoonTemplateBuilder
    Data = function(self, data)
        self._data = data
        return self
    end,

    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param priority number
    ---@return PlatoonTemplateBuilder
    Priority = function(self, priority)
        self._priority = priority
        return self
    end,
    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param location UnitGroup
    ---@return PlatoonTemplateBuilder
    Location = function(self, location)
        self._location = location
        return self
    end,
    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param pType PlatoonType
    ---@return PlatoonTemplateBuilder
    Type = function(self, pType)
        self._type = pType
        return self
    end,

    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return PlatoonTemplateBuilder
    AIFunction = function(self, fileName, functionName)
        self._function = { fileName, functionName }
        return self
    end,
    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param count integer
    ---@return PlatoonTemplateBuilder
    InstanceCount = function(self, count)
        self._instanceCount = count
        return self
    end,

    ---Adds new unit into template
    ---@param self PlatoonTemplateBuilder
    ---@param unitId UnitId
    ---@param quantity? integer @defaults to 1
    ---@param orderType? OrderType @defaults to 'Attack'
    ---@param formationType? FormationType @defaults to 'AttackFormation'
    ---@return PlatoonTemplateBuilder
    AddUnit = function(self, unitId, quantity, orderType, formationType)
        if quantity == 0 then return self end
        assert(self._template, "PlatoonTemplate wasnt initialized")
        table.insert(self._template, { unitId, 1, quantity or 1, orderType or 'Attack', formationType or 'AttackFormation' })
        return self
    end,

    ---@deprecated
    ---Adds default unit into template with OrderType as Attack and FormationType as GrowthFormation
    ---@param self PlatoonTemplateBuilder
    ---@param unitId UnitId
    ---@param quantity integer?
    ---@return PlatoonTemplateBuilder
    AddUnitDefault = function(self, unitId, quantity)
        return self:AddUnit(unitId, quantity)
    end,

    ---
    ---@param self PlatoonTemplateBuilder
    ---@param condition BuildCondition
    ---@return PlatoonTemplateBuilder
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
    ---@param self PlatoonTemplateBuilder
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return PlatoonTemplateBuilder
    AddHumansCategoryCondition = function(self, category, compareOp, value)
        return self:AddArmyCategoryCondition("HumanPlayers", category, compareOp, value)
    end,

    ---@param self PlatoonTemplateBuilder
    ---@param army ArmyName
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return PlatoonTemplateBuilder
    AddArmyCategoryCondition = function(self, army, category, compareOp, value)
        return self:AddArmiesCategoryCondition({ army }, category, compareOp, value)
    end,

    ---@param self PlatoonTemplateBuilder
    ---@param armies ArmyName[]
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return PlatoonTemplateBuilder
    AddArmiesCategoryCondition = function(self, armies, category, compareOp, value)
        return self:AddCondition(BC.ArmiesCategoryCondition(armies, category, compareOp, value))
    end,

    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param time integer
    ---@return PlatoonTemplateBuilder
    BuildTimeOut = function(self, time)
        self._buildTimeout = time
        return self
    end,

    ---Makes platoon to be built only on listed difficulty
    ---@param self PlatoonTemplateBuilder
    ---@param difficulty DifficultyStrings
    ---@return PlatoonTemplateBuilder
    Difficulty = function(self, difficulty)
        self._difficulty = Oxygen.DifficultyValue.ParseDifficulty(difficulty)
        return self
    end,

    ---Makes platoon to be built only on listed difficulties
    ---@param self PlatoonTemplateBuilder
    ---@param difficulties DifficultyStrings[]
    ---@return PlatoonTemplateBuilder
    Difficulties = function(self, difficulties)
        self._difficulty = Oxygen.DifficultyValue.ParseDifficulty(difficulties)
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
    ---@param self PlatoonTemplateBuilder
    ---@return PlatoonSpecTable
    Create = function(self)
        ---@type PlatoonSpecTable
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
            BuildTimeOut         = self._buildTimeout,
            Difficulty           = self._difficulty or ScenarioInfo.Options.Difficulty

        }
        return result
    end
}
