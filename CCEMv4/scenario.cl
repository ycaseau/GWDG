// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
// *       file: scenario.cl - version GWDG 0.4  for Xmas                *
// ********************************************************************

// this file contains a simple description of our problem scenarios
// this is a Xmas revision used for CCEM24 paper


// ********************************************************************
// *    Part 1: Scenarios                                             *
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
  -> h1c(2%)]
[h1c(p:Percent)
   -> scenario("h1c: Coal max capacity growth " /+ string%(p)),
      Coal.capacityGrowth := p,
      Coal.sensitivity := 20% + 20 * p,   // otherwise the growth is limited by demand at price
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
      for b in Block 
       (b.dematerialize := improve(b.dematerialize,-30%)) ]

// h6+ is a more optimistic scenario where the economy dependance on energy decreases faster
// h6+: 220 T$ for 12.7 Gt -> 634 CO2
[h6+()
   -> scenario("h6+: more dematerialization"),
      for b in Block 
       (b.dematerialize := improve(b.dematerialize,20%)) ]

// play with the economic outlook about growth --------------------------------------------------

// h7+ is a more optimistic scenario where Europe and Rest of the word reach better RoI closer to US
// h7+: 205 T$ for 13.12 Gt -> 652 CO2
[h7+()
   -> scenario("h7+: optimistic outlook on growth"),
      US.economy.roI := affine(list(2000,18%), list(2020,18%), list(2050, 17%), list(2100,16%)),
      EU.economy.roI := affine(list(2000,6%), list(2020,8%), list(2050, 10%), list(2100,12%)),
      CN.economy.roI := affine(list(2000,23%), list(2020,25%), list(2050, 18%), list(2100,16%)),
      Rest.economy.roI := affine(list(2000,3%), list(2020,4%), list(2050, 6%), list(2100,10%)) ]

// h7- is a more pessimistic scenario where the world disarray means that today's level of RoI in China or US
// won't be reached in the future
// h7-: 187 T$ for 12.43 Gt -> 645 CO2
[h7-()
   -> scenario("h7-: pessimistic outlook on growth"),
      US.economy.roI := affine(list(2000,18%), list(2020,18%), list(2050, 16%), list(2100,13%)),
      EU.economy.roI := affine(list(2000,4.5%), list(2020,4.5%), list(2050, 6%), list(2100,8%)),
      CN.economy.roI := affine(list(2000,23%), list(2020,25%), list(2050, 16%), list(2100,12%)),
      Rest.economy.roI := affine(list(2000,3%), list(2020,3%), list(2050, 4%), list(2100,5%))]

// increase price sensitivity
[h7p()
 -> scenario("h7p: lower price sensitivity => reach higher prices"),
    Oil.sensitivity := 30%,
    Gas.sensitivity := 30%,
    Coal.sensitivity := 50%]
// h7p: 201 T$ for 13.34 Gt -> 641 CO2
 
// play with carbon tax ===================================================

// carbonTax should accelerate the transition to clean energy
[h8-()
   -> scenario("h8: zero carbon tax"),
      US.carbonTax := affine(list(380,0.0),list(420,0.0),list(470,0.0), list(600,0.0)),
      EU.carbonTax := US.carbonTax,
      CN.carbonTax := US.carbonTax,
      Rest.carbonTax := US.carbonTax ]
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


// play with damages

// debug - no impact of warming
[h9d()
   -> scenario("h9d: no impact of warming"),
      US.disasterLoss := affine(list(1.0,0),list(1.5,0),list(2,0),list(3,0),list(4,0),list(5,0)),
      EU.disasterLoss := US.disasterLoss,
      CN.disasterLoss := US.disasterLoss,
      Rest.disasterLoss := US.disasterLoss ]


[h9-()
   -> scenario("h9: Global warming damages with moderate values for impact"),
      US.disasterLoss := affine(list(1.0,0),list(1.5,1.5%),list(2,2%),list(3,3%),list(4,4%),list(5,5%)),
      EU.disasterLoss := US.disasterLoss,
      CN.disasterLoss := US.disasterLoss,
      Rest.disasterLoss := US.disasterLoss ]

[h9+()
   -> scenario("h9+: Global warming damages with high values for impact"),
      US.disasterLoss := affine(list(1.0,0),list(1.5,3%),list(2,6%),list(3,12%),list(4,20%),list(5,30%)),
      EU.disasterLoss := US.disasterLoss,
      CN.disasterLoss := US.disasterLoss,
      Rest.disasterLoss := US.disasterLoss ]

// ********************************************************************
// *    Part 2: Triangle scenarios                                    *
// ********************************************************************

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
      for c in Consumer c.disasterLoss := affine(list(1.0,0),list(1.5,1.5%),list(2,2%),list(3,3%),list(4,4%),list(5,5%)), 
      Oil.inventory := affine(list(400,193.0), list(600, 350.0), list(800, 450), list(5000, 600.0)),       // 
      Gas.inventory := affine(list(163,160.0), list(300, 300.0), list(800, 450), list(5500, 500.0)),
      Coal.capacityGrowth := 2%,
      Coal.sensitivity := 60%,
      XtoClean(-30%),
      for c in Consumer 
       (c.saving := improve(c.saving,-30%)),
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
      XtoClean(50%),
      for c in Consumer 
       (c.saving := improve(c.saving,20%),
        c.cancel := improve(c.cancel,20%)),      // acceleration through sobriety
      // assumes that no new fossil exploration is allowed
      Oil.inventory := affine(list(400,193.0), list(600, 220.0), list(1600, 230.0), list(5000, 250.0)),       // 
      Gas.inventory := affine(list(163,160.0), list(320, 190.0), list(5500, 240.0)),
      Coal.capacityGrowth = 0%,                  // no new coal
      // double -> close to IRINA numbers
      Clean.growthPotential := affine(list(200,0.04), list(500,0.22),list(1000,0.3),list(6000,0.4)),
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
      XtoClean(60%),
      for c in Consumer 
         (c.saving := improve(c.saving,40%), // twice the improvement
          c.cancel := improve(c.cancel,10%)),
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

// h13(120%)  -> 209T$ at 10.52Gtoe 511ppm (15.8)

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