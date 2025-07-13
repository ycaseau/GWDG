// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2025 Yves Caseau                        *
// *       file: scenario.cl - version GWDG 0.6                       *
// ********************************************************************

// this file contains a simple description of our problem scenarios
// Vocabulary : 
//    Experiments : the conditions to run the CCEM model
//    Scenarios : outcome of the simulation (a set of charts that could be shared with IAMC)
// this is a 2024-Xmas revision used for CCEM24 paper

// ********************************************************************
// *    Part 1: KNU cones                                             *
// *    Part 2: Sensitivity Experiments                               *
// *    Part 3: Three scenarios : Nordhaus / Jancovici / Singularity  *
// *    Part 4: CCEMv7 Tactical Experiments                           *
// *    Part 5: Tactical Optimization (hand tuning version)           *
// ********************************************************************

// ********************************************************************
// *    Part 1: KNU cones                                             *
// ********************************************************************

// in v7 we separate between two kind of KNUs: FutureKNU (to play with in the interface) 
// and ModelKNU (to use for sensitivity analysis in the model)
// Future KNU (with explicit name to simplify scripting)
//   - KOilGas(number), Kgreen (shape : speed of renew), Kelec: speed of electrification
//     Kdamage: GDP loss = f(delta T), Khuman: engagement / efficiency of human workforce
//     Kadap: possibility of adaptation (scope) x insurance cost ratio
// Model KNU  (proper to CCEM, used for sensitivity analysis)
//   - Kintensity, Kelasticity, KRoI, Ktrade

// KOilGas is a way to play with the fossile reserves for oil and gas.
// it is a corrective factor applied to the inventory of oil and gas
KOilGas :: KNUfactor(
   description = "Oil and Gas Reserves",
   median = 1.0,
   lower = 0.7,
   higher = 3.0,
   measured-with = "Oil & Gas between 2010 and 2050",
   onto = {Oil,Gas},
   modify = inventory,
   kpi = (p){totalConso(Oil,1,40) + totalConso(Gas,1,40)})

// the mean is at 1.3PW/y in 2030, max is NZE/IRENA at 2.5 PW/y 
KGreen :: KNUcone(
   description = "Wind & Solar Deployed Capacity Growth Rate",
   median = affine(list(2000,0.2), list(2020,0.2),list(2030,1.5),list(2040,2.0),list(2100,4.0)),
   lower = affine(list(2000,0.2), list(2020,0.2),list(2030,0.5),list(2040,0.7),list(2100,1.0)),
   higher = affine(list(2000,0.2), list(2020,0.2),list(2030,2.5),list(2040,3.0),list(2100,5.0)),
   measured-with = "yearly growth from 2020 to 2030 (PWh/h)", 
   onto = pb.clean,
   modify = growthPotential,
   kpi = (p){ (p.clean.outputs[21] - p.clean.outputs[11]) / 10.0})


// Electrification of energy is the KPI that represents the speed of energy transition
// here we have a complex matrix (N x N) to which we apply a factor
KElec :: KNUfactor(
   description = "Electrification of Energy",
   median = 1.0,
   lower = 0.0,
   higher = 2.0,
   measured-with = "electrification ratio in 2050",
   onto = Consumer,
   modify = subMatrix,
   kpi = (p){electrification%(41)})

// Global Warming damage expressed as a % of GDP, as a function of temperature
// note that in the future, we should assign a zone factor (worse for Asia, better for Europe)
KDamage :: KNUcone(
   description = "Global Warming Damage",
   median = affine(list(1.0,0),list(1.5,1.5%),list(2,4%),list(3,8%),list(4,15%),list(5,25%)),  // cf. Schroders
   lower = affine(list(1.0,0),list(1.5,1%),list(2,2%),list(3,3%),list(4,5%),list(5,10%)),  // cf. Nordhaus
   higher = affine(list(1.0,0),list(1.5,5%),list(2,15%),list(3,25%),list(4,40%),list(5,60%)),  // cf. NIGEM
   measured-with = "% of GDP lost in 2100",
   onto = Consumer,
   modify = disasterLoss,
   kpi = (p){p.world.all.disasterRatios[91]})

// Impact of global satisfaction on the economy (includes material economy impact)
KHuman :: KNUfactor(
   description = "Global Satisfaction Impact on Economy",
   median = 1.0,
   lower = 0.5,
   higher = 2.0,
   measured-with = "CCEM factor pain2productivity",
   onto = Consumer,
   modify = productivityFactor,
   kpi = (p){ pain2productivity()})


// Adptation Efficiency KNU
// the affine shows how much of attenuation is reached with a total investement of x% of D3(c)
KAdapt :: KNUfactor(
   description = "Global Adaptation Efficiency",
   median = 1.0,  // ask Michelin about the cost of its adaptation plan
   lower = 0.5,   // 
   higher = 2.0,  // 
   measured-with = "% of GDP lost in 2100",  
   onto = Adaptation,
   modify = efficiency,
   kpi = (p){p.world.all.disasterRatios[91]})

// list of 6 key KNUs
KNUs :: list(KOilGas, KGreen, KElec, KDamage, KHuman, KAdapt) 

// Parametric KNU for the model ---------------------------------------------------

// note : different curves, we apply a factor (KNU)
// if proven, the theory that there is one curve and that different zones are at different
// maturity ...
KIntensity :: KNUfactor(
   description = "Energy Intensity Improvement",
   median = 1.0,
   lower = 0.0,
   higher = 3.0,
   measured-with = "CAGR between 2010 and 2050",
   onto = Block,
   modify = dematerialize,
   kpi = (p){CAGR(energyIntensity(1),energyIntensity(41),40)})

// Energy price elasticity (how cancellation grows if price increases)
// associated KPI = cancel rate in 2050 as a function of price increase
KElasticity :: KNUfactor(
   description = "Energy Price Elasticity",
   median = 1.0,
   lower = 0.5,
   higher = 2.0,
   measured-with = "cancel rate in 2050 as a function of price increase",
   onto = Supplier,
   modify = sensitivity,
   kpi = (p){elasticity()})

// Return on Investment : a factor since each zone is different
// associated KPI = CAGR of GDP (constant dollars) between 2010 and 2050
KRoI :: KNUfactor(
   description = "Growth derived from Return on Investment",
   median = 1.0,
   lower = 0.3,
   higher = 2.0,
   measured-with = "CAGR of GDP (constant dollars) between 2010 and 2050",
   onto = Block,
   modify = roI,
   kpi = (p){CAGR(p.world.all.results[1],p.world.all.results[41],40)})
   
// Trade Barrier impact
// the kpi is difficult to establish without a what-if analysis
KTrade :: KNUfactor(
   description = "Trade Barrier Impact",
   median = 1.0,
   lower = 0.5,
   higher = 2.0,
   measured-with = "trade barrier impact on GDP",
   onto = World,
   modify = protectionismFactor,
   kpi = (p){tradeBarrier()})


// ********************************************************************
// *    Part 2: Sensitivity Experiments                               *
// ********************************************************************

// note : the default scenario has no carbon 

// recalibration (May 3rd) for Model 7 on GDP x Energy
// defau(2020) PNB: 74.0T$, 150.1PWh -> 411.2ppm CO2, 14.6C, 9.4PWh clean, 18.4% electricity
// defau(2030) PNB: 88.3T$, 168.6PWh -> 437.2ppm CO2, 14.9C, 16.0PWh clean, 21.9% electricity
// defau(2050) PNB: 117.8T$, 168.1PWh -> 488.5ppm CO2, 15.5C, 33.5PWh clean, 32.1% electricity
// defau(2100) PNB: 123.4T$, 94.0PWh -> 574.8ppm CO2, 16.3C, 39.2PWh clean, 52.6% electricity


// =======================   Experiment index ========================
// h1: test capacity to grow clean energy
// h2: test impact of fossile energy reserves
// h3: test impact of savings (efficiencty) and tech progress
// h4: test impact of the speed of energy transition
// h5: test the impact of the cancellation model for adaptation
//     +h5p: test the impact of the price sensitivity for adaptation
// h6: test different hypothesis on economy dematerialization
// h7: test the impact of growth (roi) hypothesis
// h8 / h9: test the impact of the carbon tax

// h0 is default, h00 is debug
// no transition by default pushed each one to transition more ...
h00 :: Experiment(
   comment = "no transition by default",
   init = (n){ 
       for c in Consumer c.tactic.transitionStart := 0%})

// H1 looks at Green and Coal max capacity constraints
// h1+: (2100) PNB: 153.7T$, 180.8PWh -> 599.7ppm CO2, 16.4C, 96.1PWh clean, 55.8% electricity
// default for Green capacity : affine(list(2000,0.2), list(2020,0.2),list(2030,1.5),list(2040,2.0),list(2100,4.0)),
h1+ :: Experiment(
   comment = "h1g: Green max capacity growth",
   init = (n){ 
       XtoClean(20%),
       Clean.growthPotential := affine(list(2000,0.23), list(2020,1.5),list(2050,3.0),list(2100,5.0))})
  
// accelerate X to Clean transition - fixe in June to use improve% !
[XtoClean(y:Percent)
  -> for x in Consumer
       (x.subMatrix[3] := improve%(x.subMatrix[3],y),     // Oil to Clean
        x.subMatrix[5] := improve%(x.subMatrix[5],y),     // Coal to Clean
        x.subMatrix[6] := improve%(x.subMatrix[6],y))]     // Gas to Clean

// opposite : slow transition and limited capacity
// h1-: (2100) PNB: 104.9T$, 120.4PWh -> 609.3ppm CO2, 16.4C, 42.7PWh clean, 43.4% electricity
h1- :: Experiment(
   comment = "h1-: Green limited capacity growth",
   init = (n){ 
       XtoClean(-20%),
       Clean.growthPotential := affine(list(2000,0.2), list(2020,0.2),list(2050,2.0),list(2100,3.0))})


// see what happens with a lot of coal
// h1c: (2100) PNB: 128.3T$, 136.7PWh -> 615.9ppm CO2, 16.4C, 53.4PWh clean, 50.5% electricity
[string%(p:Percent)
  -> string!(integer!(p * 100)) /+ "%"]

h1c :: Experiment(
   comment = "h1c: Coal max capacity growth " /+ string%(2%),
   init = (n){ 
       Coal.capacityGrowth := 2%,
       Coal.inventory := affine(list(perMWh(50.0),PWh(600.0)), list(perMWh(100.0),PWh(1000.0)), 
                                list(perMWh(200.0),PWh(1400.0)) )})  // lots of coal
  

// H2 looks at the sensitivity to fossile inventory - not the biggest issue .. PNB(2050) ranges [125/140/155]
// this is used for the CCEM 2024 paper
// h2-: (2100) PNB: 100.9T$, 107.8PWh -> 584.2ppm CO2, 16.3C, 45.5PWh clean, 52.8% electricity
h2- :: Experiment(
   comment = "h2-: conservative estimate of Oil inventory - what we believed 10 years ago",
   init = (n){ 
       Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(600.0), PWh(220.0)), 
                               list(perMWh(1600.0), PWh(250.0)), list(perMWh(5000.0), PWh(280.0))),
       Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(320.0), PWh(190.0)), 
                               list(perMWh(5500.0), PWh(250.0)))})
 
                                
// h2+: (2100) PNB: 146.6T$, 165.7PWh -> 625.9ppm CO2, 16.4C, 58.5PWh clean, 48.9% electricity
// more oil to be found (2010: what we know in 2024)
h2+ :: Experiment(
   comment = "h2+: more oil to be found at higher price",
   init = (n){ 
       Oil.inventory := affine(list(perMWh(400.0),PWh(270.0)), list(perMWh(600.0), PWh(350.0)), 
                               list(perMWh(1200.0), PWh(450.0)), list(perMWh(5000.0), PWh(600.0))),
       Gas.inventory := affine(list(perMWh(163.0),PWh(200.0)), list(perMWh(300.0), PWh(300.0)), 
                               list(perMWh(600.0), PWh(450.0)), list(perMWh(5500.0), PWh(700.0)))})
 

// debug scenario : lots of fossile energy
// h2++: (2100) PNB: 198.1T$, 233.5PWh -> 657.3ppm CO2, 16.5C, 69.1PWh clean, 45.3% electricity
h2++ :: Experiment(
   comment = "h2++: /!\\ DEBUG SCENARIO with plenty of fossile energy",
   init = (n){ 
       Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(450.0), PWh(290.0)), 
                               list(perMWh(600.0), PWh(400.0)), list(perMWh(800.0), PWh(800.0))),
       Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(200.0), PWh(300.0)), 
                               list(perMWh(250.0), PWh(400.0)), list(perMWh(300.0), PWh(600.0))),
       Coal.capacityGrowth := 10%,              // let the consomation grow
       Coal.inventory := affine(list(perMWh(50.0),PWh(600.0)), list(perMWh(80.0),PWh(800.0)), 
                                list(perMWh(100.0),PWh(2000.0)),list(perMWh(200.0),PWh(4000.0))) })


// h3a: allows extra efficiency investments
// h3a: (2100) PNB: 148.9T$, 129.6PWh -> 600.7ppm CO2, 16.4C, 49.3PWh clean, 49.9% electricity
h3a :: Experiment(
   comment = "h3a: more enerygy efficiency",
   init = (n){ 
       for c in Consumer c.tactic.savingStart := 100%})


// h3b: (2100) PNB: 120.0T$, 129.0PWh -> 606.9ppm CO2, 16.4C, 51.8PWh clean, 51.2% electricity
h3b :: Experiment(
   comment = "h3b: more tech progress",
   init = (n){ 
       for s in Supplier s.techFactor := 3% })

//  add a Loop : pain to productivity
// h3c: (2100) PNB: 118.3T$, 126.6PWh -> 605.7ppm CO2, 16.4C, 50.4PWh clean, 51.0% electricity
h3c :: Experiment(
   comment = "h3c: pain reduces productivity",
   init = (n){ 
        for c in Consumer c.productivityFactor := 20% })

//  add a Loop : pain to population de-growth (India pop = )
// h3d: (2100) PNB: 119.4T$, 125.4PWh -> 605.8ppm CO2, 16.4C, 50.0PWh clean, 51.0% electricity
h3d :: Experiment(
   comment = "h3d: pain reduces fertility and increases early deaths",
   init = (n){ 
        for c in Consumer c.populationFactor := 20% })

// h4 reduces the subtitution capacities  (h0 supports the growth of Clean to almost 5GToe = 55 0000 TWh = twice the total capacity in 2020)
// h4-: (2100) PNB: 105.5T$, 112.3PWh -> 606.8ppm CO2, 16.4C, 36.0PWh clean, 42.9% electricity
h4- :: Experiment(
   comment = "h4-: less substitution",
   init = (n){ 
       XtoClean(-30%) })
 
// h4+ is more optimistic (20% shift to clean substitution) => Huge effect on GDP
// h4+: (2100) PNB: 149.2T$, 163.7PWh -> 597.8ppm CO2, 16.3C, 85.8PWh clean, 63.9% electricity
// the key driver is XtoClean ! 
h4+ :: Experiment(
   comment = "h4+: more substitution at " /+ string%(20%),           
   init = (n){ 
       XtoClean(20%) , 
     // this line reflect current capacity to add Nuclear, Wind & Solar (GTep/y), grows with biofuels
     Clean.growthPotential = affine(list(2000,0.02),list(2020,0.9),list(2050,1.74),list(2100,22.0))})

// note : this pair h5+/h5- with improve% (additive) is a debug version (little sense, should still work)
// better to use multiply%() - cf. simul.cl

// price sensitivity cancellation  => higher price, hence more fossile
// h5-: (2100) PNB: 122.0T$, 141.6PWh -> 613.5ppm CO2, 16.4C, 56.2PWh clean, 50.6% electricity
h5- :: Experiment(
   comment = "h5-: cancellation is harder - price will go up",
   init = (n){ 
       for c in Consumer 
         (c.cancel := multiply%(c.cancel,-20%)) })

 
// h5+: (2100) PNB: 111.3T$, 127.8PWh -> 606.5ppm CO2, 16.4C, 53.1PWh clean, 51.8% electricity
h5+ :: Experiment(
   comment = "h5+: cancellation will happen sooner  - price will stay lower",
   init = (n){ 
       for c in Consumer 
         (c.cancel := multiply%(c.cancel,20%)) })
 
// play with the dematerialization of the economy

// h6- is a more pessimistic scenario where the economy dependance on energy decreases more slowly
// h6-: (2100) PNB: 95.5T$, 150.0PWh -> 615.2ppm CO2, 16.4C, 63.1PWh clean, 52.2% electricity
 h6- :: Experiment(
   comment = "h6-: less dematerialization",
   init = (n){ 
       for b in Block 
         (b.dematerialize := improve%(b.dematerialize,-30%)) })

// h6+ is a more optimistic scenario where the economy dependance on energy decreases faster
// h6+: (2100) PNB: 149.1T$, 138.6PWh -> 602.2ppm CO2, 16.4C, 53.5PWh clean, 49.6% electricity
h6+ :: Experiment(
   comment = "h6+: more dematerialization",
   init = (n){ 
       for b in Block 
         (b.dematerialize := improve%(b.dematerialize,20%)) })

  
// play with the economic outlook about growth --------------------------------------------------

// defaults for comparison
// US:Affine(2000.00:0.17 2020.00:0.17 2023.00:0.22 2050.00:0.18 2100.00:0.17)
// EU:Affine(2000.00:0.05 2020.00:0.05 2023.00:0.15 2050.00:0.14 2100.00:0.14)
// CN:Affine(2000.00:0.24 2020.00:0.23 2023.00:0.17 2050.00:0.15 2100.00:0.15)
// IN:Affine(2000.00:0.16 2020.00:0.16 2023.00:0.21 2050.00:0.18 2100.00:0.16)
// Rest:Affine(2000.00:0.03 2020.00:0.03 2023.00:0.10 2050.00:0.09 2100.00:0.12)

// h7+ is a more optimistic scenario where Europe and Rest of the word reach better RoI closer to US
// h7+: (2100) PNB: 137.9T$, 147.7PWh -> 616.2ppm CO2, 16.4C, 58.5PWh clean, 51.0% electricity
h7+ :: Experiment(
   comment = "h7+: optimistic outlook on growth",
   init = (n){ 
       US.economy.roI := affine(list(2000,17%), list(2020,18%), list(2050, 19%), list(2100,19%)),
       EU.economy.roI := affine(list(2000,5%), list(2020,8%), list(2050, 15%), list(2100,15%)),
       CN.economy.roI := affine(list(2000,24%), list(2020,24%), list(2050, 20%), list(2100,17%)),
       IN.economy.roI := affine(list(2000,16%), list(2020,18%), list(2050, 18%), list(2100,18%)),
       Rest.economy.roI := affine(list(2000,3%), list(2020,4%), list(2050, 10%), list(2100,14%)) })

// h7- is a more pessimistic scenario where the world disarray means that today's level of RoI in China or US
// won't be reached in the future
// h7-: (2100) PNB: 110.8T$, 117.4PWh -> 601.9ppm CO2, 16.4C, 43.4PWh clean, 49.6% electricity
h7- :: Experiment(
   comment = "h7-: pessimistic outlook on growth",
   init = (n){ 
       US.economy.roI := affine(list(2000,17%), list(2020,17%), list(2050, 16%), list(2100,15%)),
       EU.economy.roI := affine(list(2000,5%), list(2020,5%), list(2050, 5%), list(2100,8%)),
       CN.economy.roI := affine(list(2000,24%), list(2020,20%), list(2050, 15%), list(2100,13%)),
       IN.economy.roI := affine(list(2000,16%), list(2020,15%), list(2050, 12%), list(2100,10%)),
       Rest.economy.roI := affine(list(2000,3%), list(2020,3%), list(2050, 5%), list(2100,8%)) })

// increase price sensitivity
// h7p: (2100) PNB: 114.0T$, 131.7PWh -> 606.7ppm CO2, 16.4C, 53.2PWh clean, 51.1% electricity
h7p :: Experiment(
   comment = "h7p: lower price sensitivity => reach higher prices",
   init = (n){ 
       Oil.sensitivity :* 50%,
       Gas.sensitivity :* 50%,
       Coal.sensitivity :* 50% })

  
// play with carbon tax ===================================================

// carbonTax should accelerate the transition to clean energy
// h8- is a scenario where tOnly Europe plays the game
// h8-: (2100) PNB: 117.4T$, 138.2PWh -> 613.9ppm CO2, 16.4C, 56.1PWh clean, 52.1% electricity
h8- :: Experiment(
   comment = "h8-: carbon tax only in Europe",
   init = (n){ 
       US.carbonTax := affine(list(380,0.0),list(420,0.0),list(470,0.0), list(600,0.0)),
       EU.carbonTax := affine(list(380,0.0),list(420,50.0),list(470,50.0), list(600,50.0)),
       CN.carbonTax := US.carbonTax,
       IN.carbonTax := US.carbonTax,
       Rest.carbonTax := US.carbonTax })

// here we appy a constant C02 tax once we reach 420 ppm
// h8: t(2100) PNB: 83.1T$, 91.3PWh -> 557.2ppm CO2, 16.2C, 41.2PWh clean, 43.0% electricity
h8 :: Experiment(
   comment = "h8: true application of the carbon tax with moderate values",
   init = (n){ 
       US.carbonTax := affine(list(380,0.0),list(420,50.0),list(470,50.0), list(600,50.0)),
       EU.carbonTax := US.carbonTax,
       CN.carbonTax := US.carbonTax,
       IN.carbonTax := US.carbonTax,
       Rest.carbonTax := US.carbonTax })

// heavy carbon tax .... at the very  begining
// h8+: (2100) PNB: 73.0T$, 86.9PWh -> 511.6ppm CO2, 15.7C, 32.7PWh clean, 37.5% electricity
h8+ :: Experiment(
   comment = "h8+: heavy carbon tax !",
   init = (n){ 
       US.carbonTax := affine(list(380,200.0),list(430,200.0),list(480,300.0), list(600,400.0)),
       EU.carbonTax := US.carbonTax,
       CN.carbonTax := US.carbonTax,
       IN.carbonTax := US.carbonTax,
       Rest.carbonTax := US.carbonTax })


// play with damages

// debug - no impact of warming
// h9d: (2100) PNB: 122.0T$, 139.5PWh -> 611.8ppm CO2, 16.4C, 57.1PWh clean, 51.4% electricity
// cool : default to h9 = environ 6% de GDP en moins 113 -> 122
h9d :: Experiment(
   comment = "h9d: no impact of warming",
   init = (n){ 
       US.disasterLoss := affine(list(1.0,0),list(1.5,0),list(2,0),list(3,0),list(4,0),list(5,0)),
       EU.disasterLoss := US.disasterLoss,
       CN.disasterLoss := US.disasterLoss,
       IN.disasterLoss := US.disasterLoss,
       Rest.disasterLoss := US.disasterLoss })

// Nordhaus like impact
// h9-: (2100) PNB: 118.9T$, 135.8PWh -> 610.6ppm CO2, 16.4C, 55.7PWh clean, 51.6% electricity
h9- :: Experiment(
   comment = "h9-: Global warming damages with moderate values for impact",
   init = (n){ 
       US.disasterLoss := affine(list(1.0,0),list(1.5,1.5%),list(2,2%),list(3,3%),list(4,4%),list(5,5%)),
       EU.disasterLoss := US.disasterLoss,
       CN.disasterLoss := US.disasterLoss,
       Rest.disasterLoss := US.disasterLoss })

// h9+: (2100) PNB: 113.0T$, 131.3PWh -> 608.5ppm CO2, 16.4C, 53.3PWh clean, 51.1% electricity
// this example shows some rebound effect for China (destruction -> less demand -> lower prices -> better for CN)
h9+ :: Experiment(
   comment = "h9+: Global warming damages with high values for impact",
   init = (n){ 
       US.disasterLoss := affine(list(1.0,0),list(1.5,3%),list(2,6%),list(3,12%),list(4,20%),list(5,30%)),
       EU.disasterLoss := US.disasterLoss,
       CN.disasterLoss := US.disasterLoss,
       Rest.disasterLoss := US.disasterLoss })

// h9++:(2100) PNB: 108.9T$, 128.2PWh -> 607.1ppm CO2, 16.4C, 51.7PWh clean, 50.7% electricity
h9++ :: Experiment(
   comment = "h9++: Global warming damages with high values for impact",
   init = (n){ 
       US.disasterLoss := affine(list(1.0,0),list(1.5,5%),list(2,9%),list(3,18%),list(4,30%)),
       EU.disasterLoss := US.disasterLoss,
       CN.disasterLoss := US.disasterLoss,
       Rest.disasterLoss := US.disasterLoss })

// adaptation scenarios (plus test)
h10t :: Experiment(
   comment = "adaptation for Eureope   ",
   init = (n){ EU.tactic.adaptStart := 10% })

h10- :: Experiment(
   comment = "h10-: Adaptation is more expensive and difficult",
   init = (n){ 
       for c in Consumer 
          (c.adapt := Adaptation(efficiency = affine(list(0,0.0), list(700%,50%))))})

h10+ :: Experiment(
   comment = "h10+: Adaptation is easier and cheaper",
   init = (n){ 
       for c in Consumer 
          (c.adapt := Adaptation(efficiency = affine(list(0,0.0), list(300%,60%), list(700%,70%))))})

// h11 : CBAM tests
// Europe sets a Carbon Border Adjustment Mechanism (CBAM) to protect its industry
h11 :: Experiment(
   comment = "h11: CBAM test",
   init = (n){ EU.carbonTax := affine(list(380,0.0),list(420,50.0),list(470,50.0), list(600,50.0)),
               EU.tactic.protectionismStart := 50% }) 

// fun test where Europe is obsessed with its CO2 emissions
h11+ :: Experiment(
   comment = "h11+: Europe is obsessed with its CO2 emissions",
   init = (n){ EU.objective := strategy(-3.5%,0%,60%,20%),
               EU.carbonTax := affine(list(380,0.0),list(420,50.0),list(470,50.0), list(600,50.0)),
               EU.tactic.protectionismStart := 50% })

// ********************************************************************
// *    Part 3: Three scenarios : Nordhaus / Jancovici / Singularity  *
// ********************************************************************

// -------------------- TRIANGLE SCENARIOS : Nordhaus, Jancovici, Diamondis -------------------


// Nordhaus: find the belief such that the economic optimal is letting the planet warm up to 3.5C 
// requires fair amount of fossile
[h21(factor:Percent)
   -> scenario("h21: Parametric Nordhaus at " /+ string!(integer!(factor * 100.0)) /+ "%"),
      for c in Consumer c.disasterLoss := affine(list(1.0,0),list(1.5,1.5%),list(2,2%),list(3,3%),list(4,4%),list(5,5%)), 
      Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(480.0), PWh(350.0)), 
                              list(perMWh(560.0), PWh(550.0)), list(perMWh(700.0), PWh(800.0))),       // 
      Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(210.0), PWh(300.0)), 
                              list(perMWh(260.0), PWh(450.0)), list(perMWh(500.0), PWh(500.0))),
      Coal.capacityGrowth := 3%,
      Coal.sensitivity := 60%,
      XtoClean(-30%),
      for b in Block 
         (b.dematerialize := improve%(b.dematerialize,-10%)),
      for c in Consumer 
       (c.tactic.savingStart := 0%,
        c.tactic.transitionStart := 0%),
      // mitigation here is CO2 tax
      US.carbonTax := step(list(380,0.0),list(420,100.0),list(470,200.0), list(600,300.0)),
      EU.carbonTax := step(list(380,0.0),list(420,100.0),list(470,200.0), list(600,300.0)),
      CN.carbonTax := step(list(380,0.0),list(420,40.0),list(470,100.0), list(600,200.0)),
      Rest.carbonTax := step(list(380,0.0),list(420,40.0),list(470,100.0), list(600,200.0)),
      // parametrization of carbon tax 
      for c in Consumer 
           adjust(c.carbonTax,factor),   // adjust  from 0 to 100%
      go(90) ]

[nordo()
   -> h21(10%)]
// h21:  PNB: 268.6T$, 183.1PWh -> 703.5ppm CO2, 16.8C, 50.1PWh clean, 38.2% electricity

// Jancovici scenario : do the best to stay below +1.5C = 15.2C (15.4 OK)
// we use a heavy carbon tax to reduce CO2 emissions
// we assume a high level of savings (efficiency) and a fast transition to clean
[h22(tax%:Percent,transfer%:Percent)
   -> scenario("h22: Jancovici scenario below +1.5C, @ " /+ string%(tax%)),
      verbose() := 1,
      XtoClean(transfer%),
      for c in Consumer 
       (c.saving := improve%(c.saving,5%),
        c.cancel := improve%(c.cancel,10%)),      // acceleration through sobriety
      // assumes that no new fossil exploration is allowed
      Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(600.0), PWh(220.0)), 
                              list(perMWh(1600.0), PWh(230.0)), list(perMWh(5000.0), PWh(250.0))),       // 
      Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(320.0), PWh(190.0)), 
                              list(perMWh(5500.0), PWh(240.0))),
      Coal.inventory := affine(list(perMWh(50.0),PWh(600.0)), list(perMWh(100.0),PWh(600.0)), 
                               list(perMWh(200.0),PWh(600.0))),  //enforce worldwide reduction on coal
      Coal.capacityGrowth = 0%,                  // no new coal
      // double -> close to IRINA numbers
      //  growthPotential = affine(list(2000,0.2), list(2020,0.2),list(2030,1.5),list(2040,2.0),list(2100,4.0)),
      Clean.growthPotential := affine(list(2000,0.3), list(2020,0.3),list(2025,1.5),list(2050,3.0),list(2100,3.0)),
      US.carbonTax := step(list(380,0.0),list(400,150.0),list(420,230.0),list(480,300.0),list(600,400.0)),
      adjust(US.carbonTax,tax%),
      EU.carbonTax := US.carbonTax,
      CN.carbonTax := US.carbonTax,
      Rest.carbonTax := US.carbonTax,
  go(90)]

// h12:  PNB: 219.9T$, 118.8PWh -> 473.8ppm CO2, 15.4C, 79.4PWh clean, 73.5% electricity
// 1.5 C however breaks China growth
// note that it worked better with the M4 CO2 absorption model since low emissions were absorbed by the earth (up to 16 Gt)
// Note: with new emission/concentration model, we get different results !
[janco() 
   -> h12(120%,30%)]

//  Abundance Scenario (Peter H Diamandis)
//  technology improves -> savings profile shows constant improvement
//  also the capapcity to grow clean will be higher in the future
//  last we transition faster to clean post 2050 thanks to technology
[h23(factor:Percent)
   -> scenario("h23: Diamandis Scenario at " /+ string!(integer!(factor * 100.0)) /+ "%"),
      XtoClean(30%),
      for c in Consumer 
         (c.saving := improve(c.saving,20%), // twice the improvement
          c.cancel := improve(c.cancel,10%)),
      for s in Supplier s.techFactor := 1.2,
      let CT2 := step(list(380,0.0),list(420,80.0),list(470,120.0), list(600,150.0)) in
           (adjust(CT2,factor),
            US.carbonTax := CT2,
            EU.carbonTax := US.carbonTax,
            CN.carbonTax := US.carbonTax,
            Rest.carbonTax := US.carbonTax),
       go(90) ]

// h23: PNB: 279.3T$, 124.6PWh -> 555.0ppm CO2, 16.3C, 66.1PWh clean, 61.7% electricity
[diam() 
  -> h23(100%)]

// parameter tuning (March 23rd)
// h21 -> 50% is the best
// h22 -> 100% is the best, but tax starts too soon
// h23 -> 100% 
// reproduce Michelin shapes
[shapes(i:integer) : void
 -> if (i = 1) h21(0%)                       // Nordhaus (16.8C,  222 CO2/K 2035, 124T$ in 2035)   
   else if (i = 2) h22(100%)                 // Jancovici (15.2C, 197 CO2/K 2035, 92T$ in 2035)
   else if (i = 3) h23(95%)                  // Diamandis (16.3C, 198 CO2/K 2035, 107T$ in 2035)
   else if (i = 4) go(90) ]                  // Default (16.5C, 222 CO2/K 2035, 112T$ in 2035)


// NGFS0 is similar to IRENA or IEA NetZero scenario with demat at -2.7% between 2020 and 2050
// since less energy is needed, we boost the transfer to get NZE type of results (70PWh of clean in 2050)
// h12:  PNB: 299.8T$, 133.4PWh -> 473.4ppm CO2, 15.4C, 96.4PWh clean, 79.3% electricity
[NGFS0() 
-> US.economy.dematerialize := affine(list(2010,0),list(2020,22%),list(2030,50%),list(2050,60%),list(2100,70%)),
   EU.economy.dematerialize := affine(list(2010,0),list(2020,10%),list(2030,30%),list(2050,50%),list(2100,65%)),
   CN.economy.dematerialize := affine(list(2010,0),list(2020,28%),list(2030,45%),list(2050,60%),list(2100,70%)),
   Rest.economy.dematerialize := affine(list(2010,0),list(2020,7%),list(2030,20%),list(2050,50%),list(2100,60%)),
   h12(70%,50%)]

/* recall previous values
USDemat :: affine(list(2010,0),list(2020,22%),list(2030,35%),list(2050,48%),list(2100,60%))
EUDemat :: affine(list(2010,0),list(2020,10%),list(2030,25%),list(2050,40%),list(2100,55%))
CNDemat :: affine(list(2010,0),list(2020,28%),list(2030,35%),list(2050,45%),list(2100,60%))
RWDemat :: affine(list(2010,0),list(2020,7%),list(2030,14%),list(2050,30%),list(2100,50%)) */

// scenario business as usual(CP) yielding +2.8 = 16.7
// NGFS1 PNB: 263.8T$, 182.3PWh -> 660.0ppm CO2, 16.7C, 51.5PWh clean, 40.0% electricity
[NGFS1()
  -> scenario("NGFS1-CP: business as usual"),
     Oil.inventory := improve(Oil.inventory,40%),    // cf "Drill, Baby, Drill"
     Gas.inventory := improve(Gas.inventory,40%),
     Coal.inventory := improve(Coal.inventory,30%),
      Coal.capacityGrowth := 3%,
      Coal.sensitivity := 60%,
      XtoClean(-20%),
      for c in Consumer 
       (c.saving := improve(c.saving,-30%)),
      go(90) ]

// scenario (NDC) that implements the default savings and energy transition + some carbon taxation  (yielding +2.3 = 16.2)
// no sequestration ... but coalition to reduce coal
[NGFS2()
  -> scenario("NGFS2-NDC: Nationally Determined Contributions"),
     XtoClean(15%),
     for c in Consumer 
       (c.saving := improve%(c.saving,10%)),
        // assumes that no new fossil exploration is allowed
      Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(600.0), PWh(220.0)), 
                              list(perMWh(1600.0), PWh(230.0)), list(perMWh(5000.0), PWh(250.0))),       // 
      Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(320.0), PWh(190.0)), 
                              list(perMWh(5500.0), PWh(240.0))),
      Coal.inventory := affine(list(perMWh(50.0),PWh(600.0)), list(perMWh(100.0),PWh(600.0)), 
                               list(perMWh(200.0),PWh(600.0))),  //enforce worldwide reduction on coal
      Coal.capacityGrowth = 0%,                  // no new coal
     // moderate carbon taxation in line with what is annonced
     US.carbonTax := step(list(380,0.0),list(420,100.0),list(470,200.0), list(600,300.0)),
     EU.carbonTax := step(list(380,0.0),list(420,150.0),list(470,250.0), list(600,300.0)),
     CN.carbonTax := step(list(380,0.0),list(420,50.0),list(470,100.0), list(600,200.0)),
     go(90) ]

// NGFS2 PNB: 247.8T$, 118.3PWh -> 546.5ppm CO2, 16.2C, 63.9PWh clean, 63.5% electricity

// ********************************************************************
// *    Part 4: CCEMv7 Tactical Experiments                           *
// ********************************************************************

// ********************************************************************
// *    Part 5: Tactical Optimization (hand tuning version)           *
// ********************************************************************

// hand tuning: whatif(c,p,val) shows the status after and before changing c.p to val
[whatif(c:Consumer, p:property, val:Percent) 
   -> let v0 := read(p,c.tactic) in
        (cStatus(c,p,v0),
         reinit(),
         write(p,c.tactic,val),
         iterate_run(90,false),
         cStatus(c,p,val),
         write(p,c.tactic,v0))]

// show the satisfaction of a consumer with detailed information
[showSat(c:Consumer,y:Year)
  -> let v := verbose() in
       (verbose() := 2,
        computeSatisfaction(c,y),
        verbose() := v)]

// cStatus(c,p,val) shows C02 ppm, c emissions in 2100, GDP, c carbon tax in 2010 and satisfaction
[cStatus(c:Consumer, p:property, val:Percent) 
   -> printf("when ~S.~S = ~F%, CO2 = ~F1ppm, emissions = ~F1Gt, GDP = ~F1T$, carbon tax = ~F1$ and satisfaction = ~F%\n",
             c, p, val, pb.earth.co2Levels[pb.year], c.co2Emissions[pb.year],
             c.economy.results[pb.year], c.taxAcceleration, satScore(c)),
      // investment analysis option
      printf("avg IG=~F2T$, avg Ie=~F2T$ for ~F2PWh avg green\n",
             average(list<float>{c.economy.investGrowth[i]| i in (1 .. pb.year)}),
             average(list<float>{c.economy.investEnergy[i]| i in (1 .. pb.year)}),
             average(list<float>{c.consos[i][4]| i in (1 .. pb.year)}))]
            

// automated scripting : a first step towards GTES
// retuns a list of KPI : GDP, CO2, Satisfaction, pain
tacticalProperties :: list(taxFromPain,cancelFromPain,transitionStart,transitionFromPain,
                           protectionismStart,protectionismFromPain)

[makeTactic(c:Consumer, i:integer, val:Percent, vother:Percent) : void
   -> reinit(),
      write(tacticalProperties[i],c.tactic,val),
      if (i = 3) c.tactic.transitionFromPain := vother
      else if (i = 4) c.tactic.transitionStart := vother
      else if (i > 4)
         (c.carbonTax := step(list(380,200.0),list(420,200.0),list(540,200.0), list(600,200.0)),
          if (i = 5) c.tactic.protectionismFromPain := vother
          else c.tactic.protectionismStart := vother),
      iterate_run(90,false),
      // proper cleanup is missing
      write(tacticalProperties[i],c.tactic,0%),
      list<float>(c.economy.results[pb.year],
                  pb.earth.co2Levels[pb.year],
                  100.0 * satScore(c),
                  100.0 * average(list<float>{c.painLevels[i]| i in (1 .. pb.year)})) ]

// create the table
makeTable(c:Consumer, i:integer, n:integer, vmin:Percent, vmax:Percent)
  -> makeTable(c,i,n,vmin,vmax,0%)

[makeTable(c:Consumer,i:integer, n:integer, vmin:Percent, vmax:Percent, vother:Percent)
  -> let l := list<list>() in 
       (printf("**** explore ~S(~@S) = ~F% to ~F% with vother = ~F% ***",
               tacticalProperties[i],c,vmin, vmax, vother),
        for j in (0 .. (n - 1))
           l :add makeTactic(c,i,vmin + (vmax - vmin) * j / float!(n - 1),vother),
        startTable(10,list<string>("gdp","co2","satisfaction","pain")),
        for j in (0 .. (n - 1))
           lineTable(string!(vmin + (vmax - vmin) * j / float!(n - 1)),10, l[j + 1]),
        separation(10,4))]
         
    

// how to use it
/* makeTable(EU,1,10,0%,50%)  -> test the various hypothesis of CO2
+----------+----------+----------+----------+----------+
|          |       gdp|       co2|satisfacti|      pain|
+----------+----------+----------+----------+----------+
|         0|      8.43|    596.70|     92.00|     19.12|
|0.05555555|      8.16|    597.27|     91.70|     20.63|
|0.11111111|      7.87|    597.44|     91.46|     21.76|
|0.16666666|      7.61|    597.36|     91.37|     22.35|
|0.22222222|      7.35|    597.26|     91.22|     23.16|
|0.27777777|      7.11|    597.16|     91.09|     23.81|
|0.33333333|      6.90|    597.07|     91.01|     24.33|
|0.38888888|      6.65|    596.90|     90.41|     27.00|
|0.44444444|      6.41|    596.80|     89.93|     29.78|
|       0.5|      6.25|    596.84|     89.83|     30.29|
+----------+----------+----------+----------+----------+ */

/* makeTable(EU,2,10,0%,50%)  -> test the various hypothesis of Cancel
+----------+----------+----------+----------+----------+
|          |       gdp|       co2|satisfacti|      pain|
+----------+----------+----------+----------+----------+
|         0|      8.43|    596.70|     92.00|     19.12|
|0.05555555|      8.42|    596.69|     92.00|     19.12|
|0.11111111|      8.41|    596.69|     92.00|     19.12|
|0.16666666|      8.40|    596.68|     91.98|     19.25|
|0.22222222|      8.39|    596.68|     91.94|     19.42|
|0.27777777|      8.37|    596.68|     91.94|     19.42|
|0.33333333|      8.36|    596.67|     91.94|     19.42|
|0.38888888|      8.35|    596.67|     91.90|     19.58|
|0.44444444|      8.34|    596.66|     91.90|     19.58|
|       0.5|      8.32|    596.66|     91.88|     19.69|
+----------+----------+----------+----------+----------+ */

/* makeTable(EU,3,10,0%,50%,10%) -> test various hypothesis of transitionStarts with 10%
+----------+----------+----------+----------+----------+
|          |       gdp|       co2|satisfacti|      pain|
+----------+----------+----------+----------+----------+
|         0|      8.24|    597.02|     91.82|     20.04|
|0.05555555|      8.24|    597.02|     91.82|     20.04|
|0.11111111|      8.25|    597.01|     91.82|     20.04|
|0.16666666|      8.26|    597.01|     91.85|     19.93|
|0.22222222|      8.27|    597.00|     91.86|     19.85|
|0.27777777|      8.28|    597.00|     91.86|     19.85|
|0.33333333|      8.30|    596.99|     91.86|     19.85|
|0.38888888|      8.32|    596.98|     91.87|     19.76|
|0.44444444|      8.32|    596.97|     91.88|     19.70|
|       0.5|      8.32|    596.93|     91.88|     19.70|
+----------+----------+----------+----------+----------+
*/

/* makeTable(EU,4,10,0%,50%,10%) -> test various hypothesis of transitionFromPain with 10%
*/
// ********************************************************************
// *    Part 4: Miscelaneous (go)                                     *
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
  -> init(),
     // HOW := 1,
     TESTE := Clean,
     one()]

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

// re-launch (test reinit :))
[rego()  
   -> reinit(),
      go(90)]

// ------------------ useful : Excel interface -------------------------------------------------
// produce a table of results - this is the simple version for the CCEM paper
// GDP, Energy, CO2 emission, temperature
// convenient: we add 2000 for reference; we also added the .csv suffix
Reference2000 :: list<float>(33.8,PWh(9.3),14.5,25.0)  // GDP, PWh, T$ and CO2
[excel(s:string)
 -> let p := fopen("excel/" /+ s /+ ".csv","w") in
   (use_as_output(p),
    printf(",~I\n",
        pListNumber(list(2000) /+ list{year!(1 + (i - 1) * 10) | i in (1 .. 10)})),
    // print GDP 
    printf("GDP (T$), ~I \n",
        pListNumber(list(Reference2000[1]) /+
            list{integer!(pb.world.all.results[1 + (i - 1) * 10 ]) | i in (1 .. 10)})),
    // print energy 
    printf("Energy (PWh), ~I \n",
       pListNumber(list(Reference2000[2]) /+
            list{integer!(pb.world.all.totalConsos[1 + (i - 1) * 10 ]) | i in (1 .. 10)})),
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
               float printf("~F2,",x))) ]


// this table reproduces the Kaya equation
// this global variable is the 4 reference values for 2000. 
ReferenceKaya :: list(6.6,240,TWh(9.3) / (10.0 * 33.8),10.0 * 33.8 / 6.6)
[kaya(s:string)
 -> let p := fopen("excel/" /+ s /+ ".csv","w") in
   (use_as_output(p),
    printf(",~I\n",
        pListNumber(list(2000) /+ list{year!(1 + (i - 1) * 10) | i in (1 .. 10)})),
    // print world population 
    printf("Pop (G), ~I \n",
        pListNumber(list(ReferenceKaya[1]) /+
            list{ worldPopulation(1 + (i - 1) * 10) | i in (1 .. 10)})),
     // print CO2/Energy
    printf("gCO2/KWh, ~I \n",
       pListNumber(list(ReferenceKaya[2]) /+
            list{co2KWh(1 + (i - 1) * 10 ) | i in (1 .. 10)})),
     // print energy/GDP 
    printf("e-intensity (kWh/$) / 10, ~I \n",
       pListNumber(list(ReferenceKaya[3]) /+
            list{ (energyIntensity(1 + (i - 1) * 10 ) * 10.0) | i in (1 .. 10)})),
    // print GDP/inhabitant 
    printf("GDP/p (100$), ~I \n",
    pListNumber(list(ReferenceKaya[4]) /+
            list{(10.0 * gdpp(1 + (i - 1) * 10 )) | i in (1 .. 10)})),
    fclose(p))]


// second version of the Excel table, where we produce GDP, oil price, energy consumption, clean energy consumption, temperature and CO2 emissions
Reference2-2000 :: list<float>(33.8,30.0,EJ(PWh(9.3)),EJ(PWh(0.4)),14.5,30.0)  
// GDP, Oil Price, EJ, Clean EJ, temperature and CO2
[excel2(s:string)
 -> let p := fopen("excel/" /+ s /+ "v2","w") in
   (use_as_output(p),
    printf(",~I\n",
        pListNumber(list(2000) /+ list{year!(1 + (i - 1) * 10) | i in (1 .. 10)})),
    // print GDP 
    printf("GDP (T$), ~I \n",
        pListNumber(list(Reference2-2000[1]) /+
            list{integer!(pb.world.all.results[1 + (i - 1) * 10 ]) | i in (1 .. 10)})),
    // print oil price 
    printf("Oil price ($/MWh), ~I \n",
        pListNumber(list(Reference2-2000[2]) /+
            list{integer!(Oil.sellPrices[1 + (i - 1) * 10 ]) | i in (1 .. 10)})),
    // print energy 
    printf("Energy (EJ), ~I \n",
       pListNumber(list(Reference2-2000[3]) /+
            list{integer!(EJ(pb.world.all.totalConsos[1 + (i - 1) * 10 ])) | i in (1 .. 10)})),
    // print clean energy 
    printf("Clean Energy (EJ), ~I \n",
       pListNumber(list(Reference2-2000[4]) /+
            list{integer!(EJ(cleanConsos(1 + (i - 1) * 10 ))) | i in (1 .. 10)})),
    // print temperature 
    printf("Temperature(C), ~I \n",
    pListNumber(list(Reference2-2000[5]) /+
            list{pb.earth.temperatures[1 + (i - 1) * 10 ] | i in (1 .. 10)})),
    // print CO2
    printf("CO2(Gt/y), ~I \n",
       pListNumber(list(Reference2-2000[6]) /+
            list{pb.earth.co2Emissions[1 + (i - 1) * 10 ] | i in (1 .. 10)})),
     fclose(p))]

// Clean consos
[cleanConsos(y:Year) : Energy
  -> sum(list{c.consos[y][Clean.index] | c in Consumer})]


// third version of the Excel table, where we produce current $GDP, energy consumption and CO2 emissions by zones
[zexcel(s:string)
 -> let p := fopen("excel/" /+ s /+ ".csv","w") in
   (use_as_output(p),
    printf(",~I\n",
        pListNumber(list{year!(1 + (i - 1) * 10) | i in (1 .. 10)})),
    // print GDP for all zones
    for c in Consumer
       printf("~S GDP (T$), ~I \n",c,
        pListNumber(list{integer!(gdp$(c,1 + (i - 1) * 10 )) | i in (1 .. 10)})),
    printf("world GDP (T$), ~I \n",
        pListNumber( list{integer!(gdp$(pb.world.all,1 + (i - 1) * 10)) | i in (1 .. 10)})),
    // print energy for all zones
    for c in Consumer
       printf("~S energy (PWh), ~I \n",c,
          pListNumber(list{integer!(c.economy.totalConsos[1 + (i - 1) * 10 ]) | i in (1 .. 10)})),
    printf("World Energy (PWh), ~I \n",
       pListNumber(list{integer!(pb.world.all.totalConsos[1 + (i - 1) * 10 ]) | i in (1 .. 10)})),
    // print CO2 for all zones
      for c in Consumer
         printf("~S CO2 (Gt/y), ~I \n",c,
            pListNumber(list{c.co2Emissions[1 + (i - 1) * 10 ] | i in (1 .. 10)})),
    printf("CO2(Gt/y), ~I \n",
       pListNumber(list{pb.earth.co2Emissions[1 + (i - 1) * 10 ] | i in (1 .. 10)})),
    fclose(p))]

// zexcel(s,c) produces an excel file "s"-"c" withj the GDP for the consumer c, the energy, the damage, 
// the adaptation spend and the adjusted CO2 emissions
[zexcel(s:string,c:Consumer)
 -> let p := fopen("excel/" /+ s /+ "_" /+ string!(c.name) /+ ".csv","w") in
   (use_as_output(p),
    printf(",~I\n",
        pListNumber(list{year!(1 + (i - 1) * 10) | i in (1 .. 10)})),
    // print GDP
    printf("GDP (T$), ~I \n",
        pListNumber(list{c.economy.results[1 + (i - 1) * 10 ] | i in (1 .. 10)})),
    // print energy
    printf("Energy (PWh), ~I \n",
       pListNumber(list{c.economy.totalConsos[1 + (i - 1) * 10 ] | i in (1 .. 10)})),
    // print adaptation spend
    printf("Adaptation (T$), ~I \n",
       pListNumber(list{c.adapt.sums[1 + (i - 1) * 10 ] | i in (1 .. 10)})),
    // print adjusted CO2 emission
      printf("CO2(Gt/y), ~I \n",
       pListNumber(list{adjustForTrade(c,1 + (i - 1) * 10,false) | i in (1 .. 10)})),
    fclose(p))]

// energy excel
[enexcel(s:string)
 -> let p := fopen("excel/" /+ s,"w") in
   (use_as_output(p),
    printf(",~I\n",
        pListNumber(list{year!(1 + (i - 1) * 10) | i in (1 .. 10)})),
    for s in Supplier
        printf("~S (PWh), ~I \n",s,
                   pListNumber(list{integer!(s.outputs[1 + (i - 1) * 10]) | i in (1 .. 10)})),
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