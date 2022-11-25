local Cinematics = import('/lua/cinematics.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

---Enters NIS mode and after callback Exits, makes units in area(s) invincible
---@param callback fun()
---@param area Area|Area[]?
function NISMode(callback, area)
    Cinematics.EnterNISMode()
    if area then
        Cinematics.SetInvincible(area)
        callback()
        Cinematics.SetInvincible(area, true)
    else
        callback()
    end
    Cinematics.ExitNISMode()
end

---Moves camera to marker with name for given amount of seconds
---@param name MarkerChain
---@param seconds number
function MoveTo(name, seconds)
    return Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker(name), seconds)
end

---Displays text with given size, color, position and for duration in seconds
---@param text string
---@param size integer
---@param color Color
---@param position "lefttop"|"leftcenter"|"leftbottom"|"righttop"|"rightcenter"|"rightbottom"|"centertop"|"center"|"centerbottom"|
---@param duration number
function DisplayText(text, size, color, position, duration)
    for s in text:gfind("[^\n]+") do
        PrintText(s, size, color, duration, position)
    end
end
