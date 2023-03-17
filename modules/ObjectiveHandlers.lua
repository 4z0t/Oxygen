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



---@param faction 'Cybran'|'Aeon'|'UEF'|'Seraphim'
function GetFactionImage(faction)
    return factionToImage[faction]
end
