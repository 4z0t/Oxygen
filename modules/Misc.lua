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