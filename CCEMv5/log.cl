

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
       - transitionFactor : factor between 0 and 100% that represents how much is applied
               transitionFactors:list<Percent>,    // record the level of transition for eah year
               transitionStart:Percent = 100%,      // minlevel of Energy transition
               transitionAcceleration:Percent = 0%, // accelerate the transition to clean energy
    
       - painLevels[y]  : record the pain level
    Earth: 3 step functions painClimate, painGrowth (inverse of growth), pain of cancellation
       - crisisFromPain:  economic inneficiency -> reduce output when pain gets too large
- game.cl  : code for M5 
     - compute pain
     - react : pain -> tax, pain -> cancel
     - add the effect of the new factors

// July 24th
- load works + pain(EU) works to

// closed for August & September  & October 
TODO: tuning protocol
 - check PNB
 - check Energy consumtion
 - check Energy savings & cancel
 - check Energy substitution
 - check PNB and investments
 - check CO2 a CO2 tax
 - check the model of total CO2 production (should be 40 Gt) = from energy + other human activity
 - CHECK inventory for Oil & other fossiles

// November 2nd, 2022 : we reopen GW3 !

improved M4 and M4
- disasterLoss (%loss = f(temperature)) added to M4 (feedback from M5)
- showM1 to showM5 : useful to display the constants in test1.cl 

Cancel(c,s,p) is augmented with a new factor : difference between expected savings and current one
this ensures that cancel gets big enough as price grows

stopped with go(90)
two things
(a) why do we eat all the gas (production should be capped from reserves) ?
(b) to avoid model complexification, make sure that maxprice -> zero consumption

// November 11-13
- fixed M3 though the introduction of transition objects (code is much cleaner)
- hM*() to look at M1 to M5
- we need to reset the parameters to get a clean 2020 trajectory
    -> techfactor = 

CAGG for PNB = 2.5%   (2010-2020)  7% decade avant -> 4.5% en moy
CAGR for Energy = 1.1% decade avant 3.1% decade avant  -> 1.7% 
 
// November 19th
 (1) change the order ! we need Oil > Coal > Gas > Clean  because US went from Coal to Gas
 (2) introduce discountPrice and renamed readMatric to priceRelatedTransfer
 (3) the subtitution matrix is indexed by years and not price
 (4) add the capacity growth constraint to M3 in updateRate function
 (5) show the energy table (consumer x supplier) in 2010 and 20XX

 // November 26th : close GW3 for two month !  -------------------------
 (1) add two subclass of Supplier: finite / infinite
      finite -> same model as before (intentory + capacityMax + threshold)
      infinite (clean) -> "potentialGrowth" describes the max(Delta Capacity) = f(price)
 (3) tune M3 :
      - transfer quantity was too high (consos vs conso x ratio)
      - cummulative addition of transfer to max capacity !


 // February 2023 : restart ! ==========================================================================  

 // February 10th
 - fix Year(2) (ex: maxCapacity was wrong)
 - tune Oil
 - tune Coal : warning  => high cancelFactor to keep price low (then get rid of it !)
 - fixed the Transfer matrix in 2020 to reflect what was seen (0.25 CtoG US, 0.15 Coal to Clean)
 - simplify invest cost : + 1GToe -> + 11,6T$
 - Transfer matrix is a policy and is executed modulo capacity
 - getOutput is simpler for Clean -> price behavior is easier to understand ()

// February 18th
- big decision: c.cancel is a function of energy price, but c.saving is a decision based on years
  managed like energy transition
- removed effiencyFactor (covered by Savings) : too important to be captured by e^-lambda.T decay !
  but we keep techFactor that reduces the cost of savings/transition investment
- run go(10) successfully !
      - check PNB, energy consumption, transitions (Coal to GAS (US), Coal to clean)
      - check sM*() [check that test data are OK] and hM*() [output consistent with real]
     commit: upload(gw3,"go(10) completed") !

Next step is to tune go(40) which implies to play with scenario h* to see if the model is correct
    - check effect of energy availability on economy !  H1/H2  (inventory) + H7 (savings)
    - cone of Energy Transition
    - fixed the maxCapacity computation for clean : adapts to the netNeed
    - h5/h6 (cancel sensitivity) works: more cancel -> less PNB (but not a huge difference)
    - carbon tax
      h8: moderate  ->  works nicely : reduces coal consumption hence CO2 : 531 to 509  (small PNB loss 144 to 139)
      h9: serious -> works better : 531 to 479 but PNB at 117. (Irrealistic: RoW will actually use its coal)
    - add the pain !  SHOW5 -> check the value
    - add cancelImpact + how it is used to compute the "loss ratio"
        weighted sum (according to energy consumption) of Impact histogram and redistribution
        Note: this would be better with G4 (4 economies)

// Saturday February 26th

(a) run to 2100 -> it works !
    - extend / tune test1.cl
    - play with demography
    - tuned the 2100 GDP impact according to various sources (Schroders)

scenario summary
              GDP (T$)       CO2 (ppm)       Energy (GToe)              Temperature
    h0:       177            666             13.57   (peak at 17.7)
    h1:       167            611             12.42   (peak at 16)
    h2:       208            743             17   (peak at 22) 
    h3:       165            671             12.48 
    h4:       185            671             14.4
    h5:       180            670             13.7
    h6:       167            652             12.7
    h7:       161            683             12.7
    h8:       145            584             10.83                      16.3C
    h9:       92             476             6.5                        15.5C (max) // peak CO2 in 2070 at 498 ppm            

(b) add a reaction for Europe, based on pain (trace pain) = h10


// TODO MARCH (while writing documents = paper from PPT and blog post en français)

// 3-5 March extended weekend
-  get decent co2KWh numbers
-  set PMAX to 10000 and increase cancel to 100% at PMAX
-  created adjust(a:Affine) and h0s & h0t to see the effect of savings and transition

(1) reproduce Nordhaus 
    - create a scenario where there is enough energy to reach 3C increase (more oil and keep using coal)
    - play with C02 mitigation -> better to have 3.1C than a strong C02 tax and 2.8C
    - TODO: look at h11(100%) and see why we have oscillations

(2) reproduce Jancovici model to see how we can curb CO2 emmission significantly with CO2 tax and redirection
    - start with a heavy carbon tax
    - h12(100%) = 15.40C max  486 ppm (max)   94T$ GDP (max)  6.5GToe (max)
    note: it will be interesting to play with time-sensitive policies


(3) reproduce an Abundance scenario based on strong tech progress
    - h13(100%) = 15.80C max  528 ppm (max)   199T$ GDP (max)  16GToe (max) -> 10
      note: the tuning of savings should be looked over (actually optimistic)
      TODO: rework the pain from warming !
      This scneario is similar to H0 until 2050 then technology takes over :) 


(4) reproduce Shape 4 scenarios
     - citadels of abundance -> impossible without a lot of Oil !
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
  Talk to AXA Climate ...
- get the curve CO2 -> temperature rise

// ------------------------------- start GW4 on May 5th ---------------------------------------------

model.cl changes
- Block : subclass of economy that is associated with a Consumer

list of changes 
- economy (M4) split into blocks (simul.cl)

Key design decision GW4 does not extend the feedback, it simply adds tactic to player

KISS:
- redistribution is left out to GW5 (too hard to model)

// resume on June 10th ! (May was lost)
// new goal is to finish code in June and play in July  
Note : pnb becomes gdp
- model.cl 
     - add pb.trade
     - add block.open  (% = 100 by default)
     - Economy = WorkEconomy + N Blocks
- test1.cl : created 4 b:blocks (economies of 4 players)
- simul.cl : 
       - init economies
       - create balanceOfTrade
- game.cl: 
    (a) M2 : use the economy of the zone to compute the energy need
    (b) replace pb.economy by block.economy
    (c) compute each economy 
    (d) consolidate into the World economy

// Note: we DO NOT geolocalize energy production, so energy investments are distributed equally
// Iron model (new in GW4)
(1) In M4,  ironConsumption is deduced from GDP x intensity (called ironDriver)
    Note: one unique cancel belief that represents consumption drop when price rises 
    (KISS : one price)
(2) ironDriver is a belief : Affine (GDP/steef of us, variation in time) per block
(3) compute steelPrice from energy_price x intensification (another belief, WW)
(4) Add an accelerating factor to the energy invest, based on steelPrice 

// June 18th: add Agro model (new in GW4)
(1) wheatOutput = f(Land * Efficiency)
(2) Land = (origin - newEnergy * landImpact) * w.lossLandWarming
(3) Efficiency = energyEfficiency * biosystem Health

// june 24th : 
- add the mood feedback (pain) from agriculture => no ! covered by pain_warming
  however, it should be a way to calibrate this pain
- add the impact of steel price on energy investment
  game.cl : steelFactor(s:Supplier,y:Year)

Note: energy investments are related to suppliers

// July 15th
- investment is better calibrated as share of GDP 
     (a) variation is not correlated with growth
     (b) the ratio is reasonably stable
- EU is 20%, US 20%, China 40% (dirigist economy)
- RoW at 25% (India 28%, Brazil 20%, Russia 24%, Niger 27% in 2021 .. lots of variation)
/!\ Europe in euro grows nicely but not in dollars ...

// July 16th
- need to take the demograhic growth into account for results !
    GROWTH = invest growth + demographic growth
- tuning of b.RoI done, good 2020 forecast

// GWGD v4 restarts on August 27th --------------------------------------

// todo
- go(10), go(40), go(90)  -> check the results
    - tune cancel (see notebook) -> to get a good 2040 forecast
    - check steel production/price + agro
    - show the four economies (new code in simul.cl)
    - we need to decide what to do with Europe (no growth = effect of dollr/euro parity)

// resume on September 3rd

Note: we start without a steel feedback loop, but clearly if steel is 10 times more expensive it 
will impact the economy (especially China)
    -> we could add a steel feedback loop (steel price -> cancelation)
 
// September 9th
we need to fix China energy consumption 
  => beware of coal ->70% for energy, 30% for industry
  => in our model, we take all usages into account (energy + industry)
  => hence our figure for China in 2010 is higher 
     (total 3.24  with coal for industry vs 2.5 energy use) ) 

// h22() : we get wrong values for Coal (price goes up too far)
-> I NEED TO WRITE THE EQUATIONS FOR ALL MODELS !
here the problem is the maxCapacity model that moved too slow
added a s.horizonFactor (was already here for Clean) : ratio of net demand that we would like to cover

-> OK, we can now play with cancel and reduce investment accordingly.

We now consider that the invest ratio is influenced by cancellation. When energy price rise, 
a fraction of the activity stops, but the for the rest, the margin goes down (same gdp, less profit)

  - M4 equation (we need to write it formally)
       x2 := x1 * populationGrowth(b,y) + iv * b.roI,                   // economy factor: loss of energy -> cancellation
       b.results[y] := x2 * (1.0 - b.lossRatios[y]) * (1 - e.lossRatios[y]),

  - M2 equation was wrong (using last year s need => introduced newMaxout)

Also : 
  (1) we keep the world "tech factor" that represents continuous efficiency improvement, which is
      different from savings that require to invest (insulation for instance). Reduced to 0.5% per year
      which represent 5% per decade.

  (2) Europe and China results 2010 -> 2020 are hard to model but OK to get a better value for Europe

// September 11th : stop with h00+h22 (no constraints) -> stable energy density

// Septembre 16th: calibrate M4 with margin impact on go(40) and go(90)
we fixed the investment formula in M4 => URGENTLY NEED TO DO THE EQUATION THING !!

// September 17th: check energy balance ... we need to
(1) make sure that production = consumption
(2) ensure that need = consimption + savings + cancelation
code is now:
     - solve(p,s),                             // M2: find the approximate equilibrium price
     - energyBalance(s,y),                     // M2: sets consos and prod for perfect balance
     - for c in Consumer record(c,s,y),        // M3: record the need of c for energy s
     - recordCapacity(s,y)),

AND IT WORKS (go(40) and go(100)) !!!!
Note: needed to tune the excel energy matrix => reset input.cl (% of primary)

// September 23rd: 
  - fixed AgroOutput with a stable equation (compute from t0) with an iterative/cummulative 
    formula for EnergyLand (from clean energy growth)

// following the CCEM tuning protocol: go(10), go(40), go(90), ... and go(190)
(1) GDP  -> gTable  OK(10)   
    go(40)  -> should we add an energyBoost term to b.RoI ?
(2) consumption / density (GDP to GToe)  -> dTable  OK(10)
(3) distribution between primary source -> eTable
    - Gas maxGrowth is raised to factor US Coal to Gas
      /!\ we need to account for all the transfer + savings
    - too much Clean in the US : fixed

(4) energy price  -> key for cancellation (with go(40) and go(90))
    - look at each energy - question the sensitivity
(5) investment (ratio + Ie/Ig balance) - OK(40) ? 
(6) co2 tax

// 27: breakthrough (GW4 prime) --------- 
seperate
(a) dans M2, need = f(gdp) x density x pop : introduce density as a belief
(b) remove ftech and merge with savings
AND, (c) make ROI time dependant, so that we can fix things :)
         avoid tempering with China ROI ... with a energyAbudantPremium

// 29/30/31 Septembre ====================== RETUNE ===============================

// 7 Octobre : back to Mac, need to retune completely
// adjust the code model (game.cl) to the PPT (equations - CFM presentation)
- game.cl : adjust M4 (investment to growth , removed square cancel impact)
- model.cl : introduce pain profile (scalar vector)

(a) go(10) training protocol
----------------------------
   (a1) -> OK a 86T$
   (a2) -> dTable OK, 14Gt
   (a3) -> eTable OK
   (a4) -> hM2() looks good, but we should do go(20) + define what is expected (2000-2020 evol)
           what 1960 to 2020 shows is +18% per decade (2.5% CAGR) double in 40 years for Oil
           For Coal, it was flat before 2000 then doubled ...
           Gas has stayed flat in 40 years (trend) because of abundance
           => changed sensitivity to get better pictures
   (a5) -> hM4() -> investE looks OK
   (a6) -> h8/h9() + go(10)  -> hM4()
           impacts (hM5()): tax 0/0.76/1.84 T$ / GDP 86.9/ 83.6 / 78 ;Energy 13.9/ 13.0 / 11.7; 
                            CO2 416.07/ 413.7 / 410
           40 Gt de CO2 -> 11 Gt de C x 80$ -> 0.8 T$ expected
          

(b) go(40) training protocol
----------------------------
   (b1) -> h22 (plenty of energy) -> 167 
           adjust b.RoI matrix until 2050 - 140T$ (impact cancel visible)
           china at 41 vs US at 45

   (b2) -> 15.3 Gt (once Coal is stabilized with maxGrowth at 0.7%)
           dTable() is OK (energy density decreases)

   (a3) -> eTable OK - balance between sources is 
         TODO : look at transfers (energy transition)
   (a4) -> prices 300% Oil, 500% Gas, 160% Coal, 226% Clean
   (a5) -> hM4() -> investissement OK, IE OK
   (a6) h8/h9   GDP : 140 / 134 / 123 CO2: 520/400/470
        note the impact on China
   


(c) go(100) training protocol
-----------------------------
    (c1)  h22 (plenty of energy) -> 339 T$ (2% CAGR) with 22 Gtoe energy (800)
          default -> 220 T$ with 13Gtoe
    (c2) 11.8 Gt / 26Gt CO2 - 3 Gt de clean (realistic), 2 Gt Oil, 5.6 Gt Coal

// October 4th
-> there is a bug in the invest formula, switch to the PPT version
// October 8th
-> tuning done ...
BUT h1g() has shown that maxCapacity did not work for Clean
=> new code (need to reflect on Equations)

// start scenarios -> looking good

====================== IGNOBLE BUG with get(c.roI,year!(y)) =================================
====================== ANOTHER bug (missed the inventory correction for getOutput(Oil) ===== 

// October 14th: retune  (twice)
go(10)   : a little bit more energy ... tune density
          87T$, 14.35 Gt, 417 CO2  (vs 412 but with COVID - 422 in 2022)
          eTable OK (cf XL file) - dTable credible

go(40):   139 T$, 17.0 Gt, 526 CO2
          CN 39.2, US 41.4, EU 18.3, RoW 39.2
          h8/h9 -> 134, 15.78, 508;  116, 12.0, 464
          checked lookSolve(Oil) -> OK

go(100):  avec h22 (debug : plenty of fossile) -> 325 T$, 23.9 Gt, 801 CO2
          default: 199 T$, 13.16Gtoe, 652 ppm (16.6 C = + 2.7)
          23Gt emissions, 1.75 Oil, 5.19 Coal, 5.7 Clean
          PNB : US:67 EU 21.2 CN 58 Rest 51
          h8/h8+:  195 T$ 12.54 Gtoe 614ppm  / 166,9.77, 527  - h8++ -> 164, 9.7, 521

redo h*() scenarios -> look for results in input.cl file


16 Octobre 2023 ---------------------- cloture pour un mois -------------------------------


SHOW2 := true is a CLAIRE BUG -> fix for CLAIRE 4.1.0 !!!!!!!!!!!!

à finir avant de passer à GW5
==============================
- imprimer les M5 outcome
- calculer un SCC associé (dOutcome/dCO2)
- a comparer avec l'effet d'une taxe CO2 au meme niveau


// December 2nd, 2023 : closure of CCEM v4 !

model.cl
   (a) move slots to Economy (from Consumer)
       dematerialize
       RoI

   (b) move to Consumer (Zone)
       population
       disasterLoss

Impact of global warming destruction is cummulative
   (a) b.disasterLoss[y] := % of productive capacity, increasing monotonously
   (b) needs (getNeed in game.cl) is reduced by disasterLoss[y - 1]
   (c) in simul.cl we keep the average value of disasterLoss (for the world)

// December 9th : re-run all simulation 
// run the sensibility analysis -> see what the two most interesting examples are

[2100] World PNB=215.3, invest=29.2, conso=13.29, steel:2.3Gt
--- CO2 at 650.45, temperature = 16.6, impact = 7.6%, tax = 0.0,0.0,0.0,0.0
Oil: price = 3361.00(819.7%), inventory = 78.70, prod = 2.09
Coal: price = 181.00(181.0%), inventory = 386.45, prod = 5.35
Gas: price = 1785.00(1095.0%), inventory = 17.62, prod = 0.59
Clean: price = 942.00(171.2%), capacity growth potential = 0.07, prod = 5.24
US: conso(GTep) 0.63 0.14 0.21 1.38  vs need 2.74 0.31 2.79 2.04  
EU: conso(GTep) 0.18 0.03 0.05 0.39  vs need 0.78 0.06 0.66 0.58  
CN: conso(GTep) 0.00 2.79 0.02 1.01  vs need 2.35 5.97 3.60 2.92  
Rest: conso(GTep) 1.28 2.38 0.30 2.45  vs need 4.65 4.73 4.65 4.02  
[2100] US PNB=73.4, invest=8.8, conso=2.37, steel:0.2Gt
[2100] EU PNB=22.3, invest=2.6, conso=0.66, steel:0.1Gt
[2100] CN PNB=66.2, invest=10.7, conso=3.83, steel:1.1Gt
[2100] Rest PNB=53.2, invest=6.9, conso=6.41, steel:0.8Gt

h0() ->  PNB = 203 (CN 51), 12.02 Gt, 626 CO2      // carbon tax
h1c() -> PNB = 238 (CN : 87), 15.5 Gt, 676 CO2      // coal growth 
h1g() -> PNB = 230 (CN: 75), 14.5 Gt, 649 CO2      // green growth

h2-() -> PNB = 194 (CN: 66), 11.9 Gt, 610 CO2      // less oil (China does not care)
h2+() -> PNB = 262 (CN: 70), 16.6 Gt, 708 CO2      // more oil (US boom, EU too)

h3+() -> PNB = 249 (CN: 87), 12.78 Gt, 649 CO2      // more savings
h3-() -> PNB = 204 (CN: 64), 13.68 Gt, 654 CO2      // less savings

h4+() -> PNB = 228 (CN: 69), 14.3 Gt, 648 CO2      // more substitution
h4-() -> PNB = 198 (CN: 50), 11.72 Gt, 652 CO2      // less substitution

h5-() -> PNB = 181 (CN: 37), 11.9 Gt, 593 CO2      // less cancel
h5+() -> PNB = 220 (CN: 63), 13.94 Gt, 659 CO2      // more cancel

h6-() -> PNB = 192 (CN: 51), 14.03 Gt, 656 CO2      // less dematerialization
h6+() -> PNB = 236 (CN: 79), 12.78 Gt, 644 CO2      // more dematerialization

h7-() -> PNB = 201 (CN: 63), 12.6 Gt, 644 CO2      // less economic growth
h7+() -> PNB = 225 (CN: 64), 13.4 Gt, 653 CO2      // more economic growth

h8() -> PNB = 206 (CN: 50), 12.38 Gt, 610 CO2      // less carbon tax
h8+() -> PNB = 175 (CN: 15.5), 9.93 Gt, 528 CO2       // more carbon tax

h9-() -> PNB = 218 (CN: 66), 13.31 Gt, 651 CO2      // less GW impact
h9+() -> PNB = 211 (CN: 67), 13.05 Gt, 649 CO2       // more GW impact

Nordo: h11(10%)  ->  PNB = 260 (CN: 68), 15.6 Gt, 747 CO2  
Janco: h12(200%)  ->  PNB = 151 (CN:24), 9.23 Gt, 500 CO2
Singulo : h13(150%) -> PNB = 224 (CN: 20), 10.6 Gt, 519 CO2    

// redo excel
- excel("excel/diamandis")


// December 23rd 2023, add the KNUs
cf. simul.cl : knu() show the six KNUs
- KNU1: 
- KNU2
- KNU3 
- KNU4 : computes the maximal energy transition from fossile to green and adds the legacy electrity ratio (10%)
- KNU5: 
- KUN6: approximate SCC (computed after the simulation) : Loss/excess CO2

WARNING: changed the getOutput(Supplier) heuristics and introduced a min(1, Cmax/max)
to separate Coal (abundant) from Oil (scarce) to get realistics price increases for coal 

// ---------- new simulations ---------------------------------

[2100] World PNB=221.7, invest=29.9, conso=13.02, steel:2.3Gt
--- CO2 at 623.42, temperature = 16.5, impact = 7.2%, tax = 0.0,0.0,0.0,0.0
Oil: price = 2198.00(536.0%), inventory = 64.91, prod = 1.65
Coal: price = 188.00(188.0%), inventory = 417.92, prod = 5.27
Gas: price = 1416.00(868.7%), inventory = 17.59, prod = 0.60
Clean: price = 960.00(174.5%), capacity growth potential = 0.14, prod = 5.50
US: conso(GTep) 0.58 0.13 0.18 1.37  vs need 2.44 0.29 2.62 2.06  
EU: conso(GTep) 0.15 0.02 0.04 0.35  vs need 0.63 0.05 0.56 0.53  
CN: conso(GTep) 0.03 2.78 0.08 1.13  vs need 2.29 6.16 3.71 3.16  
Rest: conso(GTep) 0.88 2.33 0.28 2.63  vs need 4.49 4.79 4.66 4.36  
[2100] US PNB=77.4, invest=9.5, conso=2.27, steel:0.2Gt
[2100] EU PNB=22.9, invest=2.8, conso=0.57, steel:0.1Gt
[2100] CN PNB=69.1, invest=10.9, conso=4.03, steel:1.1Gt
[2100] Rest PNB=52.1, invest=6.6, conso=6.13, steel:0.8Gt

KNU1 = max clean energy per decade = 13.2 PWh/ 10 years
KNU2 = energy intensity decrease = 1.2% (CAGR 2010-2050)
KNU3 = negative long-term elasticity energy demand to price = -33.8%
KNU4 = approx electrification of energy = 48.6% in 2050
KNU5 = average worldwide ReturnOnInvest = 9.3% (2010-2050)
KNU6 = SCC estimate based on GW impact at +2.6C: 6.7% => 269.5 $/t

h0() ->  PNB = 207 (CN 51.7), 11.62 Gt, 595 CO2      // carbon tax
h1c() -> PNB = 236 (CN : 82), 14.47 Gt, 641 CO2      // coal growth 
h1g() -> PNB = 241 (CN: 75), 14.6 Gt, 622 CO2        // green growth
// note : with the new output model, if we grow the coal capacity, we need to 
// change the price sensitivity 


h2-() -> PNB = 195 (CN: 60), 11.71 Gt, 567 CO2      // less oil (China does not care)
h2+() -> PNB = 264 (CN: 71.4), 15.97 Gt, 663 CO2      // more oil (US boom, EU too)

h3+() -> PNB = 249 (CN: 77), 12.3 Gt, 604 CO2      // more savings
h3-() -> PNB = 209 (CN: 59), 13.52 Gt, 611 CO2      // less savings

h4+() -> PNB = 236 (CN: 68), 14.35 Gt, 606 CO2      // more substitution
h4-() -> PNB = 199 (CN: 50), 11.4 Gt, 608 CO2      // less substitution

h7-() -> PNB = 204 (CN: 59), 12.2 Gt, 602 CO2      // less economic growth
h7+() -> PNB = 230 (CN: 62), 13.35 Gt, 608 CO2      // more economic growth

h8() -> PNB = 210 (CN: 49), 11.88 Gt, 580 CO2      // less carbon tax
h8+() -> PNB = 183 (CN: 23), 9.9 Gt, 531 CO2       // more carbon tax


// refaire les excel
excel("excel/h0")
kaya("excel/kaya")
h2+() / h2-()  -> low/high fossil
h8() / h8+()  -> low/high carbon tax

13.9 + 3 -> 16.9
13.9 + 1.7 -> 15.6

Nordo: h11(10%)  ->  PNB = 239 (CN: 57), 16.30 Gt, 691 CO2   16.8C
Janco: h12(200%)  ->  PNB = 203 (CN:26), 9.78 Gt, 494 CO2
Diamandis : h13(150%) -> PNB = 220 (CN: 26), 9.98 Gt, 507 CO2  


Xmas Day: close CCEM for the year !

BUT : last change on ROI  means that all figures must be redone for the paper

// January 2024 : redo simulation for CCEM24 paper

new file organisation : simul.cl and display.cl 

// March 3rd : introduce an option 
NewCO2:boolean := true means that the accumulation model is simpler
ppm = ppm + CO2addFactor * (emissions)

// February 1st : start GW5 ! ====================================================

// February 3: start model + input changes

model:
- added heat% to the Supplier ('model.cl')
- translated the energy inputs of input.cl to PWh
- added heat% to transitions ('model.cl'): share of transfer that concerns direct heart
- techFactor is Energy-based (one per source) and describes the decline in costs (for 1MW installed)
- added co2Emmisions at the zone level (easy to compute) - will check on Europe ....
- added the production of electricity per zone as a factor (electrification of energy = KPI)
    - slots: c.eSources + c.eKWh (model.cl + init in simul.cl)

// February 10th : implement electricity production 
2 steps:
- compute the electricity production (eKWh) using the ratios (at each consume(C,S) step)
- adjust for transfers (S2 -> S1) usign the formula in the notebook x . (r1 - alpha * r2)
  where alpha = 1 - t.heat%

=> tune the estimate of ePWh (electricity production) by taking the transfer into account
(cf. execel file: energyMatrix.xls)  => done (approximate but OK)
-> at the same time, tuned the growth for China and the transfer matrix to get a nice 2020 energy forecast

added a feedback loop : pain to production (ratio = productivityFactor, zone dependant: attached to Consumer)
    r = 0 -> People is not a key factor, AI will dominate
    r = 1 -> -10% people => -10% output 

// March 17th : resume (at last)  
=> change the CO2 emission to concentration model ! see the excel table that shows the linear relation
   co2Neutral gets removed and there is a absorbtion factor (0.5% per year) that is added to the ppm
   ppm (volume) translation is 28.97/44 (volume to mass) * (1 / 5.137) since the atmosphere is 5.137 * 10^18 kg
     
  in the future we could model that this factor grows (acidification of oceans reaches a maximum)
  TODO : retrofit to GW4 to see if there is a big difference


 // March 22nd: restart with the great question of protectionism -----------------------------
 // key decision is not to simulate the amount of the CBAM tax but directly the effect on reducing trade
 // this way, it can cover may kind of protectionism taxes, as well as boycotts or redirection

 (a) it starts with the tactical redirection !
      Consumer.protectionismFactor : a factor alpha that is used in M4
//    note that this factor is part of the tactical vector of the Consumer      
      openTrade is a matrix w1 x w2 -> percent of trade that is blocked
      w1.openTrade[w2] := 1 - alpha * max(0,(w2.co2perE - w1.co2perE) / w1.co2perE) *
                                      max(0,(w2.co2Tax - w1.co2tax) / w1.co2tax) 


// For a block w, the economy (CDP) is local + export
// energy demand for local grows according to (maxOut evolution)
// export is bound to the flow w -> w2 (growth of w2 is inherited to w)
// import,which is part of local, may also be impacted (if w1 reduces, or if imports get reduced) -> only a negative factor
// note : since we deal with differences through multiplicative factors, we assume small diffferences
// equation Economy = local + export + import
//          dE = dLocal + dExport + dImport
//          dE/E = dLocal/Local x (Local/E = innerTrade) + dExport/Export x (Export/E) + dImport/Import x (Import / E)

 (b) this reduces the energy consumption (getNeeds in game.cl) that will impact maxOut
     the expected flow is (economyRatio(w2,y) * pb.trade[index(w)][index(w2 as Block)]
     first factor is growth of w2, 
     we start with two constant factors of the world economy (that could be regionalized later )
     // cf World in model.cl (start with 50% and 100%, ask economists ....)    
       - w.protectionismInFactor = factor of the reduction that is kept (the rest is sourced elsewhere)
       - w.protectionismOutFactor = factor of the reduction that is applied to the loosing exporting economy.
                                    that combines selling elswhere but ripple effects on the value chain.
     // game.cl (M2) 
    [globalEconomyRatio(w:Block,y:Year) : Percent
             -> localEconomyRatio(w,y) + outerCommerceRatio(w,y) + importReductionRatio(w,y)] ]
         these two new functions take into account the two protectionism factors


 (b) stratégie player = goals (économie, pain, CO2)  
   // CO2 does not matter really but we can play

 (c) tactical  =  BR from game theory 
    (a) CO2 tax = reaction from pain (taxAcceleration, cancelAcceleration)
    (b) cancel (sobriété)
    (c) transition énergétique (inventer un framework pour customiser le vecteur de départ)
      => transition énergétique est nourrie par CO2 tax, mais nous pourrions ajouter des investissements nationaux
      => transition énergétique est également savings
     (d) CBAM : protectionism = f(delta CO2 ... or delta tax)
         we need a simple formula that links the decided (%reduction OR tarif)
 
 (d) measure CO2/habitant for all zones and see how it evolves (cf. Hannah Ritchie)

 (e) manual tactic set - model.cl 
     tactical(c:Consumer,
        transitionStart, transitionFromPain,    // default 100%, 0%
        cancelFromPain,                         // default 0%
        taxFromPain,                            // default 0%
        protectionismFromPain)                  // default 0%

// April 13th : time to debug

  - growthPotential (model.cl, game.cl, input.cl) : yearly roadmap
  - Horror: the fine tuning was lost -> redo the tuning - actually all this weekend work was lost

// May 1st : start the month of GW5 / IAMES ---

     repair !
       (1) all stupid typos ...
       (2) good formula for import Reduction
         [importReductionRatio(w:Block, w2:Block,y:Year) : Percent
          -> max(0.0, (w.openTrade[index(w2 as Block)] - 1.0) *  pb.world.protectionismInFactor) ]
       (3) growthPotential : now a yearly roadmap ....
       (4) created tTable(s,y) to check the trasnfer flows
       INCREDIBLE BUG: confusion vs s.added and s.additions[y]  

  NEXT MISSION: tune addition and transfer flows thanks to the tTable tool !!!!!!

// May 4th
    - separate S.addedCapacities[y] = cummulative added capacity (yearly log of s.addedCapacity
               S.additions[y] = yearly added capacity => used for investment
    - added checkTransfers (make sure that it is really clean < 0.1%)
    - the addedCapacity is cummulative => fix the formula for maxProd growth !!

// May 5th
   -> need to tune transers - test with and without transfers !
      seems OK ! (there was a bug in the CN:Coal->Gas transfer value)
   -> see why CN coal consumption does not seen to change ?
     This is tricky : transfer creates a capacity, but the old coal is available, hence more energy feeds more growth, and coal
     consumption is not reduced.
   -> Check the investments for Energy : do not matter much : Energy is cheap, adding 1PWh is not a big deal (1T$) 
      formulas seems OK
   THIS SHOULD BE TOLD IN BLOG AND IAMES PRESENTATION : CCEM IS A MODEL WHERE ECONOMY IS STRANGLED BY LACK OF ENERGY IN 21TH CENTURY
   WHEN WE CREATE GREEN ENERGIES, WE CREATE GROWTH BUT FOSSIL ENERGIES ARE STILL USED
  
   evening: redo all simulations for scenarios (h*) since we have changed China

// May 8th : start redirections
   - implement reinit(), so that we can do multiple runs of one scenario with different tactics
   - (1a) tEt(EU) done, crazy -> carbon tax alone = self-sacrifice for others ...
          THIS IS ALSO A KEY POINT FOR THE BLOG AND IAMES PRESENTATION
          CARBON TAX for EU ALONE DOES NOT REDUCE CO2 EMISSIONS

// May 9th: further redirections : tacx (tax), tacc (cancel), tact (transition), tacp (protectionism)
   - acceleration of cancel - NEW: cancelAcceleration only for fossil !
   - acceleration of transition
           - needs to implement a control factor for the transition (default 100%)
             trabnzitionStart, transitionFromPain  -> transitionControl

// May 10th: implement protectionism (CBAM) and display results (trade flows)
    - add tradeFlows for debug (compute in M4)
    - add carbonTaxRates(c,y) to adjust CBAM in a differential way = function (computed)

// May 11th : tune the impact on EU and CN when imports are restricted
    - EU:  missing the impact of import on MaxOut !
      CHANGE: maxout is not touched by Import BUT we add the impact when we compute gdp 
          - importReductionRatio   -> used both for need & maxout->gdp
          - exportReductionRatio
      The impact on energy has been computed already :)
    - symetrical formula : works on China exports
    NOTE: when we play with GTES, we need to add an import based on retaliation, not CO2
         => X apply the same rate for (Y -> X) than Y CBAM for (X -> Y)
    - implement a table : sample the tactic and prints the satisfaction
        tactical %,  GDP, CO2, Satisfaction, pain associated to this tactical lever
 

// May 12th
   - GW5 is officially closed
   - move to Javascript generation (project cl2js)
   
// June 9th - reopen for AXA IM presentation
-> recréer des scenarios NGFS 
    NGFS0 = Janco
    NGFS 1 = CP (2.8)
    NGFS 2 = NDG (2.1 -> 2.4 because no sequestration)

-> faire des tableaux Excel pour comparer avec NGFS
   faire tout en base 100 (2010) pour comparer les évolutions
    GDP, Oil Price (relative), Energy Consumption, Clean, temperature delta, GT emissions

Problemes à régler : commencer dans le train
(1) comprendre pourquoi h8++ n a pas plus d'impact sur les émissions de CO2
   => adapter cancel si besoin .... hypothèse 800$ de taxe carbone -> calculer le prix énegie à 300g/kWh
(2) reconstruire un Jancovici = Carbonzero avec une division par 4 des émissions en 2050
(3) on notera que CCEM ne fait pas d'hypothèse de séquestration de CO2 donc on obtient des températures plus hautes

(1) h8c : taxe uniforme a 500$/t
     -> on découvre une elasticité conservatrice = - 5% si on double, puis -30% ensuite
     -> valider que pour le petrole 500$/t -> 37$/PWh
    AHA ! la valeur n est pas la sur une tonne de carbone mais de CO2 !
    IT WORKS MUCH BETTER.
     h12: PNB: 188.1T$, 108.5PWh -> 520.9ppm CO2, 15.9C, 63.9PWh clean, 66.5% electricit
    ===>  we need to understand why h12(200%) breaks (we get a NaN, not cool)

    TRIPLE bug 
      (a) cancel augmente trop vite et passe a 1 trop tot
      (b) mais le code devrait etre safe ... corrigé dans game.cl (safe delta)
      (c) si les taxes étouffent la demande, pas clair que le prix baisse a zero.
          trouver une formule plus sympa (ou un min = prix de départ / 2)
          il suffit de multiplier par min(max(0,pRatio - 0.5) / 2,1) 

(2) ajout d'un facteur cancel dans scénario Janco
    -> fonctionne mais pas génial (terme trop faible)
    => pas vraiment utile : la taxe carbone fait le job

// conclusion de Lundi soir : il a du travail pour avoir
// (1) un bon fonctionnemenbt de la taxe carbone
// (2) des triples scénarios propres
// (2) des NGFS propres

// 15 Juin 2024 
TODO (1) creer  un NGFS0 qui marche
         - avec 70PWh de clean en 2050  -> OK
         - nécessite de faire plus de transfer  -> OK Mais XtoClean doit utiser improve%
           pour que les taux de transfer soient entre 0% et 100%
         - obtenir un run(90) qui marche -> OK  (avec XtoClean a 30%)
         - monter la demat a 2.7% par an pour NGFS (pas Janco)
         - refaire tous les scenarios !

Changement dans la formule getOutput(Supplier) pour que les prix soient plus réaliste avec une forte taxe carbone
formule quadratique qui fait que le prix ne baisse pas plus que 1/2 prix de départ

// 16 Juin 2024
    we need to put a cap on the transfer to Green since the total transfer flow should fit the capacity Growth constraint
    => in M3, maxGrowthRate(s,y) was wrong because expressed as a percentage of the total capacity vs max flow
       we had maxTransferFlow(s,y)

      (2) recalibrer les scenarios
           refaire Janco / Nordo / Diamandis

      (3) faire les 3 NGFS

      (4) refaire les EXCEL Nordo + nouveau excel NGFS
            GDP /  Oil price
            Energy /  Clean
            Temperature / GT

      (5) faire les deux slides pour AXA IM   -> fin de GW5 (extension 2)

// 11 Juillet : cloture de GW5 / creation de GW6
// ================================= Start  GW6 =========================================









