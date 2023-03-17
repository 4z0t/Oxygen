local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local SimObjectives = import("/lua/simobjectives.lua")
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")


---@class ObjectiveArgs : ObjectiveTarget
---@field Hidden boolean
---@field ShowFaction boolean | 'Cybran'|'Aeon'|'UEF'|'Seraphim'
---@field Image string
---@field Requirements ObjectiveTargetRequirements[]
---@field Timer integer
---@field Category EntityCategory
---@field AlwaysVisible boolean
---@field MarkUnits boolean

---@class UserTarget
---@field Type string


---@class IObjective
---@field Type ObjectiveType
---@field Title string
---@field Tag string
---@field Description string
---@field Active boolean
---@field Complete boolean
---@field Hidden boolean
---@field Decals UserDecal[]
---@field UnitMarkers table
---@field VizMarkers table
---@field Decal UserDecal
---@field IconOverrides Unit[]
---@field NextTargetTag integer
---@field PositionUpdateThreads thread[]
---@field SimStartTime number
---@field ResultCallbacks function[]
---@field ProgressCallbacks function[]
---@field Args ObjectiveArgs
IObjective = ClassSimple
{
    Icon = false,


    ---@param self IObjective
    ---@param objType ObjectiveType
    ---@param complete ObjectiveStatus
    ---@param title string
    ---@param description string
    ---@param objArgs ObjectiveArgs
    __init = function(self, objType, complete, title, description, objArgs)

        self.Type = objType
        self.Title = title
        self.Description = description

        self.Tag = ObjectiveHandlers.GetUniqueTag()

        self.Active = true
        self.Complete = false

        self.Hidden = objArgs.Hidden
        self.Decals = {}

        self.UnitMarkers = {}

        self.VizMarkers = {}

        self.Decal = false

        self.IconOverrides = {}

        self.NextTargetTag = 0
        self.PositionUpdateThreads = setmetatable({}, { __mode = "v" })

        self.SimStartTime = GetGameTimeSeconds()


        self.Args = objArgs

        self.ResultCallbacks = {}
        self.ProgressCallbacks = {}

        self:_ProcessArgs(objArgs)

        Sync.ObjectivesTable[self.Tag] = {
            tag = self.Tag,
            type = objType,
            complete = complete,
            hidden = self.Hidden,
            title = self.Title,
            description = self.Description,
            actionImage = self.Icon,
            targetImage = objArgs.Image,
            progress = "",
            targets = self:_FormUserTargets(objArgs),
            loading = false,
            StartTime = self.SimStartTime,
        }
    end,

    ---Adds result callback for an objective
    ---@param self IObjective
    ---@param callback function
    AddResultCallback = function(self, callback)
        table.insert(self.ResultCallbacks, callback)
    end,

    ---Adds progress callback for an objective
    ---@param self IObjective
    ---@param callback function
    AddProgressCallback = function(self, callback)
        table.insert(self.ProgressCallbacks, callback)
    end,

    OnResult = function(self, success, data)
        self.Complete = success

        -- Destroy decals
        for _, v in self.Decals do v:Destroy() end

        -- Destroy unit marker things
        for _, v in self.UnitMarkers do v:Destroy() end

        -- Revert strategic icons
        for _, v in self.IconOverrides do
            if not v:BeenDestroyed() then
                v:SetStrategicUnderlay("")
            end
        end

        -- Destroy visibility markers
        for _, v in self.VizMarkers do v:Destroy() end


        if self.PositionUpdateThreads then
            for k, v in self.PositionUpdateThreads do
                if v then
                    KillThread(self.PositionUpdateThreads[k])
                    self.PositionUpdateThreads[k] = nil
                end
            end
        end

        for _, v in self.ResultCallbacks do v(success, data) end
    end,


    OnProgress = function(self, current, total)
        for _, v in self.ProgressCallbacks do v(current, total) end
    end,

    ---Fail of an objective
    ---@param self IObjective
    Fail = function(self)
        self.Active = false
        self:OnResult(false)
        self:_UpdateUI('complete', 'failed')
    end,

    ---Updates UI of objective
    ---@param self IObjective
    ---@param field string
    ---@param data any
    _UpdateUI = function(self, field, data)
        SimObjectives.UpdateObjective(self.Title, field, data, self.Tag)
    end,



    ---@param self IObjective
    ---@param args ObjectiveArgs
    _ProcessArgs = function(self, args)
        if not args then return end

        if args.ShowFaction then
            args.Image = ObjectiveHandlers.GetFactionImage(args.ShowFaction)
        end

        if args.Units then
            for _, v in args.Units do
                if v and v.IsDead and not v.Dead then
                    self:AddUnitTarget(v)
                end
            end
        end

        if args.Unit and not args.Unit.Dead then
            self:AddUnitTarget(args.Unit)
        end

        if args.Areas then
            for _, v in args.Areas do
                self:AddAreaTarget(v)
            end
        end

        if args.Area then
            self:AddAreaTarget(args.Area)
        end

    end,

    ---Forms user targets to be displayed in UI
    ---@param self IObjective
    ---@param args ObjectiveArgs
    ---@return UserTarget[]
    _FormUserTargets = function(self, args)
        ---@type UserTarget[]
        local userTargets = {}

        if args and args.Requirements then
            for _, req in args.Requirements do
                if req.Area then
                    table.insert(userTargets, { Type = 'Area', Value = ScenarioUtils.AreaToRect(req.Area) })
                end
            end
        elseif args and args.Timer then
            userTargets = { Type = 'Timer', Time = args.Timer }
        end

        if args.Category then
            local bps = EntityCategoryGetUnitList(args.Category)
            if not table.empty(bps) then
                table.insert(userTargets, { Type = 'Blueprint', BlueprintId = bps[1] })
            end
        end

        return userTargets
    end,


    ---@param self IObjective
    ---@param unit Unit
    AddUnitTarget = function(self, unit)
        self.NextTargetTag = self.NextTargetTag + 1
        if unit.Army == ObjectiveHandlers.GetPlayerArmy() then
            ObjectiveHandlers.SetupFocusNotify(self, unit, self.NextTargetTag)
        else
            ObjectiveHandlers.SetupNotify(self, unit, self.NextTargetTag)
        end
        if self.Args.AlwaysVisible then
            ObjectiveHandlers.SetupVizMarker(self, unit)
        end

        -- Mark the units unless MarkUnits == false
        if self.Args.MarkUnits == nil or self.Args.MarkUnits then
            local icon = ObjectiveHandlers.GetUnderlayIcon(self.Type)
            if icon then
                unit:SetStrategicUnderlay(icon)
            end
            table.insert(self.IconOverrides, unit)
        end
    end,


    ---@param self IObjective
    ---@param area Area
    AddAreaTarget = function(self, area)
        self.NextTargetTag = self.NextTargetTag + 1

        self:_UpdateUI('Target',
            {
                Type = 'Area',
                Value = ScenarioUtils.AreaToRect(area),
                TargetTag = self.NextTargetTag
            })

        if self.Args.AlwaysVisible then
            ObjectiveHandlers.SetupVizMarker(self, area)
        end
    end,




}
