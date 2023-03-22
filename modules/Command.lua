
---Command represents a table with such structure:
---
---`{ <file path>, <function name>, <table of arguments> }`
---
---https://en.wikipedia.org/wiki/Command_pattern
---@class Command
Command = ClassSimple
{
    __init = function(self, args)
        self[3] = args
    end,
}

---@class BrainsCompareNumCategoryCommand : Command
BrainsCompareNumCategoryCommand = Class(Command)
{
    '/lua/editor/otherarmyunitcountbuildconditions.lua',
    "BrainsCompareNumCategory"
}

---@class FocusBrainBeingBuiltOrActiveCategoryCompareCommand : Command
FocusBrainBeingBuiltOrActiveCategoryCompareCommand = Class(Command)
{
    '/mods/Oxygen/modules/BrainsConditions.lua',
    "FocusBrainBeingBuiltOrActiveCategoryCompare"
}


