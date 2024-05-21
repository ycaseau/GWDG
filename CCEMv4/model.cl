// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
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
// *    Part 5: Experiments                                           *
// ********************************************************************

TALK:integer :: 1
DEBUG:integer :: 5

Version:float :: 0.4            // started on July 5th, 2022
NIT:integer :: 200              // number of years
NIS:integer :: 1000              // number of price sample points
PMAX:integer :: 10000            // max price for a TEP (to be tuned)

Year :: integer                 // time is in year
Percent :: float
Price :: float                  // price is in dollars
Energy :: float                 // energy is in GTep

// we use a relative index that sarts at 1 for 2010
year!(i:Year) : integer -> (2009 + i)
yearF(i:Year) : float -> float!(2009 + i)

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
    capacityMax:Energy,     // the max capacity when we start
    price:Price,            // price for 1 Tep
    sensitivity:Percent,       // price where prod grows from pmin
    investPrice:Price,            // price in T$ to add one GToe per year capaciy
    co2Factor:Percent,            // mass of carbon in one Tep of this energy
    co2Kwh:float,                 // carbonization of this energy (ratio used in Shapes)
    from:list<Transition>,        // transition that moves to this energy
    steelFactor:Percent,          // part of steel cost in investPrice
    horizonFactor:Percent = 110%, // where we want the capacity to be versus market needs
    // simulation data
    outputs:list<Energy>,         // prod level for each year
    sellPrices:list<Price>,       // prices (for one Tep)
    gone:Energy,                  // total cummulative consumption
    added:Energy,                 // total addition through substitution (cummulative)
    additions:list<Energy>,       // additions through susbtitution (added is the cummulated sum)
    netNeeds:list<Energy>,        // keep track of needs (without savings nor substitution)
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
    growthPotential:Affine)       // max(delta(capacity) in GTep) is a function of "avgMin" price
   

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
  tag:string                     // when we want to print
)

// create a transition (used in test.cl)
[makeTransition(name:string,fromIndex:integer,toIndex:integer) : void
 -> let tr := Transition(index = 1 + length(pb.transitions), from = supplier!(fromIndex), to = supplier!(toIndex), tag = name) in
      (pb.transitions :add tr,
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
  -> x * 41.86 ]
  
// transforms a Gt of oil equivalent into TWh (Tera Watt Hour)
[TWh(x:float) : float
  -> x * 11630 ]

// ********************************************************************
// *    Part 2: Consumer Blocs                                        *
// ********************************************************************

Economy <: thing
Block <: Economy

// each bloc is a group of countries (BRIC, USEurope, ...)
Consumer  <: thing(
    index:integer = 1,                //
    consumes:list<Energy>,            // consumption at start point
    // discountPrices:list<Percent>,     // local producers get a price discount (would be used if M4 is geography based)
    carbonTax:ListFunction,                 // carbonTax as a  function of PPM CO2: price in $ / T carbon
    // the behaviour is the defined with 3 cummulative curves
    cancel:Affine,                    // percentage of energy consumption that stops (fct of price)
    cancelImpact:Affine,              // percentage of economic value loss as a function of energy missing (%)
    marginImpact:Affine,              // impact on margin (cancelImpact is the share, marginImpact is a correction factor for what is not lost)
    saving:Affine,                    // percentage that is saved (policy, expressed as a function of years)
    subMatrix:list<Affine>,           // substitution of one enery form to to the next : expected % as a function of years
    population:Affine,                // pop growth model
    popEnergy:Percent,                // proportion of energy consumption linked to pop size
    // v3: M5 -> redirection parameters (not active yet)
    taxFromPain:Percent = 0%,           // 100% (pain) -> X% of carbon tax growth
    cancelFromPain:Percent = 0%,        // 100% (pain) -> X% of additional cancellation (redirection)
    redistributeFromPain:Percent = 0%,  // 100% (pain) -> X% of redistribution (redirection)
    disasterLoss:Affine,               // % of resource (Human, factories, argriculture) lost to GW
    economy:Block,                      // v4: economy is split by block
    // simulation data ----------------------------------------------------
    startNeeds:list<Energy>,            // original needs
    needs:list<list<Energy>>,           // depends on the economy (N - 1)
    consos:list<list<Energy>>,          // quantity that is consumed per type
    cancel%:list<list<Percent>>,         // cancellation because of price
    savings:list<list<Energy>>,         // savings - neutral in GDP output
    substitutions:list<list<Energy>>,   // Dirty to clean substitution : NxN-1/2 valuse - actual quantity transfered 
    transferRates:list<list<Percent>>,   // Dirty to clean substitution : NxN-1/2 valuse - STORE substitution ratio !
    carbonTaxes:list<Price>,            // amount of tax (T$)
    painLevels:list<float>,             // record level of pain for each year
    painEnergy:list<float>,             // record level of pain for each year due to Energy loss
    painWarming:list<float>,            // record level of pain for each year due to warming
    painResults:list<float>,            // record level of pain for each year due to poor results
    redistribution:Percent = 0%,        // mitigate the effects of GDP variation or Energy shortages
    taxAcceleration:Percent,            // accelerate carbon tax because of political pressure
    cancelAcceleration:Percent)         // cancel (renonce some form of products/services because of its energy form) 
   
// find a consumer by its index
C(i:integer) : Consumer -> some(c in Consumer | c.index = i)


// note: c.savings and c.substitution can only increase in a monotonic manner


// ********************************************************************
// *    Part 3: Economy and Strategies                                *
// ********************************************************************

// in v0.1 we keep one global economy
// i.e. the consumers are all aggregated into one
Economy <: thing(
   gdp:Price,                   // T$
   investG:Price,               // T$
   investE:Price,               // investments into green tech, including nuke (worldwide)
   iRevenue:Percent,            // part of revenue that is investes
   ironDriver:Affine,           // iron intensity in GDP (energy / $) in time
   // simulation data
   totalConsos:list<Energy>,      // energy consumption (all suppliers)
   cancels:list<Energy>,          // cancellation of consumption because of price
   inputs:list<Energy>,                 // includes savings : higher number
   maxout:list<Price>,                  // what we would produce without cancellation
   results:list<Price>,                 // world gdp
   investGrowth:list<Price>,
   investEnergy:list<Price>,
   disasterRatios:list<Percent>,        // record the loss of production due to global warming disasters
   lossRatios:list<Percent>,            // record the loss of production due to cancellation
   ironConsos:list<Price>,
   marginImpacts:list<Percent>)        // book-keeping the loss of margin -> impact Invest

// we create World as the global economy (sum of block)
WorldEconomy <: thing(
   all:Economy,                   // world economy: sum of all blocks
   // factors that describe the world economy worldwide
   techFactor:Percent,            // improvement of techno, annual rate (currently only applies to energy)
   crisisFromPain:Percent = 0%,   // 100% (pain) -> X% of economic ineficiencies  (up to war)
   energy4steel:Affine,           // energy needed to produce 1 ton of steel
   steelPrice:Price,              // price of steel (in $/ton)
   // agro model (wheat production)
   wheatProduction:float,         // in giga tons
   agroLand:float,                // millions of km2
   landImpact:Affine,             // land needed to produce 1 MWh of clean energy
   lossLandWarming:Affine,              // loss of agriculture land due to warming
   agroEfficiency:Affine,        // efficiency of agriculture (as a function of energy price)
   bioHealth:Affine,        // health of biosystem (as a function of CO2)   
   cropYield:Affine,        // productivity through science & best practice (as a function of time)
   // Simul output
   steelPrices:list<Price>,
   agroSurfaces:list<float>,
   energySurfaces:list<float>,
   wheatOutputs:list<float>      // table per year, in giga tons
   )

// code is cleaner if we call the economy of a Consumer a Block
Block <: Economy(
  describes:Consumer,              // each Block is associated 
  dematerialize:Affine,             // energy-de-densification, as function of time
  roI:Affine,                       // how much GDP an investment produced (Percent = f(time))
  openTrade:list<Percent>)         // represent trade barriers from other zones to c (decided by c)

(economy.inverse := describes)


// a strategy is a GTES (game theory) description of the player
Strategy <: thing(
  from:Consumer,
  // goals
  targetGdp:Percent,
  targetCO2:float,
  targetPain:float,
  weightGDP:Percent,
  weightCO2:Percent
  // tactic is what gets optimized to achieve goals
  // tbc: how to set CO2 tax, how to set barriers (with CO2 emmiting), 
  // how to regulate energy transition, how to accelerate Cancel
)

// ********************************************************************
// *    Part 4: Gaia                                                  *
// ********************************************************************

// there is only one earth :)
Earth <: thing(
    co2PPM:float,                      // qty of CO2 in atmosphere (ppm)
    co2Add:float,                      // millions T (carbon) added each year by humans
    warming:Affine,                    // global warming = f (CO2)
    avgTemp:float,                     // average world temperature when simulation starts
    avgCentury:float,                  // 20th century average, used as a reference point
    co2Ratio:float,                    // fraction of emission over threshold that gets stored
    co2Neutral:float,                  // level of emission that does not cause an increase
    painProfile:list<Percent>,        // three coefficients for warming, cancel and GDP(mat & immat)
    painClimate:StepFunction,          // level of pain (%) in function of CO2
    painGrowth:StepFunction,           // level of pain (%) as a function of GDP growth
    painCancel:StepFunction,           // Energy "shortage" (cancelation because of price) yields pain (cancel level -> pain%)
    // simulation
    co2Emissions:list<float>,
    co2Levels:list<float>,
    temperatures:list<float>,
    gdpLosses:list<float>) 
    

// ********************************************************************
// *    Part 5: Experiments                                           *
// ********************************************************************


// our problem solver object
Problem <: thing(
  comment:string  = "default scenario",                 // useful for scenarios
  world:WorldEconomy,
  earth:Earth,
  transitions:list<Transition>,
  trade:list<list<Percent>>,      // list of export flows as % of GDP
  year:integer = 1,               // from 2 to 100 :)
  oil:Supplier,                   // reference energy for cancel/subst/
  clean:Supplier,
  priceRange:list<Price>,         // v0.1= dumb - a discrete list of prices - to solve is to minimize
  debugCurve:list<Energy>,        // qty of energy produced as a function of the price
  prodCurve:list<Energy>,         // qty of energy produced as a function of the price
  needCurve:list<Energy>)         // qty of energy required as a function of price

pb :: Problem()

// utilities ------------------------------------------------------------------


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

     
sum(l:list[float]) : float
 => (let x := 0.0 in (for y in l x :+ y, x))

// makes float! a coercion (works both for integer and float)
[float!(x:float) : float -> x]



