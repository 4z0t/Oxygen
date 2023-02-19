---Returns true if given target brains are having active or building units with given category satisfying compare operation
---@param aibrain AIBrain
---@param targetBrains ArmyName[]
---@param numReq number
---@param category EntityCategory
---@param compareType CompareOp @ defaults to ">="
---@return boolean
function FocusBrainBeingBuiltOrActiveCategoryCompare(aibrain, targetBrains, numReq, category, compareType)
    local num = 0
    local targetBrainSet = {}
    local armySetup = ScenarioInfo.ArmySetup
    if type(targetBrains) == "string" then
        targetBrains = { targetBrains }
    end
    for _, brain in targetBrains do
        if brain == 'HumanPlayers' then
            local tblArmy = ListArmies()
            for _, strArmy in ipairs(tblArmy) do
                if armySetup[strArmy].Human then
                    targetBrainSet[armySetup[strArmy].ArmyName] = true
                end
            end
        else
            targetBrainSet[brain] = true
        end
    end

    for _, testBrain in ipairs(ArmyBrains) do
        if targetBrainSet[testBrain.Name] then
            num = num + testBrain:GetBlueprintStat('Units_BeingBuilt', category) +
                testBrain:GetBlueprintStat('Units_Active', category)
        end
    end

    if not compareType or compareType == '>=' then
        return num >= numReq
    elseif compareType == '==' then
        return num == numReq
    elseif compareType == '<=' then
        return num <= numReq
    elseif compareType == '>' then
        return num > numReq
    elseif compareType == '<' then
        return num < numReq
    else
        return false
    end
end
