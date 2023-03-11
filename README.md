# Oxygen

Mission scripting is one of the most hard part of making coop mission.
It has its own stages and parts that decide mission flow.
Currently there is only one way of scripting mission in coop. It is using ingame **Scenario Framework** and its dependencies.
However, it has so many problems in root that make scripting more pain than joy.

Oxygen is a Framework that solves this problem and improves some aspects of mission scripting.
These are main parts that form coop mission.

## Objectives and their management

As I mentioned before each mission is a bunch of sequential objectives of different types, such as:

* Kill specific unit
* Kill units in area
* Capture unit
* Reclaim unit
* Build specific unit
* Protect units
* Locating units
* Timer
* Damage unit on required value (by Oxygen)

There can be added more as I did for Damaging unit, but rn objectives are pure trash in their implementation.
To reduce communication with old framework Oxygen provides with **Objective Builder** and **Objective Manager**.

Objective Builder simplifies creation of objective to be loaded then with Objective Manager.

```lua

local objectives = Oxygen.ObjectiveManager()
local objectiveBuilder = Oxygen.ObjectiveBuilder()


objectives:Init
{
objectiveBuilder
  :New "objective1" --name of objective to be called then with ObjectiveManager
  :Title "your title" -- title that player will see in UI
  :Description [[
    description of objective
    ]] -- description that player will see in UI
  :Function "CategoriesInArea" -- function that will be called during objective start (annotated string)
  :To "kill" -- action to perform (can also replace objective function if wasnt specified) (also annotated)
  :Target
  {
    ... -- arguments for objective (annotated)
  }
  :OnStart(function()
    ... -- function that will be called before objective is assigned and actually started, can return table with arguments for Target (useful when specific unit required for objective)
  end)
  :OnSuccess(function()
   ... -- function that is called when objective is successfully complete
  end)
  :OnFail(function()
    ... -- function that is called when objective is failed (optional)
  end)
  :Next "objective2" -- objective that is started after success of this one (optional)
  :Create(),
  ...
}

```

I won't provide how this looks in base game because I dont want to hurt your eyes :P

After objectives were initialized they can be started:

```lua
objectives:Start "objective1"
```

When mission can be ended at success or fail:

```lua
 objectives:EndGame(true) -- success
    ...
 objectives:EndGame(false) -- fail
```

And **Objective Manager** will automatically assemble all data for primary, secondary and bonus objectives to be then displayed in UI.

## Cinematics

 TODO

## Players

TODO

## Base Managers and Platoons

AIs must have something to control to offend player during objective.
This can be reached with **Base Managers** that produce units groups.

Base Manager handles most of things dedicated to base management:

* Managing engineers
* Construction and maintenance of base
* Production of Platoons
* Scouting
* Transporting (by Oxygen)

The most important here is that base manager does most of the stuff for us from the box.
There are platoons left to be setup here and it is pretty large topic, because this makes AIs "alive".

### Platoons

Platoon is a group of units controlled by a thread specified after its assemble.
And why it is a large topic is because platoons have so many options to be set.

Here comes **Platoon Builder** to simplify this process:

```lua
...
local pb = Oxygen.PlatoonBuilder()
 -- before platoon builder is used it can be set up to reduce amount of code
pb
    -- sets AI function to be used for any platoon created by platoon builder 
    -- if there wasnt specified
    :UseAIFunction(Oxygen.PlatoonAI.Common, "PatrolChainPickerThread") 
    -- base manager name that builds this platoon
    -- not necessary since platoon loader of Advanced Base Manager sets it by default
    -- (ill show later)
    :UseLocation "SE_BASE"
    -- type of platoon to produce (can be Land, Air, Sea, Gate or Any)
    :UseType 'Land'
    -- sets PlatoonData to be used by AI function
    :UseData
    {
        PatrolChains = {
            "LAC01",
            "LAC02",
            "LAC03",
        },
        Offset = 10
    }

    -- after that we can add platoons into base manager directly with creating

baseManager:LoadPlatoons 
{
    pb:NewDefault "Rhinos SE" -- name of platoon, must be a unique value
        :InstanceCount(5)     -- number of instances of platoon that base manager will produce (defaults to 1)
        :Priority(280)        -- priority of platoon construction, base manager will build platoons with higher priority first
        :AddUnit(UNIT "Rhino", 4) -- adding 4 rhinos into platoon
        :AddUnit(UNIT "Deceiver", 1) -- and 1 deceiver
        :Create(), -- creating, before it is actually added into BM it will get all 'Use' we set before

    -- another way of doing this
    pb:NewDefault "Brick Attack"
        :InstanceCount(5)
        :Priority(200)
        -- we can set on what difficulties to build this platoon
        :Difficulty { "Medium", "Hard" }
        :AddUnits
        {
            { UNIT "Brick", 5 },
            { UNIT "Banger", 3 },
            { UNIT "Deceiver", 1 },
        }
        :Create(),
    
    -- we can make brick fly, platoon will pick transport from dedicated BM or from global pool
    -- and then move on transport by chains specified (PlatoonData is being replaced as well as AIFunction,
    -- because we specified those)
    pb:NewDefault "Flying Brick"
        :InstanceCount(3)
        :Priority(250)
        :AddUnit(UNIT "Brick", 1)
        :AddUnit(UNIT "Deceiver", 1)
        :AIFunction('/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports')
        :Data
        {
            TransportReturn = "MainBase_M",
            TransportChain = "FlyingBrickRoute",
            LandingChain = "FlyingBrickLanding",
            AttackChain = "TransportAttack"
        }
        :Create(),

    -- transporting engineers to build expansion base, also requires dedicated BM to exist
    pb:NewDefault "SE Engineers"
        :InstanceCount(1)
        :Priority(500)
        :AddUnit(UNIT "T3 Cybran Engineer", 5)
        :Data
        {
            UseTransports = true,
            TransportReturn = "MainBase_M",
            TransportChain = "SE_Base_chain",
            LandingLocation = "SE_Base_M",
        }
        -- this line makes all magic, it makes specific platoon setup
        -- so it becomes an expansion one (also provided by Oxygen)
        :Create(Oxygen.BaseManager.Platoons.ExpansionOf "SE_BASE"),
    
    -- we can load platoon template units that were defined on map
    -- setting up squad (Artillery) and its formation (GrowthFormation)
    -- by default all units added into platoon builder without specified
    -- squad or formation get those as 'Attack' and 'AttackFormation'
    pb:NewDefault "Arty attack"
        :Priority(500)
        :AddUnits(
            Oxygen.Misc.FromMapUnits("Evil Bot", "ArtyAttack", 'Artillery', 'GrowthFormation')
        )
        :Create(),

    -- Ras bots are also supported :P
    -- of course Gate must present in base
    pb:NewDefault "bois"
        :Type "Gate"
        :Priority(500)
        :AddUnit(UNIT "Cybran RAS SACU", 10)
        :Create(Oxygen.BaseManager.Platoons.ExpansionOf "NukeBaseGroup"),

}
```

## Game and Expanding map

 TODO

## Triggers

TODO

##
