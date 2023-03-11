local BMBC = '/lua/editor/BaseManagerBuildConditions.lua'
local ABMBC = '/mods/Oxygen/modules/BaseManager/AdvancedBaseManagerBuildConditions.lua'
local BMPT = '/lua/ai/opai/BaseManagerPlatoonThreads.lua'



---Sets platoon to be an expasion of provided base manager
---@param expansionName string
---@return fun(platoonBuilder:PlatoonTemplateBuilder)
function ExpansionOf(expansionName)

    ---Makes platoon to be an expansion one
    ---@param platoonBuilder PlatoonTemplateBuilder
    return function(platoonBuilder)
        platoonBuilder
            :AIFunction(Oxygen.PlatoonAI.Expansion, 'ExpansionPlatoon')
            :AddCondition { BMBC, 'BaseActive', { expansionName } }
            :AddCondition { BMBC, 'BaseManagerNeedsEngineers', { expansionName } }

        platoonBuilder._data = platoonBuilder._data or {}
        platoonBuilder._data.ExpansionData = {
            BaseName = expansionName
        }
    end

end
