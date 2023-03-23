---@alias UnitType
--- | 'T3Transport'
--- | 'MobileMissilePlatform'
--- | 'MobileShield'
--- | 'HeavyBot'
--- | 'MobileFlak'
--- | 'MobileHeavyArtillery'
--- | 'MobileStealth'
--- | 'SiegeBot'
--- | 'MobileBomb'
--- | 'RangeBot'
--- | 'LightArtillery'
--- | 'AmphibiousTank'
--- | 'LightTank'
--- | 'HeavyMobileAntiAir'
--- | 'MobileMissile'
--- | 'HeavyTank'
--- | 'MobileAntiAir'
--- | 'LightBot'
--- | 'T1Transport'
--- | 'T2Transport'
--- | 'Interceptor'
--- | 'LightGunship'
--- | 'Bomber'
--- | 'TorpedoBomber'
--- | 'GuidedMissile'
--- | 'Gunship'
--- | 'CombatFighter'
--- | 'StratBomber'
--- | 'AirSuperiority'
--- | 'HeavyGunship'
--- | 'HeavyTorpedoBomber'
--- | 'T3Transport'
--- | 'T2Transport'
--- | 'T1Transport'
--- | 'T3Engineer'
--- | 'T2Engineer'
--- | 'CombatEngineer'
--- | 'T1Engineer'
--- | 'MobileShield'
--- | 'Battleship'
--- | 'Destroyer'
--- | 'Cruiser'
--- | 'Frigate'
--- | 'Submarine'
--- | 'Frigate'
--- | 'T2Submarine'
--- | 'UtilityBoat'
--- | 'Carrier'
--- | 'NukeSubmarine'
--- | 'AABoat'
--- | 'MissileShip'
--- | 'T3Submarine'
--- | 'TorpedoBoat'
--- | 'BattleCruiser'



---@class FactionUnitIds
---@field UEF UnitId
---@field Cybran UnitId
---@field Aeon UnitId
---@field Seraphim UnitId

local combatFighters =
{
    "dea0202",
    "dra0202",
    "xaa0202",
    "xsa0202",
}

---comment
---@param unitId UnitId
---@param factionIndex Faction
---@return UnitId|nil
function FactionConvert(unitId, factionIndex)
    unitId = unitId:lower()
    local newID = unitId

    if unitId == "dea0202" then
        newID = combatFighters[factionIndex]
    elseif factionIndex == 2 then
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
    ['MobileMissilePlatform'] = {
        UEF = "",
    },
    ['MobileShield'] = {
        UEF = "",
        Aeon = "",
        Seraphim = "",
    },
    ['HeavyBot'] = CreateFactionTable("XEL0305"),
    ['MobileFlak'] = CreateFactionTable("UEL0205"),
    ['MobileHeavyArtillery'] = CreateFactionTable("UEL0304"),
    ['MobileStealth'] = {
        Cybran = "",
    },
    ['MobileBomb'] = {
        Cybran = "",
    },
    ['SiegeBot'] = CreateFactionTable("UEL0303"),
    ['RangeBot'] = CreateFactionTable("DEL0204"),
    ['LightArtillery'] = CreateFactionTable("UEL0103"),
    ['AmphibiousTank'] = CreateFactionTable("UEL0203"),
    ['LightTank'] = CreateFactionTable("UEL0201"),
    ['HeavyMobileAntiAir'] = CreateFactionTable("DELK002"),
    ['MobileMissile'] = CreateFactionTable("UEL0111"),
    ['HeavyTank'] = CreateFactionTable("UEL0202"),
    ['MobileAntiAir'] = CreateFactionTable("UEL0104"),
    ['LightBot'] = CreateFactionTable("UEL0106"),
    ['Interceptor'] = CreateFactionTable("UEA0102"),
    ['LightGunship'] = {
        Cybran = "",
    },
    ['Bomber'] = CreateFactionTable("UEA0103"),
    ['TorpedoBomber'] = CreateFactionTable("UEA0204"),
    ['GuidedMissile'] = {
        Aeon = "",
    },
    ['Gunship'] = CreateFactionTable("UEA0203"),
    ['CombatFighter'] = CreateFactionTable("DEA0202"),
    ['StratBomber'] = CreateFactionTable("UEA0304"),
    ['AirSuperiority'] = CreateFactionTable("UEA0303"),
    ['HeavyGunship'] = CreateFactionTable("UEA0305"),
    ['HeavyTorpedoBomber'] = {
        Aeon = "",
    },
    ['T3Transport'] = {
        UEF = "",
    },
    ['T2Transport'] = CreateFactionTable("UEA0104"),
    ['T1Transport'] = CreateFactionTable("UEA0107"),
    ['T3Engineer'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['T2Engineer'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['CombatEngineer'] = {
        UEF = "",

    },
    ['T1Engineer'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Battleship'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Destroyer'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Cruiser'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Submarine'] = {
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
    ['T2Submarine'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['UtilityBoat'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Carrier'] = {
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['NukeSubmarine'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
    },
    ['AABoat'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['MissileShip'] = {
        Aeon = "",
    },
    ['T3Submarine'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['TorpedoBoat'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['BattleCruiser'] = {
        UEF = "",
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
