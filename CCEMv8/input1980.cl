// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2025 Yves Caseau                        *
// *       file: input80.cl - version GWDG 0.8                          *
// ********************************************************************

// this file contains a simple description of our problem scenario
// this is the "origin - 1980" version

(printf("--- load Global Warming Dynamic Games input80.cl -- \n"),
 ORIGIN := 1980)

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
USenergy1980 :: list<Energy>(9.43,4.4,5.34,0.6)
EUenergy1980 :: list<Energy>(7.72,4.85,2.29,0.88)
CNenergy1980 :: list<Energy>(0.97, 3.55, 0.14, 0.08)
INenergy1980 :: list<Energy>(0.37, 0.68, 0.01, 0.05)
RWenergy1980 :: list<Energy>(17.08,17.59,6.46,1.4)

// Four Key constants from the data reseach
// All data come from "Our World in Data" and are in PWh
Oil1980 :: (USenergy1980[1] + EUenergy1980[1] + CNenergy1980[1] + INenergy1980[1] + RWenergy1980[1])                 // 53.6 in 2020
Coal1980 :: (USenergy1980[2] + EUenergy1980[2] + CNenergy1980[2] + INenergy1980[2] + RWenergy1980[2])                 // 43.6 in 2020
Gas1980 :: (USenergy1980[3] + EUenergy1980[3] + CNenergy1980[3] + INenergy1980[3] + RWenergy1980[3])                 // 31.06 in 2020
Clean1980 :: (USenergy1980[4] + EUenergy1980[4] + CNenergy1980[4] + INenergy1980[4] + RWenergy1980[4])                 // 3.01 in 2020
//   total : 83 PWh in 2010                 -> 149 PWh in 2020 (actually 2019 becvause of COIVID)

// yearly growth capacity for each energy source
OilMaxGrowth :: 6%
CoalMaxGrowth :: 4%
GasMaxGrowth :: 5%
CleanMaxGrowth :: 8%

// read from our world in data: electricity from fossil sources (cf "EnergyMatrix.xlsx")
// LIST : Oil, Coal, Gas, Clean
USeSources1980 :: list<Energy>(0.093,1.306,0.271,0.601)
EUeSources1980 :: list<Energy>(0.157,0.555,0.227,0.879)
CNeSources1980 :: list<Energy>(0.049,0.225,0.0,0.081)
INeSources1980 :: list<Energy>(0.01,0.101,0.0,0.049)
RWeSources1980 :: list<Energy>(0.654,1.062,0.734,1.398)  

// ElectrictySources (total 8452 TWh in 1980)
EfromOil1980 :: (USeSources1980[1] + EUeSources1980[1] + CNeSources1980[1] + 
                 INeSources1980[1] + RWeSources1980[1])          // total = 962
EfromCoal1980 ::  (USeSources1980[2] + EUeSources1980[2] + CNeSources1980[2] + 
                   INeSources1980[2] + RWeSources1980[2])        // total = 3248 TWh in 1980
EfromGas1980 ::  (USeSources1980[3] + EUeSources1980[3] + CNeSources1980[3] + 
                  INeSources1980[3] + RWeSources1980[3])           // total = 1236 TWh in 1980
EfromClean1980 :: (USeSources1980[4] + EUeSources1980[4] + CNeSources1980[4] + 
                   INeSources1980[4] + RWeSources1980[4])          // total = 3006 TWh in 1980

// this needs to be rebuilt in CCEM v8 since prices were wrong -  ALWAYS THE CURRENT/CONSTANT dollars trap
// in 1980 dollars, the price is on the 7$ to 15$ range
// data in EnergyDensity.xls/prices
// actual reserves in 2020 = 2900 PWh (250Gtep) + conso from 1980 to 2020 is 1900PWh = 4800 (look at EnergyMaxtrix)
// current hypothesis (cf reference/chatGPT) = 70% reserves at current price, 100% at double price, 120% at quadruple price
Oil :: FiniteSupplier( index = 1,
   inventory = affine(list(10.0, 3300.0),list(20.0,4800.0), list(40.0,5300.0), list(80.0,7500.0)),  // CCEM v8
   threshold = 80% * 3900.0,      // when we start to reduce production
   techFactor = 1%,         // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   production = Oil1980,
   equilibriumPrice = affine(list(1980,15.0),list(1990,7.0),list(2020,11.0),list(2050,20.0),list(2100,30.0)),                  // 20$ a baril  
   capacityOrigin = Oil1980 * 110%,    // a little elasticity
   capacityGrowth = 6%,             // adding capacity takes time/effort
   capacityFactor = 110%,               // maxCap is 110% of actual conso
   co2Factor = 0.272,                // 1 Tep -> 3.15 T C02 => 1PWh -> 0.3 Gt
   co2Kwh = 270.0,                  // each kWh of energy  yields 270g of CO2
   investPrice = 0.13,                // same as gas ? 
   steelFactor = 10%)                // part of investment that is linked to steel

// Coal supplies + traditional (biomass & wood)
// 2020 reserves at 8000PWh, 1980-2020 conso = 1260PWh = 9260PWh
// safe formula for size(reserves) = f(price)
Coal :: FiniteSupplier( index = 2,
   inventory = affine(list(5.0, 6000.0), list(10.0, 9000.0), list(20.0,14000.0),list(40.0,20000.0)),
   techFactor = 1%,         // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   production = Coal1980,
   threshold = 50% * 10000.0,      // when we start to reduce production
   equilibriumPrice = affine(list(1980,6.0),list(1990,3.5),list(2020,2.0),list(2050,5.0),list(2100,10.0)),
   capacityOrigin = Coal1980 * 110%,    // can grow slowly if we need it ...
   capacityGrowth = CoalMaxGrowth,              // growth between 2005 and 2010
   capacityFactor = 110%,               // maxCap is 110% of actual conso
   co2Factor = 0.283,                   // 1 Tep coal -> 3.28 T of CO2 => 1PWh -> 0.3 Gt
   co2Kwh = 280.0,                     // each kWh of energy  yields 280g of CO2
   investPrice = 0.43,                   // half of nuclear
   steelFactor = 15%)                   // same as oil

// Natural Gas, separated from Oil in v0.3
// in v8; we get the natural reserves at 2030PWh in 2020, with 1130PWh consumed
Gas :: FiniteSupplier( index = 3,
   inventory = affine(list(3.0,2500.0),list(6.0,3200.0),list(12.0,4000.0),list(24.0,6000.0)),
   threshold = 80% * 3200.0,
   techFactor = 1%,                // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   production = Gas1980,
   equilibriumPrice = affine(list(1980,5.2),list(1990,3.0),list(2020,2.0),list(2050,3.0),list(2100,4.0)),
   capacityOrigin = Gas1980 * (1 + GasMaxGrowth),    // a little elasticity
   capacityGrowth = GasMaxGrowth,             // adding capacity takes time/effort
   capacityFactor = 110%,               // maxCap is 110% of actual conso
   co2Factor = 0.184,                // 1 Tep -> 2.14 T CO2 => 1PWh -> 0.2 Gt
   co2Kwh = 180.0,                  // each kWh of energy  yields 270g of CO2
   investPrice = 0.13,               // cheaper than nuclear ! 1$ / 1W approx => 1.5T$ for 1GToe
   steelFactor = 10%)               // part of investment that is linked to steel

// clean is Nuclear, solar, wind and hydro  => electricity without fossile enery
// 2010 : 35% of 21500TWh, from 7500 to 10400 in 2020 (0.64 to 0.89)
// Clean: 1500$ / kW -> 1.6Mwh -> 10.9 B$ / GToe (low end) to 
Clean :: InfiniteSupplier( index = 4,
   // this line reflect current capacity to add Nuclear, Wind & Solar (GTep/y), grows with biofuels
   // knu1 should be expressed in TWh/y at a price (current is 50$ -> 0.11 = +9000TWh en 7 ans)
   techFactor = 1%,                    // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   growthPotential = affine(list(2010,0.3), list(2020,0.7),list(2030,2.0),list(2040,3.0),list(2100,5.0)),
   // growthPotential = affine(list(20.0,0.02), list(45.0,0.11),list(90.0,0.15),list(520.0,0.3)),
   capacityFactor = 110%,               // maxCap is 110% of actual conso
   production = Clean1980,
   capacityOrigin = Clean1980 * (1 + CleanMaxGrowth),   // can grow slowly if we need it ...
   equilibriumPrice = affine(list(1980,40.0),list(2020,20.0),list(2050,15.0),list(2100,10.0)),                  // 20$ a baril
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

// 60$/baril          363$/t          ok
// 120$/baril         720             -5%
// 240$/baril         1440            -10%
// 480$/baril         2800            -30%
// 1000$/baril        6000            -80%

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
Transport :: Sector(
   index = 1,
   energy% = list<Percent>(44%,3%,2.4%,1.9%),       // the weight of Transport in Oil, Coal, Gas and Clean
   subMatrix = SETM(list(2020,2050,2100),
                    list(list(Oil,list(Coal,0%,0%,0%),list(Gas,3%,10%,20%),list(Clean,0.5%,10%,30%)),
                         list(Coal,list(Gas,100%,100%,100%),list(Clean,0%,0%,0%)),
                         list(Gas,list(Clean,0%,10%,40%))))
)

// industry usage moves through electrification : both more coal then more green
Industry :: Sector(
   index = 2,
   energy% = list<Percent>(33%,51%,51%,47%),       // the weight of Industry in Oil, Coal, Gas and Clean
   subMatrix = SETM(list(2020,2050,2100),
                    list(list(Oil,list(Coal,1%,2%,0%),list(Gas,9%,30%,40%),list(Clean,12%,20%,50%)),
                         list(Coal,list(Gas,38%,38%,50%),list(Clean,18%,50%,50%)),
                         list(Gas,list(Clean,5%,30%,50%))))
)

Residential :: Sector(
   index = 3,
   energy% = list<Percent>(11%,28%,33.5%,47%),       // the weight of Residential in Oil, Coal, Gas and Clean
   subMatrix = SETM(list(2020,2050,2100),
                    list(list(Oil,list(Coal,0%,0%,0%),list(Gas,12%,20%,50%),list(Clean,10%,30%,50%)),
                         list(Coal,list(Gas,30%,35%,40%),list(Clean,12%,50%,50%)),
                         list(Gas,list(Clean,5%,30%,50%))))
)

Others :: Sector(
   index = 4,
   energy% = list<Percent>(12%,18%,13%,3.4%),       // the weight of Others in Oil, Coal, Gas and Clean
   subMatrix = SETM(list(2020,2050,2100),
                    list(list(Oil,list(Coal,0%,0%,0%),list(Gas,10%,20%,30%),list(Clean,10%,20%,50%)),
                         list(Coal,list(Gas,28%,35%,40%),list(Clean,12%,50%,50%)),
                         list(Gas,list(Clean,10%,20%,50%))))
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
USDemat :: densityCurve(1980,list(2020,1.42%),list(2050,1.2%),list(2100,1%))
EUDemat :: densityCurve(1980,list(2020,0.71%),list(2050,0.5%),list(2100,0.5%))
CNDemat :: densityCurve(1980,list(2020,2.65%),list(2050,1.5%),list(2100,1.2%))
INDemat :: densityCurve(1980,list(2020,-1.75%),list(2050,0%),list(2100,0.5%))
RWDemat :: densityCurve(1980,list(2020,1.05%),list(2050,1%),list(2100,1%))

// we define here four cancellation vectors
// KNU3 = long-term elasticity
// 69 to 138 = +100% increase in price 
// elasticity -0.3 means 30% less consumption
// reeds reference says -0.05 short term, -0.3 long term
// in v8 we have a model to produce the affine curves
USCancel :: elasticityCurve(15.0,5%,30%)
EUCancel :: USCancel
CNCancel :: elasticityCurve(15.0,10%,50%)
INCancel :: elasticityCurve(15.0,10%,40%)
RestCancel :: elasticityCurve(15.0,7%,30%)

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

// US, Europe & Japan
// note : we could model the "energy discount => more output" to balance the curve at "origin price"
US :: Consumer(
   index = 1,
   objective = strategy(0%,2%,10%,50%),     // CO2+%, economy%, energy%, => 20% for pain
   consumes = USenergy1980,
   eSources = USeSources1980,
   cancel = USCancel,
   cancelImpact = CancelImpactAdvanced,
   maxSaving = 15%,                              // 15% of additional energy savings if aggressive invest
   population = affine(list(1980,0.226),list(2010,0.311), list(2040,0.365),list(2100,0.394)),
   subMatrix = ETM(list(130%,130%,100%,100%,80%), 
                   list(list(Transport,30%),list(Industry,20%),list(Residential,20%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = Tactics(
       transitionStart = 100%,                                   // activate transition
       cancelFromPain = 0%,                                      // to be tuned
       taxFromPain = 0%))

EU :: Consumer(
   index = 2,
   objective = strategy(-3.5%,0%,40%,20%),
   consumes = EUenergy1980,
   eSources = EUeSources1980,
   cancel = EUCancel,
   cancelImpact = CancelImpactAdvanced,
   maxSaving = 10%,                              // 20% of energy savings
   population = affine(list(1980,0.406),list(2000,0.43), list(2040,0.45), list(2080, 0.42), list(2100,0.41)),
   subMatrix =  ETM(list(110%,110%,100%,100%,80%), 
                    list(list(Transport,32%),list(Industry,25%),list(Residential,26%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tact
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = Tactics(
       transitionStart = 100%,                                   // activate transition
       cancelFromPain = 0%,                                      // to be tuned
       taxFromPain = 0%))

// China is an interesting block with impressive GDP growth from 2010 to 2020
// however its energy intensity is high so its savings ability is less and its cancem
CN :: Consumer(
   index = 3,
   objective = strategy(-2%,3%,20%,60%),
   consumes = CNenergy1980,
   eSources = CNeSources1980,
   cancel = CNCancel,
   cancelImpact = CancelImpactDeveloping,
   maxSaving = 20%,                              // 40% of energy savings (energy guzzling economy)
   population = affine(list(1980, 0.981),list(2010,1.35), list(2040,1.38),list(2050,1.31),list(2080,0.97),list(2100,0.75)),
   subMatrix = ETM(list(80%,80%,100%,100%,80%), 
                   list(list(Transport,16%),list(Industry,48%),list(Residential,18%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = Tactics(
      transitionStart = 100%,                                   // activate transition
      cancelFromPain = 0%,                                      // to be tuned
      taxFromPain = 0%))

// INDIA is a Consumer (zone) in CCEM v6, because of its population and its growth
IN :: Consumer(
   index = 4,
   objective = strategy(1%,2%,10%,40%),          // India allows itself to grow its emissions
   consumes = INenergy1980,
   eSources = INeSources1980,
   cancel = INCancel,
   maxSaving = 25%,                              // lots of potential for improved efficieny
   cancelImpact = CancelImpactDeveloping,
   population = affine(list(1980,0.682),list(2010,1.35),list(2040,1.6),list(2080,1.65),list(2100,1.53)),
   subMatrix = ETM(list(80%,80%,60%,80%,80%), 
                   list(list(Transport,12%),list(Industry,49%),list(Residential,12%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = Tactics(
      transitionStart = 100%,                                   // activate transition
      cancelFromPain = 0%,                                      // to be tuned
      taxFromPain = 0%))


// similar behaviour, but more cancellation and less savings/subst
// cancel profile is similar to China as an average (worse for low-dev country, better for Japan or
// other high-dev countries)
Rest :: Consumer(
   index = 5,
   objective = strategy(-1%,1%,20%,30%),
   consumes = RWenergy1980,
   eSources = RWeSources1980,
   cancel = RestCancel,
   cancelImpact = CancelImpactDeveloping,
   maxSaving = 20%,                              // 20% of energy savings = mix of mature countries and developing
   population = affine(list(1980,4.4 - (0.226 + 0.406 + 0.981 + 0.682)),
                       list(2010,7.3 - (0.43 + 0.31 + 1.35 + 1.35)),
                       list(2040,9.0 - (0.45 + 0.365 + 1.38 + 1.6)),
                       list(2080,9.4 - (0.42 + 0.38 + 0.97 + 1.65)),
                       list(2100, 9.2 - (0.41 + 0.394 + 0.75 + 1.53))),
   subMatrix = ETM(list(70%,70%,60%,70%,80%), 
                   list(list(Transport,39%),list(Industry,18%),list(Residential,20%))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),
   adapt = Adaptation(efficiency = AdaptCurve),
   tactic = Tactics(
      transitionStart = 100%,                                   // activate transition
      cancelFromPain = 0%,                                      // to be tuned
      taxFromPain = 0%))

// debug: cancel all transfers to see how the system reacts (each energy source grows independently)
[noTransfers()
  -> //[0] ====== NO TRANSFERS: cancels all substitution matrices   =============== //,
     for c in Consumer
        c.subMatrix := list<Affine>{affine(list(1980,0%),list(2100,0%)) | i in (1 .. 6)}
]

// (noTransfers())   // only use during step 2 of tuning protocol

// world wide economy --------------------------------------------------------------------


// World Object : steel and agriculture
World :: WorldClass(
   steelPrice = 110.0,       // $/tonne (1980 price, GTP5)
   inflation = step(list(1980,2.9%),list(2020,1.7%)),         // average between 1980 and 2020 = 2.9% 
   energy4steel = affine(list(1980,40.0),list(2000,20.0),list(2020,21.0),list(2050,30.0),list(2100,60.0)),  // GJ/tonne
   wheatProduction = 0.44,         // in giga tons
   agroLand = 47.0,                // millions of km2 = 1760 M ha (200 of which for wheat)
   returnOnInvestment  = 28%,      // tuned to adjust US growth (2010 to 2020 § shared with input2010.cl)
   competitivenessFactor = affine(list(0.0,70%),list(25%,140%),list(100%,100%),list(120%,90%),list(200%,80%)),
   landImpact = affine(list(2000,8.0), list(2020,10.0), list(2050,20.0), list(2100,15.0)),          // land needed to produce 1 MWh of clean energy
   lossLandWarming = affine(list(0.0,100%),list(2.0,96%),list(4,90%)),          
   agroEfficiency = affine(list(400,100%),list(600,96%), list(1000,92%), list(2000, 85%), list(5000,75%)),
   bioHealth = affine(list(0.0,100%),list(1.0,98%),list(2.0,96%),list(4.0,90%)),
   cropYield = affine(list(1980,100%),list(2000,150%),list(2020,200%),list(2050,250%),list(2100,300%))
   )

// World is divided into five blocks: Europe, China, US, India and RoW
USgdp :: 2.86    // 15.0 in 2010    // moves to 21.4 in 2019 (constant dollars -> 17.5)
USir :: 22%      // investment as a fraction of revenue
USeco :: Block(
   describes = US,
   gdp = USgdp,
   decayTable = affine(list(1980,1.50%),list(2100,1.5%)),
   startGrowth = 2%,
   dematerialize = USDemat,
   socialExpenseRatio = affine(list(1980,21%), list(2020,21%),list(2050,23%),list(2100,23%)),
   roiEfficiency = affine(list(1980,125%), list(2010,122%),list(2020,100%),list(2030,130%),list(2100,130%)),
   investG = (USgdp * USir),  // T$
   investE = 0.05,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = USir,          // part of revenue that is invested
   ironDriver = affine(list(1980,28),list(2010,60),list(2050,150),list(2100,200)) // 1980 dollars
   )
   
// moves to 15.7 in 2019 (however, $/euro is impacting too much -> 16.5 is more realistic =   
EUgdp :: 3.7  // 14.5 in 2010   //  becomes 13.5 in 2020 (constant dollars -> recession)
EUir :: 22%      // investment as a fraction of revenue
EUeco :: Block(
   describes = EU,
   gdp = EUgdp,
   decayTable = affine(list(1980,1.50%),list(2100,1.5%)),
   startGrowth = 0%,
   dematerialize = EUDemat,
   socialExpenseRatio = affine(list(1980,27%), list(2020,27%),list(2050,30%),list(2100,30%)),
   roiEfficiency = affine(list(1980,120%), list(2010,70%),list(2020,50%), list(2030,80%),list(2100,80%)),
   investG = (EUgdp * EUir),  // T$
   investE = 0.15,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = EUir,          // part of revenue that is investes
   ironDriver = affine(list(1980,17),list(2010,30),list(2050,90),list(2100,120)) // 1980 dollars
)


// interesting : check the model to see if growth is properly estimated
// Note that the evolution of social expense ratio is a KNU (to be explored in CCEM v9 with aging and redistribution)
// we introduce the 2010 milestone for China since 1980-2010 growth 
CNgdp :: 0.19 // 6.0   // in 2010, grew to 14.3 in 2019 (11.9 in constant dollars)
CNir :: 40%
CNeco :: Block(
   describes = CN,
   gdp = CNgdp,
   decayTable = affine(list(1980,0%),list(2020,0%),list(2100,1.0%)),
   startGrowth = 6%,
   dematerialize = CNDemat,
   socialExpenseRatio = affine(list(1980,8%), list(2020,8%),list(2050,20%),list(2100,20%)),
   roiEfficiency = affine(list(1980,85%), list(2010,72%),list(2020,70%),list(2030,50%),list(2100,50%)),
   investG = (CNgdp * CNir),  // T$
   investE = 0.07,           // amount of energy in green energies + Nuke in 2010 ...
                            // approx 500 B CNY
   iRevenue = CNir,          // part of revenue that is invested
   ironDriver = affine(list(1980,5),list(2010,4),list(2050,6),list(2100,12)) // 1980 dollars
)

// Rest of the world is obtained by difference
INgdp :: 0.19 // 1.7         // in 2010,    currnt doll -> 2.85 in 2019/2020 , 3.57 in 2023
INir :: 28%                                       // investment rate in India 
INeco :: Block(
   describes = IN,
   gdp = INgdp,
   decayTable = affine(list(1980,0%),list(2040,0%),list(2100,1.0%)),
   startGrowth = 6%,
   dematerialize = INDemat,
   socialExpenseRatio = affine(list(1980,10%), list(2020,10%),list(2050,15%),list(2100,15%)),
   roiEfficiency = affine(list(1980,70%), list(2010,53%), list(2020,50%), list(2030,60%), list(2100,60%)),
   investG = (INgdp * INir),  // T$
   investE = 0.05,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = INir,          // part of revenue that is investes
   ironDriver = affine(list(1980,20),list(2010,9),list(2050,11),list(2100,20)) // 1980 dollars
   )

// Rest of the world is obtained by difference
Wgdp :: (11.3 - (EUgdp + USgdp + CNgdp + INgdp))         // in 2010 : 31, 36 in 2019 = > 30,5 in constant dollars
Wir :: 20%                                       // investment rate in RoW
RWeco :: Block(
   describes = Rest,
   gdp = Wgdp,
   decayTable = affine(list(1980,0.5%),list(2020,0.5%),list(2100,1.0%)),
   startGrowth = 0%,
   dematerialize = RWDemat,
   socialExpenseRatio = affine(list(1980,15%), list(2020,15%),list(2050,18%),list(2100,20%)),
   roiEfficiency = affine(list(1980,85%), list(2010,55%),list(2020,30%),list(2050,40%), list(2100,50%)),
   investG = (Wgdp * Wir),  // T$
   investE = 0.5,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = Wir,          // part of revenue that is investes
   ironDriver = affine(list(1980,12),list(2010,20),list(2050,30),list(2100,40)) // 1980 dollars
   )


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
    co2PPM = 338.0,                    // qty of CO2 in atmosphere  in 1980 (ppm)
    co2Add = 34.0,                     // billions T CO2
    co2Ratio = 0.0692,                    // 54% (LR) * (28.97/44) * (1 / 5.137)  volume ratio x 1/ atmospheric mass
    co2Cumul = 600.0,                     // 1980 data : 600 // 2010: 1340 Gt CO2 in atmosphere
    warming = affine(list(330,0.2),list(388,0.63),list(414,1.0),list(560,2.7),list(660,3.2),list(1200,4.7)),
    TCRE = affine(list(0,0),list(4000,2.0),list(8000,3.8)),     // temperature increase per cummulated Gt CO2
    avgTemp = 14.1,                  // 1980 data "0.2°C (1.12°F) above the 20th century average of 13.9°C"
    avgCentury = 13.9,               // reference IPCC 
    painProfile = list<Percent>(40%,30%,30%),    // not used yet
   // M5 new slots
    painClimate = step(list(1.0,0),list(1.5,1%),list(2,10%), list(3,20%), list(4,30%)),
    painGrowth = step(list(-20%,20%),list(-5%,10%),list(0%,5%),list(1%,1%),list(2%,1%),list(3%,0)),
    painCancel = step(list(0,0),list(5%,2%), list(10%,5%), list(20%,10%), list(30%,20%),list(50%,30%)))


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
[claire/jsmain()
   -> verbose() := 0,
      go(90),
      //[0] ============================ RELAUNCH ============================ //,
      reinit(),
      go(90)]



