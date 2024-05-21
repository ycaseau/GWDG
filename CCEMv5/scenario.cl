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

// recalibration (May 4-5) for Model 5
// use single-line-summary 
// defa PNB: 233.6T$, 153.0PWh -> 600.0ppm CO2, 16.5C, 59.8PWh clean, 49.4% electricity

// h0 is my default scenario for the presentation : a little bit of CO2 tax
[h0()
   -> scenario("h0: a moderate amount of carbon tax"),
      US.carbonTax := step(list(380,0.0),list(420,50.0),list(540,100.0), list(600,200.0)),
      EU.carbonTax := step(list(380,0.0),list(420,100.0),list(540,200.0), list(600,300.0)),
      CN.carbonTax := step(list(380,0.0),list(420,50.0),list(540,100.0), list(600,100.0)),
      Rest.carbonTax := step(list(380,0.0),list(420,0.0),list(540,50.0), list(600,100.0)) ]
// h0:  PNB: 216.2T$, 134.6PWh -> 590.5ppm CO2, 16.4C, 58.4PWh clean, 52.3% electricity

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
// h1g: PNB: 252.6T$, 167.3PWh -> 599.4ppm CO2, 16.5C, 76.7PWh clean, 56.0% electricity
[h1g()
  -> scenario("h1g: Green max capacity growth"),
  XtoClean(30%),
  Clean.growthPotential := affine(list(2000,0,23), list(2020,1.5),list(2050,3.0),list(2100,5.0))]
  
// accelerate X to Clean transition
[XtoClean(y:Percent)
  -> for x in Consumer
       (x.subMatrix[3] := improve(x.subMatrix[3],y),     // Oil to Clean
        x.subMatrix[5] := improve(x.subMatrix[5],y),     // Coal to Clean
        x.subMatrix[6] := improve(x.subMatrix[6],y))]     // Gas to Clean

// see what happens with a lot of coal
// h1c: PNB: 256.8T$, 172.9PWh -> 622.1ppm CO2, 16.5C, 64.5PWh clean, 48.4% electricity
[string%(p:Percent)
  -> string!(integer!(p * 100)) /+ "%"]
[h1c()
  -> h1c(2%)]
[h1c(p:Percent)
   -> scenario("h1c: Coal max capacity growth " /+ string%(p)),
      Coal.capacityGrowth := p,
      Coal.sensitivity := 20% + 20 * p,   // otherwise the growth is limited by demand at price
      Coal.inventory := affine(list(perMWh(50.0),PWh(600.0)), list(perMWh(100.0),PWh(1000.0)), list(perMWh(200.0),PWh(1400.0))) ]  // lots of coal

// H2 looks at the sensitivity to fossile inventory - not the biggest issue .. PNB(2050) ranges [125/140/155]

// h2-: PNB: 207.8T$, 137.9PWh -> 579.3ppm CO2, 16.4C, 56.8PWh clean, 51.4% electricity
[h2-()
  -> scenario("h2-: conservative estimate of Oil inventory - what we believed 10 years ago"),
  Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(600.0), PWh(220.0)), 
                          list(perMWh(1600.0), PWh(250.0)), list(perMWh(5000.0), PWh(300.0))),       // 
  Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(320.0), PWh(190.0)), list(perMWh(5500.0), PWh(250.0))) ]

// h2+: PNB: 283.1T$, 187.2PWh -> 625.6ppm CO2, 16.5C, 63.5PWh clean, 45.8% electricity
[h2+()
 ->  scenario("h2+: more oil to be found at higher price"),
   Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(600.0), PWh(290.0)),         
                           list(perMWh(800.0),PWh(400.0)), list(perMWh(5000.0), PWh(600.0))),       // 
   Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(300.0), PWh(300.0)),
                           list(perMWh(800.0), PWh(400.0)), list(perMWh(5500.0), PWh(500.0))) ] 

// debug scenario : lots of fossile energy
// h22: PNB: 398.9T$, 279.8PWh -> 668.7ppm CO2, 16.7C, 68.9PWh clean, 38.7% electricity
[h22()
 ->  scenario("h22: /!\\ DEBUG SCENARIO with plenty of fossile energy"),
   // TESTC := CN,
   // TESTE := Coal,
   Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(450.0), PWh(290.0)), 
                           list(perMWh(500.0), PWh(400.0)), list(perMWh(600.0), PWh(800.0))),       // 
   Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(200.0), PWh(300.0)), 
                           list(perMWh(250.0), PWh(400.0)), list(perMWh(300.0), PWh(600.0))),
   Coal.capacityGrowth := 10%,              // let the consomation grow
   Coal.inventory := affine(list(perMWh(50.0),PWh(600.0)), list(perMWh(80.0),PWh(800.0)), 
                            list(perMWh(100.0),PWh(2000.0)),list(perMWh(200.0),PWh(4000.0))) ]

//  two dual on savings
// - savings is harder than expected
// + more saving and better tech progress
// h3-: PNB: 222.8T$, 157.1PWh -> 601.9ppm CO2, 16.5C, 62.5PWh clean, 49.8% electricity
[h3-()
  -> scenario("h3-: less savings"),
     for c in Consumer 
       (c.saving := improve(c.saving,-10%)),
     for s in Supplier s.techFactor := 0.8 ]

// h3+: PNB: 265.6T$, 145.0PWh -> 598.6ppm CO2, 16.5C, 56.1PWh clean, 49.2% electricity
[h3+()
  -> scenario("h3+: more savings"),
     for c in Consumer 
       (c.saving := improve(c.saving,20%)),
     for s in Supplier s.techFactor := 1.2 ]

// h4 reduces the subtitution capacities  (h0 supports the growth of Clean to almost 5GToe = 55 0000 TWh = twice the total capacity in 2020)
// h4-: PNB: 201.7T$, 126.7PWh -> 600.7ppm CO2, 16.5C, 33.6PWh clean, 36.2% electricity
[h4-()
  -> scenario("h4-: less substitution"),
     XtoClean(-50%) ]
 
// h4+ is more optimistic 
// h4+: PNB: 267.3T$, 178.6PWh -> 599.0ppm CO2, 16.5C, 88.7PWh clean, 59.7% electricity
// the key driver is XtoClean ! 
[h4+() 
  -> h4+(50%) ]
[h4+(p:Percent)
  -> scenario("h4+: more substitution at " /+ string%(p)),           
     XtoClean(p), 
     // this line reflect current capacity to add Nuclear, Wind & Solar (GTep/y), grows with biofuels
     Clean.growthPotential = affine(list(2000,0.02),list(2020,0.9),list(2050,1.74),list(2100,22.0)) ]

// price sensitivity cancellation  => not much !  higher cancellation -> lower PNB but higher price -> more inventory
// h5-: PNB: 234.9T$, 162.4PWh -> 609.6ppm CO2, 16.5C, 61.5PWh clean, 48.5% electricity
[h5-()
  -> scenario("h5-: cancellation is harder - price will go up"),
     for c in Consumer 
       (c.cancel := improve(c.cancel,-30%)) ]
 
// h5+: PNB: 230.6T$, 144.4PWh -> 595.9ppm CO2, 16.4C, 58.8PWh clean, 50.5% electricity
[h5+()
  -> scenario("h5+: cancellation will happen sooner  - price will stay lower"),
    for c in Consumer 
       (c.cancel := improve(c.cancel,20%)) ]
 
// play with the dematerialization of the economy

// h6- is a more pessimistic scenario where the economy dependance on energy decreases more slowly
// h6-: PNB: 203.2T$, 160.4PWh -> 602.9ppm CO2, 16.5C, 67.8PWh clean, 51.4% electricity
[h6-()
   -> scenario("h6-: less dematerialization"),
      for b in Block 
       (b.dematerialize := improve(b.dematerialize,-30%)) ]

// h6+ is a more optimistic scenario where the economy dependance on energy decreases faster
// h6+: PNB: 260.9T$, 145.9PWh -> 597.0ppm CO2, 16.4C, 53.7PWh clean, 48.0% electricity
[h6+()
   -> scenario("h6+: more dematerialization"),
      for b in Block 
       (b.dematerialize := improve(b.dematerialize,20%)) ]

// play with the economic outlook about growth --------------------------------------------------

// defaults for comparison
// US -> roi = affine(list(2000,18%), list(2020,18%), list(2050, 18%), list(2100,15%)),
// EU -> roI = affine(list(2000,4.5%), list(2020,4.5%), list(2050, 8%), list(2100,10%)),
// CN -> roI = affine(list(2000,30%), list(2020,26%), list(2050, 20%), list(2100,15%)),
// Rest -> roI = affine(list(2000,3%), list(2020,3.5%), list(2050, 6%), list(2100,8%)),


// h7+ is a more optimistic scenario where Europe and Rest of the word reach better RoI closer to US
// h7+: PNB: 241.4T$, 155.1PWh -> 600.7ppm CO2, 16.5C, 61.8PWh clean, 50.0% electricity
[h7+()
   -> scenario("h7+: optimistic outlook on growth"),
      US.economy.roI := affine(list(2000,18%), list(2020,18%), list(2050, 18%), list(2100,16%)),
      EU.economy.roI := affine(list(2000,6%), list(2020,8%), list(2050, 10%), list(2100,12%)),
      CN.economy.roI := affine(list(2000,30%), list(2020,26%), list(2050, 20%), list(2100,16%)),
      Rest.economy.roI := affine(list(2000,3%), list(2020,4%), list(2050, 7%), list(2100,10%)) ]

// h7- is a more pessimistic scenario where the world disarray means that today's level of RoI in China or US
// won't be reached in the future
// h7-: PNB: 210.8T$, 140.6PWh -> 595.8ppm CO2, 16.4C, 53.9PWh clean, 48.8% electricity
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
// h7p: PNB: 241.0T$, 156.0PWh -> 613.9ppm CO2, 16.5C, 63.0PWh clean, 50.5% electricity

 
// play with carbon tax ===================================================

// carbonTax should accelerate the transition to clean energy
[h8-()
   -> scenario("h8: zero carbon tax"),
      US.carbonTax := affine(list(380,0.0),list(420,0.0),list(470,0.0), list(600,0.0)),
      EU.carbonTax := US.carbonTax,
      CN.carbonTax := US.carbonTax,
      Rest.carbonTax := US.carbonTax ]

// h8:  PNB: 217.8T$, 135.6PWh -> 584.3ppm CO2, 16.4C, 57.7PWh clean, 51.6% electricity
[h8()
   -> scenario("h8: true application of the carbon tax with moderate values"),
      US.carbonTax := affine(list(380,80.0),list(420,80.0),list(470,80.0), list(600,80.0)),
      EU.carbonTax := US.carbonTax,
      CN.carbonTax := US.carbonTax,
      Rest.carbonTax := US.carbonTax ]

// h8+: PNB: 185.0T$, 110.7PWh -> 556.5ppm CO2, 16.3C, 48.9PWh clean, 52.0% electricity
[h8+()
   -> scenario("h8+: heavy carbon tax !"),
      US.carbonTax := affine(list(380,200.0),list(430,250.0),list(480,350.0), list(600,450.0)),
      EU.carbonTax := US.carbonTax,
      CN.carbonTax := US.carbonTax,
      Rest.carbonTax := US.carbonTax ]

// h8++ PNB: 178.6T$, 111.1PWh -> 550.7ppm CO2, 16.2C, 45.5PWh clean, 49.9% electricity
[h8++()
   -> scenario("h8++: very heavy carbon tax !"),
      US.carbonTax := affine(list(380,400.0),list(430,450.0),list(480,550.0), list(600,650.0)),
      EU.carbonTax := US.carbonTax,
      CN.carbonTax := US.carbonTax,
      Rest.carbonTax := US.carbonTax ]


// play with damages

// debug - no impact of warming
// h9d: PNB: 244.2T$, 162.4PWh -> 603.9ppm CO2, 16.5C, 67.8PWh clean, 51.2% electricity
[h9d()
   -> scenario("h9d: no impact of warming"),
      US.disasterLoss := affine(list(1.0,0),list(1.5,0),list(2,0),list(3,0),list(4,0),list(5,0)),
      EU.disasterLoss := US.disasterLoss,
      CN.disasterLoss := US.disasterLoss,
      Rest.disasterLoss := US.disasterLoss ]

// Nordhaus like impact
// h9:  PNB: 241.4T$, 159.3PWh -> 602.1ppm CO2, 16.5C, 65.1PWh clean, 50.6% electricity
[h9-()
   -> scenario("h9-: Global warming damages with moderate values for impact"),
      US.disasterLoss := affine(list(1.0,0),list(1.5,1.5%),list(2,2%),list(3,3%),list(4,4%),list(5,5%)),
      EU.disasterLoss := US.disasterLoss,
      CN.disasterLoss := US.disasterLoss,
      Rest.disasterLoss := US.disasterLoss ]

// h9+: PNB: 228.2T$, 145.6PWh -> 598.3ppm CO2, 16.4C, 56.7PWh clean, 49.3% electricity
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
      Gaia.co2Ratio := 0.08,                // assumes it will grow because of ocean acidification
      for c in Consumer c.disasterLoss := affine(list(1.0,0),list(1.5,1.5%),list(2,2%),list(3,3%),list(4,4%),list(5,5%)), 
      Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(600.0), PWh(350.0)), 
                              list(perMWh(800.0), PWh(450.0)), list(perMWh(5000.0), PWh(600.0))),       // 
      Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(300.0), PWh(300.0)), 
                              list(perMWh(800.0), PWh(450.0)), list(perMWh(5500.0), PWh(500.0))),
      Coal.capacityGrowth := 3%,
      Coal.sensitivity := 60%,
      XtoClean(-50%),
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

// h11: PNB: 229.3T$, 181.2PWh -> 708.1ppm CO2, 16.8C, 47.5PWh clean, 36.0% electricity

// Jancovici scenario : do the best to stay below +1.5C = 15.2C (15.4 OK)
// we use a heavy carbon tax to reduce CO2 emissions
// we assume a high level of savings (efficiency) and a fast transition to clean
[h12(factor:Percent)
   -> scenario("h12: Jancovici scenario below +1.5C, @ " /+ string%(factor)),
      XtoClean(80%),
      for c in Consumer 
       (c.saving := improve(c.saving,20%),
        c.cancel := improve(c.cancel,30%)),      // acceleration through sobriety
      // assumes that no new fossil exploration is allowed
      Oil.inventory := affine(list(perMWh(400.0),PWh(193.0)), list(perMWh(600.0), PWh(220.0)), 
                              list(perMWh(1600.0), PWh(230.0)), list(perMWh(5000.0), PWh(250.0))),       // 
      Gas.inventory := affine(list(perMWh(163.0),PWh(160.0)), list(perMWh(320.0), PWh(190.0)), 
                              list(perMWh(5500.0), PWh(240.0))),
      Coal.capacityGrowth = 0%,                  // no new coal
      // double -> close to IRINA numbers
      //  growthPotential = affine(list(2000,0.2), list(2020,0.2),list(2030,1.5),list(2040,2.0),list(2100,4.0)),
      Clean.growthPotential := affine(list(2000,0.4), list(2020,2.2),list(2050,3.3),list(2100,4.0)),
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
// note that it worked better with the M4 CO2 absorption model since low emissions were absorbed by the earth (up to 16 Gt)

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
      for s in Supplier s.techFactor := 1.2,
      let CT2 := step(list(380,0.0),list(420,100.0),list(470,150.0), list(600,200.0)) in
           (US.carbonTax := CT2,
            EU.carbonTax := CT2,
            CN.carbonTax := CT2,
            Rest.carbonTax := CT2),
      // parametrization of these curves 
      for c in Consumer 
           adjust(c.carbonTax,factor),   // adjust  from 0 to 100%
      go(90) ]

// h13: PNB: 279.3T$, 124.6PWh -> 555.0ppm CO2, 16.3C, 66.1PWh clean, 61.7% electricity

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
// *    Part 4: Tactical Optimization (hand tuning version)           *
// *    Automated BR(tactic -> satis(c)) will be implemented in GW6   *
// ********************************************************************

// add CO2 tax for Europe
[tacx(c:Consumer,val:Percent) : void
   -> reinit(World,Oil,Clean),
      c.taxFromPain := val,
      add_years(90),
      //[0] ==== tactical simulation for ~S: taxFromPain = ~F1% ========= // c,val,
      see(c.economy,pb.year),
      hM5(c) ]
      
// add cancelAcceleration for c:Consumer, such as Europe
[tacc(c:Consumer, val:Percent) : void
   -> reinit(World,Oil,Clean),
      c.cancelFromPain := val,
      add_years(90),
      //[0] ==== tactical simulation for ~S: cancelFromPain = ~F1% ========= // c,val,
      see(c.economy,pb.year),
      hM2(c) ]

// add cancelAcceleration for c:Consumer, such as Europe
[tact(c:Consumer, tstart:Percent, val:Percent) : void
   -> reinit(World,Oil,Clean),
      c.transitionStart := tstart,
      c.transitionFactors[1] := tstart,
      c.transitionFromPain := val,
      add_years(90),
      //[0] ==== tactical simulation for ~S: transitionFromPain = (~F1%,~F1%) ========= // c,tstart,val,
      see(c.economy,pb.year),
      hM3(c) ]

// create some protectionism (hence add a carbon tax for that country)
// use a flat 200$/tC tax to check that the amount of tax is OK
[tacp(c:Consumer, pstart:Percent, val:Percent) : void
   -> reinit(World,Oil,Clean),
      c.protectionismFromPain := val,
      c.protectionismStart := pstart,
      TESTC := CN,
      c.carbonTax := step(list(380,200.0),list(420,200.0),list(540,200.0), list(600,200.0)),
      add_years(90),
      //[0] ==== tactical simulation for ~S: protectionismFromPain = ~F1% ========= // c,val,
      see(c.economy,pb.year),
      hM4(c) ]

// automated scripting : a first step towards GTES
// retuns a list of KPI : GDP, CO2, Satisfaction, pain
tacticalProperties :: list(taxFromPain,cancelFromPain,transitionStart,transitionFromPain,
                           protectionismStart,protectionismFromPain)

[makeTactic(c:Consumer, i:integer, val:Percent, vother:Percent) : void
   -> reinit(World,Oil,Clean),
      write(tacticalProperties[i],c,val),
      if (i = 3) (c.transitionFromPain := vother, c.transitionFactors[1] := val)
      else if (i = 4) c.transitionStart := vother
      else if (i > 4)
         (c.carbonTax := step(list(380,200.0),list(420,200.0),list(540,200.0), list(600,200.0)),
          if (i = 5) c.protectionismFromPain := vother
          else c.protectionismStart := vother),
      add_years(90),
      list<float>(c.economy.results[pb.year],
                  pb.earth.co2Levels[pb.year],
                  100.0 * average(list<float>{c.satisfactions[i] |  i in (1 .. pb.year)}),
                  100.0 * average(list<float>{c.painLevels[i]| i in (1 .. pb.year)})) ]

// create the table
makeTable(c:Consumer, i:integer, n:integer, vmin:Percent, vmax:Percent)
  -> makeTable(c,i,n,vmin,vmax,0%)

[makeTable(c:Consumer,i:integer, n:integer, vmin:Percent, vmax:Percent, vother:Percent)
  -> let l := list<list>() in 
       (for j in (0 .. (n - 1))
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
|0.05555555|     21.53|    600.04|     75.31|     18.07|
|0.11111111|     21.16|    600.03|     75.19|     18.09|
|0.16666666|     20.58|    600.01|     74.98|     18.40|
|0.22222222|     20.19|    599.99|     74.78|     18.73|
|0.27777777|     19.77|    599.97|     74.44|     19.46|
|0.33333333|     19.43|    599.98|     74.24|     19.78|
|0.38888888|     18.98|    599.98|     73.96|     20.37|
|0.44444444|     18.73|    599.98|     73.80|     20.56|
|       0.5|     18.40|    599.98|     73.49|     21.22|
|0.55555555|     18.01|    600.00|     73.28|     21.63|
+----------+----------+----------+----------+----------+ */

/* makeTable(EU,2,10,0%,50%)
+----------+----------+----------+----------+----------+
|          |       gdp|       co2|satisfacti|      pain|
+----------+----------+----------+----------+----------+
|         0|     21.53|    600.04|     75.31|     18.07|
|0.05555555|     21.36|    600.03|     75.31|     17.98|
|0.11111111|     21.30|    600.02|     75.29|     17.98|
|0.16666666|     21.15|    600.00|     75.21|     18.20|
|0.22222222|     20.94|    599.99|     75.16|     18.31|
|0.27777777|     20.82|    599.98|     75.09|     18.48|
|0.33333333|     20.64|    599.97|     75.06|     18.53|
|0.38888888|     20.59|    599.95|     74.97|     18.75|
|0.44444444|     20.39|    599.93|     74.91|     18.88|
|       0.5|     20.33|    599.92|     74.89|     18.88|
+----------+----------+----------+----------+----------+ */

// makeTable(EU,3,10,0,50%,20%) -> test various hypothesis of transitionStarts with 20% from Pain

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

// re-launch (test reinit :))
[rego()  
   -> reinit(),
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
// this global variable is the 4 reference values for 2000. 
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