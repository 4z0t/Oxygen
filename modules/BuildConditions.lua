---@param armies ArmyName[]
---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmiesCategoryCondition(armies, category, compareOp, value)
    return {
        '/lua/editor/otherarmyunitcountbuildconditions.lua',
        "BrainsCompareNumCategory",
        { armies, value, category, compareOp }
    }
end

---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function HumansCategoryCondition(category, compareOp, value)
    return ArmiesCategoryCondition({ "HumanPlayers" }, category, compareOp, value)
end
