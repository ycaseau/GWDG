// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2022 Yves Caseau                        *
// *       file: test1.cl - version GWDG3                             *
// ********************************************************************

// this file contains a simple description of our problem scenario

// energy supply ------------------------------------------------------

// Four Key constants from the data reseach
Oil2010 :: 4.2                  // 80 billions barel/j
Gas2010 :: 3.0                  // 3.3 Tm3/y (3300 bcm)
Coal2010 ::  4.9                // 7300 Mt 2010
Clean2010 :: 0.64               // 7500 TWh (1010)


// Oil & Gas,  simple name for debug :)
// units : Money = $,  Energy = GTep 
// keep it simple : production = consumption
// inventory : use 2020 numbers + 2010_2020 consumption 
Oil :: Supplier( index = 1,
   inventory = affine(list(240,193.0), list(320, 282.0), list(5500, 350.0)),       // hard case
   production = Oil2010,
   price = 410.0,                   // 60$ a baril -> 410$ a ton
   capacityMax = Oil2010 * 110%,    // a little elasticity
   capacityGrowth = 5%,             // adding capacity takes time/effort
   sensitivity = 80%,               // +25% price -> + 20% prod (sensitivity is mosly oil)
   co2Factor = 3.15,                // 1 Tep -> 3.15 T C02
   co2Kwh = 270.0,                  // each kWh of energy  yields 270g of CO2
   savingFactor = 0.020,            // 10 years to recuperate savings invests
   substitutionFactor = 0.030,      // 20 years for a substitution project
   cancelFactor = 100%)

// Natural Gas, separated from Oil in v0.3
Gas :: Supplier( index = 2,
   inventory = affine(list(240,160.0), list(320, 216.0), list(5500, 300.0)),      // hard case
   production = Gas2010,
   price =  163.0,                  // 4$ MBTU -> 163$ a TEP
   capacityMax = Gas2010 * 110%,    // a little elasticity
   capacityGrowth = 5%,             // adding capacity takes time/effort
   sensitivity = 80%,               // +25% price -> + 20% prod (sensitivity is mosly oil)
   co2Factor = 2.14,                // 1 Tep -> 2.14 T CO2
   co2Kwh = 270.0,                  // each kWh of energy  yields 270g of CO2
   savingFactor = 0.020,            // 10 years to recuperate savings invests
   substitutionFactor = 0.030,      // 20 years for a substitution project
   cancelFactor = 100%)   
   
// Coal supplies + traditional (biomass & wood)
Coal :: Supplier( index = 3,
   inventory = affine(list(50,600), list(100,800), list(200,1000)),  // lots of coal
   production = Coal2010,
   price = 100.0,                    // 70$ / ton (1tec = 0.66 Tep)
   capacityMax = Coal2010 * 102%,    // can grow slowly if we need it ...
   capacityGrowth = 0%,            // lots of constraint to add capacity
   sensitivity = 10%,                // price varies
   co2Factor = 3.3,                   // 1 Tep coal -> 3.3 T of CO2
   co2Kwh = 340.0,                     // each kWh of energy  yields 270g of CO2
   savingFactor = 0.020,               // 10 years to recuperate savings invests
   substitutionFactor = 0.030,         // 20 years for a substitution project
   cancelFactor = 500%)                // will reduce price increase

// clean is Nuclear, solar, wind and hydro  => electricity but rest
Clean :: Supplier( index = 4,
   inventory = affine(list(500,1000), list(3000,2000)),
   production = Clean2010,
   price = 550.0,                     // 50e / MWh (nuc/ charbon)  -> 80e in 2020
   capacityMax = Clean2010 * 110%,    // when you have it you use it
   capacityGrowth = 10%,              //  + 50% every 10 years
   sensitivity = 200%,                // grows because it follows the non-green electricity
   co2Factor = 0.0,                   // What clean means :)
   co2Kwh = 0.0,                      // 
   cancelFactor = 100%)               // default, because price increase will also reduce consumption of clean


// energy consumption -------------------------------------------------------

// 60$/baril          363$/t          ok
// 120$/baril         720             -5%
// 240$/baril         1440            -10%
// 480$/baril         2800            -30%
// 1000$/baril        6000            -80%

// We create one unique matrix, that can be modified for each block with accelerate(M, percent)
// the order is based on scarcity (scarce form to less scarce)
EnergyTransition :: list<Affine>(
        // 90% Oil moves to CTL and Clean
        affine(list(200,0.01),list(800,0.02),list(1400,0.05),list(2800,0.08),list(6000,0.1)),   // oil -> Gas
        affine(list(200,0.01),list(800,0.02),list(1400,0.1),list(2800,0.3),list(6000,0.4)),     // oil -> Coal (CTL)
        affine(list(200,0.01),list(800,0.03),list(1400,0.1),list(2800,0.2),list(6000,0.4)),     // oil -> Clean
        // 90% Gas moves to clean
        affine(list(200,0.01),list(800,0.02),list(1400,0.05),list(2800,0.08),list(6000,0.1)),    // Gas -> Coal (gazeified)
        affine(list(200,0.01),list(800,0.05),list(1400,0.1),list(2800,0.4),list(6000,0.8)),      // Gas -> Clean
        // Coal is abundant, moving to Clean forms takes longer
        affine(list(200,0.01),list(800,0.02),list(1400,0.1),list(2800,0.2),list(6000,0.5)))     // Coal -> clean          


// 2008, -7% de PNB (par rapport au trend, avec oil de 70$ � 150$)
// cf. rapport de Bacher sur le PPE: les substitutions font sens � 1000�

// US, Europe & Japan
// note : we could model the "energy discount => more output" to balance the curve at "origin price"
US :: Consumer(
   consumes = list<Energy>(Oil2010 * 20%, Gas2010 * 22%, Coal2010 * 8.5%, Clean2010 * 16%),
   cancel = affine(list(242,0.0),list(400,0.05),list(800,0.1),list(1600,0.2),list(6000,0.5)),
   saving = affine(list(500,0.0),list(800,0.05),list(1400,0.1),list(2800,0.15),list(6000,0.3)),
   popEnergy = 0.4,    // mature economy
   subMatrix = accelerate(EnergyTransition,20%),         
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   cancelAcceleration = 0.0,                                      // to be tuned
   taxAcceleration = 0.0)

EU :: Consumer(
   consumes = list<Energy>(Oil2010 * 15%, Gas2010 * 14%, Coal2010 * 5%, Clean2010 * 16%),
   cancel = affine(list(242,0.0),list(400,0.05),list(800,0.1),list(1600,0.2),list(6000,0.5)),
   saving = affine(list(500,0.0),list(800,0.05),list(1400,0.1),list(2800,0.15),list(6000,0.3)),
   popEnergy = 0.4,    // mature economy
   subMatrix = EnergyTransition,          
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon taxt
   cancelAcceleration = 0.0,                                      // to be tuned once pain is working
   taxAcceleration = 0.0)

// we 
CN :: Consumer(
   consumes = list<Energy>(Oil2010 * 13%, Gas2010 * 8%, Coal2010 * 50.5%, Clean2010 * 24%),
   cancel = affine(list(242,0.0),list(400,0.05),list(800,0.1),list(1600,0.2),list(6000,0.5)),
   saving = affine(list(500,0.0),list(800,0.05),list(1400,0.1),list(2800,0.15),list(6000,0.3)),
   popEnergy = 0.5,    // mature economy
   subMatrix = accelerate(EnergyTransition,20%),         
   carbonTax = affine(list(380,0.0),list(6000,0.0)),              // default is without carbon tax
   cancelAcceleration = 0.0,                                      // to be tuned
   taxAcceleration = 0.0)


// similar behaviour, but more cancellation and less savings/subst
Rest :: Consumer(
   consumes = list<Energy>(Oil2010 * 52%, Gas2010  * 56%, Coal2010 * 37%, Clean2010 * 44%),
   cancel = affine(list(242,0.0),list(400,0.1),list(800,0.2),list(1600,0.3),list(6000,0.7)),
   saving = affine(list(500,0.0),list(800,0.03),list(1400,0.05),list(2800,0.08),list(6000,0.2)),
   popEnergy = 0.7,   // see if 50% works
   subMatrix = accelerate(EnergyTransition,-10%),
   carbonTax = affine(list(380,0.0),list(6000,0.0)),
   cancelAcceleration = 0.0,                                      // to be tuned (start with Europe)
   taxAcceleration = 0.0)


// world wide economy --------------------------------------------------------------------

World :: Economy(
   population = affine(list(2000,6.6), list(2010,7.3), list(2030,8.9), list(2050,9.2)),
   pnb = 65.0,  // T$
   investG = (65.0 * 0.2),  // T$
   investE = 0.2,           // amount of energy in green ebergies in 2010 ...
   roI = 15%,               // approx 7 yrs payback, or 20% invest -> 3% growth
   iRevenue = 16%,          // part of revenue that is investes
   iGrowth = 1.0,           // part of growth that is invested
   techFactor = 0.02)       // improvement of techno, annual rate

// our Earth ----------------------------------------------------------------------------

// we have only one planet ... and its name is Gaia :)
Gaia :: Earth(
    co2Total = 388.0,                  // qty of CO2 in atmosphere  in 2010 (ppm)
    co2Add = 34.0,                     // billions T CO2
    co2Ratio = 0.13,                    // + 2.5 ppm at 19 Gtep/y
    co2Neutral = 15.0,                 // level (GT CO2/y) which is "harmless" (managed by atmosphere)
    warming = affine(list(200,0),list(400,0.7),list(600,1.5),list(1000,2.5)),
    avgTemp = 14.0,
    // M5 new slots
    painClimate = step(list(200,0),list(400,1%),list(450,10%), list(500,20%), list(600,30%)),
    painGrowth = step(list(-20%,20%),list(-5%,10%),list(0%,5%),list(1%,1%),list(2%,1%),list(3%,0)),
    painCancel = step(list(0,0),list(5%,2%), list(10%,5%), list(20%,10%), list(30%,20%)))


// variants - H0 = default

[h1()
  -> scenario("h1: conservative estimate of Oil inventory - what we believed 10 years ago"),
     Oil.inventory := affine(list(300,200.0 + 160.0), list(5500, 300.0 + 200.0)) ]

[h2()
 ->  scenario("h2: more oil top be found at higher price"),
     Oil.inventory :=  affine(list(300,360), list(600,500), list(1000,800), list(5500, 2000)) ]


[h3()
  -> scenario("h3: less substitution"),
     USEJ.subMatrix := list<Affine>(  affine(list(500,0.0), list(6000,0.01)),
                                      affine(list(500,0.0), list(6000,0.01)),
                                      affine(list(500,0.0), list(6000,0.01))),
 //    USEJ.subMatrix := list<Affine>(
 //       affine(list(500,0.0),list(800,0.01),list(1400,0.02),list(2800,0.03),list(6000,0.04)), // oil -> Coal is marginal
 //       affine(list(500,0.0),list(800,0.01),list(1400,0.03),list(2800,0.12),list(6000,0.15)), // oil -> Clean
 //       affine(list(500,0.0),list(800,0.01),list(1400,0.02),list(2800,0.04),list(6000,0.05))), // Coal -> clean
     Rest.subMatrix := USEJ.subMatrix]
 
[h4()
  -> scenario("h4: more substitution"),
     USEJ.subMatrix := list<Affine>(
        affine(list(500,0.01),list(800,0.05),list(1400,0.06),list(2800,0.2),list(6000,0.4)), // oil -> Coal
        affine(list(500,0.02),list(800,0.06),list(1400,0.1),list(2800,0.3),list(6000,0.5)), // oil -> Clean
        affine(list(500,0.02),list(800,0.07),list(1400,0.1),list(2800,0.15),list(6000,0.2))), // Coal -> clean
     Rest.subMatrix := USEJ.subMatrix]


[h5()
  -> scenario("h5: cancellation is harder - price will go up"),
    USEJ.cancel := affine(list(242,0.0),list(400,0.04),list(800,0.08),list(1600,0.15),list(6000,0.5)),
    Rest.cancel := affine(list(242,0.0),list(400,0.08),list(800,0.15),list(1600,0.2),list(6000,0.7))
 ]
 
[h6()
  -> scenario("h6: cancellation will happen sooner  - price will go up"),
     USEJ.cancel := affine(list(242,0.0),list(400,0.08),list(800,0.15),list(1600,0.25),list(6000,0.5)),
     Rest.cancel := affine(list(242,0.0),list(400,0.15),list(800,0.25),list(1600,0.4),list(6000,0.7)) ]

[h7()
  -> scenario("h7: almost no savings - price will go up"),
    USEJ.saving := affine(list(500,0.0),list(800,0.01),list(1400,0.02),list(2800,0.05),list(6000,0.1)),
    Rest.saving := affine(list(500,0.0),list(6000,0.0))
 ]
 
// play with carbon tax ===================================================
[h8()
   -> scenario("h8: true application of the carbon tax with moderate values"),
      USEJ.carbonTax := affine(list(380,40.0),list(420,100.0),list(470,200.0), list(600,300.0)),
      Rest.carbonTax := affine(list(380,0.0),list(420,40.0),list(470,100.0), list(600,200.0)) ]

[h9()
   -> scenario("h9: heavy carbon tax !"),
      USEJ.carbonTax := affine(list(380,100.0),list(430,200.0),list(480,300.0), list(600,400.0)),
      Rest.carbonTax := affine(list(380,100.0),list(430,200.0),list(480,300.0), list(600,400.0)) ]

[h10()
   -> scenario("h10: very heavy carbon tax !"),
      USEJ.carbonTax := affine(list(380,200.0),list(450,400.0),list(480,800.0), list(600,2000.0)),
      Rest.carbonTax := affine(list(380,200.0),list(450,400.0),list(480,800.0), list(600,2000.0)) ]

[scenario(s:string)
   -> pb.comment := s,
      printf("*** Apply scenario: ~A\n",s)]

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
  -> init(pb,Oil),
     // HOW := 1,
     TESTE := Clean,
     one()]

// do n years of simulation
[go(n:integer)
   -> init(pb,Oil),
      // TESTE := Oil, // Clean,
      add(n) ]

// add n years of simulations
[add(n:integer)
  -> time_set(),
     for i in (1 .. n) run(pb),
     time_show(),
     see(),
     hist(TESTE), 
     hist()]

// do one year with more info
[one()
  -> SHOW2 := 1, UTI := 1, DEBUG := 1,
     run(pb),
     see() ] 

// repeatable (step by step)
[go1(n:integer)
   -> if unknown?(earth,pb) init(pb),
      for i in (1 .. n) run(pb),
      see() ]


// ------------------ INTERPRETED CODE FRAGMENT ------------------------------------------------

// upload(m:module,proj:string,user:string,commit:string)
// uploads all the files from m onto github with a commit comment, onto
// assumes that git init has been done
[upload(m:module,proj:string,user:string,comment:string)
  -> let cdstring := "cd " /+ m.source /+ ";" in
      (for f in m.made_of shell(cdstring /+ "git add " /+ f /+ ".cl")
       shell(cdstring /+ "git commit -m \"" /+ comment /+ "\"")
       shell(cdstring /+ "git push -f origin master"))
]


[upload(m:module,s:string)
  -> upload(m,"GWDG","ycaseau",s)]

// ------------------ END OF FRAGMENT : upload -------------------------------------------------
