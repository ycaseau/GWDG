// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2022 Yves Caseau                        *
// *       file: model.cl                                             *
// ********************************************************************

// this file contains the data model for the GWDG simulation project
// this is the code that was produced in 2009 : it does not include the 
// feedback loop (only feedback = CO2 tax as a function of CO2 for each block)

// ********************************************************************
// *    Part 1: Supply side: Energy production                        *
// *    Part 2: Consumer Blocs                                        *
// *    Part 3: Energy                                                *
// *    Part 4: Gaia                                                  *
// *    Part 5: Experiments                                           *
// ********************************************************************

TALK:integer :: 1
DEBUG:integer :: 5

Version:float :: 0.3            // started on July 5th, 2022
NIT:integer :: 200              // number of years
NIS:integer :: 1000              // number of price sample points
PMAX:integer :: 6000            // max price for a TEP (to be tuned)

Year :: integer                 // time is in year
Percent :: float
Price :: float                  // price is in dollars
Energy :: float                 // energy is in GTep

year!(i:Year) : integer -> (2010 + i)

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


// an energy supplier is defined by its inventory and the way it can be brought
// to market (price-wise = strategy & production-wise = constraints)
Supplier <: thing(
    index:integer = 1,      // used for arrayed access
    inventory:Affine,       // inventory is a function of "avgMin" price
    production:Energy,      // current level of production
    price:Price,            // price for 1 Tep
    capacityMax:Energy,        // the max capacity is assumed to be proportional to current inventory (f(avg price))
    capacityGrowth:Percent,    // rate of growth (annually) of the max capacity
    sensitivity:Percent,       // price where prod grows from pmin
    savingFactor:float,           // return ratio of energy saving projects at current price
    substitutionFactor:float,     // return ratio of energy subst projects at current price
    co2Factor:Percent,            // mass of carbon in one Tep of this energy
    co2Kwh:float,                 // carbonization of this energy (ratio used in Shapes)
    cancelFactor:Percent,         // some energy (like coal) have accentuated price sensitivity
    // simulation data
    outputs:list<Energy>,         // prod level for each year
    inventories:list<Energy>,     // a useful trace for debug: level of known inventory
    sellPrices:list<Price>,       // prices (for one Tep)
    gone:Energy,                  // total cummulative consumption
    added:Energy,                 // total addition through substitution
    additions:list<Energy>,       // additions through susbtitution (added is the cummulated sum)
    netNeeds:list<Energy>,        // keep track of needs (without savings nor substitution)
    capacities:list<Energy>)   // keep track of max capacity

// access to a supplier from its index
[supplier!(i:integer) : Supplier 
  -> Supplier.instances[i]]

// ********************************************************************
// *    Part 2: Consumer Blocs                                        *
// ********************************************************************

// each bloc is a group of countries (BRIC, USEurope, ...)
Consumer  <: thing(
    index:integer = 1,              //
    consumes:list<Energy>,           // consumption at start point
    carbonTax:Affine,                // carbonTax as a  function of PPM CO2: price in $ / T carbon
    // the behaviour is the defined with 3 cummulative curves
    cancel:Affine,                    // percentage of energy consumption that stops (fct of price)
    saving:Affine,                    // percentage that is saved (at a cost = investment)
    subMatrix:list<Affine>,           // substitution of one enery form to to the next
    popEnergy:Percent,               // proportion of energy consumption linked to pop size
    // v3: M5 -> redirection parameters
    redistribution:Percent = 0%,        // mitigate the effects of GDP variation or Energy shortages
    taxFromPain:Percent = 0%,           // 100% (pain) -> X% of carbon tax growth
    cancelFromPain:Percent = 0%,        // 100% (pain) -> X% of additional cancellation (redirection)
   // simulation data
    startNeeds:list<Energy>,            // original needs
    needs:list<list<Energy>>,           // depends on the economy (N - 1)
    need:Energy,                        // local variable : amount of a given type
    consos:list<list<Energy>>,          // quantity that is consumed per type
    cancels:list<list<Energy>>,         // cancellation because of price
    savings:list<list<Energy>>,         // savings - neutral in PNB output
    substitutions:list<list<Energy>>,   // Dirty to clean substitution : 3 values per year - STORE substitution ratio !
    carbonTaxes:list<Price>,            // amount of tax (T$)
    painLevels:list<float>,             // record level of pain for each year
    taxAcceleration:Percent,            // accelerate carbon tax because of political pressure
    cancelAcceleration:Percent)         // cancel (renonce some form of products/services because of its energy form) 
   
   
// note: c.savings and c.substitution can only increase in a monotonic manner


// ********************************************************************
// *    Part 3: Energy                                                *
// ********************************************************************

// in v0.1 we keep one global economy
// i.e. the consumers are all aggregated into one
Economy <: thing(
   population:Affine,           // pop growth model
   pnb:Price,                   // T$
   investG:Price,               // T$
   investE:Price,               // 50% green
   roI:Percent,                 // 7% growth /year 2004-> 2007
   iRevenue:Percent,            // part of revenue that is investes
   iGrowth:Percent,             // part of growth that is invested
   techFactor:Percent,          // improvement of techno, annual rate
   crisisFromPain:Percent = 0%,        // 100% (pain) -> X% of economic ineficiencies  (up to war)
   // simulation data
   startConso:Energy,        // sum of consumers
   consos:list<Energy>,      // world consumption (actual energy)
   cancels:list<Energy>,     // cancellation of consumption because of price
   inputs:list<Energy>,      // includes savings : higher number
   maxout:list<Energy>,      // what we would produce without cancellation
   results:list<Price>,      // world pnb
   investGrowth:list<Price>,
   investEnergy:list<Price>)


// ********************************************************************
// *    Part 4: Gaia                                                  *
// ********************************************************************

// there is only one earth :)
Earth <: thing(
    co2Total:float,                    // qty of CO2 in atmosphere (ppm)
    co2Add:float,                      // millions T (carbon)
    warming:Affine,                    // global warming = f (CO2)
    avgTemp:float,                     // for fun
    co2Ratio:float,                    // fraction of emission over threshold that gets stored
    co2Neutral:float,                  // level of emission that does not cause an increase
    painClimate:StepFunction,          // level of pain (%) in function of CO2
    painGrowth:StepFunction,           // level of pain (%) as a function of GDP growth
    painCancel:StepFunction,           // Energy "shortage" (cancelation because of price) yields pain (cancel level -> pain%)
    // simulation
    co2Emissions:list<float>,
    co2Levels:list<float>,
    temperatures:list<float>)


// ********************************************************************
// *    Part 5: Experiments                                           *
// ********************************************************************


// our problem solver object
Problem <: thing(
  comment:string  = "default scenario",                 // useful for scenarios
  economy:Economy,
  earth:Earth,
  year:integer = 0,               // from 1 to 100 :)
  oil:Supplier,                     // reference energy for cancel/subst/savings
  priceRange:list<Price>,         // v0.1= dumb - a discrete list of prices - to solve is to minimize
  debugCurve:list<Energy>,        // qty of energy produced as a function of the price
  prodCurve:list<Energy>,         // qty of energy produced as a function of the price
  needCurve:list<Energy>)         // qty of energy required as a function of price

pb :: Problem()

// utilities ------------------------------------------------------------------

sum(l:list[float]) : float
 => (let x := 0.0 in (for y in l x :+ y, x))

// makes float! a coercion (works both for integer and float)
[float!(x:float) : float -> x]


// no longer needed for claire 4 !
// [abs(x:float) : float -> (if (x >= 0.0) x else -(x)) ]
// [sqr(x:integer) : integer -> x * x]
