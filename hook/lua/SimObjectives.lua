---@param Type ObjectiveType        # Type of objective, used for the strategic icon in the UI
---@param Complete ObjectiveStatus  # Completion status, usually this is 'incomplete' unless the player already completed it by chance
---@param Title string              # Title of the objective, supports strings with LOC
---@param Description string        # Description of the objective, supports strings with LOC
---@param Target table              # Objective data, see the description
---@return Objective
function Damage(Type, Complete, Title, Description, Target)
    Target.damaged = 0
    Target.total = table.getn(Target.Units)



    local image = GetActionIcon('kill')
    local objective = AddObjective(Type, Complete, Title, Description, image, Target)
    objective.Amount = Target.Amount
    objective.RepeatNum = Target.RepeatNum

    -- Call ManualResult
    objective.ManualResult = function(self, result)
        objective.Active = false
        objective:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective(Title, 'complete', resultStr, objective.Tag)
    end


    objective.OnUnitDamaged = function(unit, instigator)

        if not objective.Active then return end

        Target.damaged = Target.damaged + 1

        UpdateObjective(Title, 'Progress', ('(%s/%s)'):format(Target.damaged, Target.total), objective.Tag)
        objective:OnProgress(Target.damaged, Target.total)

        if Target.damaged == Target.total then
            UpdateObjective(Title, 'complete', "complete", objective.Tag)
            objective.Active = false
            objective:OnResult(true, unit)
        end
    end


    for _, unit in Target.Units do
        if not unit.Dead then
            -- Mark the units unless MarkUnits == false
            if Target.MarkUnits == nil or Target.MarkUnits then
                import("/lua/objectivearrow.lua").ObjectiveArrow { AttachTo = unit }
            end
            if Target.FlashVisible then
                FlashViz(unit)
            end
            CreateTriggers(unit, objective, true) -- Reclaiming is same as killing for our purposes
        end
    end


    UpdateObjective(Title, 'Progress', ('(%s/%s)'):format(Target.damaged, Target.total), objective.Tag)

    return objective
end

do
    local OldCreateTriggers = CreateTriggers
    function CreateTriggers(unit, objective, useOnKilledWhenReclaimed)
        if objective.OnUnitDamaged then
            Triggers.CreateUnitDamagedTrigger(objective.OnUnitDamaged, unit, objective.Amount, objective.RepeatNum)
        end
        return OldCreateTriggers(unit, objective, useOnKilledWhenReclaimed)
    end
end
