local TableGetn = table.getn
local unpack = unpack

AIBrain = Class(AIBrain) {

    ---@param self AIBrain
    ---@param bCs table
    ---@param index number
    ---@return boolean
    PBMCheckBuildConditions = function(self, bCs, index)

        local PBMBuildConditionsTable = self.PBM.BuildConditionsTable
        local isAll = (bCs.Type or "ALL") == "ALL"

        for k, v in bCs do
            if k == "Type" then
                continue
            end

            if not v.LookupNumber then
                v.LookupNumber = {}
            end

            if not v.LookupNumber[index] then
                local found = false
                if v[3][1] == "default_brain" then
                    table.remove(v[3], 1)
                end

                local argc = TableGetn(v[3])

                for num, bcData in PBMBuildConditionsTable do
                    if bcData[1] == v[1] and bcData[2] == v[2] and TableGetn(bcData[3]) == argc then
                        local tablePos = 1
                        found = num
                        while tablePos <= argc do
                            if bcData[3][tablePos] ~= v[3][tablePos] then
                                found = false
                                break
                            end
                            tablePos = tablePos + 1
                        end
                    end
                end

                if found then
                    v.LookupNumber[index] = found
                else
                    table.insert(PBMBuildConditionsTable, v)
                    v.LookupNumber[index] = TableGetn(PBMBuildConditionsTable)
                end
            end

            local lookupNumber = v.LookupNumber[index]

            if not PBMBuildConditionsTable[lookupNumber].Cached[index] then
                if not PBMBuildConditionsTable[lookupNumber].Cached then
                    PBMBuildConditionsTable[lookupNumber].Cached = {}
                    PBMBuildConditionsTable[lookupNumber].CachedVal = {}
                end
                PBMBuildConditionsTable[lookupNumber].Cached[index] = true

                local d = PBMBuildConditionsTable[lookupNumber]
                PBMBuildConditionsTable[lookupNumber].CachedVal[index] = import(d[1])[ d[2] ](self,
                    unpack(d[3]))

                self.BCFuncCalls = self.BCFuncCalls or 0

                if index == 3 then
                    self.BCFuncCalls = self.BCFuncCalls + 1
                end
            end

            local result = PBMBuildConditionsTable[lookupNumber].CachedVal[index]

            if isAll then
                if not result then
                    return false
                end
            elseif result then
                return true
            end
        end
        return isAll
    end
}
