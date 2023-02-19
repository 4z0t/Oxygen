---@param armies ArmyName[]
---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmiesCategoryCondition(armies, category, compareOp, value)
    return {
        '/lua/editor/otherarmyunitcountbuildconditions.lua',
        "BrainsCompareNumCategory",
        { "default_brain", armies, value, category, compareOp }
    }
end

---@param category EntityCategory
---@param army ArmyName
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmyCategoryCondition(army, category, compareOp, value)
    return ArmiesCategoryCondition({ army }, category, compareOp, value)
end

---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function HumansCategoryCondition(category, compareOp, value)
    return ArmyCategoryCondition("HumanPlayers", category, compareOp, value)
end

---@param armies ArmyName[]
---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmiesBuiltOrActiveCategoryCondition(armies, category, compareOp, value)
    return {
        '/mods/Oxygen/modules/BrainsConditions.lua',
        "FocusBrainBeingBuiltOrActiveCategoryCompare",
        { "default_brain", armies, value, category, compareOp }
    }
end

---@param category EntityCategory
---@param army ArmyName
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmyBuiltOrActiveCategoryCondition(army, category, compareOp, value)
    return ArmiesBuiltOrActiveCategoryCondition({ army }, category, compareOp, value)
end

---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function HumansBuiltOrActiveCategoryCondition(category, compareOp, value)
    return ArmyBuiltOrActiveCategoryCondition("HumanPlayers", category, compareOp, value)
end

---@param condition BuildCondition
---@return BuildCondition
function RemoveDefaultBrain(condition)
    if condition[3][1] == "default_brain" then
        table.remove(condition[3], 1)
    end
    return condition
end
