local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local BaseManagerThreads = import("/lua/ai/opai/BaseManagerPlatoonThreads.lua")



---comment
---@param platoon Platoon
function ExpansionPlatoon(platoon)
    ---@type AIBrain
    local aiBrain = platoon:GetBrain()
    local units = platoon:GetPlatoonUnits()
    local data = platoon.PlatoonData
    local expansionData = data.ExpansionData



    if data.UseTransports then
        if not ScenarioPlatoonAI.GetLoadTransports(platoon) then
            return
        end
    end

    -- Set Ready and hold for Wait variable
    if not ScenarioPlatoonAI.ReadyWaitVariables(data) then
        return
    end

    -- Move and unload units
    if not ScenarioPlatoonAI.StartBaseTransports(platoon, data, aiBrain) then
        return
    end

    WaitSeconds(3)

    aiBrain:DisbandPlatoon(platoon)


    ---@type Platoon
    platoon = aiBrain:MakePlatoon('', '')
    aiBrain:AssignUnitsToPlatoon(platoon, units, "Guard", "None")
    platoon.PlatoonData = expansionData
    platoon:ForkAIThread(BaseManagerThreads.BaseManagerEngineerPlatoonSplit)
end
