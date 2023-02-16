local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Utils = import("Utils.lua")
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')



Initialize = ScenarioUtils.InitializeScenarioArmies


SetUnitCap = SetArmyUnitCap

---Sets army color based on given string
---@param army Army
---@param color string
function SetColor(army, color)
    SetArmyColor(army, Utils.UnpackColor(color))
end

--- Sets an army color to Aeon
---@param army Army
function SetAeonColor(army)
    SetColor(army, "ff29BF29")
end

--- Sets an army color to Aeon ally
---@param army Army
function SetAeonAllyColor(army)
    SetColor(army, "ffA5c866")
end

--- Sets an army color to Aeon neutral
---@param army Army
function SetAeonNeutralColor(army)
    SetArmyColor(army, 16, 86, 16)
end

--- Sets an army color to Cybran
---@param army Army
function SetCybranColor(army)
    SetArmyColor(army, 128, 39, 37)
end

--- Sets an army color to Cybran ally
---@param army Army
function SetCybranAllyColor(army)
    SetArmyColor(army, 219, 74, 58)
end

--- Sets an army color to Cybran neutral
---@param army Army
function SetCybranNeutralColor(army)
    SetArmyColor(army, 165, 9, 1)
end

--- Sets an army color to UEF
---@param army Army
function SetUEFColor(army)
    SetArmyColor(army, 41, 40, 140)
end

--- Sets an army color to UEF ally
---@param army Army
function SetUEFAllyColor(army)
    SetArmyColor(army, 71, 114, 148)
end

--- Sets an army color to UEF neutral
---@param army Army
function SetUEFNeutralColor(army)
    SetArmyColor(army, 16, 16, 86)
end

--- Sets an army color to Coalition
---@param army Army
function SetCoalitionColor(army)
    SetArmyColor(army, 80, 80, 240)
end

--- Sets an army color to neutral
---@param army Army
function SetNeutralColor(army)
    SetArmyColor(army, 211, 211, 180)
end

--- Sets an army color to Aeon player
---@param army Army
function SetAeonPlayerColor(army)
    SetArmyColor(army, 36, 182, 36)
end

--- Sets an army color to evil Aeon
---@param army Army
function SetAeonEvilColor(army)
    SetArmyColor(army, 159, 216, 2)
end

--- Sets an army color to Aeon ally 1
---@param army Army
function SetAeonAlly1Color(army)
    SetArmyColor(army, 16, 86, 16)
end

--- Sets an army color to Aeon ally 2
---@param army Army
function SetAeonAlly2Color(army)
    SetArmyColor(army, 123, 255, 125)
end

--- Sets an army color to Cybran player
---@param army Army
function SetCybranPlayerColor(army)
    SetArmyColor(army, 231, 3, 3)
end

--- Sets an army color to evil Cybran
---@param army Army
function SetCybranEvilColor(army)
    SetArmyColor(army, 225, 70, 0)
end

--- Sets an army color to Cybran ally
---@param army Army
function SetCybranAllyColor(army)
    SetArmyColor(army, 130, 33, 30)
end

--- Sets an army color to UEF player
---@param army Army
function SetUEFPlayerColor(army)
    SetArmyColor(army, 41, 41, 225)
end

--- Sets an army color to UEF ally 1
---@param army Army
function SetUEFAlly1Color(army)
    SetArmyColor(army, 81, 82, 241)
end

--- Sets an army color to UEF ally 2
---@param army Army
function SetUEFAlly2Color(army)
    SetArmyColor(army, 133, 148, 255)
end

--- Sets an army color to Seraphim
---@param army Army
function SetSeraphimColor(army)
    SetArmyColor(army, 167, 150, 2)
end

--- Sets army color to Loyalist
---@param army Army
function SetLoyalistColor(army)
    SetColor(army, "ff006400")
end

---returns army units of specified category in area
---@param army Army
---@param category EntityCategory
---@param area (Area|Rectangle)?
---@return Unit[]
function GetUnits(army, category, area)
    local result = {}
    if area then
        -- TODO
    end

    if type(army) == "string" then
        return GetArmyBrain(army):GetListOfUnits(category, false)
    elseif type(army) == "number" then
        return ArmyBrains[army]:GetListOfUnits(category, false)
    end
    error "Unknown army type!"
end
