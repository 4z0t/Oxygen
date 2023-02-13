local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Utils = import("Utils.lua")
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

Armies = import("ArmyManager.lua")

SetPlayableArea = ScenarioFramework.SetPlayableArea

CreateVisibleAreaAtLocation = ScenarioFramework.CreateVisibleAreaLocation


---returns human units of specified category in area
---@param category EntityCategory
---@param area (Area|Rectangle)?
---@return Unit[]
function GetHumanUnits(category, area)
    local result = {}

    if area then
        if type(area) == 'string' then
            area = ScenarioUtils.AreaToRect(area)
        end

        local entities = GetUnitsInRect(area)

        if not entities then return result end


        local filteredList = EntityCategoryFilterDown(category, entities)

        for _, unit in filteredList do
            for _, player in ScenarioInfo.HumanPlayers do
                if unit:GetAIBrain() == ArmyBrains[player] then
                    table.insert(result, unit)
                end
            end
        end

    else
        for _, player in ScenarioInfo.HumanPlayers do
            local armyUnits = ArmyBrains[player]:GetListOfUnits(category, false)
            for _, unit in armyUnits do
                table.insert(result, unit)
            end
        end
    end
    return result
end

---returns number of human units of specified category in area
---@param category EntityCategory
---@param area (Area|Rectangle)?
---@return integer
function CountHumanUnits(category, area)
    return table.getn(GetHumanUnits(category, area))
end
