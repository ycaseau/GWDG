

                +--------------------------------------+
                | GWDG Project log file v0.            |
                +--------------------------------------+



// 20/7/2009 ------------------ v0.1 --------------------------------------
start day - goal is to run v0.1 within 2 weeks
first step is to define model.cl

22/07/09: better vision of inventory management
1&2/08/02:  code the whole thing in 1 week-end !

4/08/02: change the solve model -> intersect of Qpod and Qneed

TODO:  - run once
       - play with parameters -> make scenarios
       - update the PPT document
       - meet with e-Lab
       - write an "impertinent" paper (cf. Google doc)
       - add PNB/habitant as an output

// 11/3/2022 ------------------ v0.2 --------------------------------------

We restart after 13 years !  with a new claire (CLAIRE4) and a new ambition (web game server)
v0.2 goal is to get a clean first game (even dumb)
v0.3 introduce true GTES: bloc goals/strategy + impact of CO2
v0.4 will be to parameterize as much as possible (separate GTES from GWmodels) and add more players

// 2/4/2022
Fix the M4 model -> consumes(...)
- add w.maxout = max PNB with cheap energy
- notice that we should have two histograms ! cancelE = f(price) and cancelV = f(price)
  right now we assume that we have the same profile ....
- noticed that the saving/investment ratchet "clicquets" is already here
   -> once the saving is decided we go for it and we keep it

// 9/4/2022
fixed M1 model
- capacity max moves slower (constrained in growth + monotonous)
- two steps= capacityMax x Price elasticity (simpler = f(p/pN-1))
fixed the inventories with proper data
- play with the trajectories
  (1) tune go(10) and compare with real numbers

// 16/4/2022
  get rid of threshold ! use a sensibility = delta(price) / delta(production)
  AHA : our energy price model is not robust
    - make sure that we can mimick lots of inventory growth with slow price increase 
      currently it is dominated by the capacity 

// 18/4/2022
  - reintroduced 3 years average for maxCapacity
  - warning : minCapacity creates strange amplification (dump oil -> price drop -> price goes up)
  - We have a problem with Coal : we want to force a flat consumption ! 
    This does not work with the "solve model":
        (a) the demand curve does not show much elasticity
        (b) fixed quantity, lower than possible demand, but price will not go up (desirability is not great)
  => to fix this we do two things
      (a)  s.cancelFactor is a multipler for cancellation
      (b)  We introduce oilEquivalent(p:Price) to account for the price difference between energy sources

  OCCAM: get rid of min (creates stupid price dumps) 
  Current bug: substitution quicks in and create a capacity problem => substitution should upgrade max capacity !

// 13/5/2022 : restart - claire4 -m gw2
// renamed interface.cl to game.cl -> model of the game that we want to play
// our goal with gw2 is to get a simple, robust and fast game (50 years simulation in 10ms)

model.cl  addedCapacity : sum of all substitution
game.cl : substitution must modify capacityMax -> take into account x.gone and s.added

// 14/5/2022 : the output model cannot be relative + we need to check that production of clean makes sense,
// that is : grows when price grow and
- max capacity follows a better equation : linked to inventory and growth is a function of demand
- note that the actual maxCapacity is monotonous (and triggers and investiment)
good news:  simulation work on 10 to 50 years

// 22/5/2022: resume and fix bugs
(a) the three accessors getCancel, getSavings and getMatrix (substitution) must be used consistently
    that is, no direct use
(b) actual savings are monotonic (investments are made), same for substitution
(c) substitution is applied after cancelation and savings (which are independent)
(d) hist(c) montre : need, cancel, saves and consos

// 26/5 Ascension week-end
- new max capacity model
   (1) we keep 3-year average price but we could introduce weightedAveragePrice  (pn = 1/5 p + 4/5 pn-1) 
       to reflect the past price to evaluate inventory
   (2) maxCapTarget is the min
        - of (new Inventory - gone)   -> use the weightedPrice
        - desired capacity = needs(y - 1)
   (3) we move slowly toward the target to avoid oscillation (try 1/4 - 3/4 : to be tuned)  

- new carbon tax management
   -> carbon-tax introduced a shift in the "energy need curve" (cf game.cl / getNeed)
   -> carbon tax produces money which is used to offset transition costs and saving costs (stores in e.carbonTaxes)
   -> the balance (if any) is currently lost

DECISION: rename maxCapacity into Capacity
  - this is the capacity to produce, it can go down when the inventory goes down

// 28/5 - need(p:price) model fix !
- only the cancelation is dynamic = f(price)
- savings = f(c.savings[y -1]) fixed (reduces need)
- substitution = transfer ! game.cl : getSubstitutionFrom & getSubstitutionTo + read y-1 values

// 29/5 - carbon Tax
- carbon tax shifts the demand (acts on price -> raise cancel and savings)
- we separate sellPrice that is obtained by solve (post shift) and truePrice (with carbon tax) that triggers cancel, savings, substitution
- the production model is 80% the stupid linear curve and 20% an asymptotic curve that says that a better price yield more
- TODO: the tax money should pay for the energy investments

// 2/6 play with the taxes and see what happens

compiler fixes
(1) add CLAIRE4_HOME : variable environment
(2) src(compiler) should be home()/src
 
closed with success on June 6th
- gw2 works
- when compiled, 20 ms for go(40)

// =============================== GW3 ==========================================
NOTES:
- transition energetique et redirection écologique !
   - il y a beaucoup d'énergie / la seule question est de changer de vecteur (résoudre le probleme du stockage et/ou smart grid)
   - le modèle du GIEC est sur sur le warming, probable sur les catastrophe mais ne prédit pas les réactions (redirection)
   - le problème des politiques publiques est avant tout un problème d'équité et répartition (intra et inter pays)
   - le probleme est accentué par l importance du digtal (accélérateur inégalité / réduit viscosité)
   
META PLAN
(1) run without CO2 tax and get credible GIEC like
(2) add CO2 tax and see the impact on the economy (compare to Nordhaus)
(3) compile gw2 and test performance (one simulation should be a few ms)
(4) move to v0.3
   - add  M5 (modèle de redirection)
   - add natural gas (separated from Oil)
   - add goals for players

// ----------------------------- v0.3 --------------------------------------------


+----------------------------------------------------------+
|     M5 (ecological redirection : reaction of society)    |
+----------------------------------------------------------+

   (a) Political reactions to CO2/unrest
   ---------------------------------------
       - CO2 tax  (reinforcement of planned CO2 tax that represents global agreements)
       - note:  energy quotas (force substitution other than tax) is left aside for version 3
       - renoncement (combines gving up usages & crisis)
         it is unclear yet how the possible wars over natural resources are best represented
       - note : boycott (against other blocks) is left aside (and captured by renounce at the worldwide level)
       - note : in version 4, when we have a block economy, we could represent the effects of social unrest
         Options to investigate: add a random variation on energy price that is a function of conso tension and political tension 

   (b) stress comes from 3 signals 
   -------------------------------
       - CO2 -> disasters (non-linear) -> give up (redirection) + economical impact of disasters
           disaster: canicules, flood, fires, agriculture
       - unhappy (deltaPNB) -> poorest part of population strugles -> creates stress
       - unhappy (cancel) -> same -> ... this is mitigated by social policies (redistribution)
       

   (c) we could introduce two solidarities model factor
   ----------------------------------------------------
       - global (inter-country) that reduces the impact of disaster   => model for version 4
       - local (intra-country) that reduces the impact of unhappy  => redistribution factor in version 3

// July 5th: we start !
- model.cl : adds co2Kwh : a ration (carbonation of energy) used with Shapes
- test1.cl :
   - Oil, Gas are separated + co2Factor is fixed
     Natural Gas is more abundant than we think, but the geopolitical aspect is big

// restart on July 14th
- test1.cl : 
   - check the repartition of energy consumption in the four bloc: US, Europe and China from RoW (rest of world)
   - substitution has 6 slots:
      Coal to Oil, Coal to Gaz, Coal to Clean
      Oil to Gaz, Oil to Clean
      Gas to Clean
      substitution order (from dirty to clean) : Coal > oil > gaz > clean
   - OCCAM question : do we need 4 matrixes or 1 matrix ? 
     Matrix = Transition énergétique -> différent par bloc ... but we can start with 1 Matrix called EnergyTransition

// July 15-17th
Model M5 (see below)
- model.cl : adds 
    Consumer:
       - redistribution: 
       - taxFromPain and cancelFromPain : two coefficients (for M5: transform pain into action)
       - taxAcceleration and cancelAcceleration : two dynamic variables that stores the two actions
       - painLevels[y]  : record the pain level
    Earth: 3 step functions painClimate, painGrowth (inverse of growth), pain of cancellation
       - crisisFromPain:  economic inneficiency -> reduce output when pain gets too large
- game.cl  : code for M5 
     - compute pain
     - react : pain -> tax, pain -> cancel
     - add the effect of the new factors

// July 24th
- load works + pain(EU) works to

// closed for August & September  
TODO: tuning protocol
 - check PNB
 - check Energy consumtion
 - check Energy savings & cancel
 - check Energy substitution
 - check PNB and investments
 - check CO2 a CO2 tax
 - check the model of total CO2 production (should be 40 Gt) = from energy + other human activity



// TODO (2022 goals)
(c) retune to see that the trajectories are realistic
(c) add a realistic reaction from Europe
(d) reproduce Nordhaus results and look for GDP impact of (a) CO2 pains (b) Energy Transition Investment
     Idea: add a crisisFromPain coefficient at World level that translates pain into economic inneficiencies
         (strikes, protests, wars, etc.)
(e) reproduce Shape 4 scenarios
     - global solidarity : CO2 tax for all
     - local solidarity = redistribution

Simulate Shape 4 scenarios:
============================
warning: the SHAPE document is not clear about the when
(1) Citadel of Abundances:
    no global solidarity, +4.4C in 2100?, 220gC02/KWh, low interventionism (C02tax, cancel), 2.2% GDP growth
(2) Green above all:
    global solidarity, +1.7C, 170gC02/KWh, high interventionism (C02tax, quotas), 1.3% GDP growth
(3) Green tech divide:
    no global solidarity, +2.5C, 205gC02/KWh, medium interventionism (mostly C02tax), 3.3% GDP growth
(4) Legislative Marathon:
    a little bit of global solidarity, +2.9C, 195gC02/KWh, medium interventionism (mostly quotas), 2.9% GDP growth

TODO (on the search front)
- look for GIEC prevision impact of temperature on economy (fires, flood, agriculture, canicule)
- get the curve CO2 -> temperature rise

- introduce strategies
 (a) for blocks (will be more useful in v0.4 with more blocks)
 (b) for suppliers


TODO:
(a) search data about Natural Gas price evolution
(b) search the data to create the new blocks: US, EU, CN, RoW
    -> Mostly find about consumption (4 x 4)
(c) add the CO2/Wh metric in gw2 (easy) - to get a sense of what is feasible (and the current value)


// ================================= Possible ideas for GW4 =========================================

GW4 est le programme d'automne, une fois que GW3 fonctionne (Septembre ?) 
NOTE: ClaireServer est le programmes des vacances (Aout puis Décembre)

Le but de GW4 est d'introduire l approche GTES
==============================================
- create 4 economies (with the possibility to represent wars and fights)
    - key to differentiate the effect of investment on GDP growth
- stratégie player = goals (économie, pain)
- tactique = 
    (a) CO2 tax + reaction from pain (taxAcceleration, cancelAcceleration)
    (b) redistribution,
    (c) transition énergétique (inventer un framework pour customiser le vecteur de départ)
      => transition énergétique est nourrie par CO2 tax, mais nous pourrions ajouter des investissements nationaux
      => transition énergétique est également savings
- IDEA for GW5 : introduce strategies for supplier (requires keeping economic record ... the goal is to maximize LT profits)
     would allow to simulate scarcity management

// a copier dans un Google Doc "Affaires à prendre en vacances"

Ski (toujours trop de choses)
- gants, casque, lunette soleil et masque, tour de cou
- fuseau, deux paires de chaussette de ski
- deux Tshirt cotons, un ou deux polos de sport à manche longue, une polaire
- 3 slips, 3 chaussettes, 1 set Pyjama
- 1 jean, deux polos, un pull, une écharpe
- un bonnet, une paire de gants fins
