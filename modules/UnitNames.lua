---@alias UnitName
--- |    'Cybran ACU'
--- |    'Sera ACU'
--- |    'Seraphim ACU'
--- |    'UEF ACU'
--- |    'Aeon ACU'
--- |    "T1 Aeon Engineer"
--- |    "T1 UEF Engineer"
--- |    "T1 Cybran Engineer"
--- |    "T1 Sera Engineer"
--- |    "T2 Aeon Engineer"
--- |
--- |    "T2 UEF Engineer"
--- |
--- |    "T2 Cybran Engineer"
--- |
--- |    "T2 Sera Engineer"
--- |
--- |    "T3 Aeon Engineer"
--- |
--- |    "T3 UEF Engineer"
--- |
--- |    "T3 Cybran Engineer"
--- |
--- |    "T3 Sera Engineer"
--- |
--- |
--- |
--- |
--- |    "Soul Ripper"
--- |    "Exp Bug"
--- |
--- |    "Ahwassa"
--- |    "AssWasher"
--- |    "T4 Mercy"
--- |
--- |    "Czar"
--- |    "Donut"
--- |
--- |    "Monkeylord"
--- |    "Monkey Lord"
--- |    "ML"
--- |    "Spider"
--- |
--- |    "Mega"
--- |    "Megalith"
--- |    "Crab"
--- |
--- |    "Scathis"
--- |
--- |    "Ythota"
--- |    "Chicken"
--- |
--- |    "Galactic Colossus"
--- |    "GC"
--- |
--- |
--- |    "Fatboy"
--- |    "Fatty"
--- |    "Brick"
--- |
--- |
--- |    "Banger"
--- |    "T2 Cybran MAA"
--- |
--- |    "Deceiver"
--- |
--- |    "Gemini"
--- |    "Cybran ASF"
--- |
--- |    "Corsair"
--- |
--- |    "Zeus"
--- |    "T1 Cybran Bomber"
--- |
--- |    "Wailer"
--- |    "T3 Cybran Gunship"
--- |
--- |    "Revenant"
--- |    "T3 Cybran Bomber"
--- |
--- |    "Renegade"
--- |    "T2 Cybran Gunship"
--- |
--- |    "Medusa"
--- |    "T1 Cybran Artillery"
--- |    "T1 Cybran Arty"
--- |
--- |
--- |    "Mantis"
--- |
--- |
--- |
--- |    "Fire Beetle"
--- |    "Beetle"
--- |    "Loyalist"
--- |    "Bouncer"
--- |    "T3 Cybran MAA"
--- |    "Rhino"
--- |    "Cybran RAS SACU"
--- |
--- |    "Mole"
--- |    "Snoop"
--- |    "Spirit"
--- |    "Selen"
--- |    
--- |    "Mech Marine"
--- |    "UEF LAB"
--- |    "Flare"
--- |    "Aeon LAB"
--- |    "Hunter"
--- |    "Cybran LAB"
--- |    
--- |    
--- |    


---@type table<UnitId, UnitName[]>
local idsToNames = {


    --ACUs
    ['URL0001'] = {
        'Cybran ACU'
    },
    ['XSL0001'] = {
        'Sera ACU',
        'Seraphim ACU'
    },
    ['UEL0001'] = {
        'UEF ACU',
    },
    ['UAL0001'] = {
        'Aeon ACU'
    },




    --T1 engies
    ['UAL0105'] = {
        "T1 Aeon Engineer"
    },
    ['UEL0105'] = {
        "T1 UEF Engineer"
    },
    ['URL0105'] = {
        "T1 Cybran Engineer"
    },
    ['XSL0105'] = {
        "T1 Sera Engineer"
    },

    --T2 engies
    ['UAL0208'] = {
        "T2 Aeon Engineer"
    },
    ['UEL0208'] = {
        "T2 UEF Engineer"
    },
    ['URL0208'] = {
        "T2 Cybran Engineer"
    },
    ['XSL0208'] = {
        "T2 Sera Engineer"
    },

    --T3 engies
    ['UAL0309'] = {
        "T3 Aeon Engineer"
    },
    ['UEL0309'] = {
        "T3 UEF Engineer"
    },
    ['URL0309'] = {
        "T3 Cybran Engineer"
    },
    ['XSL0309'] = {
        "T3 Sera Engineer"
    },


    --air exps
    ["URA0401"] = {
        "Soul Ripper",
        "Exp Bug"
    },
    ["XSA0402"] = {
        "Ahwassa",
        "AssWasher",
        "T4 Mercy",
    },
    ["UAA0310"] = {
        "Czar",
        "Donut"
    },


    --land exps
    ["URL0402"] = {
        "Monkeylord",
        "Monkey Lord",
        "ML",
        "Spider"
    },
    ["XRL0403"] = {
        "Mega",
        "Megalith",
        "Crab",
    },
    ["URL0401"] = {
        "Scathis",
    },

    ["XSL0401"] = {
        "Ythota",
        "Chicken"
    },
    ["UAL0401"] = {
        "Galactic Colossus",
        "GC"
    },

    ["UEL0401"] = {
        "Fatboy",
        "Fatty"
    },




    --

    ["XRL0305"] = {
        "Brick",

    },

    ["URL0205"] = {
        "Banger",
        "T2 Cybran MAA"
    },

    ["URL0306"] = {
        "Deceiver"
    },

    ["URA0303"] = {
        "Gemini",
        "Cybran ASF"
    },

    ["DRA0202"] = {
        "Corsair",
    },

    ["URA0103"] = {
        "Zeus",
        "T1 Cybran Bomber"
    },

    ["XRA0305"] = {
        "Wailer",
        "T3 Cybran Gunship"
    },
    ["URA0304"] = {
        "Revenant",
        "T3 Cybran Bomber"
    },
    ["URA0203"] = {
        "Renegade",
        "T2 Cybran Gunship"
    },
    ["URL0103"] = {
        "Medusa",
        "T1 Cybran Artillery",
        "T1 Cybran Arty"
    },
    
    ["URL0107"] = {
        "Mantis",

    },
    ["XRL0302"] = {
        "Fire Beetle",
        "Beetle",

    },
    ["URL0303"] = {
        "Loyalist",

    },
    ["DRLK001"] = {
        "Bouncer",
        "T3 Cybran MAA"
    },
    ["URL0202"] = {
        "Rhino"
    },


    ["URL0301_RAS"] = {
        "Cybran RAS SACU"
    },
    -- [""] = {},
    -- [""] = {},
    -- [""] = {},
    -- [""] = {},
    -- t1 land scouts
    ["UEL0101"] = {
        "Snoop"
    },
     ["URL0101"] = {
        "Mole"
    },
    ["UAL0101"] = {
        "Spirit"
    },
    ["XSL0101"] = {
        "Selen"
    },

--- labs
    ["UEL0106"] = {
        "Mech Marine",
        "UEF LAB"
    },
    ["URL0106"] = {
        "Hunter",
        "Cybran LAB"
    },
    ["UAL0106"] = {
        "Flare",
        "Aeon LAB"
    },












}



local namesToIds = {}

local function Init()
    for _id, names in idsToNames do
        local id = _id:lower()
        for _, name in names do
            name = name:lower()
            if namesToIds[name] ~= nil then
                error(debug.traceback("Attempt to assign same name twice " .. name))
            else
                namesToIds[name] = id
            end
        end
        namesToIds[id] = id
    end
    LOG("Assigned nicknames:")
    reprsl(namesToIds)
end

Init()

---Returns unit id by nickname
---@see idsToNames
---@param name UnitName
---@return UnitId
function Get(name)
    name = name:lower()
    return namesToIds[name]
end

if __debug then
    ---Returns unit id by nickname
    ---@see idsToNames
    ---@param name UnitName
    ---@return UnitId
    function Get(name)
        name = name:lower()
        if namesToIds[name] == nil then
            error(debug.traceback("Cant find name " .. name .. "!"))
        end
        return namesToIds[name]
    end
end
