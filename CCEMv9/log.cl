

                +--------------------------------------+
                | GWDG Project log file v0.9           |
                +--------------------------------------+


Note: we keep the history of the two previous versions of the CCEM model (v7 and v8) in this log file. 
      The current version is CCEM v8 (2025-12-24) and we are working on CCEM v9 (2026-07-04)

// ==============================  March 23rd, 2025 : start CCEM v7  ==========================================================
backlog:
   (1) better damage model : better calibration (see associated CCEMv7 PPT)
   (2) adaptation
   (3) CO2 absobtion model (TCRE)
   (4) tech lifecycle downcost model (price decreases not in time but as a function of volume)
   (5) scripting
        - generates experiments = (belief => scenario)
          belief = set of hypotheses (KNU instantiation)
        - scripting = language to produce experiments (what we shall do with sliders)
   (6) Measures (copy from older GTES files)
        - be able to run multiple randomized experiments and produce stats (mean & stdev)

// March 25th 
model.cl change 
    - on new KNU to represent adaptation (as a fraction (invest costs / yearly max savings)
    - Consumer: adapt slot => Adaptation object (adaptSpend, adaptSum, adaptEffiency) + 
      tactic (adaptStart, adaptFromPain)
    - Damages & TCRE :  Gaia has TCRE (Affine) and co2Cumuls 
    - simplifier la satisfaction 3P (People, Profit, Planet) 

Scenario.cl : new KNUs
    - rename old KNUs
    - add Kadapt and Khuman
    - each KNU has onto:Set and modify:property that tells how to apply the "cursor" (G2WS)
    - World has a global protectionism factor that moves both in and out ratios

// April 12th (until 15th)
// extended week-end goal : write code (coarse) + move to PC (start tuning in US)

Create (model.cl)
      - Tmeasure :: list<measure>
      - Charts :: sets of Tmeasures for Earth, Consumer, Supplier
      
Produce (simul.cl)
      - updateCharts()
      - makeCharts()  : creates the empty chars (list of measures)

gtes.cl   
    -  Belief : list of KNU(name), value
    - runBelief(l) : apply the float values to each KNU of the belief
    - script(c, strategy, ...) : creates a belief
    - randomize(c, strategy, ...) : runs a complete simulation loop 
         (a) MonteCarlo instantiation
         (b) run the simulation
         (c) records the results into the charts
         (d) produces a report

game.cl : introduce CCEM v7 changes
    - damages are mitigated by adaptation levels
    - adaptation levels are modified through the tactics


input.cl : introduce adaptation + TCRE


// April 16th : USA vacation starts :)  
// May 1st: move back to Mac

(a) big decision : v7 energy is based on https://ourworldindata.org/energy-mix
    however:  Electricity is picked on https://ourworldindata.org/electricity-mix
    -> change input.cl (2010)
(b) tune energy  -> add transfers to match 2019  -> done on 2nd of May at 9:30
      - coal to clean in CN 
      - oil to clean in EU 
(c) check 2024 - 2050 - 2100 hypothesis for transfers
      -> hypothesis for energy shares in 2100  
(d) check electricity rates in 2010, 2020, 2040 with eTable  -> add tr.efficiency% as a factor for eRatio (c.ePWHs)

// May 9th
- TRCE immplemented (TCRE slot + CO2cumuls) -> no worsening impact
- re-run damages/adaptation hypothesis
      -> added w.adaptGrowthLoss (May 10th)   -> removed on June 14th
      -> recompute spend with c.tactics.adaptMax at 20%

// May 10th : recalibrate the warming model according to last IPCC model
- RPCC 4.5  -> 2.7
- RPCC 6.0  -> 3.2
h11(5% or 10%) give a good Nordhaus simulation at +3C

// May 17th : play with auto-tune for adaptation

// May 31st : start the "June CCEM" experiments (as show in the slide of CCEMv7)
// June 1st:
      - whatif to see what happens with a small change, then makeTable, then topt(c,p).
      - played with Carbon tax : best strategy is 0 (slows economy and does not reduce CO2 because of other players)
      - played with energy transition: best strategy is 100% (accelerate) because CCEMv7 does not capture well
        the cost of transition 

// Bonnieux week-end (June 7th)
- trace transfert for Europe and associated costs : 2PWh to Clean shoulf cost 2T$ (1T$ per PWh)
  compare h0 with h00 (EU.tactic.transitionStart := 0%)
- may add a transition cost factor (transitionCostFactor) (1$ in transition for 1$ in energy supply)

// RESULTS (June 7th)
- there was a bug with the transition cost factor (should us tr.to.investPrice)
- we have created two temporary slots investCapacity and investTransition to decompose investEnergy

// June 8th & 9th : implement better BR (Best Response)
// interesting : find the best tactic for Europe and China (transitionStart, transitionFromPain
gtes.cl
   -  created topt (test dichotomic opt / fixed !) and topts (with sampling: more robust)
   -  created toptp (test a pair of bound properties) : nested sampling
   - interesting results for Europe and China => best tactic is different for h0 and h00
    if no one transitions, then the best tactic is transition more ...

// June 14th & 15th : adaptation tuning
   - input.cl adaptation affine curve is simpler
      before: expressing total adaptation spend as a fraction of total property costs 
         (10-15% for real estate, 10% for Michelin, 50T$ for 500T$ with revised GPT estimates)
  - game.cl : 
      - simpler attenuation
      - make sure that we record total spend and total avoided damages  -> c.adapt.gains
  - display.cl :  hM6(c) shows the adaptation spend and gains
  - gtes.cl        topt(c) -> complete optim and show(c.tactic)

// June 20th : changed completion to Claude
Open the command palette by pressingCommand+Shift+P (Mac). 
Type change completions model and select the "GitHub Copilot: Change Completions Model" command.
In the dropdown menu, select the model you want to use.

// extends CCEMV7 for CBAM simulation
   - (1) add "ajust for trade" consumer emissions (add imports at the export level of CO2/$ and remove exports at the local leve)
         AjustForTrade(c:Consumer,y:Year) : float
   - (2) compute 2010 values and compare with our sources: OCDE and ourworldindata -> seems OK!
          EU: 3.59 to 4.185 = growth 16.5%
          
   - (3) change 3P satisfaction: planet is based on CO2 emissions "adjusted for trade" reductions until 2050
       display.cl  trade(c:Consumer,y:Year) : void show the trade flows
           new GDP x TradeMatrix x importReduction  


// August 2025
      - improved the web.cl file to work with clserve.go
      - model.cl : added scalarProduct and boundedProduct
      - game.cl: averagePain (3 years) for productivityFactor (avoid oscillations)


// =========================== Oct 5th, 2025 (62th birdthday) : start v8 ========================


Oct 5th: démarre le fichier input80.cl 
Oct 12th: update Google doc with 1980 data & energy sector data (EIA & GPT5)
Oct 19th: write excel support files "EnergySensity","EnergyMatrix.xlsx"
Oct 24th: write GDP Data Mining excel file
Oct 26th: start coding : SETM, ETM, densityCurve, elasticityCurve
Oct 27th: New RoI formulation
  RoI = world.RoI(24%) * zone.techFactor(KNU) * (1 - zone.socialExpenseRatio)^2 - decay(GDP/h)
  decay = 0% until 2000 (1980 $), 2% until 5000, 5% after

Oct 29th  go(10): raw debug
          found a bug in the Excel "GDP Data mining" -> new techFactor and decay
          go(30): tune to get 2010 value
          check : energy prices are OK in 1990 (no increases)

MEGA-DECISION1: we do not use populationGrowth any more as a factor
    (a) M1 : for energy needs
    (b) M4 : for Maxout (GDP growth)
    hence popEnergy is gone :)

Oct 30th : tune energy consumption up to 2020 (go(30)) to ensure that transfers do occur
           using eTable()

MEGA-DECISION2: we compute inverstGrowth irrespectively of energy (how we calibrate the model)
    note: we could return later to impacting InverstG from investE  
    we also decide to make c.decayTable a time-affine for each zone.

    the following matrix should be in CCEMV8 PPT
+-----------------------------------------------------------------------------------------------------+
| TUNING PROTOCOL (we need this to be simple)                                                         |
+-----------------------------------------------------------------------------------------------------+
|    (1) GDP tuning thanks to RoI, techFactor, decay  (source GDPDataMining.xls)                      |
|        mesure results and maxout (see the effect of energy shortage & damages)                      |
|        first tune US based on world.RoI, then others on tech factor                                 |
|    (2) Energy consumption by zone thanks to demat curves ()                                         |
|        first tune total by zone through demat, without transfer (use notransfer() in input)         |
|    (3) Energy price tuning thanks to sensitivity curves and growth capacity                         |
|        this is required to ensure that cancellation is minimal before fine tuning - including (2)   |
|        it also requires that transition is active  (stop using notransfer())                                                 |
|    (4) Energy by source tuning thanks to ETM (subMatrix)  (source EnergyMatrix.xlsx vs eTable)      |
|        note that fine tuning cannot be done before (3)                                              |
|    (5) check electricity consumption through elTable                                                |
|        play with heat% in transition, then adjust the speed of transitions to balance elec%(zone)   |                                              |
|    (6) move to longer time horizon to tune cancellation effects                                     |
|        it can also be tested while lowering inventories - check that price increase make sense      |
|        check cancel curve consistency (from 0 to 99% at PMAX)                                       |
|    (7) iterative process since there are dependencies:  (1) to (4)                                  |
|    (8) check steel and wheat production (adjust density & crop yield)                               |
+-----------------------------------------------------------------------------------------------------+


October 31st: revise energy supply (M1)
---------------------------------------
   MEGA-DECISION 3: create expectedPrice (based on production price, without shortage or surplus)
     - the price is hard to model : it is a KNU (look at "Price" in "EnergyDensity")
       goes up for oil (1990-2020) because of shale oil, down for all others
    - one unique supplier profile (equation [1] and [2])
    - model.cl is simplified ()

    debug:  (remove transfers first)
      - check that capacity follows demand

November 1st: follow tuning PROTOCOL
------------------------------------
    (0) validate the inflation vector => https://www.minneapolisfed.org/about-us/monetary-policy/inflation-calculator
    (1) GDP tuning: (a) total : 26.9 (b) US:6.7, EU:4.84 CN:4,79 In:0.85 RoW:9.82
        note: fix dematerialization first (not enough coal)
    (2) Energy consumption   total 2020: 147  US:24.19, EU:14.8 CN:36.6 IN: 9.09 RW:64.4
   
November 8th : 
    - total energy consumption is OK
    (3) We want the source profile (2020)   Oil: 53.6, Coal: 46.6, Gas: 39.06, Clean: 9.72
        - first we need to fix the inventories (use GPT)
    (4) we need to reproduce the transfers 80 to 2020
        - same oil,  less coal, more gas, more green 
    DONE at 17:45 = we have a good energy vector by zone and by source for 2020
    (5) check electricity consumption (eTable) => we want 26.5 PWh in 2020 -> DONE
    NOTE: in CCEM v9 we need to improve the model of electricity production (too much complexity because of not enough data)
          simple idea is to separate heat/elec for each fossil fuel (we have the data when we start)

November 9th : go(120) ! got decent results at 16:00
     go(70) : look at what happens to gas price !
     the first step is to model the rarefaction of a fossil fuel
     There was 4 bugs:
        - the formula for maxCapacity, when threshold kicks in, must be continuous
        - cancelCurve must be consistent with start price (constant ORIGIN dollars) and PMAX
        - inventory as f(Price) should be discussed with experts (cf. O. Vidal)
        - threshold ratio (when we start to reduce capacity) should be 70% of starting  value
     WE need to restart ! fix go(40) before looking at go(70)
        - price of electricity is too high => do not confuse capacityOrigin and capacityMax :)
     COOL: we get proper histograms for Gas and Oil - shapes depend on beliefs about reserves

     go(120): we need to fix the growth of China by making social expenses an affine
     KEY IDEA: this is a KNU in CCEM v8, but will depend on aging and redistribution in CCEM v9
     (a) we call roiEfficiency the tuning factor that is 100% for US and factors tech and innovation
     (b) we tune China for 2010 and 2020

     - made inflation a StepFunction (to be more precise)
     - tuning of impactFactor (impact of cancel losses to investment growth)
    
  
November 10th: tune 2010 model using input2010.cl
--------------------------------------------------
     (1) expected GDP: 73.8 total, US 17.7  EU 13.7 CN 12.6  IN 2.24  RW 27.15
     (2) Energy consumption   total 2020: 147  US:24.19, EU:14.8 CN:36.6 IN: 9.09 RW:64.4
     (3) energy prices are OK
     (4) We want the source profile (2020) total 149TWh  Oil: 53.6, Coal: 46.6, Gas: 39.06, Clean: 9.72
     (5) go (90)

     good news: done !
     bad news:
        (a) growth is too high and especially China (looks like 1980 version)
        (b) need to see how much energy is here
            - proper calibration of fossil reserves
            - proper calibration of renewable growth (look at 2024)


November 11th: produce 2200 trajectories (and see if collapse will, or could, occur)
    - it works beautifully from 1980 !
    - we now need to
        (a) calibrate gw8 vs gw7, for 2010, 2050, 2100
        (b) calibrate precisely the energy input hypothesis and make them similar
             - fossil inventory 
             - capacity growth for renewables


November 16th: prepare energy data for CCEM dinner => new calibration
    - oil, gas, coal 
    - max Growth for renewable 0.3-0.5 en 2010-20 et 07-1.0 en 20-30
      need to calibrate the transition (electrification that seems to be the bottleneck)


December 1st: resume
   - electricity calibration unti 2030 : 36 000 TWh
   - need expected Oil 52 PWh, Gas: 45 PWh, Coal: 55PWh in 2030
   - recalibrate transition
       2020: looks OK (elec at  26, Oil/Gas too high/low vs EnergyMatrix.xls, same for Coal, OK for clean)
           => Oil to Gas (both Indus & Res)
           => Coal to Gas (Res)
       NOTE: when we recalibrate transition(2020) we need to recalibrate dematerialisation to get EnergyMatrix
       2030: too much coal, not enough Clean (move 4PWh)

December 6th: finish 1980 callibration
  - steel (Iron in EnergyMatrix) : zone.ironDriver (affine) in 1980 dollars, steelPrice (1980), energy4steel
  - wheat: wheatProduction, agroLand, cropYield and landImpact
  - CO2 data in 1980: ppm, emissions, cummulative emissions, world average temperature
  => enter data in input1980.cl
  - run go(40): 2020 and go(120): 2010
  - check electricity product eTable()  => works beautifully with the addition of CARNOT factor to estimate 
    s.heat% (the part that is not electricity) in simul.cl

December 7th: do 2010 calibration (input2010.cl)
    - implement painDelay (a meta parameter for World) that is used in game.cl
      this will be used to measure the value of anticipation (*FromStart vs *FromPain)
    - enter data in 2010$ : GDP,
    - run go(10)  / follow complete calibration protocol 
       => GDP tuning: (a) total 2020 : 73.8 (b) US:17.6, EU:13.7 CN:12.6 In:2.24 RoW:27.15
    - go(90)

December 14th : adress CCEM 3 shortcoming = transition control, v7 vs v8 consistent energy hypothesis, China GDP Growth
   - note: the  completed Balance of Trade matrix (2010 and 2020) show stability
   - decision : the default run (go(x)) will be done with transition at 50%.
     getTransferRate() is changed to apply transitionFactor to years post 2020 (pivot) => tuning will work
   - tune demat:  (B) Energy consumption   total 2020: 147  US:24.19, EU:14.8 CN:36.6 IN: 9.09 RW:64.4
    
Extended week-end : tune CHINA GDP 2020,2030 and 2050 using GPT5 for consensus
   - add a laborCompetitiveness factor to RoI that is an affine function to the relative (GDP/h)
   - model.cl  create the affine associated to pb.world
   - game.cl : add getCompetitiveness & laborFactor
   - input2010.cl  : first simple tuning to get 2020, 2030 and 2050 coherent (+40% peak)
  
   - input1980.cl : obtain the 2020 vector, to tune the bonus of lower labor cost
         GDP2020:  27.9 with US:6.7, EU:4.84 CN:4,79 In:0.85 RoW:10.43  [1980 US dollars]
         GDP2010:  24.94 with US:5.8, EU:5.48 CN:2.34 In:0.67 RoW:10.7

December 20th: finalize 1980 calibration
  - GDP done (2020, consistent with 2010) -> use 28% a default growth (align with input2010.cl)
       2030 / 2050 for US/China = 31/25  and 55/45 in current GDP
       we get in 2050:current GDP = 221.32T$, US: 60.32T$, EU: 26.55T$, CN: 56.09T$, IN: 13.59T$, Rest: 64.76T$,
  - energy tuning 
      (a) energy total 2020: 149TWh  US:24.19, EU:14.8 CN:36.6 IN: 9.09 RW:64.4
      (b) energy by source: total 149TWh  Oil: 53.6, Coal: 46.6, Gas: 39.06, Clean: 9.72

December 21st: 2010 calibration following the complete protocol 
   (1) GDP 2020: 73.8 total, US 17.7  EU 13.7 CN 12.6  IN 2.24  RW 27.6
       GDP 2030/2050:    US: 31 / 55    EU: 22 / 32   CN: 25 / 45  [US current $]
   (2) + (4) Energy 2020: 149 total, US 24.19  EU 14.8 CN 36.6 IN 9.09 RW 64.4
      Energy by source 2020: Oil: 53.6, Coal: 46.6, Gas: 39.06, Clean: 9.72
   (3) prices follow the KNU :)
   (5) electricity at 27 800 TWh in 2020 is good (cf Google notes)
   (6) & (7) : will do through sensitivity analysis
   (8) wheat production => 2010: 640Mt  2020:767Mt   2030: 840Mt (GPT 5.2)
       steel production => 2010:1.4Gt   2020:1.9Gt (small COVID hit)   2030:2.1Gt (GPT 5.2)
       wheat is wrong in 2011 !  => fix from input.cl :)

December 22/23 => sensitivity analysis
    - carbonTax is added to investments, pending CCEM v9 redistribution model
    - redo optimization of tactics with topt(EU) and topt(US)
        play with delays to reactions (Gaia.painDelay)
        - réaction de redirection (pain)  => allows to balance the "*start" vs "*fromPain" in the tactic
        - play with it in an optimization loop (example : adaptation)

December 24th : simulations until 2200 (go(190))  
     (1) it works !
     (2) added fullTransfers to see what if we transfer ->  slow degrowth during 22nd century (back to 95T$)
     (3) it needs to be tuned in CCEMv9 when we add pain -> redirection 
     (4) the effect: no fossil -> economy contraction -> reduction of Clean is surprising but logical (interdependecy)
     (5) the formalas for growth are brutal : RoI x Invest is less than decay for EU and RoW  

// January 4th to 11th : audit  by GPT5 based on "CCEM2025v8.ppt"
- M1 :  fixed the expected growth formula (linear regression had a bug)
- M2 : SavingRates vs SavingFactors (thanks GPT5 !), demand algebra (1-x)(1-y) vs (1- x + y), population is not a linear factor for needs
- M3:  only change equations, code is better :)
- M4: populationGrowth transformed into productionDecline, Added adaptation invest into equations
- M5: added adaptation to equations, clarified pain

// WE CLOSE AND MOVE TO G2WS ===========================================================================

change web.cl to adapt tp CCEM v8
  - 9 KNUs and 6 tactical -> 15 sliders
  - updated the Explanations
      -  fossilToCleanMax(c) : max share (from substitution matrix) of fossil that can be transitioned to clean
  - updated slider store

updated clserve.go
  - added setup option to display additional sliders : Density, RoI, populationFactor

// Bugs for Vermont
  - explanation list should be given the first time the UX is called : we need a new method in clserve (setExplanations)
    currently, it is only updated by callback

updated g2ws.go (which has the same structure)

Add a new electricity curve (web.cl)
- Electricity in TWh
- Electricity rate 
- Transfer rate of fossil to Green
- Clean electricity

// February 14th (back in Versailles)
- make the Javascript code from cldemo.go
    => MAKE SURE THAT WE have the proper ClaireKernel.cl  (cf Warning)


// ==============================  July 28th, 2026 : start CCEM v9 ==========================================================


// ideas for CCEM v9 (started on July 4th -> Excel microModels -> PPT specs
  (a) 3 more KNUs : deathRate, inequality, AI replacement factor
  (b) New model variables: 
     - Inequality: giniLevels (variable : start in 2010 + dynamic evolution), 
     - Aging: young & senior, two timeSeries, from population: a timeSerie - different from
       populationForecast, a belief,
       populationDistribution: (young, active, senior) when we start 
       deathRate (belief : affine for zone)
     - b.aiReplaceFactor : 0% to 100% (belief) : fraction of jobs replaced by AI (affects productivity)
       we play with 3 values : world, US, China [knu]
     - socialExpensesValues is a time series, (dynamic update of belief : socialExpenseRatio)
     - Gaia has a new slot: painReplacement (affects the pain of the population when AI replaces jobs)
  (c) New system parameters:
     - pb.transferPriceSensitivity (0% to 100%)  [knu]
     - pb.seniorExcessMortality : constant that is fine tuned (cf. microModel)
     - pb.activeToSocial : percentage of SocExp that is related to non-active population (young + senior)
     - pb.socialToGini: constant that is fine tuned (cf. microModel)
     - pb.aiToGini: constant that is fine tuned (cf. microModel)
     - pb.aiTransitionDuration: duration in year for AI replacement to reach its maximum (2040 -> 30)
  (d) Setup => separate world KNus to Zone Knus (Roi and Population Impact)
  (e) some factors should change in a time-sensitive manner (nothing in 2020 up to x in 2100))
       - example : AI replacement :)
  (f) check the agro surfaces and the constant 

// July 29th : 
-  displaced (Consumer -> Block) because of 50 slots rule: 
    - carbonTaxes:list<Price>,            // amount of tax (T$) => carbonTaxAmounts
    - sellPrices:list<list<Price>>,       // deleted
    - startNeeds:list<Energy>,            // deleted: c.consumes is the start need vector
    - needs:list<list<Energy>>,           // depends on the economy (N - 1)   
- add values in input2010.cl
-  modify init(..) in simul.cl to initialize new state variables 
   (population, young, senior, socialExpenseRatio, ...)

// July 30th :
- M2 extension code: population based on microModel "PopulationMicroModel.xlsx" (see the PPT)
- M5 extension code: computes Gini
  however the driver for inequality should not be Gini (that is polluted by social exp that is driven by aging) 
  but rather the AI replacement factor (TODO later)
  KEY: the model has a AI-replacement policy, it does not really has as redistribution policy that would 
  improve Gini, increae social expenses, at the expense of economic growth (keep this idea for future versions)


//  July 31st :
- M3 extension:  add a factor that limits transfer based on price differential
    controlled by pb.transferPriceSensitivity (0% to 100%) : 0% = no limit, 100% = no transfer if price differential is > 0
    added priceDeltaRate(s1,s2,y) that is used in applyMaxGFrowthRate 
    FIXED A BUG: maxTransferRate is a max not a multiplicative factor

- M4 extension: 
      (a) NEW GDP reccurrent formula that takes labor into account
          - created LaborFactor that modulated GDP from existing assets
          - laborFactor is a multiplicative factor in productionDecline
          - GDP formula is newMaxout used in consumes(b,y)
              
      (b) NEW RoI formula that takes dynamic value of social expenses  

// August 1st :
    - set pb.slots to 0% to reproduce older results (no social expenses, no aging, no AI replacement)
    - go(90) without a bug - done
      Note that Deathrate is not a percent but a "per 10000"
    - go(10) : tune GDP (M4 constants)
       -> fixed the population (stupid bugs, remained to tune)
       -> socialExpenses(y - 1)

// August 2nd :
   - GDP results 
                   2020    2030    2050    2100      expected   2020    2030     v8 2050   2100
        ----------+-------+-------+-------+--------------------+-------+-----------+------+------
        World      76.2    90.18   111.2   122.8                73.8+   95          104    137.2
        US         18.1    22.8    32.0     48.3                17.8+   25.4        30.2   47.4
        EU         13.7    13.0    11.4     8.68                13.7    16.0       11.9   10.2
        CN         12.2    19.0    26.0     18.8                12.8    15.8        29.0   36
        IN         2.3     3.67    8.0      14.2                3.3     3.9         7.11   17.7
        RoW        29.8    31.6    33.7     32.7                27.6    33.3        26.6   25.3

     comment: pretty good, we can fine tune the 
     Obviously, the impact of depopulation is strong versus v8
     The AI tuninng will help US and China 
  
   - population tuning : look at active Pop% in 2010, 2030, 2050, 2070 and 2100 => pTable()
        also show Young, Senior and total population (from estimate)
        seniorExcessMortality:Percent = 98.5% is a good value -> similar to microModel

// August 3rd :
   - Social Expenses and Gini tuning -> iTable() in display.cl 
   - make c.socialExpenseRatio a simple affine (2010 value, 2100 trend)
   - adjust pb.activeToSocial to get a decent forecast = 25% from Excel microModel
   - set c.aiReplaceFactor to realistic values for China, US, EU and Row 
 
// August 4th: Tune GDP, used 2030 estimates from the micromodel

    Key: (a) the 2019 results are bad, in euros or in dollars
         (b) GPT is very confused about (a) the current/constant ratio (b) the fate of Europe :)
         (c) there is a 2010 to 2020 recession in Europe that must be modeled with 
 
    Two consequences: (a) WE TUNE THE 2010-2020 SLUMP by hand with roiEfficiency (EU and RoW)
                          This should be in the CCEMv9 presentation deck to Fellows
                      (b) we drop the quadratic form for social expense (too much of a burden for EU
                          apply Occam s razor here 

        
    - GDP results 
                   2020    2030    2050    2100      expected   2020    2030     2050 (with energy)
        ----------+-------+-------+-------+--------------------+-------+--------+------+------
        World      74.6    90.7    123.3    167                 73.8+   89+      124
        US         18.6    24.7    39.3     75                  18.57   24.5     40
        EU         14      15.8    19.9     24.2                ~14     15.8     20
        CN         12.13   16.3    23.0     29.3                12.4    15+      20+
        IN         2.3     3.67    6.95     9.40                2.3     3.5      7.1
        RoW        27.4    30.2    34.7     28.2                27.6    30.6     37.0

   
+-----------------------------------------------------------------------------------------------------+
| TUNING PROTOCOL (we need this to be simple)                                                         |
+-----------------------------------------------------------------------------------------------------+
|    (1) GDP tuning thanks to RoI, techFactor, decay  (source GDPDataMining.xls)                      |
|        mesure results and maxout (see the effect of energy shortage & damages)                      |
|        first tune US based on world.RoI, then others on tech factor                                 |
|    (2) Energy consumption by zone thanks to demat curves ()                                         |
|        first tune total by zone through demat, without transfer (use notransfer() in input)         |
|    (3) Energy price tuning thanks to sensitivity curves and growth capacity                         |
|        this is required to ensure that cancellation is minimal before fine tuning - including (2)   |
|        it also requires that transition is active  (stop using notransfer())                                                 |
|    (4) Energy by source tuning thanks to ETM (subMatrix)  (source EnergyMatrix.xlsx vs eTable)      |
|        note that fine tuning cannot be done before (3)                                              |
|    (5) check electricity consumption through elTable                                                |
|        play with heat% in transition, then adjust the speed of transitions to balance elec%(zone)   |                                              |
|    (6) move to longer time horizon to tune cancellation effects                                     |
|        it can also be tested while lowering inventories - check that price increase make sense      |
|        check cancel curve consistency (from 0 to 99% at PMAX)                                       |
|    (7) iterative process since there are dependencies:  (1) to (4)                                  |
|    (8) check steel and wheat production (adjust density & crop yield)                               |
+-----------------------------------------------------------------------------------------------------+

// August 5th: 2026 : continue the calibration of CCEM v9
   
     (2) Energy 2020 by zone [eTable]:  148.8 total, US 24.22 EU 14.7 CN 36.44  IN 9.2 RW: 64.19
         needed tuning with demat curves to get the right total and distribution 
         expected: 149 PWh total, US 24.19, EU 14.8 CN 36.6 IN 9.09 RW 64.4 
     (3) Energy 2020 by source [tTable]:  Oil: 52.8, Coal: 46.9, Gas: 40, Clean: 9.83
         at first, there too much transfer from Oil and Coal to clean
                    => Play with the Transfer matrix by sector
         expected: Oil 53.6, Coal(extended): 46.6, Gas: 39.06, Clean: 9.72
         WARNING: if we reduce transfer to Clean, we raise the total consumption (bact to (2))
     (4) Energy prices follow the KNU :)
     (5) electricity [elTable]:  27 800 TWh in 2020 is good (cf Google notes)
     (6) & (7) : will do through sensitivity analysis
     (8) steel: 1.88 Gt in 2020, wheat: 0.76 Gt
         expected: wheat production => 2010: 640Mt  2020:767Mt   2030: 840Mt (GPT 5.2)
                   steel production => 2010:1.4Gt   2020:1.9Gt (small COVID hit)   2030:2.1Gt (GPT 5.2)

   // do a complete sensitivity analysis using "rungw9" 
     - h1(green energy)
     - h2(peak oil)   => super intéressant
     - h3 (sensitivity)
     - h4 (substitution)
     - h5 (energy price sensitivty)
     - h6 (dematerialization)
     - h7 (tech to growth)   => shows the cone of CO2 (RoI is hard to forecast)
     - h8 (carbon tax) 
     - h9 (damages)
     - h10 (adaptation)
 
    // NOTE: in a CCEM v9 talk, there should be a slide about sensitivity analysis
    // =========================================================================== 

     // add new sensitivity
        - substitution reduced by price gaps -> h4r   -> done ! works well
        - aiReplaceFactor (China) -> h5a

// August 6th : New fossil energy reserves based on GPT5 (see "EnergyMatrix.xlsx")
    (a) play with GPT5 to understand the known reserves of Oil, at the current price
        -> key table         proven      forecast  
             30$             1000        500
             60$             2000        3000
             120$            2900        4100
            
             default = proven + X% foreast, so that peak oil is 2040 => X=40% looks good
             h2- = proven
             h2+ = proven + forecast (was defalt, but is too far from consensus)
    (b) redo the tuning : protocol and rungw9 (sensitivity analysis) 

// WE CLOSE AND MOVE TO G2WS ===========================================================================
// MOVE TO CLSERVE directory (excellent README)

   go run clserve.go plotter.go
   ----------------------------
   - make sure that gw9 works ... uncomment the "autoload" in init.cl
   - it works !!! see on http://localhost:8080/start

August 7th:
  - decision sur pain = AI replace factor * (1 - socialExpenseRatio[y]) 
    on ignore la valeur dynamique (qui dépend de active) qui va perturber
  - coder les nouveaux éléments du UI (fichier web.cl)
    ==================================================
     (1) sliders : nouveau setup
     ---------------------------
          - Setup a 4 sliders: deux globaux et deux par zone
              globaux: EnergyDensity, PopulationImpact (actually, c.populationFactor is local)
              locaux: TechEfficiency, CBAM
          - AIreplaceFactor remplace CBAM dans les locaux
          - pattern.html: replace CBAM by AIreplaceFactor
          - plotter.go: (setup section has now four sliders)
          - run a test

August 8th:
     (1) learn to write the slider values in the setup text window
        - must use a template to setup the text
        - write a new function in web.cl produce a string representing the slider values
          note that in the go world, we have svalue and evalue for the 16 sliders no matter what
     (2) inputs
          - energy (by Supplier) est par zone, ainsi que transition
     (3) outputs
          - new : schéma cummulatif qui explique la pain en 4 composants
          - new : population par zone : total, active, age moyen
          - new : cummulatf economy par zone : GDP, damageloss, energyLoss, productivityLoss
                  note: current energy becomes "World Energy"
          - par zone: economy,population,pain

August 9th:
   - implement Store.zones that is used in listSliderValues()  [web.cl]
   - added c.tactic.roiAdjustment in model.cl and game.cl to allow for a dynamic adjustment of the RoI (see the PPT)
   - run and check the new UI (slider, charts, config window)
   - added the two global sliders (EnergyDensity, PopulationImpact) to the knus (8 values)
   - make aiReplaceFactor a slot for c.tatic (initialized with c.aiReplaceFactor)
   - test gw9+ : webtest() is OK

August 10th:
  - check the sizes of slider value list in plotter.go (use NKNUS and NTACTICS)
    add proper references to CCEM Web page + check order (slider index = index in svalues)

August 11th:  
  - added servertest()
  - zone specific menus are now OK
  - putConfig handler 
       - added the hidden text field in the "PutConfig" button + clickPutConfig() in pattern.html
       - to be continued: implement writeSliderValues
  - run the interpreted clserve: go run clserve.go plotter.go

August 12th: 
  - check the UI
  - fixed bugs with input/output charts
  - removed some oscillations in the charts : pain, policies (energy)
  - tune pain for AI replacement and warming
  start working on g2ws.go (compiled version of clserve.go)
  - compile gw9 and check the consistency of results using go run g2ws.go plotter.gog2w
     => create claire4.1.18 because of stupid float compiling error (12.0 -> 12)


August 13th:
  - create a web page title that is a go variable
  - go run g2ws.go plotter.go: remove bugs & check g2ws.go for new sliders

August 14th:
  - create a Web page on the CCEM Web site to explain the new sliders and their meaning
            - each explanation must be described in the CCEM Web site
  - use c.economy.sobriety to compute KPI = sobriety%
  - KEY DESIGN DECISION: run(simulation) with no change is idempotent
     => we do not manage AIreplacement at the World level, only the zone
     => webtest() checks that the simulation is idempotent 
     - KEEP LOOKING FOR THE CAUSE with writeKnuValuesDebug 
  - identify interesting scenarios (see the PPT) for the Fellows

August 15th: 
  move to JavaScript compilation and test with cldemo.go (?)
        (a) javascript compilation (independant): claire4 -m c2j -m sgw9
            jcompile(sgw9)  -> sgw9.js
            needed to add Equal and F_BELONG to ClaireKernel.js
        (b) javascript compilation in browser mode
            bcompile(g2ws9)  -> g2ws9.js
        (c) test with cldemo.go 
            - rebuild g2ws.html qui doit ressembler à pattern.html (position des charts et sliders)
            - rebuild g2ws.js qui contient la logique du serveur (plotter.go)
            - copy ClaireKernel.js et sgw9.js dans le répertoire de g2ws.html
              Warning : the end of ClaireKernel.js must be removed (BROWSER compilation mode)
            - go run cldemo.go + http://localhost:8060/
              note: Shift + Command + R is necessary to reload :)
        
        
August 16: debug G2WS :)
  - the server is OK (loads the first page, sliders are reactive)
  - implement get/putConfig in g2ws.js
  - implement Zone Chart menu customization
  - need a diet version of put -> fix the code in web.cl 
    -> run in CLAIRE then in Javascript

August 17: debug G2WS :)
  - play with all features: zones, charts, sliders, config window
  - fix zones and add the change of name in the chart menu (see web.cl)
    => implies to addopt List as as structure for PlotsTag1&2 + clean
    >>>>>>>>>> FIX THE BUG : do not see the zone chart !!!!
  - 

August 18-21: keep debug G2WS
  - Zone Charts now work - we need to reset the menu when we change zone, because of the dynamic name changes
  - add a global variable THISYEAR = 2026 that says when Zone tactics are applied + RoI adjustment
  - add a birthrate (per 1000) curve to the population chart
  - added a MAXCANCEL = 3 factor to move up to 5% reduction  (test with h3e scenario)
  - big Bug: MaxTransferRate is multiplicative
       [applyMaxGrowthRate(w1:Percent, w2:Percent,s1:Supplier,s2:Supplier, y:Year) : Percent
         ->  w1 + (w2 - w1) * maxTransferRate(s2,y) * priceDeltaRate(s1,s2,y) ] 
         both maxTransferRate and priceDeltaRate are attenuators from 0% to 100% (ADDED the 100% max !!)
         maxtransferRate is such that the sum of all transfers is less than s.growthPotential
  - old bug in plotterEngine.js = move the mouse -> check we are in an active canvas

  // interesting note:
  //    - go run clserve.go plotter.go  is good for debugging the UI
  //    - go run g2ws.go plotter.go is good for the values of the curves (REPL available + fast simulation)
  //    - go cldemo.go is good for doing what-if 

  August 22-23 (last week-end ?)
     - created an independant Web project ready for upload on tiiny.com & upload to the web (see Google doc CCEM/G2WS Web)
     - transition acceleration default is 50% 
     - green growth has been recalibrated from IRENA data (input2010.cl)
     - updated the CCEM v9 PPT  
     - wrote a one page summary of CCEM v9 for the Web site (News section)
     - calibrated evalues (in plotter.go / g2ws.js) to get the right values when we start versus if we toggle the sliders
       only 3 values: fossil energy, clean energy max and damage impact at +3C
   
  

  // TODO
     - extract simulation results for the Fellows presentation
     - write an update of the tutorial on CCEM Web site
     - feedback from the Pierre Haren group
     - small improvements in the UI & debug from playing with the sliders: 
        - smaller arrows on charts
        - demat max at -2%
        - 
  
// ============================= closed on September XXXX ============================================================     

// BACKLOG for CCEM v10
    - created APFv10 : ActivePopulationFactor = 1 - (young + senior) / population  => if used in maxout, we need to recalibrate
         (a) save current config
         (b) retune on GDP x Zones X 2020,2030,2050
         (c) requires to redo the data mining with credible data for active population (see microModel)
    - each Experiment could have an optional post-condition that is a test.
      for instance h1- should have a max growth rate for clean energy of 0.2
      (1) we will need to have access to the default results
          -> use file : for h0, write the default results in this file (defaultResultsv9.cl)
            if different, reads the default results so that we can compare
      (2) use this for testing !!! rungw9 should spit big error messages if the post conditions are not met
   
   









