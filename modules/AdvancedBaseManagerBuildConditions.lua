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

---@param aiBrain AIBrain
---@param baseName string
---@return boolean
function NeedTransports(aiBrain, baseName)
    ---@type AdvancedBaseManager
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then return false end



    -- for _, platoon in aiBrain:GetPlatoonsList() do
    --     local platoonBaseName = platoon.PlatoonData.BaseName
    --     if platoonBaseName and platoonBaseName == baseName then
    --         for _, unit in platoon:GetPlatoonUnits() do
    --             if EntityCategoryContains(categories.TRANSPORTATION, unit) then
    --                 count = count + 1
    --             end
    --         end
    --     end
    -- end
    local transportPool = aiBrain:GetPlatoonUniquelyNamed "TransportPool"
    if not transportPool then return true end

    local count = table.getn(transportPool:GetPlatoonUnits())
    return bManager.TransportsNeeded > count
end
