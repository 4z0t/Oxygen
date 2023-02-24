local unpack = unpack

local BaseManager = import('/lua/ai/opai/basemanager.lua').BaseManager
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Factions = import('/lua/factions.lua').Factions
local BuildingTemplates = import('/lua/BuildingTemplates.lua').BuildingTemplates
local RebuildStructuresTemplate = import('/lua/BuildingTemplates.lua').RebuildStructuresTemplate
local StructureUpgradeTemplates = import('/lua/upgradetemplates.lua').StructureUpgradeTemplates
local BC = import("BuildConditions.lua")

local BMBC = '/lua/editor/BaseManagerBuildConditions.lua'
local ABMBC = '/mods/Oxygen/modules/AdvancedBaseManagerBuildConditions.lua'
local BMPT = '/lua/ai/opai/BaseManagerPlatoonThreads.lua'


---@alias ConditionType "ANY" | "ALL"

---@class ConditionFuncAndArgs
---@field func fun(...):boolean
---@field args ...

---@class BuildStructuresCondition
---@field Type ConditionType
---@field BuildConditions BuildCondition[]
---@field Priority number
---@field DifficultySeparate boolean


---@class BuildStructuresFunctionCondition
---@field type ConditionType
---@field conditions ConditionFuncAndArgs[]
---@field difficultySeparate boolean
---@field priority number

---@class AdvancedBaseManager : BaseManager
---@field BuildStructuresConditions table<UnitGroup, BuildStructuresFunctionCondition>
---@field MultiFaction boolean
---@field TransportsNeeded integer
AdvancedBaseManager = Class(BaseManager)
{

    ---@param self AdvancedBaseManager
    ---@param brain AIBrain?
    ---@param baseName UnitGroup?
    ---@param markerName Marker?
    ---@param radius number?
    ---@param levelTable any?
    __init = function(self, brain, baseName, markerName, radius, levelTable)
        self:Create()
        if brain and baseName and markerName and radius then
            self:Initialize(brain, baseName, markerName, radius, levelTable)
        end
    end,

    ---Creates AdvancedBaseManager
    ---@param self AdvancedBaseManager
    Create = function(self)
        BaseManager.Create(self)
        self.BuildStructuresConditions = {}
        self.TransportsNeeded = 0
    end,

    ---Initializes AdvancedBaseManager
    ---@param self AdvancedBaseManager
    ---@param brain AIBrain
    ---@param baseName UnitGroup
    ---@param markerName Marker
    ---@param radius number
    ---@param levelTable table<UnitGroup, number>
    ---@param multiFaction boolean
    ---@param diffultySeparate boolean
    Initialize = function(self, brain, baseName, markerName, radius, levelTable, multiFaction, diffultySeparate)
        self.MultiFaction = multiFaction
        BaseManager.Initialize(self, brain, baseName, markerName, radius, levelTable, diffultySeparate)
        self:LoadTransportPlatoonTemplate()
        self:ForkThread(self.CheckBuildStructuresConditions)
    end,

    --- Initialises the base manager using the _D1, _D2 and _D3 difficulty tables.
    ---@param self AdvancedBaseManager
    ---@param brain AIBrain
    ---@param baseName UnitGroup
    ---@param markerName Marker
    ---@param radius number
    ---@param levelTable any
    ---@param multiFaction boolean
    ---@return nil
    InitializeDifficultyTables = function(self, brain, baseName, markerName, radius, levelTable, multiFaction)
        self:Initialize(brain, baseName, markerName, radius, levelTable, multiFaction, true)
    end,

    ---Adds build structures condition
    ---@param self AdvancedBaseManager
    ---@param groupName UnitGroup
    ---@param conditions BuildStructuresCondition
    AddBuildStructures = function(self, groupName, conditions)
        if self.BuildStructuresConditions[groupName] then
            error("AdvancedBaseManager.AddBuildStructures: given UnitGroup " ..
                groupName .. " already presents in conditions")
        end
        if conditions.Priority == nil then
            error("AdvancedBaseManager.AddBuildStructures: Priority must be a number, not nil")
        end
        local bcs = conditions.BuildConditions
        if bcs == nil then
            error("AdvancedBaseManager.AddBuildStructures: BuildCondition must be a reference to a function: {<MODULE PATH>,<FUNCTION NAME>,{<ARGS>}")
        end
        ---@type ConditionFuncAndArgs[]
        local conditionsAndArgs = {}
        for _, bc in bcs do
            if bc[1] == nil or bc[2] == nil then
                error("AdvancedBaseManager.AddBuildStructures: BuildCondition must contain a reference to a function!")
            end
            bc = BC.RemoveDefaultBrain(bc)
            local func = import(bc[1])[ bc[2] ]
            if func == nil then
                error("AdvancedBaseManager.AddBuildStructures: (" .. bc[1] .. ") " .. bc[2] .. " does not exist!")
            end
            table.insert(conditionsAndArgs,
                {
                    func = func,
                    args = bc[3],
                })
        end
        self.BuildStructuresConditions[groupName] = {
            type = conditions.Type or "OR",
            priority = conditions.Priority,
            conditions = conditionsAndArgs,
            difficultySeparate = conditions.DifficultySeparate,
        }
    end,

    ---comment
    ---@param self AdvancedBaseManager
    ---@param conditions ConditionFuncAndArgs[]
    ---@param conditionType ConditionType
    ---@return boolean
    CheckConditions = function(self, conditions, conditionType)
        if conditionType == "ANY" then
            for _, condition in conditions do
                if condition.func(self.AIBrain, unpack(condition.args)) then
                    return true
                end
            end
            return false
        end
        for _, condition in conditions do
            if not condition.func(self.AIBrain, unpack(condition.args)) then
                return false
            end
        end
        return true
    end,

    ---Thread function to check build structures conditions
    ---@param self AdvancedBaseManager
    CheckBuildStructuresConditions = function(self)
        local buildConditions = self.BuildStructuresConditions
        while true do
            if self.Active then
                for groupName, buildCondition in buildConditions do
                    if self:CheckConditions(buildCondition.conditions, buildCondition.type) then
                        if buildCondition.difficultySeparate then
                            self:AddBuildGroupDifficulty(groupName, buildCondition.priority, false, false)
                        else
                            self:AddBuildGroup(groupName, buildCondition.priority, false, false)
                        end
                        buildConditions[groupName] = nil
                    end
                end
            end
            WaitSeconds(Random(3, 5))
        end
    end,


    ---Sets Transporting of AdvancedBaseManager to provided value
    ---@param self AdvancedBaseManager
    ---@param value boolean
    SetBuildTransports = function(self, value)
        self.FunctionalityStates.Transporting = value
    end,


    ---Loads platoons into base manager
    ---@param self AdvancedBaseManager
    ---@param platoons PlatoonTable[]
    LoadPlatoons = function(self, platoons)
        local location = self.BaseName
        local aiBrain = self.AIBrain
        for _, platoon in platoons do
            if platoon.LocationType ~= location then
                local prevLocation = platoon.LocationType
                platoon.LocationType = location
                aiBrain:PBMAddPlatoon(platoon)
                platoon.LocationType = prevLocation
            else
                aiBrain:PBMAddPlatoon(platoon)
            end
        end
    end,

    ---Loads OpAIs into base manager
    ---@param self AdvancedBaseManager
    ---@param opAIs OpAITable[]
    LoadOpAIs = function(self, opAIs)
        for _, opAItable --[[@as OpAITable]]in opAIs do
            if opAItable.unitGroup then
                ---@type OpAIData
                local data = opAItable.data
                local buildCondition = opAItable.buildCondition
                if buildCondition then
                    data.BuildCondition = {
                        {
                            buildCondition[1],
                            buildCondition[2],
                            buildCondition[3]
                        }
                    }
                end
                self:AddUnitAI(
                    opAItable.unitGroup,
                    data
                )
            else
                local opAI = self:AddOpAI(
                    opAItable.type,
                    opAItable.name,
                    opAItable.data
                )

                for childrenType, quantity in opAItable.quantity do
                    opAI:SetChildQuantity(childrenType, quantity)
                end

                for childrenType, state in opAItable.childrenState do
                    opAI:SetChildActive(childrenType, state)
                end

                for lockType, lockData in opAItable.lock do
                    opAI:SetLockingStyle(lockType, lockData)
                end
                if opAItable.buildCondition then
                    opAI:AddBuildCondition(
                        opAItable.buildCondition[1],
                        opAItable.buildCondition[2],
                        opAItable.buildCondition[3]
                    )
                end
                if opAItable.remove then
                    opAI:RemoveChildren(opAItable.remove)
                end

                if opAItable.formation then
                    opAI:SetFormation(opAItable.formation)
                end
            end
        end

    end,


    ---@param self AdvancedBaseManager
    AddToBuildingTemplate = function(self, groupName, addName)
        if not self.MultiFaction then
            return BaseManager.AddToBuildingTemplate(self, groupName, addName)
        end
        local aiBrain = self.AIBrain

        local tblUnit = ScenarioUtils.AssembleArmyGroup(aiBrain.Name, groupName)

        local baseTemplates = aiBrain.BaseTemplates[addName]

        local template = baseTemplates.Template
        local list = baseTemplates.List
        local unitNames = baseTemplates.UnitNames
        local buildCounter = baseTemplates.BuildCounter
        if not tblUnit then
            error('*AI DEBUG - Group: ' .. groupName, 2)
        else
            for factionIndex = 1, 4 do
                -- Convert building to the proper type to be built if needed (ex: T2 and T3 factories to T1)
                for i, unit in tblUnit do
                    for k, unitId in RebuildStructuresTemplate[factionIndex] do
                        if unit.type == unitId[1] then
                            table.insert(self.UpgradeTable, { FinalUnit = unit.type, UnitName = i, })
                            unit.buildtype = unitId[2]
                            break
                        end
                    end
                    if not unit.buildtype then
                        unit.buildtype = unit.type
                    end
                end
                for i, unit in tblUnit do
                    self:StoreStructureName(i, unit, unitNames)
                    for j, buildList in BuildingTemplates[factionIndex] do -- BuildList[1] is type ("T1LandFactory"); buildList[2] is unitId (ueb0101)
                        local unitPos = { unit.Position[1], unit.Position[3], 0 }
                        if unit.buildtype == buildList[2] and buildList[1] ~= 'T3Sonar' then -- If unit to be built is the same id as the buildList unit it needs to be added
                            self:StoreBuildCounter(buildCounter, buildList[1], buildList[2], unitPos, i)

                            local inserted = false
                            for k, section in template do -- Check each section of the template for the right type
                                if section[1][1] == buildList[1] then
                                    table.insert(section, unitPos) -- Add position of new unit if found
                                    list[unit.buildtype].AmountWanted = list[unit.buildtype].AmountWanted + 1 -- Increment num wanted if found
                                    inserted = true
                                    break
                                end
                            end
                            if not inserted then -- If section doesn't exist create new one
                                table.insert(template, { { buildList[1] }, unitPos }) -- add new build type to list with new unit
                                list[unit.buildtype] = { StructureType = buildList[1], StructureCategory = unit.buildtype,
                                    AmountNeeded = 0, AmountWanted = 1, CloseToBuilder = nil } -- add new section of build list with new unit type information
                            end
                            break
                        end
                    end
                end
            end
        end
    end,

    ---@param self AdvancedBaseManager
    LoadDefaultBaseEngineers = function(self)
        if not self.MultiFaction then
            return BaseManager.LoadDefaultBaseEngineers(self)
        end
        local name = self.BaseName
        for faction = 1, 4 do
            local factionName = Factions[faction].Key
            -- The Engineer AI Thread
            for i = 1, 3 do
                self.AIBrain:PBMAddPlatoon {
                    BuilderName = 'T' .. i .. 'BaseManaqer_EngineersWork_' .. name .. factionName,
                    PlatoonTemplate = self:CreateEngineerPlatoonTemplate(i, nil, faction),
                    Priority = 1,
                    PlatoonAIFunction = { BMPT, 'BaseManagerEngineerPlatoonSplit' },
                    BuildConditions = {
                        { BMBC, 'BaseManagerNeedsEngineers', { name } },
                        { BMBC, 'BaseActive', { name } },
                    },
                    PlatoonData = {
                        BaseName = name,
                    },
                    PlatoonType = 'Any',
                    RequiresConstruction = false,
                    LocationType = name,
                }
            end

            -- Disband platoons - engineers built here
            for i = 1, 3 do
                for j = 1, 5 do
                    for _, pType in { 'Air', 'Land', 'Sea' } do
                        self.AIBrain:PBMAddPlatoon {
                            BuilderName = 'T' ..
                                i .. 'BaseManagerEngineerDisband_' .. j .. 'Count_' .. name .. factionName,
                            PlatoonAIPlan = 'DisbandAI',
                            PlatoonTemplate = self:CreateEngineerPlatoonTemplate(i, j, faction),
                            Priority = 300 * i,
                            PlatoonType = pType,
                            RequiresConstruction = true,
                            LocationType = name,
                            PlatoonData = {
                                NumBuilding = j,
                                BaseName = name
                            },
                            BuildConditions = {
                                { BMBC, 'BaseEngineersEnabled', { name } },
                                { BMBC, 'BaseBuildingEngineers', { name } },
                                { BMBC, 'HighestFactoryLevel', { i, name } },
                                { BMBC, 'FactoryCountAndNeed', { i, j, pType, name } },
                                { BMBC, 'BaseActive', { name } },
                            },
                            PlatoonBuildCallbacks = { { BMBC, 'BaseManagerEngineersStarted' }, },
                            InstanceCount = 3,
                            BuildTimeOut = 10, -- Timeout really fast because they dont need to really finish
                        }

                    end
                end
            end
        end
    end,

    ---@param self AdvancedBaseManager
    LoadDefaultBaseCDRs = function(self)
        if not self.MultiFaction then
            return BaseManager.LoadDefaultBaseCDRs(self)
        end
        local name = self.BaseName
        for faction = 1, 4 do
            local factionName = Factions[faction].Key
            -- CDR Build
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_CDRPlatoon_' .. name .. factionName,
                PlatoonTemplate = self:CreateCommanderPlatoonTemplate(faction),
                Priority = 1,
                PlatoonType = 'Any',
                RequiresConstruction = false,
                LocationType = name,
                PlatoonAddFunctions = {
                    -- {'/lua/ai/opai/OpBehaviors.lua', 'CDROverchargeBehavior'}, -- TODO: Re-add once it doesnt interfere with BM engineer thread
                    { BMPT, 'UnitUpgradeBehavior' },
                },
                PlatoonAIFunction = { BMPT, 'BaseManagerSingleEngineerPlatoon' },
                BuildConditions = {
                    { BMBC, 'BaseActive', { name } },
                },
                PlatoonData = {
                    BaseName = name,
                },
            }
        end
    end,

    ---@param self AdvancedBaseManager
    LoadDefaultBaseSupportCDRs = function(self)
        if not self.MultiFaction then
            return BaseManager.LoadDefaultBaseSupportCDRs(self)
        end
        local name = self.BaseName
        for faction = 1, 4 do
            local factionName = Factions[faction].Key
            -- sCDR Build
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_sCDRPlatoon_' .. name .. factionName,
                PlatoonTemplate = self:CreateSupportCommanderPlatoonTemplate(faction),
                Priority = 1,
                PlatoonType = 'Any',
                RequiresConstruction = false,
                LocationType = name,
                PlatoonAddFunctions = {
                    { BMPT, 'UnitUpgradeBehavior' },
                },
                PlatoonAIFunction = { BMPT, 'BaseManagerSingleEngineerPlatoon' },
                BuildConditions = {
                    { BMBC, 'BaseActive', { name } },
                },
                PlatoonData = {
                    BaseName = name,
                },
            }


            -- Disband platoon
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_sACUDisband_' .. name .. factionName,
                PlatoonAIPlan = 'DisbandAI',
                PlatoonTemplate = self:CreateSupportCommanderPlatoonTemplate(faction),
                Priority = 900,
                PlatoonType = 'Gate',
                RequiresConstruction = true,
                LocationType = name,
                BuildConditions = {
                    { BMBC, 'BaseEngineersEnabled', { name } },
                    { BMBC, 'NumUnitsLessNearBase',
                        { name, categories.SUBCOMMANDER, name .. '_sACUNumber' } },
                    { BMBC, 'BaseActive', { name } },
                },
                InstanceCount = 2,
                BuildTimeOut = 10, -- Timeout really fast because they dont need to really finish
            }
        end
    end,

    ---@param self AdvancedBaseManager
    LoadDefaultScoutingPlatoons = function(self)
        if not self.MultiFaction then
            return BaseManager.LoadDefaultScoutingPlatoons(self)
        end
        local name = self.BaseName
        for faction = 1, 4 do
            local factionName = Factions[faction].Key
            -- Land Scouts
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_LandScout_' .. name .. factionName,
                PlatoonTemplate = self:CreateLandScoutPlatoon(faction),
                Priority = 500,
                PlatoonAIFunction = { BMPT, 'BaseManagerScoutingAI' },
                BuildConditions = {
                    { BMBC, 'LandScoutingEnabled', { name, } },
                    { BMBC, 'BaseActive', { name } },
                },
                PlatoonData = {
                    BaseName = name,
                },
                PlatoonType = 'Land',
                RequiresConstruction = true,
                LocationType = name,
                InstanceCount = 1,
            }


            -- T1 Air Scouts
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_T1AirScout_' .. name .. factionName,
                PlatoonTemplate = self:CreateAirScoutPlatoon(1, faction),
                Priority = 500,
                PlatoonAIFunction = { BMPT, 'BaseManagerScoutingAI' },
                BuildConditions = {
                    { BMBC, 'HighestFactoryLevelType', { 1, name, 'Air' } },
                    { BMBC, 'AirScoutingEnabled', { name } },
                    { BMBC, 'BaseActive', { name } },
                },
                PlatoonData = {
                    BaseName = name,
                },
                PlatoonType = 'Air',
                RequiresConstruction = true,
                LocationType = name,
                InstanceCount = 1,
            }


            -- T2 Air Scouts
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_T2AirScout_' .. name .. factionName,
                PlatoonTemplate = self:CreateAirScoutPlatoon(2, faction),
                Priority = 750,
                PlatoonAIFunction = { BMPT, 'BaseManagerScoutingAI' },
                BuildConditions = {
                    { BMBC, 'HighestFactoryLevelType', { 2, name, 'Air' } },
                    { BMBC, 'AirScoutingEnabled', { name } },
                    { BMBC, 'BaseActive', { name } },
                },
                PlatoonData = {
                    BaseName = name,
                },
                PlatoonType = 'Air',
                RequiresConstruction = true,
                LocationType = name,
                InstanceCount = 1,
            }


            -- T3 Air Scouts
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_T3AirScout_' .. name .. factionName,
                PlatoonTemplate = self:CreateAirScoutPlatoon(3, faction),
                Priority = 1000,
                PlatoonAIFunction = { BMPT, 'BaseManagerScoutingAI' },
                BuildConditions = {
                    { BMBC, 'HighestFactoryLevelType', { 3, name, 'Air' } },
                    { BMBC, 'AirScoutingEnabled', { name } },
                    { BMBC, 'BaseActive', { name } },
                },
                PlatoonData = {
                    BaseName = name
                },
                PlatoonType = 'Air',
                RequiresConstruction = true,
                LocationType = name,
                InstanceCount = 1,
            }
        end
    end,

    ---@param self AdvancedBaseManager
    LoadDefaultBaseTMLs = function(self)
        if not self.MultiFaction then
            return BaseManager.LoadDefaultBaseTMLs(self)
        end
        local name = self.BaseName
        for faction = 1, 4 do
            local factionName = Factions[faction].Key
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_TMLPlatoon_' .. name .. factionName,
                PlatoonTemplate = self:CreateTMLPlatoonTemplate(faction),
                Priority = 300,
                PlatoonType = 'Any',
                RequiresConstruction = false,
                LocationType = name,
                PlatoonAIFunction = { BMPT, 'BaseManagerTMLAI' },
                BuildConditions = {
                    { BMBC, 'BaseActive', { name } },
                    { BMBC, 'TMLsEnabled', { name } },
                },
                PlatoonData = {
                    BaseName = name,
                },
            }

        end
    end,


    ---@param self AdvancedBaseManager
    LoadDefaultBaseNukes = function(self)
        if not self.MultiFaction then
            return BaseManager.LoadDefaultBaseNukes(self)
        end
        local name = self.BaseName
        for faction = 1, 4 do
            local factionName = Factions[faction].Key
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_NukePlatoon_' .. name .. factionName,
                PlatoonTemplate = self:CreateNukePlatoonTemplate(faction),
                Priority = 400,
                PlatoonType = 'Any',
                RequiresConstruction = false,
                LocationType = name,
                PlatoonAIFunction = { BMPT, 'BaseManagerNukeAI' },
                BuildConditions = {
                    { BMBC, 'BaseActive', { name } },
                    { BMBC, 'NukesEnabled', { name } },
                },
                PlatoonData = {
                    BaseName = name,
                },
            }
        end
    end,

    CreateTMLPlatoonTemplate = function(self, faction)
        faction = faction or self.AIBrain:GetFactionIndex()
        local template = {
            'TMLTemplate',
            'NoPlan',
            { 'ueb2108', 1, 1, 'Attack', 'None' },
        }
        template = ScenarioUtils.FactionConvert(template, faction)

        return template
    end,

    CreateNukePlatoonTemplate = function(self, faction)
        faction = faction or self.AIBrain:GetFactionIndex()
        local template = {
            'NukeTemplate',
            'NoPlan',
            { 'ueb2305', 1, 1, 'Attack', 'None' },
        }
        template = ScenarioUtils.FactionConvert(template, faction)

        return template
    end,

    CreateLandScoutPlatoon = function(self, faction)
        faction = faction or self.AIBrain:GetFactionIndex()
        local template = {
            'LandScoutTemplate',
            'NoPlan',
            { 'uel0101', 1, 1, 'Scout', 'None' },
        }
        template = ScenarioUtils.FactionConvert(template, faction)

        return template
    end,

    CreateAirScoutPlatoon = function(self, techLevel, faction)
        faction = faction or self.AIBrain:GetFactionIndex()
        local template = {
            'AirScoutTemplate',
            'NoPlan',
            { 'uea', 1, 1, 'Scout', 'None' },
        }

        if techLevel == 3 then
            template[3][1] = template[3][1] .. '0302'
        else
            template[3][1] = template[3][1] .. '0101'
        end

        template = ScenarioUtils.FactionConvert(template, faction)

        return template
    end,

    CreateCommanderPlatoonTemplate = function(self, faction)
        faction = faction or self.AIBrain:GetFactionIndex()
        local template = {
            'CommanderTemplate',
            'NoPlan',
            { 'uel0001', 1, 1, 'Support', 'None' },
        }
        template = ScenarioUtils.FactionConvert(template, faction)

        return template
    end,

    CreateSupportCommanderPlatoonTemplate = function(self, faction)
        faction = faction or self.AIBrain:GetFactionIndex()
        local template = {
            'CommanderTemplate',
            'NoPlan',
            { 'uel0301', 1, 1, 'Support', 'None' },
        }
        template = ScenarioUtils.FactionConvert(template, faction)

        return template
    end,

    CreateEngineerPlatoonTemplate = function(self, techLevel, platoonSize, faction)
        faction = faction or self.AIBrain:GetFactionIndex()
        local size = platoonSize or 5
        local template = {
            'EngineerThing',
            'NoPlan',
            { 'uel', 1, size, 'Support', 'None' },
        }

        if techLevel == 1 then
            template[3][1] = template[3][1] .. '0105'
        elseif techLevel == 2 then
            template[3][1] = template[3][1] .. '0208'
        else
            template[3][1] = template[3][1] .. '0309'
        end

        template = ScenarioUtils.FactionConvert(template, faction)

        return template
    end,


    ---@param self AdvancedBaseManager
    LoadTransportPlatoonTemplate = function(self)
        -- if not self.MultiFaction then
        --     return BaseManager.LoadDefaultBaseNukes(self)
        -- end
        local name = self.BaseName
        for faction = 1, 4 do
            local factionName = Factions[faction].Key
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_TransportPlatoon_' .. name .. factionName,
                PlatoonTemplate = self:CreateTransportPlatoonTemplate(2, faction),
                Priority = 400,
                PlatoonType = 'Air',
                RequiresConstruction = true,
                LocationType = name,
                PlatoonAIFunction = { '/lua/ScenarioPlatoonAI.lua', 'TransportPool' },
                BuildConditions = {
                    { ABMBC, 'NeedTransports', { name } },
                    { ABMBC, 'TransportsEnabled', { name } },
                },
                PlatoonData = {
                    BaseName = name,
                },
                InstanceCount = 3,
            }
        end
    end,

    CreateTransportPlatoonTemplate = function(self, techLevel, faction)
        faction = faction or self.AIBrain:GetFactionIndex()
        local template = {
            'TransportTemplate',
            'NoPlan',
            { 'uea', 1, 1, 'Attack', 'None' },
        }
        if techLevel == 1 then
            template[3][1] = template[3][1] .. '0107'
        elseif techLevel == 2 then
            template[3][1] = template[3][1] .. '0104'
        else
            template[3][1] = "xea0306"
        end
        template = ScenarioUtils.FactionConvert(template, faction)
        return template
    end,



}
