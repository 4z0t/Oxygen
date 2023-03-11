local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Utils = import("Utils.lua")
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')



---Scatters units on targets with given order
---@param order fun(units:Unit[], target:Unit)
---@param units Unit[]
---@param targets Unit[]
function ScatterUnits(order, units, targets)
    local targetCount = table.getn(targets)
    local unitsCount = table.getn(units)

    local unitsPerTarget = unitsCount / targetCount
    if unitsPerTarget * targetCount < unitsCount then
        unitsPerTarget = unitsPerTarget + 1
    end

    local index = 1
    local curPoolSize = 0
    local pool = {}
    for _, unit in units do
        table.insert(pool, unit)
        curPoolSize = curPoolSize + 1
        if curPoolSize == unitsPerTarget then
            order(pool, targets[index])
            pool = {}
            curPoolSize = 0
            index = index + 1
        end

    end

    if index == targetCount and curPoolSize ~= unitsPerTarget then
        order(pool, targets[index])
    end

end

---Makes from map units UnitEntry list for Platoon Builder
---@param army any
---@param name any
---@return UnitEntry[]
function FromMapUnits(army, name, difficultySeparate)
    if difficultySeparate then
        name = name .. "_D" .. ScenarioInfo.Options.Difficulty
    end

    local unitGroup = ScenarioUtils.FindUnitGroup(name, Scenario.Armies[army].Units)

    assert(unitGroup, "Units of " .. army .. " named " .. name .. " not found")

    local idToCount = {}
    for _, unit in unitGroup.Units do
        idToCount[unit.type] = (idToCount[unit.type] or 0) + 1
    end

    local result = {}
    for id, count in idToCount do
        table.insert(result, { id, count })
    end
    return result
end
