local Random = Random

local AIBuildStructures = import("/lua/ai/aibuildstructures.lua")
local ScenarioFramework = import("/lua/scenarioframework.lua")
local StructureTemplates = import("/lua/buildingtemplates.lua")
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")


function OffsetVector(v, offset)
    local xOffSet = Random() * 2 * offset - offset
    local yOffSet = Random() * 2 * offset - offset
    return { v[1] + xOffSet, v[2], v[3] + yOffSet }
end

---Adds random offset to chain positions
---@param chain Vector[]
---@param offset number
function AddRandomOffset(chain, offset)
    for i, v in chain do
        chain[i] = OffsetVector(v, offset)
    end
end

---@param platoon Platoon
function PatrolChainPickerThread(platoon)
    local data = platoon.PlatoonData
    platoon:Stop()

    assert(data, '*SCENARIO PLATOON AI ERROR: PlatoonData not defined')
    assert(data.PatrolChains, '*SCENARIO PLATOON AI ERROR: PatrolChains not defined')

    local chain = table.random(data.PatrolChains)

    local positions = ScenarioUtils.ChainToPositions(chain)

    if data.Offset then
        AddRandomOffset(positions, data.Offset)
    end
    ScenarioFramework.PlatoonPatrolRoute(platoon, positions)

end