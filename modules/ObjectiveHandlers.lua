local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")
local VizMarker = import("/lua/sim/vizmarker.lua").VizMarker

local objNumber = 0

---Returns unique objective tag
---@return string
function GetUniqueTag()
    objNumber = objNumber + 1
    return ("Objective%i"):format(objNumber)
end

local factionToImage = {
    ['Cybran'] = '/textures/ui/common/faction_icon-lg/cybran_ico.dds',
    ['Aeon'] = '/textures/ui/common/faction_icon-lg/aeon_ico.dds',
    ['UEF'] = '/textures/ui/common/faction_icon-lg/uef_ico.dds',
    ['Seraphim'] = '/textures/ui/common/faction_icon-lg/seraphim_ico.dds',
}


local playerArmy
function GetPlayerArmy()
    if not playerArmy then
        for _, v in ArmyBrains do
            if v.BrainType == 'Human' then
                playerArmy = v:GetArmyIndex()
                break
            end
        end
    end
    return playerArmy
end

---@param faction 'Cybran'|'Aeon'|'UEF'|'Seraphim'
function GetFactionImage(faction)
    return factionToImage[faction]
end

local typeToUnderlay = {
    ['primary'] = 'icon_objective_primary',
    ['secondary'] = 'icon_objective_secondary',
    ['bonus'] = 'icon_objective_bonus'
}

---@param objType ObjectiveType
function GetUnderlayIcon(objType)
    return typeToUnderlay[objType]
end

---@overload fun(objective:IObjective, area:Area)
---@param objective IObjective
---@param object  Entity
function SetupVizMarker(objective, object)
    if IsEntity(object) then
        local pos = object:GetPosition()
        local spec = {
            X = pos[1],
            Z = pos[2],
            Radius = 8,
            LifeTime = -1,
            Omni = false,
            Vision = true,
            Army = GetPlayerArmy(),
        }
        local vizmarker = VizMarker(spec)
        object.Trash:Add(vizmarker)
        vizmarker:AttachBoneTo(-1, object, -1)
        objective.VizMarkers:Add(vizmarker)
        return
    end


    local rect = ScenarioUtils.AreaToRect(object)
    local width = rect.x1 - rect.x0
    local height = rect.y1 - rect.y0
    local spec = {
        X = rect.x0 + width / 2,
        Z = rect.y0 + height / 2,
        Radius = math.max(width, height),
        LifeTime = -1,
        Omni = false,
        Vision = true,
        Army = GetPlayerArmy(),
    }
    objective.VizMarkers:Add(VizMarker(spec))
end

---@param obj IObjective
---@param unit Unit
---@param targetTag integer
function SetupNotify(obj, unit, targetTag)

    local detectedByCB = function(cbunit, armyindex)
        if not obj.Active then
            return
        end

        -- now if weve been detected by the focus army ...
        if armyindex ~= GetPlayerArmy() then return end
        -- get the blip that is associated with the unit
        local blip = cbunit:GetBlip(armyindex)

        -- Only provide the target position to the user layer if
        -- the blip IsSeenEver() (i.e. has been identified).
        obj.PositionUpdateThreads[targetTag] = ForkThread(
            function()
                while obj.Active do
                    WaitTicks(10)
                    if blip:BeenDestroyed() then
                        return
                    end

                    if blip:IsSeenEver(armyindex) then
                        obj:_UpdateUI(
                            'Target',
                            {
                                Type = 'Position',
                                Value = blip:GetPosition(),
                                BlueprintId = blip:GetBlueprint().BlueprintId,
                                TargetTag = targetTag
                            })

                        -- If it's not mobile we can exit the thread since
                        -- the blip won't move.
                        if not unit.Dead and not unit:BeenDestroyed() and
                            not EntityCategoryContains(categories.MOBILE, unit) then
                            return
                        end
                    end
                end
            end
        )


        local destroyCB = function(cbblip)
            if not obj.Active then
                return
            end

            if obj.PositionUpdateThreads[targetTag] then
                KillThread(obj.PositionUpdateThreads[targetTag])
                obj.PositionUpdateThreads[targetTag] = nil
            end

            -- When the blip is destroyed, tell objectives we dont
            -- have a blip anymore. This doesnt necessarily mean the
            -- unit is killed, we simply lost the blip.
            obj:_UpdateUI('Target',
                {
                    Type = 'Position',
                    Value = nil,
                    BlueprintId = nil,
                    TargetTag = targetTag,
                })

        end
        -- When the blip is destroyed, have it call this callback
        -- function (defined above)
        blip:AddDestroyHook(destroyCB)

    end
    -- When the unit is detected by an army, have it call this callback
    -- function (defined above)
    unit:AddDetectedByHook(detectedByCB)

    -- See if we can detect the unit right now
    local blip = unit:GetBlip(GetPlayerArmy())
    if blip then
        detectedByCB(unit, GetPlayerArmy())
    end
end

-- Take an objective target unit that is owned by the focus army
-- Info passed to user layer to handle zoom to button and chiclet image
---@param obj IObjective
---@param unit Unit
---@param targetTag integer
function SetupFocusNotify(obj, unit, targetTag)
    obj.PositionUpdateThreads[targetTag] = ForkThread(
        function()
            while obj.Active do
                if unit:BeenDestroyed() then
                    return
                end

                obj:_UpdateUI('Target',
                    {
                        Type = 'Position',
                        Value = unit:GetPosition(),
                        BlueprintId = unit:GetBlueprint().BlueprintId,
                        TargetTag = targetTag
                    })

                -- If it's not mobile we can exit the thread since the unit won't move.
                if not unit.Dead and not unit:BeenDestroyed() and not EntityCategoryContains(categories.MOBILE, unit) then
                    return
                end

                WaitTicks(10)
            end
        end
    )

    local destroyCB = function()
        if not obj.Active then
            return
        end

        if obj.PositionUpdateThreads[targetTag] then
            KillThread(obj.PositionUpdateThreads[targetTag])
            obj.PositionUpdateThreads[targetTag] = nil
        end

        -- when the blip is destroyed, tell objectives we dont
        -- have a blip anymore. This doesnt necessarily mean the
        -- unit is killed, we simply lost the blip.
        obj:_UpdateUI('Target',
            {
                Type = 'Position',
                Value = nil,
                BlueprintId = nil,
                TargetTag = targetTag,
            })
    end
    -- When the unit is destroyed have it call this callback
    -- function (defined above)
    unit:AddUnitCallback(destroyCB, 'OnKilled')
end
