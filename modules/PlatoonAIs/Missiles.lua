---comment
---@param platoon Platoon
function PlatoonNukeAI(platoon)
    LOG("started nuke AI")
    platoon:ForkAIThread(platoon.NukeAI)
end
