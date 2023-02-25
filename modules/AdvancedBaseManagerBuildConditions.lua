---@param aiBrain AIBrain
---@param baseName string
---@return boolean
function TransportsEnabled(aiBrain, baseName)
    ---@type AdvancedBaseManager
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then return false end
    return bManager.FunctionalityStates.Transporting
end

-- use base manager transport pool!
-- transport attack function must have timeout during which units await transport








---@param aiBrain AIBrain
---@param baseName string
---@return boolean
function NeedTransports(aiBrain, baseName)
    ---@type AdvancedBaseManager
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then return false end


    local transportPool = aiBrain:GetPlatoonUniquelyNamed(baseName .. "_TransportPool")
    if not transportPool then return true end

    local count = table.getn(transportPool:GetPlatoonUnits())

    if count >= bManager.TransportsNeeded then return false end

    local globalPool = aiBrain:GetPlatoonUniquelyNamed("TransportPool")
    if not globalPool then return true end


    local counter = 0
    for _, transport in globalPool:GetPlatoonUnits() do
        aiBrain:AssignUnitsToPlatoon(transportPool, { transport }, 'Scout', "None")
        IssueMove({ transport }, bManager.Position)

        counter = counter + 1
        if counter + count >= bManager.TransportsNeeded then return false end

    end

    return true
end
