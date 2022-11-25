local difficulty

local diffucltyValuesRegister = {}


function Add(key, value)
    difficulty = difficulty or ScenarioInfo.Options.Difficulty or 1
    diffucltyValuesRegister[key] = value
end

function Extend(tbl)
    for k, v in tbl do
        Add(k, v)
    end
end

function Get(key)
    return diffucltyValuesRegister[key][difficulty]
end

if __debug then
    function Add(key, value)
        if diffucltyValuesRegister[key] ~= nil then
            error(debug.traceback("Difficulty value " .. key .. " already exists, attempt to overwrite!"))
        end
        difficulty = difficulty or ScenarioInfo.Options.Difficulty or 1
        diffucltyValuesRegister[key] = value
    end

    function Get(key)
        if diffucltyValuesRegister[key] == nil then
            error(debug.traceback("Attempt to get difficulty value that doesnt exist!"))
        end
        return diffucltyValuesRegister[key][difficulty]
    end
end
