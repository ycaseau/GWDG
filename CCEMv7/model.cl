// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2025 Yves Caseau                        *
// *       file: model.cl                                             *
// ********************************************************************

// this file contains the data model for the GWDG simulation project
// this is the code that was produced in 2009 : it does not include the 
// feedback loop (only feedback = CO2 tax as a function of CO2 for each block)
// this code is shared on GitHub

// ********************************************************************
// *    Part 1: Supply side: Energy production                        *
// *    Part 2: Consumer Blocs                                        *
// *    Part 3: Energy                                                *
// *    Part 4: Gaia                                                  *
// *    Part 5: KNUs (Key Known Unknowns)                             *
// *    Part 6: Charts & Experiments                                           *
// ********************************************************************

TALK:integer :: 1
DEBUG:integer :: 5

Version:float :: 0.7            // started on March 23rd, 2025
NIT:integer :: 100              // number of years
NIS:integer :: 5000              // number of price sample points
PMIN:integer :: 4                // min price for a MWh (to be tuned)
PMAX:integer :: 860              // max price for a  MWh (to be tuned)

Year :: integer                 // time is in year (1 .. Max)
Percent :: float
Price :: float                  // price is in dollars
Energy :: float                 // energy is in PWh

// we use a relative index that sarts at 1 for 2010
year!(i:Year) : integer -> (2009 + i)
yIndex(i:integer) : Year -> (i - 2009)
yearF(i:Year) : float -> float!(2009 + i)

// transforms a Gt of oil equivalent into PWh
[PWh(x:float) : float
   -> x * 11.6]

// transforms a price per Tep into a price per MWh
[perMWh(x:float) : float
    -> x / 11.6]

// list of measures 
Tmeasure :: list<measure>
// creates a Teasure of size y
[makeTmeasure(x:integer) : Tmeasure
  -> list<measure>{measure() | n in (1 .. x)}]

// forward definition of charts
Charts <: object()
ChartsEarth <: Charts
ChartsSupplier <: Charts
ChartsConsumer <: Charts

// ********************************************************************
// *    Part 1: Supply side: Energy Production                        *
// ********************************************************************

// we need to manipulate simple curves - in version 0.3 we use both step- and  piece-wise linear
// functions, defined by a list of pairs (x,f(x))
ListFunction <: object(
  xValues:list<float>,
  yValues:list<float>,
  minValue:float = 0.0,
  maxValue:float = 0.0,
  n:integer = 0)

// StepFunction is the simplest
StepFunction <: ListFunction()

// Affine uses a linear interpolation  
Affine <: ListFunction()

// assumes l is a list of pairs (x-i,y-i) and x-i is a strictly increasing sequence
[affine(l:listargs) : Affine
  -> let m1 := 1e9, M1 := -1e9,
         l1 := list<float>{float!(x[1]) | x in l},
         l2 := list<float>{float!(x[2]) | x in l} in
       (for i in (2 .. length(l)) (if (l1[i - 1] >= l1[i]) error("affine params decrease: ~S",l1)),
        for v in l2 (m1 :min v, M1 : max v),
        Affine(n = length(l), minValue = m1, maxValue = M1,
               xValues = l1, yValues = l2)) ]

// same code for StepFunction
[step(l:listargs) : StepFunction
  -> let m1 := 1e9, M1 := -1e9,
         l1 := list<float>{float!(x[1]) | x in l},
         l2 := list<float>{float!(x[2]) | x in l} in
       (for i in (2 .. length(l)) (if (l1[i - 1] >= l1[i]) error("step function params decrease: ~S",l1)),
        for v in l2 (m1 :min v, M1 : max v),
        StepFunction(n = length(l), minValue = m1, maxValue = M1,
                     xValues = l1, yValues = l2)) ]

[self_print(x:ListFunction) : void
  -> printf("~S(~I)",x.isa,
        for i in (1 .. x.n)
          (if (i != 1) princ(" "),
           princ(x.xValues[i],2),princ(":"), princ(x.yValues[i],2))) ]

Transition <: object

// an energy supplier is defined by its inventory and the way it can be brought
// to market (price-wise = strategy & production-wise = constraints)
Supplier <: thing(
    index:integer = 1,      // used for arrayed access
    production:Energy,      // current level of production
    capacityMax:Energy,           // the max capacity when we start
    price:Price,                  // price for 1 Tep
    sensitivity:Percent,          // price where prod grows from pmin
    investPrice:Price,            // price in T$ to add one GToe per year capaciy
    co2Factor:Percent,            // mass of carbon in one Tep of this energy
    co2Kwh:float,                 // carbonization of this energy (ratio used in Shapes)
    from:list<Transition>,        // transition that moves to this energy
    steelFactor:Percent,          // part of steel cost in investPrice
    heat%:Percent,                // part of the energy that is used for direct heat vs electricty (1 - elec%, as defined in CCEM paper)
    capacityFactor:Percent = 110%, // where we want the capacity to be versus market needs
    techFactor:Percent,            // improvement of techno, annual rate (currently only applies to energy)
    // simulation data
    charts:ChartsSupplier,         // chart for this supplier
    outputs:list<Energy>,         // prod level for each year
    sellPrices:list<Price>,       // prices (for one Tep)
    gone:Energy,                  // total cummulative consumption
    addedCapacity:Energy,          // total addition through substitution (cummulative)
    addedCapacities:list<Energy>,   // total capacity added (yearly log for easy debug)
    additions:list<Energy>,       // additions through susbtitution (added is the cummulated sum)
    netNeeds:list<Energy>,        // keep track of needs (without substitution)
    capacities:list<Energy>)   // keep track of max capacity

// two subclasses with two capacity model
// This is the regular one for fossile fuels : finite inventory = f(price)
FiniteSupplier <: Supplier(
    inventory:Affine,           // inventory is a function of "avgMin" price
    capacityGrowth:Percent,    // rate of growth (annually) of the max capacity
    threshold:Energy,          // threshold inventory : reduce capacity proportionally when inventory(p) is less than threshold
    // simulation data
    inventories:list<Energy>)     // a useful trace for debug: level of known inventory
   
// new in GW3: infinite energy model where the potential of new capacity depends on the price
InfiniteSupplier <: Supplier(
    growthPotential:Affine)       // max(delta(capacity) in PWh) is a yearly roadmap (does not only depend on price but volume effects)
   

// access to a supplier from its index - ugly but faster than "exists(s in Supplier ...)"
[supplier!(i:integer) : Supplier 
  -> let n := size(FiniteSupplier) in
        (if (i <= n) FiniteSupplier.instances[i]
         else InfiniteSupplier.instances[i - n]) ]

// in GW3 we create transition objects (s1 -> s2) to make the code easier to read !
Transition <: object(
  index:integer = 1,             // i = 1 to N x (N - 1)/2
  from:Supplier,                 // transition from s1 ...
  to:Supplier,                   // to s1
  efficiency%:Percent = 100%, 	 // CCEMv7 - when we transition to electricity we need less primary energy
  heat%:Percent,                 // part of the energy that is still used for direct heat vs electricty  (1 - elec%)
  adaptationFactor:Percent = 0%,       // adaptation cost to add to investment (60% to 120%)
  tag:string                     // when we want to print
)

// create a transition (used in test.cl)
[makeTransition(name:string,fromIndex:integer,toIndex:integer,h%:Percent,e%:Percent,a%:Percent) : void
 -> let tr := Transition(index = 1 + length(pb.transitions), from = supplier!(fromIndex), to = supplier!(toIndex), tag = name) in
      (pb.transitions :add tr,
       tr.heat% := h%,
       tr.efficiency% := e%,
       tr.adaptationFactor := a%,
       supplier!(fromIndex).from :add tr)]

[self_print(x:Transition)
   -> printf("(~S->~S):~A",x.from,x.to,x.index)]

// finds a transition
[getTransition(s1:Supplier,s2:Supplier) : Transition
  -> let x := some(tr in s1.from | tr.to = s2) in
    (case x (Transition x, any error("no transition exists from ~S to ~S",from,to)))
]

// tranforms a Gt of oil equivalent into EJ (Exa Joule)
[EJ(x:float) : float
  -> (x / 11.6) * 41.86 ]
  
// transforms a Gt of oil equivalent into TWh (Tera Watt Hour)
[TWh(x:float) : float
  -> x * 11630 ]

// ********************************************************************
// *    Part 2: Consumer Blocs                                        *
// ********************************************************************

Economy <: thing
Block <: Economy
Strategy <: object
Tactics <: object

// CCEM v7 toto: we add an adaptation policy to each Consumer
Adaptation <: object(
    efficiency:Affine,       	      // belief: cost(fraction/domage) -> attenuation (%)
    // computed slots
    investFactor:Percent,           // adaptation investment as a ratio of Energy spending
    spends:list<Price>,             // adaptation spending
    sums:list<Price>,               // cummulative adaptation spending
    levels:list<Percent>,           // adaptation efficiency = attenutation of damages
    losses:list<Price>,             // losses due to damages (in T$)
    gains:list<Price>               // cummulative gains from adaptation
)

// each bloc is a group of countries (BRIC, USEurope, ...)
Consumer  <: thing(
    index:integer = 1,                //
    consumes:list<Energy>,            // consumption at start point
    eSources:list<Energy>,               // electricty propduction (in PWh) by primary sources
    // discountPrices:list<Percent>,     // local producers get a price discount (would be used if M4 is geography based)
    carbonTax:ListFunction,                 // carbonTax as a  function of PPM CO2: price in $ / T carbon
    // the behaviour is the defined with 3 cummulative curves
    cancel:Affine,                    // percentage of energy consumption that stops (fct of price)
    cancelImpact:Affine,              // percentage of economic value loss as a function of energy missing (%)
    maxSaving:Percent,                // max % of energy that can be saved through efficiency investments
    yearlySaving:Percent = 1%,        // max additional % from one year to another 
    subMatrix:list<Affine>,           // substitution of one enery form to to the next : expected % as a function of years (maximum for c)
    population:Affine,                // pop growth model
    popEnergy:Percent,                // proportion of energy consumption linked to pop size
     economy:Block,                      // v4: economy is split by block
    // v3: M5 -> redirection parameters (not active yet)
    tactic:Tactics,                  // redirection parameters
    disasterLoss:Affine,               // % of resource (Human, factories, argriculture) lost to GW
    productivityFactor:Percent = 0%,   // productivity factor (declines as pain grows)
    populationFactor:Percent = 0%,     // population decline factor (pop declines faster as pain grows)
    // v5: we implement redirection through tactical parameters -------------------------------------
    redistribution:Percent = 0%,        // mitigate the effects of GDP variation or Energy shortages
    taxAcceleration:Percent,            // accelerate carbon tax because of political pressure
    cancelAcceleration:Percent,         // cancel (renonce some form of products/services because of its energy form) 
    protectionismFactor:Percent = 0%,    // redirect to protectionism -> compute openTrade percent
    objective:Strategy,                  // the strategy of the block
    adapt:Adaptation,                    // v7: adaptation policy
    // simulation data ------------------------------------------------------------------------------
    charts:ChartsConsumer,              // chart for this consumer
    startNeeds:list<Energy>,            // original needs
    needs:list<list<Energy>>,           // depends on the economy (N - 1)
    consos:list<list<Energy>>,          // quantity that is consumed per type
    sellPrices:list<list<Price>>,       // book-keeping : price with carbon tax
    ePWhs:list<Energy>,                 // quantity of electricity that is produced 
    eDeltas:list<Energy>,               // delta of electricity production (debug)
    co2Emissions:list<float>,           // CO2 emissions
    cancel%:list<list<Percent>>,        // cancellation because of price
    substitutions:list<list<Energy>>,   // Dirty to clean substitution : NxN-1/2 valuse - actual quantity transfered 
    savingRates:list<Percent>,          // saving% - actual level at year y
    savings:list<list<Energy>>,         // savings in PWh - neutral in GDP output - additional efficiency 
    eSavings:list<list<Energy>>,        // keep specific track of savings produced by electrification (v7)
    transferRates:list<list<Percent>>,  // Dirty to clean substitution : NxN-1/2 valuse - STORE substitution ratio !
    transferFlows:list<list<Energy>>,   // record actual quantity transfered for each transition (useful for debug)
    carbonTaxes:list<Price>,            // amount of tax (T$)
    painLevels:list<float>,             // record level of pain for each year
    painEnergy:list<float>,             // record level of pain for each year due to Energy loss
    painWarming:list<float>,            // record level of pain for each year due to warming
    painResults:list<float>,            // record level of pain for each year due to poor results
    savingFactors:list<Percent>,    // record the level of transition for eah year
    transitionFactors:list<Percent>,    // record the level of transition for eah year
    satisfactions:list<float>,          // record level of satisfaction for each year
    cursat:float)                       // current satisfaction (score) -> classical for GTES
   
// find a consumer by its index
C(i:integer) : Consumer -> some(c in Consumer | c.index = i)


// note: c.substitution can only increase in a monotonic manner

// Tactics is a bloc of slots that represent redirection parameters
Tactics <: object(
   tacticFrom:Consumer,
   taxFromPain:Percent = 0%,           // 100% (pain) -> X% of carbon tax growth
   cancelFromPain:Percent = 0%,        // 100% (pain) -> X% of additional cancellation (redirection)
   // redistributeFromPain:Percent = 0%,  // to do later ... 100% (pain) -> X% of redistribution (redirection)
   savingStart:Percent = 0%,           // minlevel of Energy saving
   savingFromPain:Percent = 0%,        // 100% (pain) -> X% of additional saving (redirection)
   transitionStart:Percent = 100%,      // minlevel of Energy transition
   transitionFromPain:Percent = 0%,   // accelerate the transition to clean energy
   protectionismStart:Percent = 0%,     // minlevel of
   protectionismFromPain:Percent = 0%,  // 100% (pain) -> X% of protectionism (adds trade barriers or CMAM to reduce imports)
   adaptMax:Percent = 20%,              // max level of adaptation
   adaptStart:Percent = 0%,            // minlevel of adaptation
   adaptFromPain:Percent = 0%)         // 100% (pain) -> X% of adaptation spending

(tacticFrom.inverse := tactic)

// prints a tactics
[self_print(x:Tactics) : void
  -> printf("Tactics(~S)",x.tacticFrom) ]
  
// ********************************************************************
// *    Part 3: Economy and Strategies                                *
// ********************************************************************

// in v0.1 we keep one global economy
// i.e. the consumers are all aggregated into one
Economy <: thing(
   gdp:Price,                   // T$
   startGrowth:Percent,         // initial growth rate
   investG:Price,               // T$
   investE:Price,               // investments into green tech, including nuke (worldwide)
    iRevenue:Percent,            // part of revenue that is investes
   ironDriver:Affine,           // iron intensity in GDP (energy / $) in time
   // simulation data
   totalConsos:list<Energy>,      // energy consumption (all suppliers)
   cancels:list<Energy>,          // cancellation of consumption because of price
   inputs:list<Energy>,                 // higher number than consos because of substitution ??
   maxout:list<Price>,                  // what we would produce without cancellation
   results:list<Price>,                 // world gdp
   investGrowth:list<Price>,
   investEnergy:list<Price>,
   investTransition:list<Price>,               // debug (to remove later) : investments into transition
   investCapacity:list<Price>,               // debug (to remove later) : investments into capacity
   disasterRatios:list<Percent>,        // record the loss of production due to global warming disasters
   lossRatios:list<Percent>,            // record the loss of production due to cancellation
   ironConsos:list<Price>,
   reducedImports:list<Price>,          // book-keeping the loss of imports because of protectionism
   marginImpacts:list<Percent>)        // book-keeping the loss of margin -> impact Invest

// we create World as the global economy (sum of block)
WorldClass <: thing(
   all:Economy,                   // world economy: sum of all blocks
   // factors that describe the world economy worldwide
   energy4steel:Affine,           // energy needed to produce 1 ton of steel
   steelPrice:Price,              // price of steel (in $/ton)
   inflation:Percent = 1.7%,      // inflation rate when we want a GDP in current dollars
   decay:Percent = 0%,            // decay of GDP (as a function of time)
   adaptGrowthLoss:Percent,       // faction of adaptation that reduces the growth invest
   // agro model (wheat production)
   wheatProduction:float,         // in giga tons
   agroLand:float,                // millions of km2
   landImpact:Affine,             // land needed to produce 1 MWh of clean energy
   lossLandWarming:Affine,              // loss of agriculture land due to warming
   agroEfficiency:Affine,        // efficiency of agriculture (as a function of energy price)
   bioHealth:Affine,        // health of biosystem (as a function of CO2)   
   cropYield:Affine,        // productivity through science & best practice (as a function of time)
   // two factors that show the impact of trade barriers (they could be zone dependent in the future) + a control factor 
   protectionismInFactor:Percent = 50%,       // If an importing country decides to stop an import, it may source elsewhere but at higher cost and not completely
   protectionismOutFactor:Percent = 100%,     // If an exporting country looses an export, it has ripple effects, but it can also be sold elsewhere
   protectionismFactor:Percent = 50%,         // CCEM v7: new control parameter
   // Simul output
   steelPrices:list<Price>,
   agroSurfaces:list<float>,
   energySurfaces:list<float>,
   wheatOutputs:list<float>      // table per year, in giga tons
   )

// code is cleaner if we call the economy of a Consumer a Block
Block <: Economy(
  describes:Consumer,              // each Block is associated 
  dematerialize:Affine,            // energy-de-densification, as function of time
  roI:Affine,                      // how much GDP an investment produced (Percent = f(time))
  openTrade:list<Percent>,         // represent trade barriers from other zones to c (decided by c)
  tradeFactors:list<list<Percent>>)    // keep track of trade flows import factors

(economy.inverse := describes)

// same index for a block and its economy                      
[index(w:Block) : integer 
  -> w.describes.index]

// a strategy is a GTES (game theory) description of the player
// formula : sat(c) = sigma{y | (1 - discountRate) ^ (y - 1) * sat(c,y)}
//           sat(c,y) = weightCO2 * absR(co2(y) - targetCO2(y)) +                 // expects linear degrowth to netZero
//                      weightGPD * (1 - relR(CAGR(y) - targetGDP(y)) +
//                     + weightPeople * (1 - Pain(y))) }
Strategy <: object(
  stratFrom:Consumer,
  discountRate:Percent,          // discount rate for future benefits
  // goals
  targetCO2:Percent,               // expected carbon emission "adjusted for trade" yearly decrease
  targetGDP:Percent,               // expected CAGR
  weightCO2:Percent,
  weightEconomy:Percent,
  weightPeople:Percent             // the rest is assigned to damages pain
)

(stratFrom.inverse := objective)

// tactic is what gets optimized to achieve goals
//  how to set CO2 tax, how to set barriers (with CO2 emmiting), 
// how to regulate energy transition, how to accelerate Cancel

// constructor for Strategy
[strategy(tCO2:Percent,tGDP:Percent,wCO2:Percent,wEconomy:Percent) : Strategy
  -> Strategy(targetCO2 = tCO2,            // expected NetZero
              targetGDP = tGDP,            // expected CGAR
              weightCO2 = wCO2, 
              weightEconomy = wEconomy, 
              weightPeople = 1 - (wEconomy + wCO2)) ]

// prints a strategy
[self_print(x:Strategy) : void
  -> printf("strategy(CO2:~F%x~F%,Economy:~F%x~F%,Climate:~F%)",
            x.targetCO2,x.weightCO2,x.targetGDP,x.weightEconomy,x.weightPeople) ]


// returns the satisfaction score once the satisfaction vector is computed
[satScore(c:Consumer) : float
  -> let s := 0.0, s2 := 0.0, n := pb.year in 
      (for y in (2 .. n) 
         let discount := (1 - c.objective.discountRate) ^ float!(y - 1) in
        (s :+ discount * c.satisfactions[y],
         s2 :+ discount),
       s / s2) ]

// sets the tactic for a consumer
[tactical(c:Consumer,tStart:Percent,tFromPain:Percent,tCancel:Percent,pStart:Percent,tProtect:Percent,tTax:Percent) : void
  -> c.transitionStart := tStart,
     c.transitionFromPain := tFromPain,
     c.cancelFromPain := tCancel,
     c.protectionismStart := pStart,
     c.protectionismFromPain := tProtect,
     c.taxFromPain := tTax ]

// ********************************************************************
// *    Part 4: Gaia                                                  *
// ********************************************************************

// there is only one earth :)
Earth <: thing(
    co2PPM:float,                      // qty of CO2 in atmosphere (ppm)
    co2Add:float,                      // millions T (carbon) added each year by humans
    co2Cumul:float,                    // cumulated anthropic CO2 (in Gt) in the atmosphere since 1850
    warming:Affine,                    // global warming = f (CO2 concentration)
    TCRE:Affine,                       // alternate model : warming = f (cumul CO2)
    avgTemp:float,                     // average world temperature when simulation starts
    avgCentury:float,                  // 20th century average, used as a reference point
    co2Ratio:float,                    // fraction of emission over threshold that gets stored
    // co2Neutral:float,               // level of emission that does not cause an increase
    painProfile:list<Percent>,        // three coefficients for warming, cancel and GDP(mat & immat)
    painClimate:StepFunction,          // level of pain (%) in function of CO2
    painGrowth:StepFunction,           // level of pain (%) as a function of GDP growth
    painCancel:StepFunction,           // Energy "shortage" (cancelation because of price) yields pain (cancel level -> pain%)
    // simulation
    charts:ChartsEarth,            // chart for the earth
    co2Emissions:list<float>,
    co2Levels:list<float>,
    co2Cumuls:list<float>,
    temperatures:list<float>,
    gdpLosses:list<float>,          // GDP losses because of global warming
    adaptGains:list<float>)        // losses avoided thanks to adaptation 
    


// ********************************************************************
// *    Part 5: KNU (Key Known Unknowns) Storage & Charts             *
// ********************************************************************
 

// here we shall store the original input values that are mofidied by the KNUs
KNUstorage <: thing(
  dematerializes:list<Affine>,
  subMatrices:list<list<Affine>>,
  cancels:list<Affine>,
  roIs:list<Affine>)

 // what we want to record for the Earth
 ChartsEarth <: Charts(
  co2Emissions:Tmeasure,          // CO2 emissions
  co2Levels:Tmeasure,             // CO2 levels
  temperatures:Tmeasure,          // temperature
  gdpLosses:Tmeasure)            // GDP losses

// what we want to record for the Suppliers
ChartsSupplier <: Charts(
  inventories:Tmeasure,           // inventory
  outputs:Tmeasure,            // production
  sellPrices:Tmeasure,                // price
  netNeeds:Tmeasure,                 // net needs
  capacities:Tmeasure)            // capacities

// what we want to record for the Consumers
ChartsConsumer <: Charts(
  needs:Tmeasure,                 // needs in energy (sum of all sources)
  gdp:Tmeasure,                   // GDP
  consos:list<Tmeasure>,          // consumption by energy sources
  carbonTaxes:Tmeasure,             // carbon tax
  cancel%:Tmeasure,               // cancellation
  savings:Tmeasure,               // savings
  painLevels:Tmeasure)            // pain levels
 


// ********************************************************************
// *    Part 6: Experiments                                           *
// ********************************************************************

// our problem solver object
Problem <: thing(
  comment:string  = "default scenario",                 // useful for scenarios
  world:WorldClass,
  earth:Earth,
  transitions:list<Transition>,
  trade:list<list<Percent>>,      // list of export flows as % of GDP
  year:integer = 1,               // from 2 to 100 :)
  oil:Supplier,                   // reference energy for cancel/subst/
  clean:Supplier,
  priceRange:list<Price>,         // v0.1= dumb - a discrete list of prices - to solve is to minimize
  prodCurve:list<Energy>,         // qty of energy produced as a function of the price
  needCurve:list<Energy>,         // qty of energy required as a function of price
  // Useful book-kleeping
  totalInvest:Price,
  totalGrowth:Price,
  totalEInvest:Price)

pb :: Problem()

// an experiment is defined by a specific parametric setup
// experiments are defined in the scenario.cl file
// the outcome of an experiment is a scenario (set of charts)
Experiment <: thing(
  comment:string,           // a tag when we print the results
  init:lambda)              // the initialization function

// utilities ------------------------------------------------------------------

// inflation is a convention for printing a result in CCEM - by default, we use constant 2010 dollars
[gdp$(y:Year) : Price 
    -> gdp$(pb.world.all,y) ]
[gdp$(e:Economy,y:Year) : Price 
    -> e.results[y] * (1.0 + pb.world.inflation) ^ float!(y - 1) ]
[gdp$(c:Consumer,y:Year) : Price 
    -> gdp$(c.economy,y) ]


// returns the value of the affine function for a given point between m and M
[get(a:Affine,x:float) : float
  -> let i := 0 in
       (for j in (1 .. a.n)
         (if (a.xValues[j] > x) break(i := j)),
        if (i = 0) a.yValues[a.n]       // x is bigger than all x Values
        else if (i = 1) a.yValues[1]    // x is smaller than all x value
        else let x1 := a.xValues[i - 1], x2 := a.xValues[i],
                 y1 := a.yValues[i - 1], y2 := a.yValues[i] in
               (y1 + (y2 - y1) * (x - x1) / (x2 - x1))) ]

// this would make gw0 non diet
// [get(a:Affine,x:integer) : float 
//   -> get(a,float!(x)) ]

// returns the value of the step function for a given point between m and M : easier !
[get(a:StepFunction,x:float) : float
  -> let i := 0 in
       (for j in (1 .. a.n)
         (if (a.xValues[j] > x) break(i := j)),
        if (i = 0) a.yValues[a.n]       // x is bigger than all x Values
        else if (i = 1) a.yValues[1]    // x is smaller than all x value
        else a.yValues[i - 1]) ]        // easier for step-wise functions :)

// print a float in fixed number of characters -------------------------------
[fP(x:float,i:integer) : void
  -> if (x < 0.0) (princ("-"),fP(-(x),i - 1))
     else if (x >= 10.0) 
        let n := integer!(log(x) / log(10.0)) in 
           (princ(x,i - (n + 2)),
            if (i = (n + 2)) princ(" "))
     else princ(x,i - 2) ]

// random number generator -------------------------------------------------
[random(a:float,b:float) : float
  ->  if (a > b) error("random(a,b): a must be <= b"),
      let r := float!(random(1000000)) in
        (a + (r * (b - a) / 1e6)) ]

// our sum macro  
sum(l:list[float]) : float
 => (let x := 0.0 in (for y in l x :+ y, x))

// average
average(l:list[float]) : float
  -> (sum(l) / length(l))

// Composed Anual Growth Rate
[CAGR(x1:float,x2:float,n:integer) : float
  -> ((x2 / x1) ^ (1.0 / float!(n)) - 1.0) * 100.0 ]

// makes float! a coercion (works both for integer and float)
[float!(x:float) : float -> x]



