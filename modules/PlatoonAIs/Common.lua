local Random = Random

local AIBuildStructures = import("/lua/ai/aibuildstructures.lua")
local ScenarioFramework = import("/lua/scenarioframework.lua")
local StructureTemplates = import("/lua/buildingtemplates.lua")
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")
local NavGenerator = import('/lua/sim/NavGenerator.lua')
local NavUtils = import('/lua/sim/NavUtils.lua')

if not NavGenerator.IsGenerated() then
    NavGenerator.Generate()
end



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

---@param platoon Platoon
function PlatoonSetTargetPriorities(platoon)
    local units = platoon:GetPlatoonUnits()
    local categories = platoon.PlatoonData.CategoryPriorities
    for _, unit in units do
        unit:SetTargetPriorities(categories)
    end
end

---@param platoon Platoon
function PlatoonNavigateToPosition(platoon)
    local destination = platoon.PlatoonData.Destination
    local layer = platoon.PlatoonData.Layer

    assert(destination, "PlatoonNavigateToPosition: PlatoonData.Destination wasnt specified")
    assert(layer, "PlatoonNavigateToPosition: PlatoonData.Layer wasnt specified")

    local pos = platoon:GetPlatoonPosition()
    local path, n, length = NavUtils.PathTo(layer, pos, ScenarioUtils.MarkerToPosition(destination))

    assert(path, "PlatoonNavigateToPosition: Unable to find path to " .. destination)

    ScenarioFramework.PlatoonPatrolRoute(platoon, path)
end
