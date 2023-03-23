---@alias UnitType
--- | 'T3Transports'
--- | 'MobileMissilePlatforms'
--- | 'MobileShields'
--- | 'HeavyBots'
--- | 'MobileFlak'
--- | 'MobileHeavyArtillery'
--- | 'MobileStealth'
--- | 'SiegeBots'
--- | 'MobileBombs'
--- | 'RangeBots'
--- | 'LightArtillery'
--- | 'AmphibiousTanks'
--- | 'LightTanks'
--- | 'HeavyMobileAntiAir'
--- | 'MobileMissiles'
--- | 'HeavyTanks'
--- | 'MobileAntiAir'
--- | 'LightBots'
--- | 'T1Transports'
--- | 'T2Transports'
--- | 'Interceptors'
--- | 'LightGunships'
--- | 'Bombers'
--- | 'TorpedoBombers'
--- | 'GuidedMissiles'
--- | 'Gunships'
--- | 'CombatFighters'
--- | 'StratBombers'
--- | 'AirSuperiority'
--- | 'HeavyGunships'
--- | 'HeavyTorpedoBombers'
--- | 'T3Transports'
--- | 'T2Transports'
--- | 'T1Transports'
--- | 'T3Engineers'
--- | 'T2Engineers'
--- | 'CombatEngineers'
--- | 'T1Engineers'
--- | 'MobileShields'
--- | 'Battleships'
--- | 'Destroyers'
--- | 'Cruisers'
--- | 'Frigate'
--- | 'Submarines'
--- | 'Frigates'
--- | 'T2Submarines'
--- | 'UtilityBoats'
--- | 'Carriers'
--- | 'NukeSubmarines'
--- | 'AABoats'
--- | 'MissileShips'
--- | 'T3Submarines'
--- | 'TorpedoBoats'
--- | 'BattleCruisers'



---@class FactionUnitIds
---@field UEF UnitId
---@field Cybran UnitId
---@field Aeon UnitId
---@field Seraphim UnitId


---comment
---@param unitId UnitId
---@param factionIndex Faction
---@return UnitId|nil
function FactionConvert(unitId, factionIndex)
    unitId = unitId:lower()
    local newID = unitId

    if factionIndex == 2 then
        if unitId == 'uel0203' then
            newID = 'xal0203'
        elseif unitId == 'xes0204' then
            newID = 'xas0204'
        elseif unitId == 'uea0305' then
            newID = 'xaa0305'
        elseif unitId == 'xel0305' then
            newID = 'xal0305'
        elseif unitId == 'delk002' then
            newID = 'dalk003'
        else
            newID = string.gsub(unitId, 'ue', 'ua')
        end
    elseif factionIndex == 3 then
        if unitId == 'uea0305' then
            newID = 'xra0305'
        elseif unitId == 'xes0204' then
            newID = 'xrs0204'
        elseif unitId == 'xes0205' then
            newID = 'xrs0205'
        elseif unitId == 'xel0305' then
            newID = 'xrl0305'
        elseif unitId == 'uel0307' then
            newID = 'url0306'
        elseif unitId == 'del0204' then
            newID = 'drl0204'
        elseif unitId == 'delk002' then
            newID = 'drlk001'
        else
            newID = string.gsub(unitId, 'ue', 'ur')
        end
    elseif factionIndex == 4 then
        if unitId == 'uel0106' then
            newID = 'xsl0201'
        elseif unitId == 'xel0305' then
            newID = 'xsl0305'
        elseif unitId == 'delk002' then
            newID = 'dslk004'
        else
            newID = string.gsub(unitId, 'ue', 'xs')
        end
    end
    if __blueprints[newID] then
        return newID
    end
    return nil
end

---@param unitId any
---@return FactionUnitIds
local function CreateFactionTable(unitId)
    return {
        UEF = FactionConvert(unitId, 1),
        Cybran = FactionConvert(unitId, 2),
        Aeon = FactionConvert(unitId, 3),
        Seraphim = FactionConvert(unitId, 4),
    }
end

---@type table<UnitType, FactionUnitIds>
unitTypes = {
    ['MobileMissilePlatforms'] = {
        UEF = "",
    },
    ['MobileShields'] = {
        UEF = "",
        Aeon = "",
        Seraphim = "",
    },
    ['HeavyBots'] = CreateFactionTable("XEL0305"),
    ['MobileFlak'] = CreateFactionTable("UEL0205"),
    ['MobileHeavyArtillery'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['MobileStealth'] = {

        Cybran = "",

    },
    ['SiegeBots'] = CreateFactionTable("UEL0303"),
    ['MobileBombs'] = {

        Cybran = "",

    },
    ['RangeBots'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['LightArtillery'] = CreateFactionTable("UEL0103"),
    ['AmphibiousTanks'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['LightTanks'] = CreateFactionTable("UEL0201"),
    ['HeavyMobileAntiAir'] = CreateFactionTable("DELK002"),
    ['MobileMissiles'] = CreateFactionTable("UEL0111"),
    ['HeavyTanks'] = CreateFactionTable("UEL0202"),
    ['MobileAntiAir'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['LightBots'] = CreateFactionTable("UEL0106"),
    ['Interceptors'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['LightGunships'] = {

        Cybran = "",

    },
    ['Bombers'] = CreateFactionTable("UEA0103"),
    ['TorpedoBombers'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['GuidedMissiles'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Gunships'] = CreateFactionTable("UEA0203"),
    ['CombatFighters'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['StratBombers'] = CreateFactionTable("UEA0304"),
    ['AirSuperiority'] = CreateFactionTable("UEA0303"),
    ['HeavyGunships'] = CreateFactionTable("UEA0305"),
    ['HeavyTorpedoBombers'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['T3Transports'] = {
        UEF = "",

    },
    ['T2Transports'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['T1Transports'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['T3Engineers'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['T2Engineers'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['CombatEngineers'] = {
        UEF = "",

    },
    ['T1Engineers'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Battleships'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Destroyers'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Cruisers'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Frigate'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Submarines'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Frigates'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['T2Submarines'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['UtilityBoats'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Carriers'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['NukeSubmarines'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['AABoats'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['MissileShips'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['T3Submarines'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['TorpedoBoats'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['BattleCruisers'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
}

---@alias FactionName
--- | "UEF"
--- | "Cybran"
--- | "Aeon"
--- | "Seraphim"

---@param faction FactionName
function FactionUnitParser(faction)
    ---@param unitType UnitType
    ---@return UnitId
    return function(unitType)
        local unit = unitTypes[unitType][faction]
        assert(unit, "UNIT " .. unitType .. " of " .. faction .. " DOES NOT EXIST")
        return unit
    end
end
