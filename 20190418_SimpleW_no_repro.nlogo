;;Code of 20190418

globals [
  ;;----------------------------"Thresholds":
  h-t                           ;;h-t --> Hunger Threshold
  t-t                           ;;t-t --> Thirst Threshold
  s-t                           ;;s-t --> Sleepness Threshold
  i-t                           ;;i-t --> Interact Threshold
  e-t                           ;;e-t --> Entertainment Threshold
  ;;----------------------------"Limits":
  h-li                          ;;h-li --> Hunger limit
  t-li                          ;;t-li --> Thirst limit
  s-li                          ;;s-li --> Sleepness limit
  i-li                          ;;i-li --> Interaction limit
  e-li                          ;;e-li --> Entertainment limit
  ;;----------------------------
  Info22                        ;;Auxiliary varible to count the number of "1" on the binary representation of each varible of the agents and patches
  ;;----------------------------
  ones                          ;;varible to count the number of "1" bits on our binary representation
  ones_agents                   ;;varible to count the total number of "1" bits on our binary representation of the agents
  ones_patches                  ;;varible to count the total number of "1" bits on our binary representation of the patches
  ;;----------------------------
  agents_bits                   ;;Total bits measured required to measure on binary the caracteristics of agents
  patches_bits                  ;;Total bits measured required to measure on binary the caracteristics of patches
  total_bits                    ;;Total number of bits expected to be needed to reresent the varibles of all agents and patches at any step
  ;;----------------------------
  Info_agents                   ;;Variable used to calculate and store the Info of the Adult agent on simulation
  Info_patches                  ;;Variable used to calculate and store the Info of the patches
  Info_Global                   ;;Variable used to calculate and store the Info of the whole simulation
  ;;----------------------------
  ;;Complexity0 measures:
  Agents_Emergence              ;;Variable used to calculate and store the value for Emergence measured by E=Iout, where Iout= Info_agents of the Adult agents on simulation
  Agents_Self_organization      ;;Variable used to calculate and store the value for Self-Organization measured by S=1-Iout, where Iout= Info_agents of the Adult agents on simulation
  Agents_Complexity             ;;Variable used to calculate and store the value for Complexity measured by C=4*E*S, of the Adult agents on simulation
  ;;----------------------------
  Patches_Emergence             ;;Variable used to calculate and store the value for Emergence measured by E=Iout, where Iout= Info_patches of the Patches on simulation
  Patches_Self_organization     ;;Variable used to calculate and store the value for Self-Organization measured by S=1-Iout, where Iout= Info_patches of the Patches
  Patches_Complexity            ;;Variable used to calculate and store the value for Complexity measured by C=4*E*S, of the Patches
  ;;----------------------------
  Global_Emergence              ;;Variable used to calculate and store the value for Emergence measured by E=Iout, where Iout= Info_Global of the whole simulation
  Global_Self_organization      ;;Variable used to calculate and store the value for Self-Organization measured by S=1-Iout, where Iout= Info_Global of the whole simulation
  Global_Complexity             ;;Variable used to calculate and store the value for Complexity measured by C=4*E*S, of the whole simulation
  ;;----------------------------
  ;;Complexity_2 measures:
  ;;Those are the same as the Complexity0 measures but E=Iout/Iin, S=Iin-Iout and C=4*E*S where Iout= (Info_agents, Info_patches or Info_Global) and
  ;;      Iin= (Agents_Emergence, Patches_Emergence or Global_Emergence as this variables have the previous value for the Info measured)
  ;;There is just 1 exception on the calculus of those variables on the "set" of the world, check it for more details
  Agents_Emergence_2
  Agents_Self_organization_2
  Agents_Complexity_2
  ;;----------------------------
  Patches_Emergence_2
  Patches_Self_organization_2
  Patches_Complexity_2
  ;;----------------------------
  Global_Emergence_2
  Global_Self_organization_2
  Global_Complexity_2
  ;;----------------------------
]
;;----------------"Thresholds":---------------------
;;if Any need of the "Adult  agent" is below their corresponding threshold then the agent will be looking to satisfy this need.
;;   example: if "hunger" caracteristic is below the "h-t" level the agent will look for food.
;;Note: If an Adult agent has to look for more than one need/resource/caracteristic to satisfy,
;;      the agent will look to satisfy those needs in the next order: 1.Food, 2.Water, 3.Sleep, 4.Interact, 5.Entertaiment.
;;--------------------------------------------------
;;----------------"Limits"--------------------------
;;The level of satisfaction for each "need" should not surpass their defined limit,
;;    this due to the fact that in the real world someone can't eat, drink or sleep limitless for example.
;;--------------------------------------------------

turtles-own [
  Cx                     ;;On this variable the Adult agent stores the inicial "xcor" (X coordinate) on which it appeared.
  Cy                     ;;On this variable the Adult agent stores the inicial "ycor" (Y coordinate) on which it appeared.

  hunger                 ;;This variable indicates the level of food  the agent has, can go from h-t/2 (the half of it's threshold) to h-li, if it goes below h-t/2 the Adult agent dies.
  thirst                 ;;This variable indicates the level of water the agent has, can go from h-t/2 (the half of it's threshold) to h-li, if it goes below h-t/2 the Adult agent dies.

  sleepness              ;;this variable can go from cero to s-li, when below it's threshold will make the agent to go to his house to "sleep", increasing "sleepness" variable each tick

  interact               ;;Interact and entertaiment: variables requieres the agent to find other agent to increase it, can range it's value from cero to i-li, e-li,
  entertainment          ;;the agent will try to increase this variables when they are below it's threshold and "hunger", "thirst", "sleepness" are above it's threshold.

  sleeping               ;;this variable indicates the agent is sleeping, works as a counter to make the agent maintain sleep for "n" ticks (n=sleeping)
  interacting            ;;while this variable is greater than cero the agent will try to keep besides another agent.
  entertainment-count    ;;while this variable is greater than cero the agent will try to keep besides another agent.
  Pparent                ;;Probability to look out to be a parent (create another agent)
  Wparent                ;;Probability of acceptance to a proposal by another agent to be a parent
]
;;Comments on Agents variables ("hunger", "thirst", "sleepness", "interact", "entertainment":
;;
;;    Those reduce with the pass of ticks to cause the need to look for the resorces which satifies the corresponding need.
;;"Interact" and "entertainment" are needs to be satisfied between agents.
;;"hunger", "thirst" are to be satisfied by findin water, food on patches and "sleepness" is satisfied by going to sleep at the house patch (patch at Cx and Cy coordinates).
;;
;;      Note: this applies for all agents, evethough the house agents (hs breed) will not use any of those variables

patches-own [
  house            ;;If this variable is true means that the patch was the original position of an Adult agent on the setting of the world and will go back to this position to increment its variable "sleepness"
  house-num        ;;here the "who" number of the first agent to declare this patch its hosue is stored, like an adress (but was never used, only to measure info on patches :S)
  water-level      ;;This variable indicates the level of water currently available on the patch
  food-amount      ;;This variable indicates the level of water currently available on the patch
  water-available  ;;This variable if true indicates the patch will spawn water each tick until the level reached 100
  food-available   ;;This variable if true indicates the patch will spawn food  each tick until the level reached 100
  F-neighbors      ;;This variable will indicate how many neighboring patches contain or will spawn Food
  W-neighbors      ;;This variable will indicate how many neighboring patches contain or will spawn Water
]
;;Notes for patches variables:
;; At the setting of the world the varibles "house", "house-num", "water-available", "food-available" ae set.
;; The amaount of water and food at each patch will encrease with each tick
;; The amount of water or food consumed by an agent at a patch will be rest to the amount previously indicated by the corresponding patch


breed [ hs h ]        ;; Proto agents, represents houses for the Adult agents, those will remain on the initial position of the adult agents (the houses of the Adult agents).
                      ;; this due to the limitation that links so far are just stablish between agents
breed [ adults adult ];; Adult breed, represent the people

;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

;;The initial setup of the world:
to setup
  clear-all;; first we clear all the previous simulation

  ;;First, for the agents (yet inexisting agents) the global variables will be set
  ;;
  ;;Set the thresholds at which they will look to satisfy the corresponding need,
  ;;    as to try to keep satisfied their needs.
  set h-t 25   ;;hunger threshold
  set t-t 15   ;;Thirst threshold
  set s-t 50   ;;Sleepness Threshold
  set i-t 3    ;;Interaction Threshold
  set e-t 1    ;;Entertaiment Threshold
  ;;
  ;;We will set the limits for the satisfaction of each need of the agents
  set h-li 30   ;;hunger limit, no turtle can have more than this amout of "hunger"--> food
  set t-li 18   ;;Thirst limit, no turtle can have more than this amout of "thirst" --> water
  set s-li 100  ;;Sleepness limit, no turtle can have more than this amout of "sleepness" --> good sleep or rest
  set i-li 10   ;;Interaction limit, no turtle can have more than this amout of "interaction" --> social satisfaction
  set e-li 10   ;;Entertaiment limit, no turtle can have more than this amout of "entertainment"

  ;;Now, to set the Patches
  ask patches [
    ;;we will set to false all patches on their boolean variables
    ;;   meaning: initialization of variables for the patches: house, water-available and food available will be false by default
    set house false
    set water-available false
    set food-available false

    ;;At random some patches will have water available
    ;;   so this procedure sets approximately the percent of the
    ;;   cells indicated by "water%" slidebar; if water% is set at 50%
    ;;   then about half the patches will be set as water available spots
    if ((random-float 100) <= water% )[
      set water-available true
      repeat 100 [ spawn ]
    ]

    ;;At random some patches will have food available
    ;;   so this procedure sets approximately the percent of the
    ;;   cells indicated by "food%" slidebar; if resources is set at 50%
    ;;   then about half the patches will be set as food available spots
    if ((random-float 100) <= food% )[
      set food-available true
      repeat 100 [ spawn ]
    ]
  ]

;;The adult agents are created at this part, set their position and needs variables randomly
  create-adults population[
    set Cx random-xcor
    set Cy random-ycor
    setxy Cx Cy
    set color yellow
    set pcolor red
    set house  true
    ;;at the next lines of code the hunger, thirst, interact and entertainment needs/variables will be set randomly above the threshold but below its limit for each agent
    set hunger (h-t + random-float (h-li - h-t))
    set thirst (t-t + random-float (t-li - t-t))
    set sleepness random-float s-li                     ;;As the agents does not die of lack of sleep their initial value for how much they have
                                                        ;;     satisfied this need is random from zero to the sleep limit value of the variable
    set interact (i-t + random-float (i-li - i-t ))     ;;Even tought the agents does not die from the lack of interaction or the lack of entertainment
    set entertainment (e-t + random-float (e-li - e-t)) ;;     those 2 variables/needs are set originally between their limit and threshold to observe the behavior with this initial condition
    set sleeping 0                                      ;;"Sleeping" is set to zero initially as it is expected for the agent to check by his own which need to satisfy first
    set interacting 0                                   ;;The variables entertaiment and interacting are set to zero from the begining as it is not expected to have any agents
    set entertainment-count 0                           ;;     with the initial needs to satisfy those 2 needs/variables
    set Pparent ((random-float 0.05) + 0.01)
    set Wparent ((random-float 0.05) + 0.01)
  ]


;;after the creation of the agents and its configuring the creation of the houses and set of those for each agent take place in the next lines of code
  ask adults [                         ;;so we ask every Adult agent
   if not any? hs-here [               ;;if there is no house agent at their initial location then
     ask patch-here [                  ;;the patch at this place is ask to sprout an house agent
        sprout-hs 1[                   ;;so then, having the house agent created, we set it
        set shape "circle"
        set color white
        set size 0.5
        set house-num who              ;;and give to the patch the house-number of the house agent created on it
       ]
     ]
   ]
   create-links-with hs-here           ;;finally the Adult agent creates a link with its house agent
   fd 20                               ;;and moves from this location, as to avoid some kind of competition
                                       ;;with the rest of the agents that could be sharing this original place
  ]

  World-binary-measure ;;On this block we will measure the variables of all agents and patches on binary and with it form 1 binary string
                       ;;This to after measure the Information represented on the enviroment on the form: -ƩP(x)logP(x).
  Complexity0          ;;On this funtion we will measure Emergence, Self-organization and Complexity for the initial setup of the world, this takes "Iin" as 1

  ;;For the first measure Complexity_2 (which takes "Iin" as previous "Iout") will be equal to Complexity0, taking "Iin" as 1
  set Global_Emergence_2          Global_Emergence
  set Agents_Emergence_2          Agents_Emergence
  set Patches_Emergence_2         Patches_Emergence
  set Global_Self_organization_2  Global_Self_organization
  set Agents_Self_organization_2  Agents_Self_organization
  set Patches_Self_organization_2 Patches_Self_organization
  set Global_Complexity_2         (Global_Emergence_2  * Global_Self_organization_2)
  set Agents_Complexity_2         (Agents_Emergence_2  * Agents_Self_organization_2)
  set Patches_Complexity_2        (Patches_Emergence_2 * Patches_Self_organization_2)

  reset-ticks                          ;;also we reset the ticks for the new simulation, the ticks are some kind of time lapse
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
to go ;;The main part that runs the activities at the simulation for patches and Agents
;;the Adult agents and the patches will be asked to perform the next actions/settings
  ask Adults[
    ;;all the Adult agents are ask to decrease their needs/variables by certain amount, etheir defined by an slider or a fix number
    set hunger (hunger - food_metabolism )
    set thirst (thirst - water_metabolism )
    set sleepness (sleepness - sleep_metabolism )
    ;;As the living Adult agents are the only ones to apply actions the needs which does not kill the agents are limited to decrease near to zero
    if ( interact > 0.0005 )[
      set interact (interact - 0.0005 )
    ]
    if ( entertainment > 0.003 )[
      set entertainment (entertainment - 0.003 )
    ]
    ;;the last and only action at this block for Adult agents
    State ;;at "State" the agent will check which needs require to increase and acordingly take actions to satisfy those
  ]

  ask patches [
    set F-neighbors count neighbors with [food-available ] ;;the neighbors of the patch with food  available are counted on their variable F-neighbors
    set W-neighbors count neighbors with [water-available] ;;the neighbors of the patch with water available are counted on their variable W-neighbors
    ;;--------------
    ;;The patches which were set to contain water or food will be updated
    if ((water-available = true) or (food-available = true)) [
      spawn  ;;At Spawn block the patches will restablish a certain amount of water or food acordingly to "food_spawning" or "water_spawning" respectibely
    ]
  ]
  ;;-----------------------------
  if ((count Adults) = 0) [stop] ;To prevent errors measuring Information of the enviroment when there is no more agents the simulation is stoped.
  ;;-----------------------------
  World-binary-measure ;;On this block we will count the numer of Bits and 1's of the variables of all agents and patches represented on binary
                       ;;and with this measure the Information represented on the enviroment on the form: -ƩP(x)logP(x). values of x = 0, 1
  Complexity_2         ;;On this funtion Emergence = (Iout / Iin), Self-organization = (Iin - Iout) and Complexity = 4 * (E * S)
  Complexity0          ;;On this funtion we will measure Emergence = Iout, Self-organization = (1 - Iout) and Complexity = 4 * (E * S)

  tick                 ;; finally a tick is encreased to denote the past of time on the actions taken or apply on the Adult agents and pacthes
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x


to State ;;State is the block which decides which actions takes the Adult Agent
;;----------------------------------------------------------------------
;;"If" to check and satisfy the need "hunger" ------------------------
;;----------------------------------------------------------------------
  if hunger < h-t [          ;;Checks if the Agents needs to eat
    eat                      ;;Adult agents eat or go look for something to eat randomly
    if hunger < (h-t / 2)[   ;;also it checks:
      die                    ;;     if the agent has pass below half of the Hungry Threshold, it dies
    ]
  ]
;;----------------------------------------------------------------------
;;"If" to check and satisfy the need "thirst" ------------------------
;;----------------------------------------------------------------------
  if thirst < t-t [          ;;Checks if the Agents needs to drink
    drink                    ;;Adult agents drink or go look for something to drink randomly
    if thirst < (t-t / 2)[   ;;also it is checks:
      die                    ;;     if the agent has pass below half of the "thirst Threshold" it dies
    ]
  ]
;;----------------------------------------------------------------------
;;"Ifs" to check and satisfy the need "Sleepness" ----------------------
;;----------------------------------------------------------------------
  if ((sleepness <= s-t) and (sleeping = 0))[ ;;Checks if the agent needs to sleep and is not sleeping already,
                                              ;;each time the agent goes to sleep this If is only true once
    set sleeping (1 + random (s-li - s-t))    ;; sleeping will make the agent to rest above the s-t (sleeping threshold) a random amount
                                              ;;          more precicely a random amount between the diference the sleepness threshold and the sleepness limit
    go-to-sleep                               ;;here the agent will go to rest at his home, the initial place at which the agent appeared, and the only valid place to rest (to restablish the sleepness need)
  ]
  if sleeping > 0 [                           ;;when the agent has already gone to sleep this "if" will keep the agent sleeping at it's house
    go-to-sleep                               ;;     as much ticks as the initial value given to the "sleeping" variable at the previous "If"
  ]
;;----------------------------------------------------------------------
;;"Ifs" to check and satisfy the need "Interact" -----------------------
;;----------------------------------------------------------------------
  if ((hunger >= h-t) and (thirst >= t-t) and (sleepness > s-t) and (sleeping <= 0))[ ;; if the thirst, hungry and sleepness needs are satisfied at the moment
    if (interact <= i-t)[                     ;; Then if the need interact is below it's threshold the "interacting" variable will be set to a random amount between 1 and 250
      set interacting (1 + random 250)        ;; interacting will make the agent to interact above the i-t (interact threshold) a random amount
      interactuar                             ;; with this block the agent will "look for" another agent to interact and begin to satisfy the need "interact"
    ]
    if (interacting > 0) [                    ;; At the previous "If" variable interacting was set
      interactuar                             ;;    so the agent can continue to look for an agent to interact and to continue to satisfy the "interact" need
                                              ;;    as much ticks as the initial value given to the "interacting" variable
    ]
  ]
;;----------------------------------------------------------------------
;;"Ifs" to check and satisfy the need "Entertainment" ------------------
;;----------------------------------------------------------------------
  if ((hunger >= h-t) and (thirst >= t-t) and (sleepness > s-t) and (sleeping <= 0))[ ;; if the thirst, hungry and sleepness needs are satisfied at the moment
                                                                                      ;; so in case another previous need goes below its threshold
                                                                                      ;; the agent will look to satisfy that previous need first, suspending the look for "entertainment"
    if ((entertainment <= e-t) and (entertainment-count <= 0))[                       ;;When the entertainment variable gets below the "e-t" (Entertainment threshold)
                                                                                      ;;      Note: this "If" will be activated only once every time the agent needs to satisfy "entertainment"
      set entertainment-count (1 + random 250)                                        ;; "entertainment-count" variable will be set a random amount between 1 and 250
                                                                                      ;;  to try to make the agent to entertain (satisfy that need) above the e-t (Entertainment threshold)
      entretenerse                                                                    ;;  At this block the agent will "look for" another agent to entertain and begin to satisfy the need "entertainment"
    ]
    if (entertainment-count > 0) [                                                    ;;after "entertainment-count" has set to a random number here we will keep on calling the block "entretenerse"
      entretenerse                                                                    ;;If "entertainment-count" is not zero and another need, like hungry, goes below its threshold this part will be pending
                                                                                      ;;    and completed until all the previous needs are satisfied.
    ]
  ]
;;----------------------------------------------------------------------
;;"Ifs" to check and satisfy "Reproduction" ----------------------------
;;----------------------------------------------------------------------
;;After the needs for food, water, sleep and entertainment are satisfied, the agent will now look to satisfy "Reproduction"
;  if ((hunger >= h-t) and (thirst >= t-t) and (sleepness > s-t) and (sleeping <= 0) and (entertainment > e-t) and (entertainment-count = 0))[
;    if ((random-float 1.0) < Pparent)[ Procreate_try ]                               ;;The agent will have "Procreate_try" posibilities to try to reproduce
;  ]
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to look-for ;;at this block we define how the agent will move randomly
  rt 90         ;;first it rotates rigth 90 degress
  lt random 180 ;;and from there 180 to the left randomly
                ;;this way the agent always look forward but randomly
  fd 0.8        ;;and ofcourse advances, just 0.8 patches as to do not pass by a patch withouht inspecting it
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to go-home ;;The agent go to their corresponding home, the original point at which they appeared at the "set" of the simulation
setxy (round Cx) (round Cy)
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to eat ;;Adult agents eat or go look for something to eat randomly
      while [ (food-amount > 0)     and (hunger < h-li)  ][                     ;;The adult agent eats at the pacth with food until it is satisfied
        ifelse ((food-amount - 1) < 0)                                          ;; or until the patch is left without any food
        [
           set hunger        (hunger + food-amount)
           set food-amount   0
        ]
        [
           set hunger        (hunger + 1)
           set food-amount   (food-amount - 1)
        ]
      ]
      look-for                                                                  ;; In case of no water here, keeps looking for
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to drink ;;Adult agents drink or go look for something to drink randomly
    while [ (([water-level] of patch-here) > 0)        and ( thirst < t-li ) ][ ;; if there is water on it's current patch drinks it
                                                                                ;; or if it is lees than 1 unit on the patch the agent drink that the whole water
      ifelse ((water-level - 1) < 0)                                            ;; on the patch and the patch is left without any water
      [
         set thirst          (thirst + water-level)
         set water-level     0
      ]
      [
         set thirst          (thirst + 1)
         set water-level     (water-level - 1)
      ]
    ]
    look-for                                                                    ;; In case of no water here, keeps looking for it
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to go-to-sleep             ;;With this block the Adult Agents return to home to sleep, to increase the sleepness variable
  go-home                  ;;With this block the Adult Agent return to his home, the patch at the rounded coordinates Cx and Cy for each agent
  if (sleepness < s-li)[   ;;We check if the agent has not reach the limit of the sleepness variable
    set sleepness (sleepness + (s-li / 100))  ;;we add just a cent of the sleep limit so the recovery of this need is not so fast
  ]
  set sleeping (sleeping - 1) ;;the agent will only increase the "sleepness" variable until it reachs it's limit,
                              ;;nonetheless the agent will remain "sleeping" until "sleeping" variable reaches cero
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to spawn  ;;Spawn funtion refill each patch designed to have water or Food respectively
  ;;We check if the patch can have water
  ;;   If the water level is below 100 a refill by 0.01 (water_spawning) of water is made at the patch
  if water-available = true [
    if water-level < 100 [
      set water-level (water-level + water_spawning)
      set pcolor (100 + (water-level * 0.07 + 2))         ;;The color is set was to only vary between the Blue color scale, between 102 and 109
    ]
  ]
  ;;We check if the patch can have food
  ;;   If the food level is below 100 a refill by 0.01 (food_spawning) of food is made at the patch
  if food-available = true [
    if food-amount < 100 [
      set food-amount (food-amount + food_spawning)
      set pcolor (60 + (food-amount * 0.07 + 2))          ;;The color is set was to only vary between the lime color scale, between 62 and 69
    ]
  ]
  ;;If a patch have both water and food available they will change color to some shade of orange, pcolor between 22 and 29
  if ((water-available = true) and (food-available = true)) [
      set pcolor (22 + ((water-level + food-amount) * 0.035))
  ]
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to interactuar ;; the rutin to make an agent interact with other/s
  ifelse any? (other Adults in-radius 1) [ ;;the agent in question will look and go to agents near him, at most at a radious of 1, if there is at least 1
    move-to (min-one-of (other Adults in-radius 1) [ distance myself])
    if interact <= i-li [                  ;;We limit the level of satisfaction (resupply) for the "interact" need/variable
      set interact (interact + 0.02)       ;;So it will be increased only when below the "interaction limit" (i-li)
    ]
    set interacting (interacting - 1)      ;;then if the agent is "interacting" the variable with the same name will decrease by 1 at each tick
  ][                                       ;;it can be seen at the calling of this block that "interactuar" will continue as "interacting" is greater than zero
    look-for                               ;;In case the agent does not find another to "interact" this variable is not increased, "interacting" is not decreased
  ]                                        ;;   and the agent will move, loking for another agent to "interact"
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to entretenerse ;;The working of this block to try to satisfy "entertainment" is the same as the previuos for "interact"
  ifelse any? (other Adults in-radius 1) [
    move-to (min-one-of (other Adults in-radius 1) [ distance myself])
    if entertainment <= e-li [
      set entertainment (entertainment + 0.02)
    ]
    set entertainment-count (entertainment-count - 1)
  ][
    look-for
  ]
end

to Procreate_try ;;The agent will try to reproduce with the closest other Adult agent to him
  ask (min-one-of (other Adults) [distance myself]) [
    if  ( ([Wparent] of myself) < Wparent) [                ;;If the variable Wparent of the agent which request to reproduce is smaller than that of the agent asked then the asked agent hatch a new Adult
      hatch 1 [                                             ;;the patch at this place is ask to sprout the new Adult agent
        (fd 2 )                                             ;;the new Adult agent goes forward the legnth of 2 patches on its current random heading
        (set color white)                                   ;;The color of the new Adult agent is set to white
        ;;at the next lines of code the hunger and thirst needs/variables will be set randomly just below the threshold
        set hunger (h-t - 0.0001)
        set thirst (t-t - 0.0001)
        set sleepness random-float s-li                     ;;As the agents does not die of lack of sleep their initial value is random between zero and it's limit s-li
        set interact (i-t + random-float (i-li - i-t ))     ;;Even tought the agents does not die from the lack of interaction or the lack of entertainment
        set entertainment (e-t + random-float (e-li - e-t)) ;;     those 2 variables/needs are set originally between their limit and threshold to observe the behavior with this initial condition
        set sleeping 0                                      ;;"Sleeping" is set to zero initially as it is expected for the agent to check by his own which need to satisfy first, Note: so the new adult does no begin asleep
        set interacting 0                                   ;;The variables enteracting and entertainment-count are set to zero, as it is not expected for the new adult to need to satisfy interact or entertainment rigth away
        set entertainment-count 0                           ;;     as it is not expected for the new adult to need to satisfy interact or entertainment rigth away
        set Pparent ((random-float 0.05) + 0.01)            ;;This variable is created whitin the same range as the original Adults
        set Wparent ((random-float 0.05) + 0.01)            ;;This variable is created whitin the same range as the original Adults
        (create-link-with (one-of ([link-neighbors] of myself) ))   ;;finally the Adult agent creates a link with its house agent (the same house agent his parent has)
      ]
    ]
  ]
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

;;On this block we will measure the variables of all agents and patches on binary, the number of "1´s" those have and it's total number of bits
;;This to after measure the Information represented on the enviroment on the form: -ƩP(x)logP(x).
to World-binary-measure

  set ones (0 + (count adults))           ;;As the representation of dead or alive of any agent is 1 for alive and 0 for dead
                                          ;;we will only count how many agent are alive and add this number of "1" to "ones"
  set total_bits ( 0 + (count adults) )   ;;So also the numbers of adults alive is the number of bits required to measure them as alive
  ask Adults[
    ;;Measurement of "1's" and bits for "heading" of each agent in binary
    set Info22 (heading)
    Bits_1_count                          ;;At this funtion we count how many "1" does the representation in binary for the decimal value stored at "Info22"
;;-----------------
    ;;Now measurement of "1's" and bits for "xcor" of each agent in binary
    set Info22 (int(xcor * 1000))         ;;With 3 decimals of precision, so we multiplied "xcor" by 1,000.0,
                                          ;;truncate the result and now count the "1" on the binary rersentation of the number
    Bits_1_count
;;-----------------
    ;;Now measurement of "1's" and bits for "ycor" of each agent in binary
    set Info22 (int(ycor * 1000))         ;;With 3 decimals of precision, so we multiplied "ycor" by 1,000.0,
                                          ;;truncate the result and now count the "1's" on the binary rersentation of the number and it's total number of bits
    Bits_1_count
;;-----------------
    ;;Now measurement of "1's" and bits for the variable "hunger" of each agent
    set Info22 (int(hunger * 10000))      ;;With 4 decimals of precision, so we multiplied "hunger" by 10,000.0,
                                          ;;truncate the result and now count the "1" on the binary rersentation of the number and it's total number of bits
    Bits_1_count
;;-----------------
    ;;Now measurement of "1's" and bits for the variable "thirst" of each agent
    set Info22 (int(thirst * 10000))      ;;With 4 decimals of precision, so we multiplied "thirst" by 10,000.0,
                                          ;;truncate the result and now count the "1's" on the binary rersentation of the number and it's total number of bits
    Bits_1_count
;;-----------------
    ;;Now measurement of "1's" and bits for the variable "sleepness" of each agent
    set Info22 (int(sleepness * 2000))    ;;With 3~4 decimals of precision, so we multiplied "sleepness" by 2,000.0,
                                          ;;truncate the result and now count the "1's" on the binary rersentation of the number and it's total number of bits
                                          ;;this beacuse the smallest granularity of the variable is 0.0005, so 0.0005*2,000.0 = 1
    Bits_1_count
;;-----------------
    ;;Now measurement of "1's" and bits for the variable "interact" of each agent
    set Info22 (int(interact * 2000))     ;;With 3~4 decimals of precision, so we multiplied "interact" by 2,000.0,
                                          ;;truncate the result and now count the "1's" on the binary rersentation of the number and it's total number of bits
                                          ;;this beacuse the smallest granularity of the variable is 0.0005, so 0.0005*2,000.0 = 1
    Bits_1_count
;;-----------------
    ;;Now measurement of "1's" and bits for the variable "entertainment" of each agent
    set Info22 (int(entertainment * 1000)) ;;With 3 decimals of precision, so we multiplied "entertainment" by 1,000.0, (because the resolution of interes of this variable is at 0.003)
                                           ;;truncate the result and now count the "1's" on the binary rersentation of the number and it's total number of bits
    Bits_1_count
  ] ;;End of Ask agents / end of measurement on number of 1's on the binary reresentation of all variables of interes of the agents and it's total number of bits
  set ones_agents ones                     ;;Now we can re-use variable "ones" to measure the 1's for the patches binary representation
  set agents_bits total_bits               ;;The "total_bits" so far correspond to the total bits of the measurements from agents

  ;;
  ;;___________Now to proceed with the 1's and bits measurement on Patches_______________________________________________________________________
  ;;
  set ones (0 + (count hs))    ;;As the patches wich are houses equals the number of "hs" agents and the respresentation is of a 1 for each patch which is a house
                               ;;we will only count how many "hs" agent are and add this number of "1's" to the "ones" variable
  set ones (ones + (count patches with [food-available = true]))  ;;As the respresentation is of a 1 for each "food-available" patch we will only count them and add that number on varible "ones"
  set ones (ones + (count patches with [water-available = true])) ;;As the respresentation is of a 1 for each "water-available" patch we will only count them and add that number on varible "ones"
  set total_bits ( total_bits + (3 * (count patches) ) )          ;;The patches which do have and do not have a house, or are "food-available" and are "water-available" are represented with 1 bit each so we add 3 times the total number of patches to total_bits
  ask patches [
    ;;Measurement of "1's" and bits for "pxcor" of each patch
    set Info22 (pxcor)                ;;This cordinate is integer for patches cordinates, therefore the measurement is direct and is not multiplied
    Bits_1_count                      ;;At this funtion we count how many "1's" does the representation in binary for the decimal value stored at "Info22" and it's total number of bits
;;-----------------
    ;;Measurement of "1's" and bits for "pycor" of each patch
    set Info22 (pycor)                ;;This cordinate is integer for patches cordinates, therefore the measurement is direct and is not multiplied
    Bits_1_count                      ;;At this funtion we count how many "1" does the representation in binary for the decimal value stored at "Info22" and it's total number of bits
;;-----------------
    ;;Measurement of "1's" and bits for "house-num" of each patch
    set Info22 (house-num)            ;;The "house-num" is an integer variable, therefore the measurement is direct and is not multiplied
    Bits_1_count                      ;;At this funtion we count how many "1's" does the representation in binary for the decimal value stored at "Info22" and it's total number of bits
;;-----------------
    ;;Measurement of "1's" and bits for "food-amount" of each patch
    set Info22 (food-amount * 1000)   ;;With 3 decimals of precision, so we multiplied "food-amount" by 1,000.0,
    Bits_1_count                      ;;At this funtion we count how many "1's" does the representation in binary for the decimal value stored at "Info22" and it's total number of bits
;;-----------------
    ;;Measurement of "1's" and bits for "water-level" of each patch
    set Info22 (water-level * 1000)   ;;With 3 decimals of precision, so we multiplied "water-level" by 1,000.0,
    Bits_1_count                      ;;At this funtion we count how many "1" does the representation in binary for the decimal value stored at "Info22" and it's total number of bits
;;-----------------
    ;;Measurement of "1's" and bits for "F-neighbors" of each patch
    set Info22 (F-neighbors)          ;;The "F-neighbors" is an integer variable, therefore the measurement is direct and is not multiplied
    Bits_1_count                      ;;At this funtion we count how many "1´s" does the representation in binary for the decimal value stored at "Info22" and it's total number of bits
;;-----------------
    ;;Measurement of "1's" and bits for "W-neighbors" of each patch
    set Info22 (W-neighbors)          ;;The "W-neighbors" is an integer variable, therefore the measurement is direct and is not multiplied
    Bits_1_count                      ;;At this funtion we count how many "1" does the representation in binary for the decimal value stored at "Info22"
;;-----------------
  ];;End of Ask patches / end of measurement on number of 1's and bits on the binary reresentation of all patches

  set patches_bits ( total_bits - agents_bits ) ;;from the total of bits measured after the whole processe of measurement for the complite environment we subtract the bits for the agents and so the bits required for the patches are left
  set ones_patches ones                         ;;The number of ones measured on "ones" variable correspond to the ones on the binary representation of all the measured variables of the patches
  set ones (ones_agents + ones_patches)         ;;Adding ones_patches and ones_agents we can proced to calculate the Info of all the system

  ;;Measurement the Information represented on the enviroment (Agents + Patches) on the form: -ƩP(x)logP(x). for X=1 and X=0.
  set Info_Global  (-1 * (   (ones / total_bits) * (log (ones / total_bits) 2 )    +   ( (total_bits - ones) / total_bits) * (log ((total_bits - ones) / total_bits) 2 )   ))

  ;;Measurement the Information represented on the Agents on the form: -ƩP(x)logP(x). for X=1 and X=0.
  ifelse ( agents_bits > 0 ) [     ;;We take some preventive actions in case that there is no Adult agents left to measure their info to prevent error like log2(0) or log2(0/0)
     set Info_agents  (-1 * (   (ones_agents / agents_bits) * (log (ones_agents / agents_bits) 2 )    +   ( (agents_bits - ones_agents) / agents_bits) * (log ((agents_bits - ones_agents) / agents_bits) 2 )   ))
  ][
                         ;; before= set agents_bits  1
     set Info_agents  0  ;; before= set Info_agents  (-1 * (   (ones_agents / agents_bits) * (log (ones_agents / agents_bits) 2 )    +   ( (agents_bits - ones_agents) / agents_bits) * (log ((agents_bits - ones_agents) / agents_bits) 2 )   ))
  ]

  ;;Measurement the Information represented on the patches on the form: -ƩP(x)logP(x). for X=1 and X=0.
  set Info_patches (-1 * (   (ones_patches / patches_bits) * (log (ones_patches / patches_bits) 2 )    +   ( (patches_bits - ones_patches) / patches_bits) * (log ((patches_bits - ones_patches) / patches_bits) 2 )   ))
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to Bits_1_count                                              ;;Funtion to count how many "1's" does the representation in binary for the decimal value stored at "Info22" has and it's total number of bits
    if ( Info22 = 0 ) [ set total_bits ( total_bits + 1 ) ]  ;;If the value to measure is cero the minimal representation is with 1 bit, so 1 bit is added to the total number of bits measured so far
    while [Info22 > 0][                                      ;;With this "While" we will count the bits and how many of those are 1's for the binary representation of our variable
      set total_bits ( total_bits + 1 )
      if (Info22 mod 2) = 1 [
        set ones (ones + 1)
      ]
      set Info22 (int (Info22 / 2))
    ]
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to Complexity0 ;;On this funtion we will measure Emergence(E), Self-organization(S) and Complexity(C) for the form of the ecuations as E=Iout S=(1-Iout) C=4*E*S
               ;;On the "go" funtion this funtion will consider "I-in" = 1 from tick = 0.
  set Global_Emergence Info_Global
  set Agents_Emergence Info_agents
  set Patches_Emergence Info_patches
  set Global_Self_organization  (1 - Info_Global  )
  set Agents_Self_organization  (1 - Info_agents  )
  set Patches_Self_organization (1 - Info_patches )
  set Global_Complexity         (4 * Global_Emergence  *  Global_Self_organization  )
  set Agents_Complexity         (4 * Agents_Emergence  *  Agents_Self_organization  )
  set Patches_Complexity        (4 * Patches_Emergence *  Patches_Self_organization )
end
;; x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

to Complexity_2 ;;On this funtion we will measure Emergence(E), Self-organization(S) and Complexity(C), taken the last measurement of Info as "Iin" and the current as "Iout" for [ E=(Iout / Iin), S= (Iin - Iout), C=4*E*S ]
  set Global_Emergence_2          ( Info_Global  / Global_Emergence  )
  set Agents_Emergence_2          ( Info_agents  / Agents_Emergence  )
  set Patches_Emergence_2         ( Info_patches / Patches_Emergence )
  set Global_Self_organization_2  ( Global_Emergence  - Info_Global  )
  set Agents_Self_organization_2  ( Agents_Emergence  - Info_agents  )
  set Patches_Self_organization_2 ( Patches_Emergence - Info_patches )
  set Global_Complexity_2         (4 * Global_Emergence_2  *  Global_Self_organization_2  )
  set Agents_Complexity_2         (4 * Agents_Emergence_2  *  Agents_Self_organization_2  )
  set Patches_Complexity_2        (4 * Patches_Emergence_2 *  Patches_Self_organization_2 )
end
;; Autor: Daniel Flores Araiza x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-xx-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
;;
;;
@#$#@#$#@
GRAPHICS-WINDOW
7
315
294
603
-1
-1
5.471
1
10
1
1
1
0
1
1
1
0
50
0
50
0
0
1
ticks
30.0

BUTTON
6
280
61
313
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
115
280
170
313
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
10
291
43
Population
Population
0
1000
100.0
1
1
NIL
HORIZONTAL

BUTTON
61
280
116
313
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
146
291
179
water%
water%
0
100
10.0
0.05
1
%
HORIZONTAL

PLOT
295
158
764
320
Hunger A1
ticks
hunger level
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "ifelse ((turtle 0) != nobody)[plot [hunger] of turtle 0][plot 0]"
"pen-1" 1.0 0 -13345367 true "" "plot 25"
"pen-2" 1.0 0 -2674135 true "" "plot 31"
"pen-3" 1.0 0 -7500403 true "" "ifelse (any? Adults) [plot ((sum [hunger] of adults) / (count adults)) ][plot 0]"
"pen-4" 1.0 0 -13345367 true "" "ifelse (any? Adults) [plot (min [hunger] of adults)][plot 0]"
"pen-5" 1.0 0 -2674135 true "" "ifelse (any? Adults) [plot (max [hunger] of adults)][plot 0]"
"pen-6" 1.0 0 -955883 true "" "plot (h-t / 2)"

PLOT
295
10
764
161
Thirst
Ticks
Thirts level
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "ifelse ((turtle 0) != nobody) [plot [thirst] of turtle 0][plot 0]"
"pen-1" 1.0 0 -13345367 true "" "plot 15"
"pen-2" 1.0 0 -2674135 true "" "plot 19"
"pen-3" 1.0 0 -7500403 true "" "ifelse (any? Adults) [plot ((sum [thirst] of adults) / (count adults)) ][plot 0]"
"pen-4" 1.0 0 -2674135 true "" "ifelse (any? Adults) [plot (max [thirst] of adults)][plot 0]"
"pen-5" 1.0 0 -13345367 true "" "ifelse (any? Adults) [plot (min [thirst] of adults)][plot 0]"
"pen-6" 1.0 0 -955883 true "" "plot (t-t / 2)"

PLOT
295
319
764
454
Sleepness
Ticks
Sleepness level
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "ifelse ((turtle 0) != nobody) [plot [sleepness] of turtle 0][plot 0]"
"pen-1" 1.0 0 -7500403 true "" "ifelse (any? Adults) [plot ((sum [sleepness] of turtles) / (count adults))][plot 0]"
"pen-2" 1.0 0 -2674135 true "" "ifelse (any? Adults) [plot (max [sleepness] of adults)][plot 0]"
"pen-3" 1.0 0 -13345367 true "" "ifelse (any? Adults) [plot (min [sleepness] of adults)][plot 0]"
"pen-4" 1.0 0 -13345367 true "" "plot s-t"
"pen-5" 1.0 0 -5298144 true "" "plot s-li"

PLOT
764
10
1262
203
Food & Water on Patches
Patches
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Fo." 1.0 0 -10899396 true "" "plot count patches with [food-available = true]"
"Wa." 1.0 0 -13345367 true "" "plot count patches with [water-available = true]"

MONITOR
1201
441
1262
486
Population
count adults
2
1
11

MONITOR
802
203
874
248
Food points
count patches with [food-available = true]
17
1
11

MONITOR
945
203
1017
248
water points
count patches with [water-available]
17
1
11

PLOT
295
454
764
590
Interactions
ticks
Need to interact
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot i-li"
"pen-1" 1.0 0 -7500403 true "" "ifelse (any? Adults) [plot ((sum [interact] of adults) / (count adults))][plot 0]"
"pen-2" 1.0 0 -13345367 true "" "plot i-t"
"pen-3" 1.0 0 -13345367 true "" "ifelse (any? Adults) [plot (min ([interact] of adults))][plot 0]"
"pen-4" 1.0 0 -16777216 true "" "ifelse ((turtle 0) != nobody)[plot [interact] of turtle 0][plot 0]"
"pen-5" 1.0 0 -2674135 true "" "ifelse (any? Adults) [plot (max ([interact] of adults))][plot 0]"

PLOT
295
590
764
726
Entertaiment
Ticks
Fun? Entertaiment?
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot e-li"
"pen-1" 1.0 0 -7500403 true "" "ifelse (any? Adults)[ plot ((sum [entertainment] of adults) / (count adults) ) ][plot 0]"
"pen-2" 1.0 0 -13345367 true "" "plot e-t"
"pen-3" 1.0 0 -13345367 true "" "ifelse (any? Adults)[ plot min ([entertainment] of adults ) ][plot 0]"
"pen-4" 1.0 0 -16777216 true "" "ifelse ((turtle 0) != nobody )[ plot [entertainment] of (turtle 0) ][plot 0]"
"pen-5" 1.0 0 -2674135 true "" "ifelse (any? Adults)[ plot max ([entertainment] of adults ) ][plot 0]"

SLIDER
5
47
291
80
food%
food%
0
100
10.0
0.1
1
%
HORIZONTAL

SLIDER
5
210
291
243
water_metabolism
water_metabolism
0
0.1
0.01
0.0001
1
NIL
HORIZONTAL

SLIDER
5
111
291
144
food_metabolism
food_metabolism
0
0.1
0.01
0.0001
1
NIL
HORIZONTAL

MONITOR
873
203
945
248
Food%
(count patches with [food-available = true]) * 100 /(count patches)
2
1
11

MONITOR
1017
203
1089
248
water%
(count patches with [water-available = true]) * 100 /(count patches)
2
1
11

SLIDER
5
245
291
278
sleep_metabolism
sleep_metabolism
0
0.05
0.005
0.0005
1
NIL
HORIZONTAL

SLIDER
5
179
291
212
water_spawning
water_spawning
0
0.1
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
5
80
291
113
food_spawning
food_spawning
0
0.1
0.01
0.001
1
NIL
HORIZONTAL

MONITOR
1782
99
1872
144
Global_Info
Info_Global
10
1
11

MONITOR
1782
10
1872
55
Agents_Info
Info_agents
10
1
11

MONITOR
1782
55
1872
100
Patches_Info
Info_patches
10
1
11

MONITOR
1049
446
1138
491
Ones_Patches
ones_patches
10
1
11

MONITOR
964
446
1049
491
Agents_Ones
ones_agents
10
1
11

MONITOR
879
446
965
491
Ones
ones
10
1
11

MONITOR
878
491
965
536
Global_Bits
total_bits
10
1
11

MONITOR
964
491
1049
536
Agents_bits
agents_bits
10
1
11

MONITOR
1049
491
1138
536
Patches_bits
patches_bits
10
1
11

PLOT
1262
10
1782
203
Global_Info
ticks
Global_Info
0.0
1.0
0.99
1.0
true
true
"" ""
PENS
"Agents" 1.0 0 -13791810 true "" "plot Info_agents"
"Patces" 1.0 0 -2674135 true "" "plot Info_patches"
"Global" 1.0 0 -16777216 true "" "plot Info_Global"

PLOT
1262
203
1781
396
Complexity_simplified
NIL
Complexity
0.0
10.0
0.0
0.001
true
true
"" ""
PENS
"Agents" 1.0 2 -13791810 true "" "plot Agents_Complexity"
"Patches" 1.0 2 -2674135 true "" "plot Patches_Complexity"
"Global" 1.0 0 -16777216 true "" "plot Global_Complexity"

PLOT
1262
579
1781
770
Complexity_2
ticks
Complexity_2
0.0
10.0
0.0
1.0E-4
true
true
"" ""
PENS
"Global" 1.0 0 -16777216 true "" "plot Global_Complexity_2"
"Agents" 1.0 0 -14454117 true "" "plot Agents_Complexity_2"
"Patches" 1.0 0 -5298144 true "" "plot Patches_Complexity_2"

MONITOR
1781
579
1891
624
G_Complexity_2
Global_Complexity_2
8
1
11

PLOT
1262
394
1781
580
Population
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Popula." 1.0 0 -16777216 true "" "plot count Adults"

MONITOR
1781
293
1891
338
Global_Complexity
Global_Complexity
10
1
11

MONITOR
1781
203
1891
248
Agents_Complexity
Agents_Complexity
10
1
11

MONITOR
1781
248
1891
293
Patches_Complexity
Patches_Complexity
10
1
11

MONITOR
802
468
879
513
P(x=1) - %
100 * (ones / total_bits )
5
1
11

MONITOR
1019
535
1138
580
%_Bits_on_Agents
100 * (agents_bits / total_bits)
5
1
11

MONITOR
1138
535
1262
580
%_Bits_on_Patches
100 * (patches_bits / total_bits)
5
1
11

PLOT
764
579
1262
770
Bits on %
NIL
NIL
0.0
10.0
0.0
0.1
true
true
"" ""
PENS
"of Agents" 1.0 0 -13345367 true "" "plot (100 * (agents_bits / total_bits))"
"of Pacthes" 1.0 0 -5298144 true "" "plot (100 * (patches_bits / total_bits))"

PLOT
764
248
1262
441
[food-amount] of patches
NIL
NIL
0.0
0.01
0.0
0.01
true
true
"" ""
PENS
" 0 0" 1.0 0 -16777216 true "" "plot [food-amount] of patch 0 0"
" 0 1" 1.0 0 -13345367 true "" "plot [food-amount] of patch 0 1"
"1 0" 1.0 0 -2674135 true "" "plot [food-amount] of patch 1 0"
"1 1" 1.0 0 -13840069 true "" "plot [food-amount] of patch 1 1"
"pen-4" 1.0 0 -7500403 true "" "plot 50"

TEXTBOX
117
610
267
638
Torus 51x51
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

The model tries to represent the general behavior of living beings with needs on an environment with static resources.
The idea is to represent the elementary needs of humans whithout their sofistication, like the critical need for Food and Water but also the needs to sleep, and interact with other humans or get some entertainment, so the way the agents on the simulation act is moving randomly, whitout inteligents or memory and based upon the necesity to satisfy some need. 
This while a proposal for the measuremnt of complexity based on the information available on agents and patches is taken.
All this to observe: The complexity measurements are high or low?
                     How do the measurement change when the paraments change?
                     Which is the range for the Complexity measured after have changed the value of the available variables to set?

This will be compared with another models where the resources changen dinamically based of the behavior of the "game of Life" and other simulations where the agents can see their neighboring patches and decide where to move based on a NN.

The proposition for these series of observations is to answer:
	Enviroments whit agents capable of some learning encrease their complexity, rigth?
The way we measure the complexity is useful? or valid?
Differences on the enviroment, how do they affect the measuremt of complexity been propoused here?


## HOW IT WORKS

This model presents an enviroment with resources on the patches, Water and Food, which spawns from some of them.
The agents will have to look for the resources randomly (the patches with water and food) and collect them because at each tick the agents consumes a little of their internal variables which represents needs, as a living being needs to drink water or colect food; they can have their belly's full of food and water and also the agents on this simulation have a limit to how much resources can have, then there is a point when living beings feel hungry or thirst and so the agents on simulation have a "threshold" for their variables to indicate the to look for the resources needed, and for the case of Food and Water there is a point if too much time (ticks) passes and the needs are not satisfied the agent dies.
Also the need for sleep, interactions and entertainment are emulated in a simplified way and these other needs does not kill the agents at any point.

So there are several features to play with as to observe the behavior that develops from the simulation, the metabolism of the agents for some needs, the rate at which the resources spawn from the patches, the % of Patches with water or food and the initial population of agents on the simulation.

## HOW TO USE IT

The first time try running the simulation as it is until the 20,000 ticks and see what happens.
It is highly recommended to do not update the map all the time, just when there is an interest on the behavior of the agents with more detail, like for the times when the agents look for each other to interact or entertainment, also if it is of your interes to see how they move randomly looking for resourses (spoiler alert: they can avoid patches with resouces pretty well, lol ).

You can play changing any of the values of the sliders in the simulation and see the resulting behavior, also you can change the size of the world, but the code was though on the ability of the environment to wrap all the time.


## THINGS TO NOTICE

Note: Usually interesting changes on the graphs can take a few thousands of ticks.

The needs for Interaction and Entertainment are satisfied a little bit when the agents are on the same patch with other/s agents so some interactions are to be expected between the agents, and actually some grouping of the agents appear ocassionally but no cooperation appears at any point so and aditional mechanism is to be expected to triger cooperative behaviors.

## THINGS TO TRY

Try different % of patches with Food or Water it can be seen how the population with enough resources moves randomly and ussually keep still, even the grouping of the agents appear a little more while when there is not enough resorces all variables behave different on the graphs and a good % of the population can die until the final behavior stabilices.
When changing the "metabolism" of the agents for water or food the resoulting behavior can accelerate or decelerate.
For the measurement of the complexity it can be seen curious behaviors when the size of the world is change to be too small (like 2x2 patches) or too big, also when the population is big or too little.

## EXTENDING THE MODEL

It is suggested to implement the measurements of the World-binary-measure, Bits_1_count, Complexity0 on other models to observe and compare the resulting graphs and measures.

## NETLOGO FEATURES

The calculous of the Inforation of the agents on World-binary-measure can present an error due to Log of 0, example:
"(log ((agents_bits - ones_agents) / agents_bits) 2 ) "
When there is no agents agents_bits = 0 and ones_agents = 0, so be carefull


## RELATED MODELS

Sheep Wolf models were an inspiration to this model

## CREDITS AND REFERENCES

Github link coming soon
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="20190408_2100_SimpleW_sin_repro" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="25000"/>
    <metric>(count Adults)</metric>
    <metric>(count patches with [water-available])</metric>
    <metric>(100 * (count patches with [water-available = true])/(count patches))</metric>
    <metric>(count patches with [food-available = true])</metric>
    <metric>(100 * (count patches with [food-available = true])/(count patches))</metric>
    <metric>(max [thirst] of adults)</metric>
    <metric>(min [thirst] of adults)</metric>
    <metric>((sum [thirst] of adults)/(count adults))</metric>
    <metric>(max [hunger] of adults)</metric>
    <metric>(min [hunger] of adults)</metric>
    <metric>((sum [hunger] of adults)/(count adults))</metric>
    <metric>(max [sleepness] of adults)</metric>
    <metric>(min [sleepness] of adults)</metric>
    <metric>((sum [sleepness] of turtles)/(count adults))</metric>
    <metric>(max ([interact] of adults))</metric>
    <metric>(min ([interact] of adults))</metric>
    <metric>((sum [interact] of adults)/(count adults))</metric>
    <metric>(max ([entertainment] of adults))</metric>
    <metric>(min ([entertainment] of adults))</metric>
    <metric>((sum [entertainment] of adults)/(count adults))</metric>
    <metric>Info_Global</metric>
    <metric>Info_agents</metric>
    <metric>Info_patches</metric>
    <metric>ones</metric>
    <metric>ones_agents</metric>
    <metric>ones_patches</metric>
    <metric>total_bits</metric>
    <metric>agents_bits</metric>
    <metric>patches_bits</metric>
    <metric>(100 * (agents_bits / total_bits))</metric>
    <metric>(100 * (patches_bits / total_bits))</metric>
    <metric>(100 * (ones / total_bits))</metric>
    <metric>Global_Complexity</metric>
    <metric>Agents_Complexity</metric>
    <metric>Patches_Complexity</metric>
    <metric>Global_Complexity_2</metric>
    <metric>Agents_Complexity_2</metric>
    <metric>Patches_Complexity_2</metric>
    <enumeratedValueSet variable="Population">
      <value value="2"/>
      <value value="10"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food%">
      <value value="0"/>
      <value value="4"/>
      <value value="16"/>
      <value value="48"/>
      <value value="64"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="water%">
      <value value="0"/>
      <value value="4"/>
      <value value="16"/>
      <value value="48"/>
      <value value="64"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="water_spawning">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food_spawning">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food_metabolism">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="water_metabolism">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sleep_metabolism">
      <value value="0.005"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="20190409_2130_SimpleW_sin_repro" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="20000"/>
    <metric>(count Adults)</metric>
    <metric>(count patches with [water-available])</metric>
    <metric>(100 * (count patches with [water-available = true])/(count patches))</metric>
    <metric>(count patches with [food-available = true])</metric>
    <metric>(100 * (count patches with [food-available = true])/(count patches))</metric>
    <metric>(max [thirst] of adults)</metric>
    <metric>(min [thirst] of adults)</metric>
    <metric>((sum [thirst] of adults)/(count adults))</metric>
    <metric>(max [hunger] of adults)</metric>
    <metric>(min [hunger] of adults)</metric>
    <metric>((sum [hunger] of adults)/(count adults))</metric>
    <metric>(max [sleepness] of adults)</metric>
    <metric>(min [sleepness] of adults)</metric>
    <metric>((sum [sleepness] of turtles)/(count adults))</metric>
    <metric>(max ([interact] of adults))</metric>
    <metric>(min ([interact] of adults))</metric>
    <metric>((sum [interact] of adults)/(count adults))</metric>
    <metric>(max ([entertainment] of adults))</metric>
    <metric>(min ([entertainment] of adults))</metric>
    <metric>((sum [entertainment] of adults)/(count adults))</metric>
    <metric>Info_Global</metric>
    <metric>Info_agents</metric>
    <metric>Info_patches</metric>
    <metric>ones</metric>
    <metric>ones_agents</metric>
    <metric>ones_patches</metric>
    <metric>total_bits</metric>
    <metric>agents_bits</metric>
    <metric>patches_bits</metric>
    <metric>(100 * (agents_bits / total_bits))</metric>
    <metric>(100 * (patches_bits / total_bits))</metric>
    <metric>(100 * (ones / total_bits))</metric>
    <metric>Global_Complexity</metric>
    <metric>Agents_Complexity</metric>
    <metric>Patches_Complexity</metric>
    <metric>Global_Complexity_2</metric>
    <metric>Agents_Complexity_2</metric>
    <metric>Patches_Complexity_2</metric>
    <enumeratedValueSet variable="Population">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food%">
      <value value="0"/>
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="water%">
      <value value="0"/>
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="water_spawning">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food_spawning">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food_metabolism">
      <value value="0.01"/>
    </enumeratedValueSet>
    <steppedValueSet variable="water_metabolism" first="0.005" step="0.01" last="0.035"/>
    <steppedValueSet variable="sleep_metabolism" first="0.005" step="0.01" last="0.035"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
