---retuns existing platoon with name ot makes it
---@param aiBrain AIBrain
---@param name string
---@return Platoon
local function GetPlatoonUniquelyNamedOrMake(aiBrain, name)
    local platoon = aiBrain:GetPlatoonUniquelyNamed(name)
    if not platoon then
        platoon = aiBrain:MakePlatoon('', '')
        platoon:UniquelyNamePlatoon(name)
    end
    return platoon
end

---@param platoon Platoon
function TransportPool(platoon)
    ---@type AIBrain
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData

    local poolName = 'TransportPool'

    local baseName = data.BaseName
    if baseName then
        poolName = baseName .. '_TransportPool'
    end

    GetPlatoonUniquelyNamedOrMake(aiBrain, poolName)

    if data.TransportMoveLocation then
        if type(data.TransportMoveLocation) == 'string' then
            data.MoveRoute = { ScenarioUtils.MarkerToPosition(data.TransportMoveLocation) }
        else
            data.MoveRoute = { data.TransportMoveLocation }
        end
    end

    if data.MoveChain or data.MoveRoute then
        MoveToThread(platoon)
    end

    aiBrain:AssignUnitsToPlatoon(poolName, platoon:GetPlatoonUnits(), 'Scout', 'GrowthFormation')
end

--- Utility Function
--- Function that gets the correct number of transports for a platoon
---@param platoon Platoon
---@return number
function GetTransportsThread(platoon)
    local data = platoon.PlatoonData
    ---@type AIBrain
    local aiBrain = platoon:GetBrain()

    local neededTable = GetNumTransports(platoon)
    local numTransports = 0
    local transportsNeeded = neededTable.Small > 0 or neededTable.Medium > 0 or neededTable.Large > 0
    local transSlotTable = {}

    if transportsNeeded then
        local poolName = 'TransportPool'
        local baseName = data.BaseName
        if baseName then
            poolName = baseName .. '_TransportPool'
        end
        
        local pool = GetPlatoonUniquelyNamedOrMake(aiBrain, poolName)

        while transportsNeeded do
            neededTable = GetNumTransports(platoon)
            -- Make sure more are needed
            local tempNeeded = {}
            tempNeeded.Small = neededTable.Small
            tempNeeded.Medium = neededTable.Medium
            tempNeeded.Large = neededTable.Large
            -- Find out how many units are needed currently
            for _, v in platoon:GetPlatoonUnits() do
                if not v.Dead then
                    if EntityCategoryContains(categories.TRANSPORTATION, v) then
                        local id = v.UnitId
                        if not transSlotTable[id] then
                            transSlotTable[id] = GetNumTransportSlots(v)
                        end
                        local tempSlots = {}
                        tempSlots.Small = transSlotTable[id].Small
                        tempSlots.Medium = transSlotTable[id].Medium
                        tempSlots.Large = transSlotTable[id].Large
                        while tempNeeded.Large > 0 and tempSlots.Large > 0 do
                            tempNeeded.Large = tempNeeded.Large - 1
                            tempSlots.Large = tempSlots.Large - 1
                            tempSlots.Medium = tempSlots.Medium - 2
                            tempSlots.Small = tempSlots.Small - 4
                        end
                        while tempNeeded.Medium > 0 and tempSlots.Medium > 0 do
                            tempNeeded.Medium = tempNeeded.Medium - 1
                            tempSlots.Medium = tempSlots.Medium - 1
                            tempSlots.Small = tempSlots.Small - 2
                        end
                        while tempNeeded.Small > 0 and tempSlots.Small > 0 do
                            tempNeeded.Small = tempNeeded.Small - 1
                            tempSlots.Small = tempSlots.Small - 1
                        end
                        if tempNeeded.Small <= 0 and tempNeeded.Medium <= 0 and tempNeeded.Large <= 0 then
                            transportsNeeded = false
                        end
                    end
                end
            end
            if transportsNeeded then
                local location = platoon:GetPlatoonPosition()
                local transports = {}
                -- Determine distance of transports from platoon
                for _, unit in pool:GetPlatoonUnits() do
                    if EntityCategoryContains(categories.TRANSPORTATION, unit) and not unit:IsUnitState('Busy') then
                        local unitPos = unit:GetPosition()
                        local curr = { Unit = unit, Distance = VDist2(unitPos[1], unitPos[3], location[1], location[3]),
                            Id = unit.UnitId }
                        table.insert(transports, curr)
                    end
                end
                if not table.empty(transports) then
                    local sortedList = {}
                    -- Sort distances
                    for k = 1, table.getn(transports) do
                        local lowest = -1
                        local key, value
                        for j, u in transports do
                            if lowest == -1 or u.Distance < lowest then
                                lowest = u.Distance
                                value = u
                                key = j
                            end
                        end
                        sortedList[k] = value
                        -- Remove from unsorted table
                        table.remove(transports, key)
                    end
                    -- Take transports as needed
                    for i = 1, table.getn(sortedList) do
                        if transportsNeeded then
                            local id = sortedList[i].Id
                            aiBrain:AssignUnitsToPlatoon(platoon, { sortedList[i].Unit }, 'Scout', 'GrowthFormation')
                            numTransports = numTransports + 1
                            if not transSlotTable[id] then
                                transSlotTable[id] = GetNumTransportSlots(sortedList[i].Unit)
                            end
                            local tempSlots = {}
                            tempSlots.Small = transSlotTable[id].Small
                            tempSlots.Medium = transSlotTable[id].Medium
                            tempSlots.Large = transSlotTable[id].Large
                            -- Update number of slots needed
                            while tempNeeded.Large > 0 and tempSlots.Large > 0 do
                                tempNeeded.Large = tempNeeded.Large - 1
                                tempSlots.Large = tempSlots.Large - 1
                                tempSlots.Medium = tempSlots.Medium - 2
                                tempSlots.Small = tempSlots.Small - 4
                            end
                            while tempNeeded.Medium > 0 and tempSlots.Medium > 0 do
                                tempNeeded.Medium = tempNeeded.Medium - 1
                                tempSlots.Medium = tempSlots.Medium - 1
                                tempSlots.Small = tempSlots.Small - 2
                            end
                            while tempNeeded.Small > 0 and tempSlots.Small > 0 do
                                tempNeeded.Small = tempNeeded.Small - 1
                                tempSlots.Small = tempSlots.Small - 1
                            end
                            if tempNeeded.Small <= 0 and tempNeeded.Medium <= 0 and tempNeeded.Large <= 0 then
                                transportsNeeded = false
                            end
                        end
                    end
                end
            end
            if transportsNeeded then
                WaitSeconds(7)
                if not aiBrain:PlatoonExists(platoon) then
                    return false
                end
                local unitFound = false
                for _, unit in platoon:GetPlatoonUnits() do
                    if not EntityCategoryContains(categories.TRANSPORTATION, unit) then
                        unitFound = true
                        break
                    end
                end
                if not unitFound then
                    ReturnTransportsToPool(platoon, data)
                    return false
                end
            end
        end
    end
    return numTransports
end
