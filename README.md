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

TODO

## Game and Expanding map

 TODO

## Triggers

TODO

## ...