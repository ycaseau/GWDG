// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
// *       file: input.cl - version GWDG 0.4  for Xmas                *
// ********************************************************************

// this file contains a simple description of our problem scenario
// the original file is input2023.cl - this is a Xmas revision around the
// KNUs (Key kNown Unknowns) of the problem
// this is the CCEM5 file that moved to kTWh

// ********************************************************************
// *    Part 1: Problem description : input parameters                *
// *    Part 2: Scenarios                                             *
// *    Part 3: Miscelaneous (go)                                     *
// ********************************************************************

// ********************************************************************
// *    Part 1: Problem description : input parameters                *
// ********************************************************************

// energy supply ------------------------------------------------------

// Four Key constants from the data reseach
// we used Gtoe (Gigaton of oil equivalent) as the unit of energy and moved to PWh (1 Gtoe = 11.6 TWh)
Oil2010 :: 46.4                 // 80 billions barel/j    -   4.0 Gtoe in 2010  4.4 in 2020 (+16%)
Gas2010 :: 34.8                 // 3.3 Tm3/y (3300 bcm)   -   3.0 in 2010,   3.6 in 2020 (+20%)
Coal2010 ::  56.8               // 7300 Mt 2010           -    4.9 Gtoe in 2010, 5.2 in 2020 (+6%)
Clean2010 :: 7.5                // 7500 TWh (2010)        -    0.64 Gtoe in 2010, 0.89 (10.2 PWh) in 2020 (+40%)
//   total : 12.74 Gtoe : 148 PWh in 2010                 -     14.6 Gto / 170 PWh total (+14%)

// ElectrictySources
EfromOil2010 :: 1.074          // total = 21069 TWh in 2010
EfromCoal2010 ::  8.405        // 
EfromGas2010 ::  4.704           //
EfromClean2010 :: 6.886          // a little bit of green (solar and bio mass goes to heat)

// units : Money = $,  Energy = GTep + keep it simple : production = consumption
// inventory : use 2020 numbers + 2010_2020 consumption (40Gtep)
// in 2010 : inventory at 193, 2020 : 242 (+ 45 +40 de consommation)
// key design : inventory at current price in 2010 = 70% of reserves ?
// we add +50GTep if price go very high (hard case = conservative)
Oil :: FiniteSupplier( index = 1,
   inventory = affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(600.0), PWh(290.0)), 
                      list(perMWh(1600.0), PWh(350.0)), list(perMWh(5000.0), PWh(450.0))),       // 
   threshold = PWh(193.0) * 90%,
   techFactor = 1%,         // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   production = Oil2010,
   price = 35.3,                   // 60$ a baril -> 410$ a ton -> 35.34 a PWh 
   capacityMax = Oil2010 * 110%,    // a little elasticity
   capacityGrowth = 6%,             // adding capacity takes time/effort
   horizonFactor = 120%,            // steers the capacity growth
   sensitivity = 40%,               // +25% price -> + 20% prod 
   co2Factor = 0.272,                // 1 Tep -> 3.15 T C02 => 1PWh -> 0.3 Gt
   co2Kwh = 270.0,                  // each kWh of energy  yields 270g of CO2
   investPrice = 0.13,                // same as gas ? 
   steelFactor = 10%)                // part of investment that is linked to steel

// Coal supplies + traditional (biomass & wood)
Coal :: FiniteSupplier( index = 2,
   inventory = affine(list(perMWh(80.0),PWh(600.0)), list(perMWh(150.0),PWh(800.0)),
                      list(perMWh(200.0),PWh(1000.0))),  // lots of coal
   threshold = PWh(400.0),
   techFactor = 1%,         // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   production = Coal2010,
   price = 8.62,                    // 70$ / ton (1tec = 0.66 Tep) - 2010
   capacityMax = Coal2010 * 110%,    // can grow slowly if we need it ...
   horizonFactor = 110%,            // steers the capacity growth
   capacityGrowth = 0.7%,              // lots of constraint to add capacity
   sensitivity = 20%,                 // price varies (lower sensitivity -> higher price)
   co2Factor = 0.283,                   // 1 Tep coal -> 3.28 T of CO2 => 1PWh -> 0.3 Gt
   co2Kwh = 280.0,                     // each kWh of energy  yields 280g of CO2
   investPrice = 0.43,                   // half of nuclear
   steelFactor = 15%)                   // same as oil

// Natural Gas, separated from Oil in v0.3
// 2010 : 160, 2020 : 185 + 10 years conso = 35
// we add +50GTep if price go very high (hard case = conservative)
Gas :: FiniteSupplier( index = 3,
   inventory = affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(320.0), PWh(220.0)), 
                      list(perMWh(5500.0), PWh(270.0))),      // hard case
   threshold = PWh(100.0),
   techFactor = 1%,                // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
   production = Gas2010,
   price =  14.1,                  // 4$ MBTU -> 163$ a TEP -> 14.1 $/MWh
   capacityMax = Gas2010 * 110%,    // a little elasticity
   capacityGrowth = 8%,             // adding capacity takes time/effort
   horizonFactor = 110%,            // steers the capacity growth
   sensitivity = 80%,               // +25% price -> + 20% prod 
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
   growthPotential = affine(list(2000,0.2), list(2020,0.2),list(2030,1.5),list(2040,2.0),list(2100,4.0)),
   // growthPotential = affine(list(20.0,0.02), list(45.0,0.11),list(90.0,0.15),list(520.0,0.3)),
   horizonFactor = 110%,               // steers the capacity growth
   production = Clean2010,
   capacityMax = Clean2010 * 110%,
   price = 50.0,                      // 50e / MWh (nuc/ charbon)  -> 80e in 2020
   sensitivity = 50%,                 // expected price growth expressed as % of GDP growth
   investPrice = 0.95,                // nuclear = 1000e/(MWh/y),  green = 800-1500e/MWh (will go down) - G$/PWh
   co2Factor = 0.0,                   // What clean means :)
   co2Kwh = 0.0,                      // 
   steelFactor = 40%)                 // typical for 1MW wind: 3.2Me cost, 460T steel, 1.7Me cost of steel

// energy consumption -------------------------------------------------------

// 60$/baril          363$/t          ok
// 120$/baril         720             -5%
// 240$/baril         1440            -10%
// 480$/baril         2800            -30%
// 1000$/baril        6000            -80%

// create the transitions - order matters
// the transition matrix also tells about the "heat (vs elec)" production and how much is trasnsfered
// heat% ratio is the part that is kept as a primary energy (vs electricity)
// tune to get the proper electricity production in 2020 - 26446 TWh vs 21000 TWh in 2010
(makeTransition("Oil to Coal (CTL)",1,2,100%),          // use coal to produce oil (for heat) 
 makeTransition("Oil to Gas",1,3,80%),
 makeTransition("Oil to clean electricity",1,4,10%),
 makeTransition("Coal to Gas",2,3,80%),                      // part of (coal to heat) -> gas
 makeTransition("Coal to clean",2,4,20%),
 makeTransition("Gas to clean",3,4,30%))


// We create one unique matrix, that can be modified for each block with accelerate(M, percent)
// the order is based on scarcity (scarce form to less scarce)
// initial value for 2020 : reproduce the 0.4 Gt transfer (0.25 Coal to Gaz US + 0.15 Coal to Green WW)
EnergyTransition :: list<Affine>(
        // Oil moves Gas (already done mostly, transport), to Coal (CTL is bound to happen) and Clean
        affine(list(2010,0.0),list(2100,0.0)),                    // oil -> Coal (CTL) - none by default (we shall see ...)
        affine(list(2010,0.0),list(2020,0.0),list(2040,0.05),list(2100,0.08)),                 // oil -> Gas
        affine(list(2010,0.0),list(2020,0.0),list(2040,0.07),list(2100,0.15)),                 // oil -> Clean
        // Coal is abundant, moving to Clean forms takes longer, Coal to Gas has happened in the US
        affine(list(2010,0.0),list(2020,0.0),list(2040,0.05),list(2100,0.1)),                   // Coal to Gas (US specific)
        affine(list(2010,0.0),list(2020,0.02),list(2040,0.1),list(2100,0.2)),                 // Coal -> clean          
        // Gas moves to clean will start after Ukraine war :)
        affine(list(2010,0.0),list(2020,0.05),list(2040,0.15),list(2100,0.3)))                // Gas -> Clean

 // KNU 4 is the expected electricity in 2050 = 10% (2010) fossile + 5% clean
 // in 2050 we compute the transition ratio, apply itto 85% of fossile and add 10% of legacy fossile electricty      
 
// key M2 beliefs : savings & cancel/impact for each zone ----------------------------
  
// 2008, -7% de PNB (par rapport au trend, avec oil de 70$ � 150$)
// cf. rapport de Bacher sur le PPE: les substitutions font sens � 1000�

// this is the energy saving policy (expressed as a % that can be saved through new tech/process)
// this vector is the best policy that we think is achievable (with appropriate invest)
// the player's tactic will modulate 
USSaving :: affine(list(2010,0),list(2020,10%),list(2030,18%),list(2050,25%),list(2100,35%))
EUSaving :: affine(list(2010,0),list(2020,8%),list(2030,18%),list(2050,25%),list(2100,35%))
CNSaving :: affine(list(2010,0),list(2020,7%),list(2030,10%),list(2050,20%),list(2100,35%))
RWSaving :: affine(list(2010,0),list(2020,6%),list(2030,10%),list(2050,15%),list(2100,30%))


// this is the energy (de)densifying profile, which comes from immaterial/material economy ratio 
// (service economy produces more GDP per toe) and inflation, since our model measures GDP in current $
// this vector is adjusted to follow the observed trajectory of energy density
// This is KNU2 : CAGR between 1990 and 2022 is -1.4%
USDemat :: affine(list(2010,0),list(2020,22%),list(2030,35%),list(2050,50%),list(2100,55%))
EUDemat :: affine(list(2010,0),list(2020,10%),list(2030,25%),list(2050,45%),list(2100,50%))
CNDemat :: affine(list(2010,0),list(2020,28%),list(2030,35%),list(2050,45%),list(2100,50%))
RWDemat :: affine(list(2010,0),list(2020,7%),list(2030,14%),list(2050,30%),list(2100,30%))

// we define here four cancellation vectors
// KNU3 = long-term elasticity
// 69 to 138 = +100% increase in price 
// elasticity -0.3 means 30% less consumption
// reeds reference says -0.05 short term, -0.3 long term
UScancel :: affine(list(35.3,0.0),list(69.0,0.05),list(138.0,0.34),list(276.0,0.54),list(520.0,0.8),list(860.0,1.0))
EUcancel :: UScancel
CNcancel :: affine(list(35.3,0.0),list(69.0,0.3),list(138.0,0.6),list(276.0,0.7),list(520.0,0.9),list(860.0,1.0))
RestCancel :: affine(list(35.3,0.0),list(69.0,0.15),list(138.0,0.45),list(276.0,0.6),list(520.0,0.9),list(860.0,1.0))

// Last, we use a common profile for economic impact of cancellation (pending more detailed sources)
// it should also be tuned for each block / there should be a parallel with margin impact
CancelImpact :: affine(list(0%,0%),list(10%,5%),list(20%,14%),list(30%,24%),list(40%,33%),list(50%,43%),list(70%,60%),list(100%,100%))

// read from our world in data: electricity from fossil sources
USeSources2010 :: list<Energy>(0.047, 1.847, 0.987, 1.322)
EUeSources2010 :: list<Energy>(0.152, 0.701, 0.587, 1.507)
CNeSources2010 :: list<Energy>(0.034, 3.233, 0.077, 0.863)
RWeSources2010 :: list<Energy>(EfromOil2010 - USeSources2010[1] - EUeSources2010[1] - CNeSources2010[1],
                               EfromCoal2010 - USeSources2010[2] - EUeSources2010[2] - CNeSources2010[2],
                               EfromGas2010 - USeSources2010[3] - EUeSources2010[3] - CNeSources2010[3],
                               EfromClean2010 - USeSources2010[4] - EUeSources2010[4] - CNeSources2010[4])

// energy production by zone and source (read from the excel file)
USenergy2010 :: list<Energy>(10.44,6.03,7.08,1.59)
EUenergy2010 :: list<Energy>(7.89,3.13,4.64,1.67)
CNenergy2010 :: list<Energy>(5.45, 21.34, 1.04, 0.93)
RWenergy2010 :: list<Energy>(22.62,26.33,22.04,3.24)

// US, Europe & Japan
// note : we could model the "energy discount => more output" to balance the curve at "origin price"
US :: Consumer(
   index = 1,
   objective = strategy(3%,600.0,90%,40%,30%),
   consumes = USenergy2010,
   eSources = USeSources2010,
   cancel = UScancel,
   cancelImpact = CancelImpact,
   marginImpact = improve(UScancel,-30%),   // high value companies are less sensitive to enery price
   saving = USSaving,
   population = affine(list(2010,0.311), list(2040,0.365),list(2100,0.394)),
   popEnergy = 0.4,    // mature economy
   subMatrix = tune(EnergyTransition,Coal,Gas,
                    affine(list(2010,0.1),list(2020,0.6),list(2040,0.7),list(2100,0.8))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   cancelFromPain = 0%,                                      // to be tuned
   taxFromPain = 0%)

EU :: Consumer(
   index = 2,
   objective = strategy(2%,500.0,100%,30%,40%),
   consumes = EUenergy2010,
   eSources = EUeSources2010,
   cancel = EUcancel,
   cancelImpact = CancelImpact,
   marginImpact = improve(EUcancel,-20%),    // high value companies are less sensitive to enery price
   saving = EUSaving,
   population = affine(list(2000,0.43), list(2040,0.45), list(2080, 0.42), list(2100,0.41)),
   popEnergy = 0.4,    // mature economy
   subMatrix = tune(EnergyTransition,Coal,Gas,
                    affine(list(2010,0.1),list(2020,0.3),list(2040,0.5),list(2100,0.8))),         
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tact
   cancelFromPain = 0%,                                      // to be tuned
   taxFromPain = 0%)

// China is an interesting block with impressive GDP growth from 2010 to 2020
// however its energy intensity is high so its savings ability is less and its cancem
CN :: Consumer(
   index = 3,
   objective = strategy(4%,600.0,60%,40%,40%),
   consumes = CNenergy2010,
   eSources = CNeSources2010,
   cancel = CNcancel,
   cancelImpact = improve(CancelImpact,30%),
   marginImpact = improve(CNcancel,20%),      // CN economy is a high consumer of energy (cf density)
   saving = CNSaving,
   population = affine(list(2010,1.35), list(2040,1.38),list(2050,1.31),list(2080,0.97),list(2100,0.75)),
   popEnergy = 0.5,    // mature economy
   subMatrix = tune(tune(EnergyTransition,Coal,Gas,
                    affine(list(2010,0.03),list(2020,0.08),list(2040,0.1),list(2100,0.12))),
                   Coal,Clean,
                      affine(list(2010,0.0),list(2020,0.03),list(2040,0.07),list(2100,0.2))),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   cancelFromPain = 0%,                                      // to be tuned
   taxFromPain = 0%)


// similar behaviour, but more cancellation and less savings/subst
// cancel profile is similar to China as an average (worse for low-dev country, better for Japan or
// other high-dev countries)
Rest :: Consumer(
   index = 4,
   objective = strategy(3%,600.0,80%,50%,40%),
   consumes = RWenergy2010,
   eSources = RWeSources2010,
   cancel = RestCancel,
   cancelImpact = CancelImpact,
   marginImpact = RestCancel,   // assumes that the gains of energy suppliers even out the losses
   saving = RWSaving,
   population = affine(list(2010,7.3 - (0.43 + 0.31 + 1.35)),
                       list(2040,9.0 - (0.45 + 0.365 + 1.38)),
                       list(2080,9.4 - (0.42 + 0.38 + 0.97)),
                       list(2100, 9.2 - (0.41 + 0.394 + 0.75))),
   popEnergy = 0.7,   // see if 50% works
   subMatrix = accelerate(EnergyTransition,-10%),
   disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   carbonTax = affine(list(380,0.0),list(6000,0.0)),
   cancelFromPain = 0%,                                      // to be tuned
   taxFromPain = 0%)


// world wide economy --------------------------------------------------------------------

// PBN : de 65 en 2010 a 84 en 2020 : 2.5% de croissance
// ENERGY:  de 12.7 a 14.6 en 2020: 1.3 %   (ratio efficience progresse de 1.2%)
// used to tune the savings curve: we gained 12% in 10 years from 2010 to 2020

// Part of the data is no longer needed : we create the global economy from the four blocks
// previous code =>  World :: Economy(
//   population = affine(list(2000,6.6), list(2010,7.3), list(2030,8.9), list(2050,9.2), list(2080, 9.4), list(2100,9.2)),
//   gdp = 65.0,  // T$
//   investG = (65.0 * 0.2),  // T$
//   investE = 1.0,           // amount of energy in green energies in 2010 ...
//   roI = 16%,               // approx 7 yrs payback, or 20% invest -> 3% growth
//   iRevenue = 16%,          // part of revenue that is investes
World :: WorldClass(
   steelPrice = 3800.0,       // $/tonne
   energy4steel = affine(list(2000,0.5),list(2020,0.45),list(2050,0.6),list(2100,1)),
   wheatProduction = 0.66,         // in giga tons
   agroLand = 17.6,                // millions of km2
   landImpact = affine(list(2000,8.0), list(2020,10.0), list(2050,20.0), list(2100,15.0)),          // land needed to produce 1 MWh of clean energy
   lossLandWarming = affine(list(0.0,100%),list(2.0,96%),list(4,90%)),          
   agroEfficiency = affine(list(400,100%),list(600,96%), list(1000,92%), list(2000, 85%), list(5000,75%)),
   bioHealth = affine(list(0.0,100%),list(1.0,98%),list(2.0,96%),list(4.0,90%)),
   cropYield = affine(list(2000,100%),list(2020,115%),list(2050,130%),list(2100,150%))
   )

// World is divided into four blocks: Europe, China, US and RoW
USgdp :: 15.0    // moves to 21.4 in 2019
USir :: 20%      // investment as a fraction of revenue
USeco :: Block(
   describes = US,
   gdp = USgdp,
   dematerialize = USDemat,
   roI = affine(list(2000,18%), list(2020,18%), list(2050, 18%), list(2100,15%)),
   investG = (USgdp * USir),  // T$
   investE = 0.05,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = USir,          // part of revenue that is invested
   ironDriver = affine(list(2010,122),list(2020,156),list(2050,200),list(2100,300)) 
   )
   
   
EUgdp :: 14.5    // moves to 15.7 in 2019 (however, $/euro is impacting too much -> 16.5 is more realistic)
EUir :: 20%      // investment as a fraction of revenue
EUeco :: Block(
   describes = EU,
   gdp = EUgdp,
   dematerialize = EUDemat,
   roI = affine(list(2000,4.5%), list(2020,4.5%), list(2050, 8%), list(2100,10%)),
   investG = (EUgdp * EUir),  // T$
   investE = 0.15,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = EUir,          // part of revenue that is investes
   ironDriver = affine(list(2010,92),list(2020,96),list(2050,120),list(2100,200)) 
   )


// interesting : check the model to see if growth is properly estimated
CNgdp :: 6.0   // in 2010, grew to 14.6 in 2019
CNir :: 42%
CNeco :: Block(
   describes = CN,
   gdp = CNgdp,
   dematerialize = CNDemat,
   roI = affine(list(2000,30%), list(2020,26%), list(2050, 20%), list(2100,15%)),
   investG = (CNgdp * CNir),  // T$
   investE = 0.07,           // amount of energy in green energies + Nuke in 2010 ...
                            // approx 500 B CNY
   iRevenue = CNir,          // part of revenue that is invested
   ironDriver = affine(list(2010,9),list(2020,14.4),list(2050,30),list(2100,60)) 
   )


// Rest of the world is obtained by difference
Wgdp :: (66.6 - (EUgdp + USgdp + CNgdp))         // in 2010 : 34, 36 in 2019
Wir :: 25%                                       // investment rate in RoW
RWeco :: Block(
   describes = Rest,
   gdp = Wgdp,
   dematerialize = RWDemat,
   roI = affine(list(2000,3%), list(2020,3.5%), list(2050, 6%), list(2100,8%)),
   investG = (Wgdp * Wir),  // T$
   investE = 0.5,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = Wir,          // part of revenue that is investes
   ironDriver = affine(list(2010,54),list(2020,50),list(2050,55),list(2100,60)) 
   )


// we use the balance of trade as a matrix (percentage vs GDP of inmports/exports)
// US / EU / CN  / RoW
// the arg is the trade flows matrix in B$ - From / To
(pb.trade := balanceOfTrade(list(
                  list(0,167,90,1250), // US : tot 1500
                  list(248,0,132,1200),  // EU: tot 1500 B out of 14.5 T
                  list(360,250,0,900),   // CN: 1500
                  list(1250,1200,900,0)))) // RoW


// our Earth ----------------------------------------------------------------------------

// we have only one planet ... and its name is Gaia :)
//  warming: IPCC input =>  temperature increase = f(CO2 concentrartion) - based on RPC 4.5, 6 and 8.5
//  disasterLoss : Nordhaus hypothesis about GDP loss = f(temperature)
//  The calibration proposed here (disaster Loss) is more pessimistic than Nordhaus, based on Schroders.
Gaia :: Earth(
    co2PPM = 388.0,                  // qty of CO2 in atmosphere  in 2010 (ppm)
    co2Add = 34.0,                     // billions T CO2
    co2Ratio = 0.0692,                    // 54% (LR) * (28.97/44) * (1 / 5.137)  volume ratio x 1/ atmospheric mass
    // co2Neutral = 15.0,                 // level (GT CO2/y) which is "harmless" (managed by atmosphere)
    warming = affine(list(200,0),list(400,0.7),list(560,2.4),list(680,2.8),list(1200,4.3)),
    avgTemp = 14.63,                  // 2010 data "0.62°C (1.12°F) above the 20th century average of 13.9°C"
    avgCentury = 13.9,               // reference IPCC 
    painProfile = list<Percent>(40%,30%,30%),    // not used yet
   // M5 new slots
    painClimate = step(list(1.0,0),list(1.5,1%),list(2,10%), list(3,20%), list(4,30%)),
    painGrowth = step(list(-20%,20%),list(-5%,10%),list(0%,5%),list(1%,1%),list(2%,1%),list(3%,0)),
    painCancel = step(list(0,0),list(5%,2%), list(10%,5%), list(20%,10%), list(30%,20%),list(50%,30%)))

// ********************************************************************
// *    Part 4: Launch (go(n))                                        *
// ********************************************************************

// do n years of simulation
[go(n:integer)
   -> init(World,Oil,Clean),
      add_years(n) ]

// what we launch by default with js
[claire/jsmain()
   -> verbose() := 0,
      go(90)]


