---Sets target priorities after being built
---@param categories EntityCategory[]
---@return fun(platoonBuilder: PlatoonTemplateBuilder)
function TargettingPriorities(categories)
    ---@param platoonBuilder PlatoonTemplateBuilder
    return function(platoonBuilder)
        platoonBuilder
            :AddCompleteCallback(Oxygen.PlatoonAI.Common, 'PlatoonSetTargetPriorities')
            :MergeData
            {
                CategoryPriorities = categories
            }
    end
end
