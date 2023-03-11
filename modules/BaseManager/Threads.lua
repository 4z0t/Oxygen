
local AIUtils = import("/lua/ai/aiutilities.lua")
local AMPlatoonHelperFunctions = import("/lua/editor/amplatoonhelperfunctions.lua")
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")
local ScenarioPlatoonAI = import("/lua/scenarioplatoonai.lua")
local SUtils = import("/lua/ai/sorianutilities.lua")
local TriggerFile = import("/lua/scenariotriggers.lua")
local Buff = import("/lua/sim/buff.lua")
local BMBC = import("/lua/editor/basemanagerbuildconditions.lua")
local MIBC = import("/lua/editor/miscbuildconditions.lua")
local BaseManagerThreads = import("/lua/ai/opai/BaseManagerPlatoonThreads.lua")




--- Split the platoon into single unit platoons
---@param platoon Platoon
function BaseManagerEngineerPlatoonSplit(platoon)
    ---@type AIBrain
    local aiBrain = platoon:GetBrain()
    local units = platoon:GetPlatoonUnits()
    local baseName = platoon.PlatoonData.BaseName
    ---@type AdvancedBaseManager
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then
        aiBrain:DisbandPlatoon(platoon)
        return
    end
    for _, v in units do
        if not v.Dead then
            -- Make sure current base manager isnt at capacity of engineers
            if EntityCategoryContains(categories.ENGINEER, v) and
                bManager.EngineerQuantity > bManager.CurrentEngineerCount then
                if bManager.EngineerBuildRateBuff then
                    Buff.ApplyBuff(v, bManager.EngineerBuildRateBuff)
                end

                ---@type Platoon
                local engPlat = aiBrain:MakePlatoon('', '')
                aiBrain:AssignUnitsToPlatoon(engPlat, { v }, 'Support', 'None')
                engPlat.PlatoonData = table.deepcopy(platoon.PlatoonData)
                v.BaseName = baseName
                engPlat:ForkAIThread(BaseManagerThreads.BaseManagerSingleEngineerPlatoon)

                -- If engineer is not a commander or sub-commander, increment number of units working for the base
                -- set up death trigger for the engineer
                if not EntityCategoryContains(categories.COMMAND, v) then
                    bManager:AddCurrentEngineer()

                    -- Only add death callback if it hasnt been set yet
                    if not v.Subtracted then
                        TriggerFile.CreateUnitDeathTrigger(BaseManagerThreads.BaseManagerSingleDestroyed, v)
                    end

                    -- If the base is building engineers, subtract one from the amount being built
                    if bManager:GetEngineersBuilding() > 0 then
                        bManager:SetEngineersBuilding(-1)
                    end
                end
            end
        end
    end
    aiBrain:DisbandPlatoon(platoon)
end