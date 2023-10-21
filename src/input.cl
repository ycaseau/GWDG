// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
// *       file: input.cl - version GWDG4                             *
// ********************************************************************

// this file contains a simple description of our problem scenario

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
// we use Gtoe (Gigaton of oil equivalent) as the unit of energy (1 Gtoe = 11.6 TWh)
Oil2010 :: 4.0                  // 80 billions barel/j    ->     4.4 in 2020 (+16%)
Gas2010 :: 3.0                  // 3.3 Tm3/y (3300 bcm)   ->     3.6 in 2020 (+20%)
Coal2010 ::  4.9                // 7300 Mt 2010           ->     5.2 in 2020 (+6%)
Clean2010 :: 0.64               // 7500 TWh (2010)        ->     0.89 in 2020 (+40%)
//   total : 12.74                                        ->     14.6 total (+14%)


// units : Money = $,  Energy = GTep + keep it simple : production = consumption
// inventory : use 2020 numbers + 2010_2020 consumption (40Gtep)
// in 2010 : inventory at 193, 2020 : 242 (+ 45 +40 de consommation)
// key design : inventory at current price in 2010 = 70% of reserves ?
// we add +50GTep if price go very high (hard case = conservative)
Oil :: FiniteSupplier( index = 1,
   inventory = affine(list(400,193.0), list(600, 290.0), list(1600, 350), list(5000, 450.0)),       // 
   threshold = 193.0 * 90%,
   production = Oil2010,
   price = 410.0,                   // 60$ a baril -> 410$ a ton
   capacityMax = Oil2010 * 110%,    // a little elasticity
   capacityGrowth = 6%,             // adding capacity takes time/effort
   horizonFactor = 120%,            // steers the capacity growth
   sensitivity = 40%,               // +25% price -> + 20% prod 
   co2Factor = 3.15,                // 1 Tep -> 3.15 T C02
   co2Kwh = 270.0,                  // each kWh of energy  yields 270g of CO2
   investPrice = 1.5,                // same as gas ? 
   steelFactor = 10%)                // part of investment that is linked to steel


// Coal supplies + traditional (biomass & wood)
Coal :: FiniteSupplier( index = 2,
   inventory = affine(list(50,600), list(100,800), list(200,1000)),  // lots of coal
   threshold = 400.0,
   production = Coal2010,
   price = 100.0,                    // 70$ / ton (1tec = 0.66 Tep)
   capacityMax = Coal2010 * 110%,    // can grow slowly if we need it ...
   horizonFactor = 110%,            // steers the capacity growth
   capacityGrowth = 0.7%,              // lots of constraint to add capacity
   sensitivity = 50%,                // price varies
   co2Factor = 3.28,                   // 1 Tep coal -> 3.28 T of CO2
   co2Kwh = 280.0,                     // each kWh of energy  yields 280g of CO2
   investPrice = 5.0,                   // half of nuclear
   steelFactor = 15%)                   // same as oil
   

// Natural Gas, separated from Oil in v0.3
// 2010 : 160, 2020 : 185 + 10 years conso = 35
// we add +50GTep if price go very high (hard case = conservative)
Gas :: FiniteSupplier( index = 3,
   inventory = affine(list(163,160.0), list(320, 220.0), list(5500, 270.0)),      // hard case
   threshold = 100.0,
   production = Gas2010,
   price =  163.0,                  // 4$ MBTU -> 163$ a TEP
   capacityMax = Gas2010 * 110%,    // a little elasticity
   capacityGrowth = 8%,             // adding capacity takes time/effort
   horizonFactor = 110%,            // steers the capacity growth
   sensitivity = 80%,               // +25% price -> + 20% prod 
   co2Factor = 2.14,                // 1 Tep -> 2.14 T CO2
   co2Kwh = 180.0,                  // each kWh of energy  yields 270g of CO2
   investPrice = 1.5,               // cheaper than nuclear ! 1$ / 1W approx => 1.5T$ for 1GToe
   steelFactor = 10%)               // part of investment that is linked to steel
    
// clean is Nuclear, solar, wind and hydro  => electricity without fossile enery
// 2010 : 35% of 21500TWh, from 7500 to 10400 in 2020 (0.64 to 0.89)
// Clean: 1500$ / kW -> 1.6Mwh -> 10.9 B$ / GToe (low end) to 
Clean :: InfiniteSupplier( index = 4,
   // this line reflect current capacity to add Nuclear, Wind & Solar (GTep/y), grows with biofuels
   growthPotential = affine(list(200,0.02), list(500,0.05),list(1000,0.05),list(6000,0.1)),
   horizonFactor = 110%,              // steers the capacity growth
   production = Clean2010,
   capacityMax = Clean2010 * 110%,
   price = 550.0,                     // 50e / MWh (nuc/ charbon)  -> 80e in 2020
   sensitivity = 50%,                 // expected price growth expressed as % of GDP growth
   investPrice = 11.0,                // nuclear = 1000e/(MWh/y),  green = 800-1500e/MWh (will go down)
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
(makeTransition("Oil to Coal (CTL)",1,2),
 makeTransition("Oil to Gas",1,3),
 makeTransition("Oil to clean electricity",1,4),
 makeTransition("Coal to Gas",2,3),
 makeTransition("Coal to clean",2,4),
 makeTransition("Gas to clean",3,4))


// We create one unique matrix, that can be modified for each block with accelerate(M, percent)
// the order is based on scarcity (scarce form to less scarce)
// initial value for 2020 : reproduce the 0.4 Gt transfer (0.25 Coal to Gaz US + 0.15 Coal to Green WW)
EnergyTransition :: list<Affine>(
        // Oil moves Gas (already done mostly, transport), to Coal (CTL is bound to happen) and Clean
        affine(list(2010,0.0),list(2100,0.0)),                    // oil -> Coal (CTL) - none by default (we shall see ...)
        affine(list(2010,0.0),list(2020,0.0),list(2040,0.05),list(2100,0.08)),                 // oil -> Gas
        affine(list(2010,0.0),list(2020,0.0),list(2040,0.05),list(2100,0.1)),                 // oil -> Clean
        // Coal is abundant, moving to Clean forms takes longer, Coal to Gas has happened in the US
        affine(list(2010,0.0),list(2020,0.0),list(2040,0.05),list(2100,0.1)),                   // Goal to Gas (US specific)
        affine(list(2010,0.0),list(2020,0.02),list(2040,0.1),list(2100,0.2)),                 // Coal -> clean          
        // Gas moves to clean will start after Ukraine war :)
        affine(list(2010,0.0),list(2020,0.05),list(2040,0.1),list(2100,0.3)))                    // Gas -> Clean
        
// 2008, -7% de PNB (par rapport au trend, avec oil de 70$ � 150$)
// cf. rapport de Bacher sur le PPE: les substitutions font sens � 1000�

// key M2 beliefs : savings & cancel/impact for each zone ----------------------------


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
USDemat :: affine(list(2010,0),list(2020,22%),list(2030,30%),list(2050,40%),list(2100,50%))
EUDemat :: affine(list(2010,0),list(2020,10%),list(2030,25%),list(2050,30%),list(2100,40%))
CNDemat :: affine(list(2010,0),list(2020,28%),list(2030,35%),list(2050,40%),list(2100,50%))
RWDemat :: affine(list(2010,0),list(2020,7%),list(2030,10%),list(2050,20%),list(2100,30%))

// we define here four cancellation vectors
UScancel :: affine(list(410,0.0),list(800,0.05),list(1600,0.15),list(3200,0.4),list(6000,0.8),list(10000,1.0))
EUcancel :: UScancel
CNcancel :: affine(list(410,0.0),list(800,0.3),list(1600,0.6),list(3200,0.7),list(6000,0.8),list(10000,1.0))
RestCancel :: affine(list(410,0.0),list(800,0.15),list(1600,0.3),list(3200,0.4),list(6000,0.9),list(10000,1.0))

// Last, we use a common profile for economic impact of cancellation (pending more detailed sources)
// it should also be tuned for each block / there should be a parallel with margin impact
CancelImpact :: affine(list(0%,0%),list(10%,5%),list(20%,14%),list(30%,24%),list(40%,33%),list(50%,43%),list(70%,60%),list(100%,100%))

// US, Europe & Japan
// note : we could model the "energy discount => more output" to balance the curve at "origin price"
US :: Consumer(
   index = 1,
   consumes = list<Energy>(Oil2010 * 23%, Coal2010 * 11%, Gas2010 * 20%, Clean2010 * 21%),
   cancel = UScancel,
   cancelImpact = CancelImpact,
   marginImpact = improve(UScancel,-30%),   // high value companies are less sensitive to enery price
   saving = USSaving,
   dematerialize = USDemat,
   popEnergy = 0.4,    // mature economy
   subMatrix = tune(EnergyTransition,Coal,Gas,
                    affine(list(2010,0.1),list(2020,0.6),list(2040,0.7),list(2100,0.8))),
   roI = affine(list(2000,18%), list(2020,18%), list(2050, 16%), list(2100,15%)),
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   cancelFromPain = 0%,                                      // to be tuned
   taxFromPain = 0%)

EU :: Consumer(
   index = 2,
   consumes = list<Energy>(Oil2010 * 17%, Coal2010 * 6%, Gas2010 * 13%, Clean2010 * 23%),
   cancel = EUcancel,
   cancelImpact = CancelImpact,
   marginImpact = improve(EUcancel,-20%),    // high value companies are less sensitive to enery price
   saving = EUSaving,
   dematerialize = EUDemat,
   popEnergy = 0.4,    // mature economy
   subMatrix = tune(EnergyTransition,Coal,Gas,
                    affine(list(2010,0.1),list(2020,0.3),list(2040,0.5),list(2100,0.8))),         
   roI = affine(list(2000,4.5%), list(2020,4.5%), list(2050, 8%), list(2100,10%)),
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon taxt
   cancelFromPain = 0%,                                      // to be tuned
   taxFromPain = 0%)

// China is an interesting block with impressive GDP growth from 2010 to 2020
// however its energy intensity is high so its savings ability is less and its cancem
CN :: Consumer(
   index = 3,
   consumes = list<Energy>(Oil2010 * 12%, Coal2010 * 38%, Gas2010 * 3%, Clean2010 * 13%),
   cancel = CNcancel,
   cancelImpact = improve(CancelImpact,30%),
   marginImpact = improve(CNcancel,20%),      // CN economy is a high consumer of energy (cf density)
   saving = CNSaving,
   dematerialize = CNDemat,
   popEnergy = 0.5,    // mature economy
   subMatrix = tune(tune(EnergyTransition,Coal,Gas,
                    affine(list(2010,0.0),list(2020,0.08),list(2040,0.2),list(2100,0.4))),
                   Coal,Clean,
                      affine(list(2010,0.0),list(2020,0.03),list(2040,0.07),list(2100,0.1))),
   roI = affine(list(2000,25%), list(2020,25%), list(2050, 18%), list(2100,15%)),
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   cancelFromPain = 0%,                                      // to be tuned
   taxFromPain = 0%)


// similar behaviour, but more cancellation and less savings/subst
// cancel profile is similar to China as an average (worse for low-dev country, better for Japan or
// other high-dev countries)
Rest :: Consumer(
   index = 4,
   consumes = list<Energy>(Oil2010 * 49%,  Coal2010 * 46%, Gas2010  * 63%, Clean2010 * 44%),
   cancel = RestCancel,
   cancelImpact = CancelImpact,
   marginImpact = RestCancel,   // assumes that the gains of energy suppliers even out the losses
   saving = RWSaving,
   dematerialize = RWDemat,
   popEnergy = 0.7,   // see if 50% works
   subMatrix = accelerate(EnergyTransition,-10%),
   roI = affine(list(2000,3%), list(2020,3.5%), list(2050, 6%), list(2100,8%)),
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
World :: WorldEconomy(
   techFactor = 1%,         // improvement of techno, annual rate (different from savings) - 5% gain every 10 years
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
EUgdp :: 14.5    // moves to 15.7 in 2019 (however, $/euro is impacting too much -> 16.5 is more realistic)
EUir :: 20%      // investment as a fraction of revenue
EUeco :: Block(
   describes = EU,
   population = affine(list(2000,0.43), list(2040,0.45), list(2080, 0.42), list(2100,0.41)),
   gdp = EUgdp,
   investG = (EUgdp * EUir),  // T$
   investE = 0.15,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = EUir,          // part of revenue that is investes
   ironDriver = affine(list(2010,92),list(2020,96),list(2050,120),list(2100,200)) 
   )

USgdp :: 15.0    // moves to 21.4 in 2019
USir :: 20%      // investment as a fraction of revenue
USeco :: Block(
   describes = US,
   population = affine(list(2010,0.311), list(2040,0.365),list(2100,0.394)),
   gdp = USgdp,
   investG = (USgdp * USir),  // T$
   investE = 0.05,           // amount of energy in green energies + Nuke in 2010 ...
   iRevenue = USir,          // part of revenue that is invested
   ironDriver = affine(list(2010,122),list(2020,156),list(2050,200),list(2100,300)) 
   )

// interesting : check the model to see if growth is properly estimated
CNgdp :: 6.0   // in 2010, grew to 14.6 in 2019
CNir :: 42%
CNeco :: Block(
   describes = CN,
   population = affine(list(2010,1.35), list(2040,1.38),list(2050,1.31),list(2080,0.97),list(2100,0.75)),
   gdp = CNgdp,
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
   population = affine(list(2010,7.3 - (0.43 + 0.31 + 1.35)),
                       list(2040,9.0 - (0.45 + 0.365 + 1.38)),
                       list(2080,9.4 - (0.42 + 0.38 + 0.97)),
                       list(2100, 9.2 - (0.41 + 0.394 + 0.75))),
   gdp = Wgdp,
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
    co2Ratio = 0.13,                    // + 2.5 ppm at 19 Gtep/y
    co2Neutral = 15.0,                 // level (GT CO2/y) which is "harmless" (managed by atmosphere)
    warming = affine(list(200,0),list(400,0.7),list(560,2.4),list(680,2.8),list(1200,4.3)),
    avgTemp = 14.63,                  // 2010 data "0.62°C (1.12°F) above the 20th century average of 13.9°C"
    avgCentury = 13.9,               // reference IPCC 
    painProfile = list<Percent>(40%,30%,30%),    // not used yet
   // M5 new slots
    disasterLoss = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
    painClimate = step(list(1.0,0),list(1.5,1%),list(2,10%), list(3,20%), list(4,30%)),
    painGrowth = step(list(-20%,20%),list(-5%,10%),list(0%,5%),list(1%,1%),list(2%,1%),list(3%,0)),
    painCancel = step(list(0,0),list(5%,2%), list(10%,5%), list(20%,10%), list(30%,20%),list(50%,30%)))

// ********************************************************************
// *    Part 2: Scenarios                                             *
// ********************************************************************


// default: 199T$ for 13.1 Gt ->  652 CO2

// h0 is my default scenario for the presentation : a little bit of CO2 tax
[h0()
   -> scenario("h0: a moderate amount of carbon tax"),
      US.carbonTax := step(list(380,0.0),list(420,50.0),list(540,100.0), list(600,200.0)),
      EU.carbonTax := step(list(380,0.0),list(420,100.0),list(540,200.0), list(600,300.0)),
      CN.carbonTax := step(list(380,0.0),list(420,50.0),list(540,100.0), list(600,100.0)),
      Rest.carbonTax := step(list(380,0.0),list(420,0.0),list(540,50.0), list(600,100.0)) ]
// h0 (used for Gaya) : 190 T$, 12.14Gtoe 627 ppm

// scenario index
// h1: test capacity to grow clean energy
// h2: test impact of fossile energy reserves
// h3: test impact of savings (efficiencty) and tech progress
// h4: test impact of the speed of energy transition
// h5: test the impact of the cancellation model for adaptation
//     +h5p: test the impact of the price sensitivity for adaptation
// h6: test different hypothesis on economy dematerialization
// h7: test the impact of growth (roi) hypothesis
// h8 / h9: test the impact of the carbon tax

// H1 looks at Green and Coal max capacity constraints
// h1g: 215 T$ for 14.7 Gt -> 651 CO2 (6.81 Gtoe clean)
[h1g()
  -> scenario("h1g: Green max capacity growth"),
  XtoClean(30%),
  Clean.growthPotential := affine(list(200,0.02), list(500,0.2),list(1000,0.3),list(6000,0.4))]
  
// Clean.growthPotential := affine(list(200,0.02), list(500,0.1),list(1000,0.2),list(6000,0.3))
   
// accelerate X to Clean transition
[XtoClean(y:Percent)
  -> for x in Consumer
       (x.subMatrix[3] := improve(x.subMatrix[3],y),     // Oil to Clean
        x.subMatrix[5] := improve(x.subMatrix[5],y),     // Coal to Clean
        x.subMatrix[6] := improve(x.subMatrix[6],y))]     // Gas to Clean

// h1c: 216 T$ for 14.9 Gt -> 677 CO2  (6.96 Gt Coal)
[string%(p:Percent)
  -> string!(integer!(p * 100)) /+ "%"]
[h1c()
  -> h1c(1%)]
[h1c(p:Percent)
   -> scenario("h1c: Coal max capacity growth" /+ string%(p)),
      Coal.capacityGrowth = p,
      Coal.inventory := affine(list(50,600), list(100,1000), list(200,1400)) ]  // lots of coal

// H2 looks at the sensitivity to fossile inventory - not the biggest issue .. PNB(2050) ranges [125/140/155]

// h2-: 181 T$ for 11.77 Gt -> 610 CO2
[h2-()
  -> scenario("h2-: conservative estimate of Oil inventory - what we believed 10 years ago"),
  Oil.inventory := affine(list(400,193.0), list(600, 220.0), list(1600, 250), list(5000, 300.0)),       // 
  Gas.inventory := affine(list(163,160.0), list(320, 190.0), list(5500, 250.0)) ]

// h2+: 238T$ for 16.26 Gt -> 713 CO2
[h2+()
 ->  scenario("h2+: more oil to be found at higher price"),
   Oil.inventory := affine(list(400,193.0), list(600, 290.0), list(800, 400), list(5000, 600.0)),       // 
   Gas.inventory := affine(list(163,160.0), list(300, 300.0), list(800, 400), list(5500, 500.0)) ] 

// debug scenario : lots of fossile energy
[h22()
 ->  scenario("h2: /!\\ DEBUG SCENARIO with plenty of fossile energy"),
   // TESTC := CN,
   // TESTE := Coal,
   Oil.inventory := affine(list(400,193.0), list(450, 290.0), list(500, 400), list(600, 800.0)),       // 
   Gas.inventory := affine(list(163,160.0), list(200, 300.0), list(250, 400), list(300, 600.0)),
   Coal.capacityGrowth := 10%,              // let the consomation grow
   Coal.inventory := affine(list(50,600), list(80,800), list(100,2000),list(200,4000)) ]

//  two dual on savings
// - savings is harder than expected
// + more saving and better tech progress
// h3-: 188 T$ for 13.41 Gt -> 654 CO2
[h3-()
  -> scenario("h3-: less savings"),
     for c in Consumer 
       (c.saving := improve(c.saving,-10%)),
      World.techFactor := 0.8 ]

// h3+: 230T$ for 12.75 Gt -> 649 CO2
[h3+()
  -> scenario("h3+: more savings"),
     for c in Consumer 
       (c.saving := improve(c.saving,20%)),
      World.techFactor := 1.2 ]

// h4 reduces the subtitution capacities  (h0 supports the growth of Clean to almost 5GToe = 55 0000 TWh = twice the total capacity in 2020)
// h4-: 186 T$ for 12 Gt -> 652 CO2
[h4-()
  -> scenario("h4-: less substitution"),
     XtoClean(-30%) ]
 
// h4+ is more optimistic 
// h4+: 209 T$ for 14 Gt -> 650 CO2  (6GToe clean)
// the key driver is XtoClean ! 
[h4+() 
  -> h4+(30%) ]
[h4+(p:Percent)
  -> scenario("h4+: more substitution at " /+ string%(p)),           
     XtoClean(p), 
     // this line reflect current capacity to add Nuclear, Wind & Solar (GTep/y), grows with biofuels
     Clean.growthPotential = affine(list(200,0.02),list(500,0.08),list(1000,0.15),list(6000,0.2)) ]

// price sensitivity cancellation  => not much !  higher cancellation -> lower PNB
// we can either play with accelerate (happens faster) or improve (happens more)
// h5-: 172 T$ for 12.08 Gt -> 597 CO2
[h5-()
  -> scenario("h5-: cancellation is harder - price will go up"),
     for c in Consumer 
       (c.cancel := accelerate(c.cancel,-30%)) ]
 
// h5+: 204 T$ for 13.9 Gt -> 659 CO2
[h5+()
  -> scenario("h5+: cancellation will happen sooner  - price will stay lower"),
    for c in Consumer 
       (c.cancel := accelerate(c.cancel,20%)) ]
 
// play with the dematerialization of the economy

// h6- is a more pessimistic scenario where the economy dependance on energy decreases more slowly
// h6-: 178 T$ for 13.8 Gt -> 650 CO2
[h6-()
   -> scenario("h6-: less dematerialization"),
      for c in Consumer 
       (c.dematerialize := improve(c.dematerialize,-30%)) ]

// h6+ is a more optimistic scenario where the economy dependance on energy decreases faster
// h6+: 220 T$ for 12.7 Gt -> 634 CO2
[h6+()
   -> scenario("h6+: more dematerialization"),
      for c in Consumer 
       (c.dematerialize := improve(c.dematerialize,20%)) ]

// play with the economic outlook about growth --------------------------------------------------

// h7+ is a more optimistic scenario where Europe and Rest of the word reach better RoI closer to US
// h7+: 205 T$ for 13.12 Gt -> 652 CO2
[h7+()
   -> scenario("h7+: optimistic outlook on growth"),
      US.roI := affine(list(2000,18%), list(2020,18%), list(2050, 17%), list(2100,16%)),
      EU.roI := affine(list(2000,6%), list(2020,8%), list(2050, 10%), list(2100,12%)),
      CN.roI := affine(list(2000,23%), list(2020,25%), list(2050, 18%), list(2100,16%)),
      Rest.roI := affine(list(2000,3%), list(2020,4%), list(2050, 6%), list(2100,10%)) ]

// h7- is a more pessimistic scenario where the world disarray means that today's level of RoI in China or US
// won't be reached in the future
// h7-: 187 T$ for 12.43 Gt -> 645 CO2
[h7-()
   -> scenario("h7-: pessimistic outlook on growth"),
      US.roI := affine(list(2000,18%), list(2020,18%), list(2050, 16%), list(2100,13%)),
      EU.roI := affine(list(2000,4.5%), list(2020,4.5%), list(2050, 6%), list(2100,8%)),
      CN.roI := affine(list(2000,23%), list(2020,25%), list(2050, 16%), list(2100,12%)),
      Rest.roI := affine(list(2000,3%), list(2020,3%), list(2050, 4%), list(2100,5%))]

// increase price sensitivity
[h7p()
 -> scenario("h7p: lower price sensitivity => reach higher prices"),
    Oil.sensitivity := 30%,
    Gas.sensitivity := 30%,
    Coal.sensitivity := 50%]
// h7p: 201 T$ for 13.34 Gt -> 641 CO2
 
// play with carbon tax ===================================================

// carbonTax should accelerate the transition to clean energy
[h8()
   -> scenario("h8: true application of the carbon tax with moderate values"),
      US.carbonTax := affine(list(380,80.0),list(420,80.0),list(470,80.0), list(600,80.0)),
      EU.carbonTax := US.carbonTax,
      CN.carbonTax := US.carbonTax,
      Rest.carbonTax := US.carbonTax ]

[h8+()
   -> scenario("h8+: heavy carbon tax !"),
      US.carbonTax := affine(list(380,200.0),list(430,250.0),list(480,350.0), list(600,450.0)),
      EU.carbonTax := US.carbonTax,
      CN.carbonTax := US.carbonTax,
      Rest.carbonTax := US.carbonTax ]

[h8++()
   -> scenario("h8++: very heavy carbon tax !"),
      US.carbonTax := affine(list(380,400.0),list(430,450.0),list(480,550.0), list(600,650.0)),
      EU.carbonTax := US.carbonTax,
      CN.carbonTax := US.carbonTax,
      Rest.carbonTax := US.carbonTax ]

// -------------------- TRIANGLE SCENARIOS : Nordhaus, Jancovici, Diamondis -------------------

// here we look at h0 with different levels of savings and transition policies
[h0s(factor:Percent)
  -> scenario("h0s: Parametric savings at " /+ string!(integer!(factor * 100.0)) /+ "%"),
     for c in Consumer 
          adjust(c.saving,factor),   // adjust the savings from 0 to 100%
      go(90)]

[h0t(factor:Percent)
  -> scenario("h0t: Parametric transition at " /+ string!(integer!(factor * 100.0)) /+ "%"),
     for c in Consumer 
          (for a in c.subMatrix adjust(a,factor)),
      go(90)]

// Nordhaus: find the belief such that the economic optimal is letting the planet warm up to 3.5C 
// requires fair amount of fossile
[h11(factor:Percent)
   -> scenario("h11: Parametric Nordhaus at " /+ string!(integer!(factor * 100.0)) /+ "%"),
      Gaia.disasterLoss := affine(list(1.0,0),list(1.5,1.5%),list(2,2%),list(3,3%),list(4,4%),list(5,5%)), 
      Oil.inventory := affine(list(400,193.0), list(600, 350.0), list(800, 450), list(5000, 600.0)),       // 
      Gas.inventory := affine(list(163,160.0), list(300, 300.0), list(800, 450), list(5500, 500.0)),
      Coal.capacityGrowth := 2%,
      XtoClean(-30%),
      // mitigation here is CO2 tax
      US.carbonTax := step(list(380,0.0),list(420,100.0),list(470,200.0), list(600,300.0)),
      EU.carbonTax := step(list(380,0.0),list(420,100.0),list(470,200.0), list(600,300.0)),
      CN.carbonTax := step(list(380,0.0),list(420,40.0),list(470,100.0), list(600,200.0)),
      Rest.carbonTax := step(list(380,0.0),list(420,40.0),list(470,100.0), list(600,200.0)),
      // parametrization of carbon tax 
      for c in Consumer 
           adjust(c.carbonTax,factor),   // adjust  from 0 to 100%
      go(90) ]

// result at 10%: 255, 15,7 Gt -at 725 (+ 3C)

// Jancovici scenario : do the best to stay below +1.5C = 15.2C (15.4 OK)
// we use a heavy carbon tax to reduce CO2 emissions
// we assume a high level of savings (efficiency) and a fast transition to clean
[h12(factor:Percent)
   -> scenario("h12: Jancovici scenario below +1.5C, @ " /+ string%(factor)),
      XtoClean(40%),
      for c in Consumer 
       (c.cancel := improve(c.cancel,-40%)),      // acceleration through sobriety
      // assumes that no new fossil exploration is allowed
      Oil.inventory := affine(list(400,193.0), list(600, 220.0), list(1600, 230.0), list(5000, 250.0)),       // 
      Gas.inventory := affine(list(163,160.0), list(320, 190.0), list(5500, 240.0)),
      Coal.capacityGrowth = 0%,                  // no new coal
      Clean.growthPotential := affine(list(200,0.02), list(500,0.2),list(1000,0.3),list(6000,0.4)),
      US.carbonTax := step(list(380,0.0),list(420,200.0),list(450,250.0),list(480,300.0),list(600,400.0)),
      EU.carbonTax := step(list(380,0.0),list(420,250.0),list(450,300.0),list(480,400.0),list(600,500.0)),
      CN.carbonTax := step(list(380,0.0),list(420,200.0),list(450,250.0),list(480,300.0),list(600,400.0)),
      Rest.carbonTax := step(list(380,0.0),list(420,200.0),list(450,250.0),list(480,300.0),list(600,400.0)),
      // parametrization of carbon tax 
      for c in Consumer 
           adjust(c.carbonTax,factor),   // adjust  from 0 to 100%
      go(90) ]

// h12(200%): 148T$ for 9.3 Gt -> 500 CO2 (15.7 C, 1.8) - fits "accord de Paris"
// however breaks China growth

//  Abundance Scenario (Peter H Diamandis)
//  technology improves -> savings profile shows constant improvement
//  also the capacity to grow clean will be higher in the future
//  last we transition faster to clean post 2050 thanks to technology
[h13(factor:Percent)
   -> scenario("h13: Diamandis Scenario at " /+ string!(integer!(factor * 100.0)) /+ "%"),
      XtoClean(50%),
      for c in Consumer 
         (c.saving := improve(c.saving,30%)),
      World.techFactor := 1.2,
      let CT2 := step(list(380,0.0),list(420,100.0),list(470,150.0), list(600,200.0)) in
           (US.carbonTax := CT2,
            EU.carbonTax := CT2,
            CN.carbonTax := CT2,
            Rest.carbonTax := CT2),
      // parametrization of these curves 
      for c in Consumer 
           adjust(c.carbonTax,factor),   // adjust  from 0 to 100%
      go(90) ]

// h13(150%)  -> 209T$ at 10.52Gtoe 511ppm (15.8)

// parameter tuning (March 23rd)
// h11 -> 50% is the best
// h12 -> 100% is the best, but tax starts too soon
// h13 -> 100% 
// reproduce Michelin shapes
[shapes(i:integer) : void
 -> if (i = 1) h11(0%)                       // Nordhaus (16.8C,  222 CO2/K 2035, 124T$ in 2035)   
   else if (i = 2) h12(100%)                 // Jancovici (15.2C, 197 CO2/K 2035, 92T$ in 2035)
   else if (i = 3) h13(95%)                  // Diamandis (16.3C, 198 CO2/K 2035, 107T$ in 2035)
   else if (i = 4) go(90) ]                  // Default (16.5C, 222 CO2/K 2035, 112T$ in 2035)

[scenario(s:string)
   -> pb.comment := s,
      printf("*** Apply scenario: ~A\n",s)]

// ********************************************************************
// *    Part 3: Miscelaneous (go)                                     *
// ********************************************************************


// launch a scenario
[go(p:property,n:integer) 
  -> p(), go(n)]

// play with the model -----------------------------------------------------------------


// test display
A :: affine(list(500,0.0),list(800,1.0),list(1400,4.0),list(2800,2.0),list(6000,0.0))
[ga() 
  -> display(A)]

// first step : do one year of simulation in verbose mode
[go0()
  -> init(World,Oil,Clean),
     // HOW := 1,
     TESTE := Clean,
     one()]

// CRAZY CLAIRE BUG: if this method is called add, the code cannot be printed
// add n years of simulations
[add_years(n:integer)
  -> time_set(),
     for i in (1 .. n) run(pb),
     time_show(),
     see() ]
     // hist(TESTE), 
     // hist()]

// do n years of simulation
[go(n:integer)
   -> init(World,Oil,Clean),
      add_years(n) ]

// do one year with more info
[one()
  -> SHOW2 := 1, DEBUG := 1,
     run(pb),
     see() ] 

// repeatable (step by step)
[go1(n:integer)
   -> if unknown?(earth,pb) init(pb),
      for i in (1 .. n) run(pb),
      see() ]

// shortcut for one century
[go(h:property)
  -> call(h,list()),
     go(90)]

// ------------------ useful : Excel interface -------------------------------------------------
// produce a table of results - this is the simple version for the CCEM paper
// GDP, Energy, CO2 emission, temperature
// convenient we add 2000 for reference
Reference2000 :: list<float>(33.8,EJ(9.3),14.5,25.0)  // GDP, EJ, T$ and CO2
[excel(s:string)
 -> let p := fopen(s,"w") in
   (use_as_output(p),
    printf(",~I\n",
        pListNumber(list(2000) /+ list{year!(1 + (i - 1) * 10) | i in (1 .. 10)})),
    // print GDP 
    printf("GDP (T$), ~I \n",
        pListNumber(list(Reference2000[1]) /+
            list{integer!(pb.world.all.results[1 + (i - 1) * 10 ]) | i in (1 .. 10)})),
    // print energy 
    printf("Energy (EJ), ~I \n",
       pListNumber(list(Reference2000[2]) /+
            list{integer!(EJ(pb.world.all.totalConsos[1 + (i - 1) * 10 ])) | i in (1 .. 10)})),
    // print temperature 
    printf("Temperature(C), ~I \n",
    pListNumber(list(Reference2000[3]) /+
            list{pb.earth.temperatures[1 + (i - 1) * 10 ] | i in (1 .. 10)})),
    // print CO2
    printf("CO2(Gt/y), ~I \n",
       pListNumber(list(Reference2000[4]) /+
            list{pb.earth.co2Emissions[1 + (i - 1) * 10 ] | i in (1 .. 10)})),
     fclose(p))]


// print a list on numbers
[pListNumber(l:list)
  -> for x in l 
      (case x (integer printf("~A,",x),
               float printf("~F1,",x))) ]


// this table reproduces the Kaya equation
ReferenceKaya :: list(6.6,240,TWh(9.3) / (10.0 * 33.8),33.8 / 6.6)
[kaya(s:string)
 -> let p := fopen(s,"w") in
   (use_as_output(p),
    printf(",~I\n",
        pListNumber(list(2000) /+ list{year!(1 + (i - 1) * 10) | i in (1 .. 10)})),
    // print world population 
    printf("Pop (G), ~I \n",
        pListNumber(list(ReferenceKaya[1]) /+
            list{ worldPopulation(year!(1 + (i - 1) * 10)) | i in (1 .. 10)})),
     // print CO2/Energy
    printf("gCO2/KWh, ~I \n",
       pListNumber(list(ReferenceKaya[2]) /+
            list{co2KWh(1 + (i - 1) * 10 ) | i in (1 .. 10)})),
     // print energy/GDP 
    printf("e-intensity (kWh/$) / 10, ~I \n",
       pListNumber(list(ReferenceKaya[3]) /+
            list{ (energyIntensity(1 + (i - 1) * 10 ) * 100.0) | i in (1 .. 10)})),
    // print GDP/inhabitant 
    printf("GDP/p (100$), ~I \n",
    pListNumber(list(ReferenceKaya[4]) /+
            list{(10.0 * gdpp(1 + (i - 1) * 10 )) | i in (1 .. 10)})),
    fclose(p))]
// ------------------ INTERPRETED CODE FRAGMENT ------------------------------------------------

// upload(m:module,proj:string,user:string,commit:string)
// uploads all the files from m onto github with a commit comment, onto
// assumes that git init has been done
// note: this is why we need m.resources !!!
[upload(m:module,proj:string,user:string,resources:list<string>,comment:string)
  -> let cdstring := "cd " /+ m.source /+ ";" in
      (for f in m.made_of shell(cdstring /+ "git add " /+ f /+ ".cl"),
       for f in resources shell(cdstring /+ "git add " /+ f),
       shell(cdstring /+ "git commit -m \"" /+ comment /+ "\""),
       shell(cdstring /+ "git push -f origin master"))
]

// this uploads the current version of the code on github
[upload(m:module,s:string)
  -> upload(m,"GWDG","ycaseau",list<string>("test1.cl"),s) 
]

// how to use it: upload(gw4,"bla bla bla"")
// ------------------ END OF FRAGMENT : upload -------------------------------------------------