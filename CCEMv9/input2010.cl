// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2025 Yves Caseau                        *
// *       file: input80.cl - version GWDG 0.8                          *
// ********************************************************************

// this file contains a simple description of our problem scenario
// this is the "origin - 2010" version - extended to the 2200 horizon

(printf("--- load Global Warming Dynamic Games input2010.cl -- \n"),
 ORIGIN := 2010)

// ********************************************************************
// *    Part 1: Problem description : Energy                          *
// *    Part 2: Consumers and Economies                               *
// *    Part 3: KNU definitions                                       *
// *    Part 4: Miscelaneous (go)                                     *
// ********************************************************************

// ********************************************************************
// *    Part 1: Problem description : Energy                          *
// ********************************************************************

// ------ energy supply data ------------------------------------------------------

// energy production by zone and source (read from the excel file: EnergyMatrix.xlsx)
EUenergy2010 :: list<Energy>(6.87,3.34,4.23,1.51)
USenergy2010 :: list<Energy>(9.8,6.51,6.4,1.32)
CNenergy2010 :: list<Energy>(5.2,20.46,1.08,0.86)
INenergy2010 :: list<Energy>(1.84,3.45,0.545,0.17)
RWenergy2010 :: list<Energy>(24.29,10.35,19.25,3.03)

// Four Key constants from the data reseach
// All data come from "Our World in Data" and are in PWh
Oil2010 :: (USenergy2010[1] + EUenergy2010[1] + CNenergy2010[1] + INenergy2010[1] + RWenergy2010[1])                 // 53.6 in 2020
Coal2010 :: (USenergy2010[2] + EUenergy2010[2] + CNenergy2010[2] + INenergy2010[2] + RWenergy2010[2])                 // 43.6 in 2020
Gas2010 :: (USenergy2010[3] + EUenergy2010[3] + CNenergy2010[3] + INenergy2010[3] + RWenergy2010[3])                 // 31.06 in 2020
Clean2010 :: (USenergy2010[4] + EUenergy2010[4] + CNenergy2010[4] + INenergy2010[4] + RWenergy2010[4])                 // 3.01 in 2020
//   total : 83 PWh in 2010                 -> 149 PWh in 2020 (actually 2019 becvause of COIVID)

// yearly growth capacity for each energy source
OilMaxGrowth :: 6%
CoalMaxGrowth :: 4%
GasMaxGrowth :: 5%
CleanMaxGrowth :: 8%

// read from our world in data: electricity from fossil sources (cf "EnergyMatrix.xlsx")
// LIST : Oil, Coal, Gas, Clean
USeSources2010 :: list<Energy>(0.047, 1.847, 0.987, 1.322)
EUeSources2010 :: list<Energy>(0.152, 0.701, 0.587, 1.507)
CNeSources2010 :: list<Energy>(0.034, 3.233, 0.077, 0.863)
INeSources2010 :: list<Energy>(0.011, 0.642,0.118, 0.166)
RWeSources2010 :: list<Energy>(0.83, 1.982, 2.935, 3.028) 

// ElectrictySources (total 8452 TWh in 1980)
EfromOil2010 :: (USeSources2010[1] + EUeSources2010[1] + CNeSources2010[1] + 
                 INeSources2010[1] + RWeSources2010[1])          // total = 1074 TWh in 2010
EfromCoal2010 ::  (USeSources2010[2] + EUeSources2010[2] + CNeSources2010[2] + 
                   INeSources2010[2] + RWeSources2010[2])        // total = 8405 TWh in 2010
EfromGas2010 ::  (USeSources2010[3] + EUeSources2010[3] + CNeSources2010[3] + 
                  INeSources2010[3] + RWeSources2010[3])           // total = 4704 TWh in 2010
EfromClean2010 :: (USeSources2010[4] + EUeSources2010[4] + CNeSources2010[4] + 
                   INeSources2010[4] + RWeSources2010[4])          // total = 6886 TWh in 2010

// this needs to be rebuilt in CCEM v8 since prices were wrong -  ALWAYS THE CURRENT/CONSTANT dollars trap
// we need 2010 dollars, the price is on the 7$ to 15$ range
// data in EnergyDensity.xls/prices
// actual reserves (EnergyMatrix) in 2020 = 1000 PWh (at 30$) - conso from 2010 to 2020 is 480PWh
// current hypothesis (cf reference/chatGPT) = 5000 at x2, 7000 x4 (vs 2020) (with future reserves)
// note that the price peak of 2010 is shaven -> 60$ a baril -> 410$ a ton -> 35.34 a MWh
// equilibrium price is abstracted from "energyDensity.xls"/Prices with a fair amount of smoothing
// the 
Oil :: FiniteSupplier( index = 1,
   inventory = affine(list(30.0, 1745.0),list(60.0,3745.0), list(120.0,5085.0)),    // CCEM v9
   threshold = 80% * 2900.0,      // when we start to reduce production
   techFactor = 1%,         // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   production = Oil2010,
   equilibriumPrice = affine(list(2010,35.0),list(2020,30.0),list(2050,50.0),list(2100,100.0),list(2200,150.0)),                    
   capacityOrigin = Oil2010 * 110%,    // a little elasticity
   capacityGrowth = 6%,             // adding capacity takes time/effort
   capacityFactor = 110%,               // maxCap is 110% of actual conso
   co2Factor = 0.272,                // 1 Tep -> 3.15 T C02 => 1PWh -> 0.3 Gt
   co2Kwh = 270.0,                  // each kWh of energy  yields 270g of CO2
   investPrice = 0.13,                // same as gas ? 
   steelFactor = 10%)                // part of investment that is linked to steel

// Coal supplies + traditional (biomass & wood)
// 2020 reserves at 8000PWh, 1980-2020 conso = 400PWh
// gpt estimates : 14000 with p x2, 20000 p x4
// price in 2010 : 7.7 
// safe formula for size(reserves) = f(price)
Coal :: FiniteSupplier( index = 2,
   inventory = affine(list(7.0, 7240.0), list(15.0, 11400.0), list(30.0,15540.0)),
   techFactor = 1%,         // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   production = Coal2010,
   threshold = 50% * 10000.0,      // when we start to reduce production
   equilibriumPrice = affine(list(2010,7.7),list(2020,6.0),list(2050,10.0),list(2100,15.0),list(2200,20.0)),
   capacityOrigin = Coal2010 * 110%,    // can grow slowly if we need it ...
   capacityGrowth = CoalMaxGrowth,              // growth between 2005 and 2010
   capacityFactor = 110%,               // maxCap is 110% of actual conso
   co2Factor = 0.283,                   // 1 Tep coal -> 3.28 T of CO2 => 1PWh -> 0.3 Gt
   co2Kwh = 280.0,                     // each kWh of energy  yields 280g of CO2
   investPrice = 0.43,                   // half of nuclear
   steelFactor = 15%)                   // same as oil

// Natural Gas, separated from Oil in v0.3
// in v8; we get the natural reserves at 1800PWh in 2020, with 300PWh consumed 2010 to 2020
// gpt estimates: 3000 at x2, 4800 x4 (vs 2020)
// price in 2010 : 14.0, 2020: 7.0 
Gas :: FiniteSupplier( index = 3,
   inventory = affine(list(7.0,1875.0),list(15.0,4415.0),list(30.0,5600.0)),
   threshold = 80% * 3200.0,
   techFactor = 1%,                // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   production = Gas2010,
   equilibriumPrice = affine(list(2010,14.0),list(2020,7.0),list(2050,15.0),list(2100,30.0),list(2200,40.0)),
   capacityOrigin = Gas2010 * (1 + GasMaxGrowth),    // a little elasticity
   capacityGrowth = GasMaxGrowth,             // adding capacity takes time/effort
   capacityFactor = 110%,               // maxCap is 110% of actual conso
   co2Factor = 0.184,                // 1 Tep -> 2.14 T CO2 => 1PWh -> 0.2 Gt
   co2Kwh = 180.0,                  // each kWh of energy  yields 270g of CO2
   investPrice = 0.13,               // cheaper than nuclear ! 1$ / 1W approx => 1.5T$ for 1GToe
   steelFactor = 10%)               // part of investment that is linked to steel

// clean is Nuclear, solar, wind and hydro  => electricity without fossile enery
// 2010 : 35% of 21500TWh, from 7500 to 10400 in 2020 (0.64 to 0.89)
// price : 68$/MWh in 2010, 60 in 2020 
Clean :: InfiniteSupplier( index = 4,
   // this line reflect current capacity to add Nuclear, Wind & Solar (GTep/y), grows with biofuels
   // knu1 should be expressed in TWh/y at a price (current is 50$ -> 0.11 = +9000TWh en 7 ans)
   techFactor = 1%,                    // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   growthPotential = affine(list(2010,0.3), list(2020,0.6),list(2030,1.0),list(2040,1.3),list(2100,2.0),list(2200,3.0)),
   capacityFactor = 110%,               // maxCap is 110% of actual conso
   production = Clean2010,
   capacityOrigin = Clean2010 * (1 + CleanMaxGrowth),   // can grow slowly if we need it ...
   equilibriumPrice = affine(list(2010,68.0),list(2020,50.0),list(2050,40.0),list(2100,30.0),list(2200,20.0)),                  // 20$ a baril
   investPrice = 0.95,                // nuclear = 1000e/(MWh/y),  green = 800-1500e/MWh (will go down) - G$/PWh
   co2Factor = 0.0,                   // What clean means :)
   co2Kwh = 0.0,                      // 
   steelFactor = 40%)                 // typical for 1MW wind: 3.2Me cost, 460T steel, 1.7Me cost of steel


// debug utilities for tracing one specific Energy source
[traceOil() 
    -> TESTO := Oil]
[traceGas() 
    -> TESTO := Gas]
[traceCoal() 
    -> TESTO := Coal]
[traceClean() 
    -> TESTO := Clean]
// (traceClean())

// energy consumption -------------------------------------------------------

// CCEM v7 : typical additional cost of transition to adapt from fossil to clean electricity
AdaptFossil :: 60%

// create the transitions - order matters
// the transition matrix also tells about the "heat (vs elec)" production and how much is trasnsfered
// heat% ratio is the part that is kept as a primary energy (vs electricity)
// tune to get the proper electricity production in 2020 - 26446 TWh vs 21000 TWh in 2010
// makeTransition(name,i->j,heat%, 1 / efficiency gain%, adaptationFactor%)
(makeTransition("Oil to Coal",1,2,30%,100%,0%),          // CTL (heat) or switch in elec generation
 makeTransition("Oil to Gas",1,3,85%,100%,20%),
 makeTransition("Oil to clean electricity",1,4,0%,40%,AdaptFossil),
 makeTransition("Coal to Gas",2,3,85%,80%,20%),
 makeTransition("Coal to clean",2,4,0%,40%,AdaptFossil),
 makeTransition("Gas to clean",3,4,0%,40%,AdaptFossil))


// Four energy sectors, basis for energy transition
// in CCEMv8 this is how we represent the energy transition KNU: 4 sectors, two transition points 2050 and 2100
// note that the 2020 value is very different in the 2010 and 1980 version (by construction : 40 vs 10 years of change)
// modulation through tactic only start at 2020 (TransitionPivot)
Transport :: Sector(
   index = 1,
   energy% = list<Percent>(44%,3%,2.4%,1.9%),       // the weight of Transport in Oil, Coal, Gas and Clean
   subMatrix = SETM(list(2020,2050,2100,2200),
                    list(list(Oil,list(Coal,0%,0%,0%,0%),list(Gas,3%,10%,20%,30%),list(Clean,0.5%,10%,30%,50%)),
                         list(Coal,list(Gas,100%,100%,100%,100%),list(Clean,0%,0%,0%,0%)),
                         list(Gas,list(Clean,0%,10%,40%,50%))))
)

// industry usage moves through electrification : both more coal then more green
Industry :: Sector(
   index = 2,
   energy% = list<Percent>(33%,51%,51%,47%),       // the weight of Industry in Oil, Coal, Gas and Clean
   subMatrix = SETM(list(2020,2050,2100,2200),
                    list(list(Oil,list(Coal,1%,2%,0%,0%),list(Gas,3%,20%,40%,50%),list(Clean,1%,20%,50%,60%)),
                         list(Coal,list(Gas,13%,20%,30%,40%),list(Clean,10%,50%,55%,55%)),
                         list(Gas,list(Clean,5%,30%,50%,60%))))
)

Residential :: Sector(
   index = 3,
   energy% = list<Percent>(11%,28%,33.5%,47%),       // the weight of Residential in Oil, Coal, Gas and Clean
   subMatrix = SETM(list(2020,2050,2100,2200),
                    list(list(Oil,list(Coal,0%,0%,0%,0%),list(Gas,3%,10%,50%,60%),list(Clean,1%,30%,50%,60%)),
                         list(Coal,list(Gas,13%,20%,30%,40%),list(Clean,6%,40%,50%,50%)),
                         list(Gas,list(Clean,5%,35%,50%,60%))))
)

Others :: Sector(
   index = 4,
   energy% = list<Percent>(12%,18%,13%,3.4%),       // the weight of Others in Oil, Coal, Gas and Clean
   subMatrix = SETM(list(2020,2050,2100,2200),
                    list(list(Oil,list(Coal,0%,0%,0%,0%),list(Gas,3%,10%,30%,40%),list(Clean,1%,20%,50%,60%)),
                         list(Coal,list(Gas,13%,20%,30%,40%),list(Clean,6%,40%,50%,60%)),
                         list(Gas,list(Clean,10%,25%,50%,60%))))
)

// ETM (Energy Transition Matrix) would be produced from the sector transition matrices and
// zone-specific transition speeds 
// example : => ETM(list(80%,100%),list(Transport,20%),list(Industry,30%),list(Residential,20%))


 // KNU 4 is the expected electricity in 2050 = 10% (2010) fossile + 5% clean
 // in 2050 we compute the transition ratio, apply itto 85% of fossile and add 10% of legacy fossile electricty      
 
// key M2 beliefs : savings & cancel/impact for each zone ----------------------------
  
// 2008, -7% de PNB (par rapport au trend, avec oil de 70$   150$)
// cf. rapport de Bacher sur le PPE: les substitutions font sens   1000 

// this is the energy (de)densifying profile, which comes both from immaterial/material economy ratio 
// (service economy produces more GDP per toe) and energy efficiency (less energy per unit of GDP)
// This is KNU2 : CAGR between 1990 and 2022 is -1.4%
// what we put in this curve is the Percentage of improvement (less density)
// look at ExcelFile "EnergyDensity.xlsx" for the data
// retro-tuning to get the 2020 values !
USDemat :: densityCurve(2010,list(2020,1.75%),list(2050,1.2%),list(2100,1%),list(2200,0.5%))
EUDemat :: densityCurve(2010,list(2020,0.15%),list(2050,0.5%),list(2100,0.5%),list(2200,0.5%))
CNDemat :: densityCurve(2010,list(2020,4.1%),list(2050,2.0%),list(2100,1.2%),list(2200,0.5%))
INDemat :: densityCurve(2010,list(2020,-1.5%),list(2050,0%),list(2100,0.5%),list(2200,0.5%))
RWDemat :: densityCurve(2010,list(2020,-1.91%),list(2050,0%),list(2100,0.5%),list(2200,0.5%))

// we define here four cancellation vectors
// KNU3 = long-term elasticity
// 69 to 138 = +100% increase in price 
// elasticity -0.3 means 30% less consumption
// reeds reference says -0.05 short term, -0.3 long term
// in v8 we have a model to produce the affine curves
USCancel :: elasticityCurve(35.0,5%,30%)
EUCancel :: USCancel
CNCancel :: elasticityCurve(35.0,10%,50%)
INCancel :: elasticityCurve(35.0,10%,40%)
RestCancel :: elasticityCurve(35.0,7%,30%)

// Last, we use a common profile for economic impact of cancellation (pending more detailed sources)
// Recall: Impact[20%] : loss of revevue for the 80% business that did not stop (cancel = 20%)
// it should also be tuned for each block / there should be a parallel with margin impact
// CCEMv6 simplification : two level of development (low, high) for US/EU and China/India/Rest
CancelImpactAdvanced :: affine(list(0%,0%),list(10%,4%),list(20%,8%),list(30%,12%),list(40%,20%),list(50%,30%),list(70%,50%),list(100%,100%))
CancelImpactDeveloping :: affine(list(0%,0%),list(10%,10%),list(20%,20%),list(30%,32%),list(40%,44%),list(50%,60%),list(70%,100%),list(100%,100%))

// ********************************************************************
// *    Part 2: Consumers and Economies                               *
// ********************************************************************

// default adaptation curve : 
AdaptCurve :: affine(list(0,0.0), list(500%,60%))

// we have a default tactic that is used for all zone before we start to optimize, that is used for 
// sensitivity analysis
[defaultTactic(ai%:Percent) : Tactics
 -> Tactics(
       transitionStart = 0%,                                   // activate 50% of transition by default
       transitionFromPain = 100%,                                // other 50% based on pain
       cancelFromPain = 0%,                                      // to be tuned
       taxFromPain = 0%,
       aiReplaceFactor = ai%) ]

// US, Europe & Japan
// note : we could model the "energy discount => more output" to balance the curve at "origin price"
US :: Consumer(
   index = 1,
   objective = strategy(0%,2%,10%,50%),     // CO2+%, economy%, energy%, => 20% for pain
   consumes = USenergy2010,
   eSources = USeSources2010,
   cancel = USCancel,
   cancelImpact = CancelImpactAdvanced,
   maxSaving = 15%,                              // 15% of additional energy savings if aggressive invest
   populationEstimate = affine(list(1980,0.226),list(2010,0.311), list(2040,0.365),list(2100,0.394),list(2200,0.400)),
   populationDistribution = list<Percent>(28%,54%,19%),   // 2010 repartition in young, adult, old
   deathRates = affine(list(2010,8.2), list(2030,8.9),list(2050,10.1),list(2070,11),list(2100,11)),
   subMatrix = ETM(list(130%,130%,100%,100%,100%), 
                   list(list(Transport,30%),list(Industry,20%),list(Residential,20%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = defaultTactic(30%))

EU :: Consumer(
   index = 2,
   objective = strategy(-3.5%,0%,40%,20%),
   consumes = EUenergy2010,
   eSources = EUeSources2010,
   cancel = EUCancel,
   cancelImpact = CancelImpactAdvanced,
   maxSaving = 10%,                              // 20% of energy savings
   populationEstimate = affine(list(1980,0.406),list(2000,0.43), list(2040,0.45), list(2080, 0.42), list(2100,0.41), list(2200,0.33)),
   populationDistribution = list<Percent>(22%,54%,25%),   // 2010 repartition in young, adult, old
   deathRates = affine(list(2010,10.6), list(2030,11.5),list(2050,13.1),list(2070,14.1),list(2100,12.8)),
   subMatrix =  ETM(list(110%,110%,100%,100%,100%), 
                    list(list(Transport,32%),list(Industry,25%),list(Residential,26%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tact
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = defaultTactic(30%))

// China is an interesting block with impressive GDP growth from 2010 to 2020
// however its energy intensity is high so its savings ability is less and its cancem
CN :: Consumer(
   index = 3,
   objective = strategy(-2%,3%,20%,60%),
   consumes = CNenergy2010,
   eSources = CNeSources2010,
   cancel = CNCancel,
   cancelImpact = CancelImpactDeveloping,
   maxSaving = 20%,                              // 40% of energy savings (energy guzzling economy)
   populationEstimate = affine(list(1980, 0.981),list(2010,1.35), list(2040,1.38),list(2050,1.31),list(2080,0.97),list(2100,0.75),list(2200,0.5)),
   populationDistribution = list<Percent>(27%,60%,13%),   // 2010 repartition in young, adult, old
   deathRates = affine(list(2010,7.3), list(2030,9.7),list(2050,13.4),list(2070,16.1),list(2100,15.5)),
   subMatrix = ETM(list(80%,80%,100%,100%,100%), 
                   list(list(Transport,16%),list(Industry,48%),list(Residential,18%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = defaultTactic(100%))

// INDIA is a Consumer (zone) in CCEM v6, because of its population and its growth
IN :: Consumer(
   index = 4,
   objective = strategy(1%,2%,10%,40%),          // India allows itself to grow its emissions
   consumes = INenergy2010,
   eSources = INeSources2010,
   cancel = INCancel,
   maxSaving = 25%,                              // lots of potential for improved efficieny
   cancelImpact = CancelImpactDeveloping,
   populationEstimate = affine(list(1980,0.682),list(2010,1.24),list(2040,1.6),list(2080,1.5),list(2100,1.2),list(2200,0.9)),
   populationDistribution = list<Percent>(41%,51%,8%),   // 2010 repartition in young, adult, old
   deathRates = affine(list(2010,8.2), list(2030,9.4),list(2050,9.5),list(2070,10.8),list(2100,12.3)),
   subMatrix = ETM(list(80%,80%,60%,80%,80%), 
                   list(list(Transport,12%),list(Industry,49%),list(Residential,12%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = defaultTactic(10%))


// similar behaviour, but more cancellation and less savings/subst
// cancel profile is similar to China as an average (worse for low-dev country, better for Japan or
// other high-dev countries)
Rest :: Consumer(
   index = 5,
   objective = strategy(-1%,1%,20%,30%),
   consumes = RWenergy2010,
   eSources = RWeSources2010,
   cancel = RestCancel,
   cancelImpact = CancelImpactDeveloping,
   maxSaving = 20%,                              // 20% of energy savings = mix of mature countries and developing
   populationEstimate = affine(list(1980,4.4 - (0.226 + 0.406 + 0.981 + 0.682)),
                               list(2010,7.3 - (0.43 + 0.31 + 1.35 + 1.35)),
                               list(2040,9.0 - (0.45 + 0.365 + 1.38 + 1.6)),
                               list(2080,9.4 - (0.42 + 0.38 + 0.97 + 1.65)),
                               list(2100, 9.2 - (0.41 + 0.394 + 0.75 + 1.53)),
                               list(2200, 7.0 - (0.4 + 0.33 + 0.5 + 0.9))),
   populationDistribution = list<Percent>(44%,43%,13%),   // 2010 repartition in young, adult, old    
   deathRates = affine(list(2010,7.2%), list(2030,5.3%),list(2050,7.3%),list(2070,8.4%),list(2100,7.4%)),
   subMatrix = ETM(list(70%,70%,60%,70%,80%), 
                   list(list(Transport,39%),list(Industry,18%),list(Residential,20%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = defaultTactic(10%))

// debug: cancel all transfers to see how the system reacts (each energy source grows independently)
[noTransfers()
  -> //[0] ====== NO TRANSFERS: cancels all substitution matrices   =============== //,
     for c in Consumer
        c.subMatrix := list<Affine>{affine(list(1980,0%),list(2100,0%)) | i in (1 .. 6)}
]

// (noTransfers())   // only use during step 2 of tuning protocol

// opposite : appply the full transfer strategy
[fullTransfers()
  -> //[0] ====== FULL TRANSFERS: applies the full substitution matrices   =============== //,
     for c in Consumer c.tactic.transitionStart := 100%]

// specific energy calibration that is used to reproduce CCEM v7 calibration
[ev7()
  -> //[0] Fossil Energy reserves - CCEM v7 Hypotheses ==================== //,
     Oil.inventory := affine(list(30.0, 2300.0),list(60.0,4000.0), list(120.0,5600.0)),  // CCEM v7 level
     Gas.inventory := affine(list(7.0, 1900.0),list(15.0,3000.0), list(30.0,4600.0)),  // CCEM v7 level
     Coal.inventory := affine(list(7.0, 7000.0),list(15.0,15000.0), list(30.0,30000.0)),  // CCEM v7 level
     Clean.growthPotential := affine(list(2010,0.4), list(2020,0.4),list(2030,1.5),list(2040,2.0),list(2100,4.0)) 
  ]

// world wide economy --------------------------------------------------------------------


// World Object : steel and agriculture
World :: WorldClass(
   steelPrice = 190.0,       // $/tonne (2010 price, GPT5)
   inflation = step(list(2020,1.7%),list(2030,2.5%),list(2100,2%),list(2200,1%)),         // average between 1980 and 2020 = 2.9% 
   energy4steel = affine(list(1980,40.0),list(2000,20.0),list(2020,21.0),list(2050,30.0),list(2100,60.0),list(2200,80.0)),  // GJ/tonne
   wheatProduction = 0.64,         // in giga tons
   agroLand = 47.0,                // millions of km2 = 4700 M ha (200 of which for wheat)
   returnOnInvestment  = 23%,      // tuned to adjust US growth
   competitivenessFactor = affine(list(0.0,70%),list(25%,140%),list(100%,100%),list(120%,90%),list(200%,80%)),
   landImpact = affine(list(2000,8.0), list(2020,10.0), list(2050,20.0), list(2100,15.0), list(2200,10.0)),          // land needed to produce 1 MWh of clean energy
   lossLandWarming = affine(list(0.0,100%),list(2.0,96%),list(4,90%)),          
   agroEfficiency = affine(list(30,100%),list(60,96%), list(100,92%), list(200, 85%), list(500,75%)),
   bioHealth = affine(list(0.0,100%),list(1.0,99%),list(2.0,96%),list(4.0,90%)),
   cropYield = affine(list(2000,100%),list(2020,120%),list(2050,150%),list(2100,180%),list(2200,200%))
   )


// World is divided into five blocks: Europe, China, US, India and RoW
USgdp :: 15.0 in 2010    // moves to 21.4 in 2019 (constant dollars -> 17.5)
USir :: 22%      // investment as a fraction of revenue
// US tech factor reflects the tech progress (AI)
USeco :: Block(
   describes = US,
   gdp = USgdp,
   decayTable = affine(list(1980,1.50%),list(2100,2%)),
   startGrowth = 2%,
   dematerialize = USDemat,
   socialExpenseRatio = affine(list(2010,21%), list(2100,27%)),
   roiEfficiency = affine(list(2010,100%),list(2020,120%),list(2025,140%),list(2050,140%),list(2100,140%),list(2200,100%)),
   investG = (USgdp * USir),  // T$
   investE = 0.05,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = USir,          // part of revenue that is invested
   ironDriver = affine(list(2010,158),list(2020,182),list(2050,200),list(2100,250)),
   giniStart  = 40%)
   
// we have a recession in 2010-2020 that is reflected with roiEfficiency (tech factor)
// the weight of social expenses explains the differenvce with US
// 2020 is a COVID year, it should have been approximately 14.0 in 2020 
EUgdp :: 14.5 in 2010   //  becomes 16.2 (current + COVID correction) 13.7 in 2020 (constant dollars -> recession)
EUir :: 22%      // investment as a fraction of revenue
EUeco :: Block(
   describes = EU,
   gdp = EUgdp,
   decayTable = affine(list(1980,2.0%),list(2100,2.0%)),
   startGrowth = 0%,
   dematerialize = EUDemat,
   socialExpenseRatio = affine(list(2010,27%), list(2100,28%)),
   roiEfficiency = affine(list(2010,50%),list(2020,60%), list(2025,120%),list(2030,130%),list(2050,120%), list(2100,120%),list(2200,80%)),
   investG = (EUgdp * EUir),  // T$
   investE = 0.15,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = EUir,          // part of revenue that is investes
   ironDriver = affine(list(2010,83),list(2020,104),list(2050,120),list(2100,150)),
   giniStart  = 30%)


// interesting : check the model to see if growth is properly estimated
// Note that the evolution of social expense ratio is a KNU (to be explored in CCEM v9 with aging and redistribution)
// we introduce the 2010 milestone for China since 1980-2010 growth 
CNgdp :: 6.0   // in 2010, grew to 14.3 in 2019 (11.9 in constant dollars)
CNir :: 40%
CNeco :: Block(
   describes = CN,
   gdp = CNgdp,
   decayTable = affine(list(1980,0%),list(2020,0%),list(2050,1.5%),list(2100,2%)),
   startGrowth = 6%,
   dematerialize = CNDemat,
   socialExpenseRatio = affine(list(2010,8%), list(2100,22%)),
   roiEfficiency = affine(list(2010,80%),list(2020,75%),list(2022,40%),list(2030,40%),list(2050,50%),list(2100,70%),list(2200,80%)),
   investG = (CNgdp * CNir),  // T$
   investE = 0.07,           // amount of energy in green energies + Nuke in 2010 ...
                            // approx 500 B CNY
   iRevenue = CNir,          // part of revenue that is invested
   ironDriver = affine(list(2010,9.8),list(2020,11.8),list(2050,25),list(2100,60)),
   giniStart  = 44%)

// Rest of the world is obtained by difference
INgdp :: 1.7         // in 2010,    currnt doll -> 2.85 in 2019/2020 , 3.57 in 2023
INir :: 28%                                       // investment rate in India 
INeco :: Block(
   describes = IN,
   gdp = INgdp,
   decayTable = affine(list(1980,0%),list(2040,0.5%),list(2100,2%)),
   startGrowth = 6%,
   dematerialize = INDemat,
   socialExpenseRatio = affine(list(2010,7%), list(2100,18%)),    // from Excel micromodel
   roiEfficiency = affine(list(1980,40%), list(2020,42%), list(2025,55%),list(2050,60%),list(2100,65%),list(2200,60%)),
   investG = (INgdp * INir),  // T$
   investE = 0.05,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = INir,          // part of revenue that is investes
   ironDriver = affine(list(2010,24),list(2020,22),list(2050,15),list(2100,30)),
   giniStart  = 35%)

// Rest of the world is obtained by difference
// notice that the 2010-2020 slump is also hard coded with roiEfficiency (tech factor) 
Wgdp :: (66.0 - (EUgdp + USgdp + CNgdp + INgdp))         // in 2010 : 28.5, 32.7 in 2019 => 27.6 in constant dollars
Wir :: 20%                                       // investment rate in RoW
RWeco :: Block(
   describes = Rest,
   gdp = Wgdp,
   decayTable = affine(list(2010,3%),list(2020,2.5%),list(2100,2%)),
   startGrowth = 0%,
   dematerialize = RWDemat,
   socialExpenseRatio = affine(list(2010,11%), list(2100,20%)),
   roiEfficiency = affine(list(2010,30%), list(2020,30%), list(2025,60%),list(2030,60%),list(2050,65%),list(2100,70%),list(2200,70%)),
   investG = (Wgdp * Wir),  // T$
   investE = 0.5,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = Wir,          // part of revenue that is investes
   ironDriver = affine(list(2010,63),list(2020,56),list(2050,45),list(2100,60)),
   giniStart  = 70%)


// we use the balance of trade as a matrix (percentage vs GDP of inmports/exports)
// US / EU / CN  / RoW
// the arg is the trade flows matrix in B$ - From / To  => 5x 5 matrix
// SIMPLIFICATION: we use a percentage matrix sampled from 2010 data
// HENCE, in CCEM v8, we have two args : the trade list and the gdp list
(pb.trade := balanceOfTrade(list(
                  list(0,167,90,46,1204),       // US : tot 1500
                  list(248,0,132,25,1175),      // EU: tot 1500 B out of 14.5 T
                  list(360,250,0,10,1035),       // CN: 1500
                  list(75,25,10,0,139),         // IN: tot 220 B out of 1.7 T
                  list(1204,1275,1200,890,205,0)),      // RoW
                  list(15.0, 14.5, 6.0, 1.7, 29.4)))    // list of gdp in T


// our Earth ----------------------------------------------------------------------------

// we have only one planet ... and its name is Gaia :)
//  warming: IPCC input =>  temperature increase = f(CO2 concentrartion) - based on RPC 4.5, 6 and 8.5
//  disasterLoss : Nordhaus hypothesis about GDP loss = f(temperature)
//  The calibration proposed here (disaster Loss) is more pessimistic than Nordhaus, based on Schroders.
Gaia :: Earth(
    co2PPM = 388.0,                    // qty of CO2 in atmosphere  in 2010 (ppm)
    co2Add = 34.0,                     // billions T CO2
    co2Ratio = 0.0692,                    // 54% (LR) * (28.97/44) * (1 / 5.137)  volume ratio x 1/ atmospheric mass
    co2Cumul = 1340.0,                  // 2010 data : 1340 Gt CO2 in atmosphere
    // co2Neutral = 15.0,                 // level (GT CO2/y) which is "harmless" (managed by atmosphere)
    warming = affine(list(388,0.63),list(414,1.0),list(560,2.7),list(660,3.2),list(1200,4.7)),
    TCRE = affine(list(0,0),list(4000,2.0),list(8000,3.8)),     // temperature increase per cummulated Gt CO2
    avgTemp = 14.53,                  // 2010 data "0.62°C (1.12°F) above the 20th century average of 13.9°C"
    avgCentury = 13.9,               // reference IPCC 
    painProfile = list<Percent>(40%,30%,30%),    // not used yet
   // M5 new slots
    painClimate = step(list(0.7,0),list(1.0,5%),list(1.5,10%),list(2,15%), list(3,30%), list(4,50%)),
    painGrowth = step(list(-20%,20%),list(-5%,10%),list(0%,5%),list(1%,1%),list(2%,0.1%),list(3%,0%)),
    painCancel = step(list(0,0),list(5%,2%), list(10%,5%), list(20%,10%), list(30%,20%),list(50%,30%)),
    painReplacement = affine(list(0%,0%),list(20%,10%),list(100%,50%)))


// ********************************************************************
// *    Part 4: Launch (go(n))                                        *
// ********************************************************************

// register World, Oil, Clean as key constants
(registerConstant(World, Oil, Clean))

// do n years of simulation
[go(n:integer)
   -> init(),
      iterate_run(n,true) ]

// what we launch by default with js
// two things : the first simulation and a reinit/go(90)
[claire/jsmain()
   -> verbose() := 0,
      go(90),
      //[0] ============================ RELAUNCH ============================ //,
      reinit(),
      go(90)]



