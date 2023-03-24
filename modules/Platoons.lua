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

---@param marker Marker
---@param layer? NavLayers
---@return fun(platoonBuilder: PlatoonTemplateBuilder)
function NavigateTo(marker, layer)
    ---@param platoonBuilder PlatoonTemplateBuilder
    return function(platoonBuilder)
        platoonBuilder
            :AIFunction(Oxygen.PlatoonAI.Common, 'PlatoonNavigateToPosition')
            :MergeData
            {
                Destination = marker,
                Layer = layer or 'Land'
            }
    end
end
