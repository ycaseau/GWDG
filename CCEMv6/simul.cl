// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
// *       file: simul.cl                                             *
// ********************************************************************

// this file contains the overall simulation engine

// ********************************************************************
// *    Part 1: Time-step simulation                                  *
// *    Part 2: Simulation & Results                                  *
// *    Part 3: Experiment Init                                       *
// *    Part 4: KNU reset                                              *
// *    Part 5: Utility functions for input                           *
// ********************************************************************


// ********************************************************************
// *    Part 1: Time-step simulation                                  *
// ********************************************************************


YSTOP:integer :: 1000    // debug: control variable
YTALK:integer :: 1000

// one simulation step
[run(p:Problem) : void
  -> let y := p.year + 1 in
       (pb.year := y,
        //[2] ==================================  [~A] =================================== // year!(y),
        if (y = YTALK | y = YSTOP) (DEBUG := 1, SHOW2 := 1),
        for c in Consumer getNeed(c,y),             // M2: overall need (all energies)
        for s in Supplier
           (//[SHOW2] ********* energy ~S : ~F2 PWh ********************************************* // s,sum(list{c.needs[y][s.index] | c in Consumer}),
            getProd(s,p.year),                      // M1: set first vector = supply
            if not(DI) 
               (resetNeed(p),                // reset second vector to 0
                for c in Consumer getNeed(c,s,y)),       // computes the need of c for energy s
            s.sellPrices[y] := TESTsolve(p,s),          // M2: find the approximate equilibrium price
            if (s = TESTO) //[1] >>> set price(~S) =~F2 (cap -> ~F2) => demand : ~F2 [~F2]// s,s.sellPrices[y],capacity(s,y,s.sellPrices[y]),totalDemand(y,s,s.sellPrices[y]),s.capacities[y],
            balanceEnergy(s,y),                     // M2: sets consos and prod for perfect balance
            for c in Consumer record(c,s,y),        // M3: record the need of c for energy s
            recordCapacity(s,y)),                   // M2: compute investEnergy
        //[SHOW4] ========== move to world economy (input = ~F2 PWh) ================ // sum(list{b.inputs[y] | b in Block}),
        getEconomy(y),                                  // M4: economy
        if (verbose() > 0)
         printf("[~A] gdp = ~F2T$ from ~F2PWh input at ~I\n",year!(y), pb.world.all.results[y], pb.world.all.inputs[y],
                printEnergyPrices(y)),
        react(p.earth,y),                                    // M5: CO2 + carbon tax
        if (y = YSTOP) error("stop at YSTOP")) ]


// show the prices
[printEnergyPrices(y:Year) 
  -> for s in Supplier printf("~S:~F1$,",s,s.sellPrices[y]) ]  


[resetNeed(p:Problem) : void
  -> for i in (1 .. NIS) p.needCurve[i] := 0.0 ]

// average tax 
[avgTax(s:Supplier,y:Year) : float
 -> let w1 := 0.0, w2 := 0.0 in
      (for c in Consumer
         (w1 :+ tax(c,s,y) * c.needs[y][s.index],
          w2 :+ c.needs[y][s.index]),
       w1 / w2)]


// sample makes an affine object from the prod/need curves - x axis is price increment
[priceSample(l:list<float>) : Affine
  -> let m1 := 1e9, M1 := -1e9,
         l1 := list<float>{pb.priceRange[x] | x in (1 .. NIS)} in
       (for v in l (m1 :min v, M1 : max v),
        Affine(n = length(l), minValue = m1, maxValue = M1,
               xValues = l1, yValues = l)) ]

// same with a time serie - x axis is years
[timeSample(l:list<float>) : Affine
   -> let m1 := 1e9, M1 := -1e9, nL := length(l),
         l1 := list<float>{yearF(i) | i in (1 .. nL)} in
       (for v in l (m1 :min v, M1 : max v),
        Affine(n = length(l), minValue = m1, maxValue = M1,
               xValues = l1, yValues = l)) ]

// run n years of simulation, then show the results
[iterate_run(n:integer)
  -> time_set(),
     for i in (1 .. n) run(pb),
     time_show(),
     see(),
     if (n >= 40) showKNU() ]
     
// combine for all suppliers  (used in hist(c:Consumer))
[allNeed(c:Consumer,y:Year) : float 
   -> sum(c.needs[y])]
[allCancel(c:Consumer,y:Year) : float 
   -> c.economy.cancels[y]]
[allSaving(c:Consumer,y:Year) : float 
   -> sum(c.savings[y])]
[allConso(c:Consumer,y:Year) : float 
   -> sum(c.consos[y])]
[allSaving(y:Year) : float 
    -> sum(list{sumSavings(c,y) | c in Consumer})]

[steelConso(y:Year) : float
  -> sum(list{b.ironConsos[y] | b in Block})]

[carbonTax(y:Year) : float
  -> sum(list{c.carbonTaxes[y] | c in Consumer}) ]

// saving ratios
[savingRatio(c:Consumer,y:Year) : Percent 
    -> sumSavings(c,y) / sumNeeds(c,y)]

// actual transfer in PWh (world wide)
[actualEnergy(tr:Transition,y:Year) : Energy
  -> sum(list{c.substitutions[y][tr.index] | c in Consumer}) ]

// computes the co2KWh ratio for each year
[co2KWh(y:Year) : float
  -> sum(list{ (s.co2Kwh * s.outputs[y]) | s in Supplier} ) / sum(list{s.outputs[y] | s in Supplier}) ]

// computes the energy intensity (kW.h/$) for each year
[energyIntensity(y:Year) : float
  -> TWh(pb.world.all.totalConsos[y]) / (1000.0 * pb.world.all.results[y]) ]

// same for a zone
[energyIntensity(c:Consumer,y:Year) : float
  -> TWh(sumConsos(c,y)) / (1000.0 * c.economy.results[y]) ]


// compute the GDP/person
[gdpp(y:Year) : float
  -> pb.world.all.results[y] / worldPopulation(y) ]

// averagePain
[averagePain(y:Year) : float
  -> sum(list{c.painLevels[y] | c in Consumer}) / 4.0 ]

// averagePain from (lack of) energy
[averageEnergyPain(y:Year) : float
  -> sum(list{c.painEnergy[y] | c in Consumer}) / 4.0 ]

// averagePain from Economy (loss of PNB)
[averageEconomyPain(y:Year) : float
  -> sum(list{c.painResults[y] | c in Consumer}) / 4.0 ]

// averagePain from warming
[averageWarmingPain(y:Year) : float
  -> sum(list{c.painWarming[y] | c in Consumer}) / 4.0 ]

// ********************************************************************
// *    Part 2: Simulation & Results                                  *
// ********************************************************************


// see() shows the situation for a given year
[see() : void
  -> printf("************************************************************************************\n"),
     printf("*          Simulation results in Year ~A                                         *\n", year!(pb.year)),
     printf("*          ~I    *\n",princ(pb.comment,68)),
     printf("************************************************************************************\n"),
     see(pb.world.all, pb.year),
     see(pb.earth, pb.year),
     for s in Supplier see(s,pb.year),
     for c in Consumer see(c,pb.year),
     for c in Consumer see(c.economy,pb.year),
     seeGDP(pb.year),
     sls()]

// show the GDP with inflation
[seeGDP(y:Year) : void
  -> printf("[~A] current GDP = ~F2T$, ~I/t\n",year!(y),gdp$(y),
               for c in Consumer printf("~S: ~F2T$, ",c,gdp$(c,y)))]
// single line summary
[sls()
  -> let w := pb.world.all, y := pb.year in
      printf("// ~I(~A) PNB: ~F1T$, ~F1PWh -> ~F1ppm CO2, ~F1C, ~F1PWh clean, ~F% electricity\n",
             princ(pb.comment,5),year!(y),
             w.results[y],w.totalConsos[y],pb.earth.co2Levels[y],
             pb.earth.temperatures[y],pb.clean.outputs[y],
             electrification%(y))]  
               
// electrification ratio
[electrification%(y:Year) : float
  -> sum(list{c.ePWhs[y] | c in Consumer}) / pb.world.all.totalConsos[y] ]

[see(x:Economy, y:Year) : void
  -> printf("[~A] ~S PNB=~F2T$, invest=~F1T$, conso=~F2, steel:~F1Gt\n",year!(y),
            (case x (Block x.describes, any pb.world)),
            x.results[y], x.investGrowth[y], x.totalConsos[y],
            x.ironConsos[y], pb.world.wheatOutputs[y]),
    if (x = pb.world)
      (printf("[~A] steel consos: ~F1Gt at price ~F1$/t\n",year!(y),
              x.ironConsos[y], x.steelPrices[y]),
       printf("[~A] agro production: ~F1Gt from surface ~F1\n",year!(y),
             x.wheatOutputs[y], x.agroSurfaces[y]))]

[see(x:Earth,y:Year)
  -> printf("--- CO2 at ~F2, temperature = ~F1, impact = ~F%, tax = ~A\n",
             x.co2Levels[y], x.temperatures[y], pb.world.all.disasterRatios[y],
             list{get(c.carbonTax,x.co2Levels[y]) | c in Consumer}) ]

[see(s:FiniteSupplier,y:Year) : void
  -> printf("~S: price = ~F2(~F%), inventory = ~F2, prod = ~F2\n",
            s,s.sellPrices[y],s.sellPrices[y] / s.sellPrices[1],
            get(s.inventory,s.sellPrices[y]) - s.gone,s.outputs[y]) ]

[see(s:InfiniteSupplier,y:Year) : void
  -> printf("~S: price = ~F2(~F%), capacity growth potential = ~F2, prod = ~F2\n",
            s,s.sellPrices[y],s.sellPrices[y] / s.sellPrices[1],
            get(s.growthPotential,yearF(y)),s.outputs[y]) ]


[see(c:Consumer,y:Year) : void
  -> printf("~S: conso(PWh) ~I vs need ~I, elec:~F2\n",c,pl2(c.consos[y]),pl2(c.needs[y]),c.ePWhs[y]) ]

// prints a list of float with F2
[pl2(l:list) : void 
  -> for x:float in l printf("~F2 ",x)]

// worldwide population
[worldPopulation(y:Year) : float
  -> sum(list{get(c.population,yearF(y)) | c in Consumer}) ]

// ********************************************************************
// *    Part 3: Experiments                                           *
// ********************************************************************

// initialize all the simulation objects
// we want the time series *s[y]
[init(w:WorldClass,e:Supplier,c:Supplier) : void
  -> pb.world := w,
     pb.earth := Earth.instances[1],
     pb.oil := e,
     pb.clean := c,
     pb.priceRange := list<float>{(PMIN + (float!(PMAX * sqr(i))) / sqr(NIS + 1)) 
                                 | i in (2 .. (NIS + 1))},
     pb.needCurve := list<float>{0.0 | x in (1 .. NIS)},
     pb.prodCurve := list<float>{0.0 | x in (1 .. NIS)},
     reinit(),
     initKNU()]

// reusable part (reinit)
[reinit()
  -> pb.year := 1,
     init(pb.world),
     init(pb.earth),
     consolidate(),
     for s in Supplier init(s),
     for c in Consumer init(c),     // will init the economy block
     consolidate(pb.world.all,1)
    ]

 // reinit version (refresh data)   
[reinit(w:WorldClass,e:Supplier,c:Supplier) : void
   -> if known?(earth,pb) reinit()
      else init(w,e,c) ]

// supplier initialization (and reinit)
[init(s:Supplier) : void
  ->   s.outputs := list<Energy>{ 0.0 | i in (1 .. NIT)},
       s.outputs[1] := s.production,
       s.heat% := (s.production - sum(list{c.eSources[s.index] | c in Consumer})) / s.production,
       s.sellPrices := list<Price>{0.0 | i in (1 .. NIT)},
       s.sellPrices[1] := s.price,
       s.gone := 0.0,
       s.addedCapacity := 0.0,
       s.additions := list<Energy>{0.0 | i in (1 .. NIT)},
       s.addedCapacities := list<Energy>{0.0 | i in (1 .. NIT)},
       case s (FiniteSupplier 
                 (s.inventories := list<Energy>{0.0 | i in (1 .. NIT)},
                  s.inventories[1] := get(s.inventory,s.price))),
       s.netNeeds := list<Energy>{0.0 | i in (1 .. NIT)},
       s.capacities := list<Energy>{0.0 | i in (1 .. NIT)},
       s.capacities[1] := s.capacityMax]

// consumer initialization (and reinit)
[init(c:Consumer) : void
  -> c.startNeeds := list<Energy>{ (c.consumes[s.index] / (1.0 - get(c.cancel,s.price))) |
                                   s in Supplier },
     c.needs := list<list<Energy>>{ list<Energy>() | i in (1 .. NIT)},
     c.needs[1] := c.consumes,
     c.consos := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.consos[1] := c.consumes,
     c.sellPrices := list<list<Price>>{list<Price>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.cancel% := list<list<Percent>>{list<Percent>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.savings := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.substitutions := list<list<Energy>>{list<Energy>{0.0 | tr in pb.transitions} | i in (1 .. NIT)},
     c.transferRates := list<list<Energy>>{list<Percent>{0.0 | tr in pb.transitions} | i in (1 .. NIT)},
     c.transferFlows := list<list<Energy>>{list<Percent>{0.0 | tr in pb.transitions} | i in (1 .. NIT)},
     c.taxAcceleration := 0.0,
     c.cancelAcceleration := 0.0,
     c.carbonTaxes := list<Price>{0.0 | i in (1 .. NIT)},
     c.painLevels := list<float>{0.0 | i in (1 .. NIT)},
     c.painWarming := list<float>{0.0 | i in (1 .. NIT)},
     c.painResults := list<float>{0.0 | i in (1 .. NIT)},
     c.painEnergy := list<float>{0.0 | i in (1 .. NIT)},
     c.co2Emissions := list<float>{0.0 | i in (1 .. NIT)}, 
     c.satisfactions := list<float>{0.0 | i in (1 .. NIT)},
     c.transitionFactors := list<float>{1.0 | i in (1 .. NIT)},
     c.ePWhs := list<float>{0.0 | i in (1 .. NIT)}, 
     c.eDeltas := list<float>{0.0 | i in (1 .. NIT)}, 
     c.ePWhs[1] := sum(list{(c.consumes[s.index] * eRatio(c,s)) | s in Supplier}),
     initBlock(c)]

 // reads form the initial data the ratio of primary energy used for electricity (vs "heat")
[eRatio(c:Consumer,s:Supplier) : float
  -> c.eSources[s.index] / c.consumes[s.index] ]

 // init for the world economy
 [init(w:WorldClass) : void
   -> w.all := Economy(),
      init(w.all),
      w.all.totalConsos[1] := sum(list{sum(c.consumes) | c in Consumer}),
      w.steelPrices := list<Price>{0.0 | i in (1 .. NIT)},
      w.steelPrices[1] := w.steelPrice,
      w.agroSurfaces := list<float>{0.0 | i in (1 .. NIT)},
      w.agroSurfaces[1] := w.agroLand,
      w.energySurfaces := list<float>{0.0 | i in (1 .. NIT)},
      w.wheatOutputs := list<float>{0.0 | i in (1 .. NIT)},
      w.wheatOutputs[1] := w.wheatProduction ]

// init the variables associated to a block (represents a consumer economy)    
[init(x:Economy) : void
  -> x.totalConsos := list<Energy>{0.0 | i in (1 .. NIT)},
     x.inputs := list<Energy>{0.0 | i in (1 .. NIT)},
     x.cancels := list<Energy>{0.0 | i in (1 .. NIT)},
     x.results := list<Price>{0.0 | i in (1 .. NIT)},
     x.results[1] := x.gdp,
     x.maxout := list<Price>{0.0 | i in (1 .. NIT)},
     x.maxout[1] := x.gdp,
     x.investGrowth := list<Price>{0.0 | i in (1 .. NIT)},
     x.investGrowth[1] := x.investG,
     x.investEnergy := list<Price>{0.0 | i in (1 .. NIT)},
     x.lossRatios := list<float>{0.0 | i in (1 .. NIT)},
     x.disasterRatios := list<float>{0.0 | i in (1 .. NIT)},
     x.investEnergy[1] := x.investE,
     x.ironConsos := list<float>{0.0 | i in (1 .. NIT)},
     x.marginImpacts :=  list<Percent>{0.0 | i in (1 .. NIT)} ]

[initBlock(c:Consumer)
   -> let w := c.economy in
         (init(w),
          w.ironConsos[1] := (w.gdp / get(w.ironDriver,yearF(1))),
          w.totalConsos[1] := sum(c.consumes),
          w.describes := c,
          w.openTrade := list<Percent>{100%  | w2 in Block},
          w.tradeFactors := list<list<Percent>>{list<Percent>{100% | w2 in Block} | i in (1 .. NIT)}) ]
      
// consolidation of the world economy : init version
[consolidate()
   -> let e := pb.world.all in
         (e.gdp := sum(list{w.gdp | w in Block}), 
          e.investG := sum(list{w.investG | w in Block}),
          e.investE := sum(list{w.investE | w in Block}))]

// consolidation for a given year
[consolidate(e:Economy, y:Year)
   -> e.totalConsos[y] := sum(list{w.totalConsos[y] | w in Block}),
      e.inputs[y] := sum(list{w.inputs[y] | w in Block}),
      e.cancels[y] := sum(list{w.cancels[y] | w in Block}),
      e.results[y] := sum(list{w.results[y] | w in Block}),
      e.maxout[y] :=  sum(list{w.maxout[y] | w in Block}),
      e.investGrowth[y] :=  sum(list{w.investGrowth[y] | w in Block}),
      e.investEnergy[y] :=  sum(list{w.investEnergy[y] | w in Block}),
      // computes the weighted loss and disaster ratio for blocks
      let loss := 0.0, disaster := 0.0, result := 0.0 in
         (for w in Block
            (result :+ w.results[y],
             disaster :+ w.results[y] * (w.disasterRatios[y] / (1 - w.disasterRatios[y])),
             loss :+ w.results[y] * w.lossRatios[y]),
          e.disasterRatios[y] := disaster / result,
          e.lossRatios[y] := loss / result)]

[init(x:Earth) : void
   -> x.temperatures := list<float>{0.0 | i in (1 .. NIT)},
      x.temperatures[1] := x.avgTemp,
      x.co2Levels := list<float>{0.0 | i in (1 .. NIT)},
      x.gdpLosses := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Levels[1] := x.co2PPM,
      x.co2Emissions := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Emissions[1] := x.co2Add ]
   
// ********************************************************************
// *    Part : KNU reset                                              *
// ********************************************************************

KNUs:list<KNU> :: list<KNU>()
KNUstore :: KNUstorage()

// init the store for values that will be mofidied by the KNU sliders
[initKNU()
  -> KNUstore.dematerializes := list<Affine>{b.dematerialize | b in Block},
     KNUstore.subMatrices := list<list<Affine>>{c.subMatrix | c in Consumer},
     KNUstore.cancels := list<Affine>{c.cancel | c in Consumer},
     KNUstore.roIs := list<Affine>{b.roI | b in Block}]
     
// resets the KNU according to the 8 KNU factors in l and reinit for the simulation
[runKNU(l:list<float>) : void
  -> //[?] length(l) = 8,
     // how we use the KNU factors varies with each sub-model
     Clean.growthPotential := getAffine(KNUs[1],l[1]),
     for b in Block b.dematerialize := applyKNU(KNUstore.dematerializes[b.describes.index],KNUs[2],l[2]),
     for c in Consumer c.subMatrix := applyKNU(KNUstore.subMatrices[c.index],KNUs[3],l[3]),
     for c in Consumer c.cancel := applyKNU(KNUstore.cancels[c.index],KNUs[4],l[4]),
     for b in Block b.roI := applyKNU(KNUstore.roIs[b.describes.index], KNUs[5],l[5]),
     pb.world.protectionismInFactor := applyKNU(50%,KNUs[6],l[6]),
     pb.world.protectionismOutFactor := applyKNU(100%, KNUs[6],l[6]),
     for c in Consumer c.disasterLoss := getAffine(KNUs[7],l[7]),
     reinit() ]

// test median
[testMedian()
  -> runKNU(list<float>{0.5 | i in (1 .. 8)})]

// low solar and low transition
[testFirst()
  -> runKNU(list<float>(0.0,0.5,0.1,0.5,0.5,0.5,0.5,0.5))]

// show the important KNU kpi for growth / demat tuning
[showKNU()
  -> //[0] ---- growth analysis based on the KNU //,
     showKNU(KNUs[1]),   // renewable growth
     showKNU(KNUs[2]),   // dematerialization of the economy : observed
     // explain the part that is due to savings (efficiency)
     printf("Saving ratio improvement 2010-2050: ~F% (~F% in 2050)\n",
            CAGR(100.0 - savingRatio(1),100.0 - savingRatio(41),40), savingRatio(41)),
     showKNU(KNUs[5])]

// generic KNU show
[showKNU(k:KNU)
  -> printf("~A, ~A: ~F2\n",k.description,k.measured-with, funcall(k.kpi,pb))]
    

// ********************************************************************
// *    Part 5: Utility functions for input                           *
// ********************************************************************

// accelerate : change the date to accelerate a policy (pivot is 2000)
[accelerate(policy:list<Affine>, factor:Percent) : list<Affine>
  ->  list<Affine>{ accelerate(p,factor)|  p in policy} ]

[accelerate(p:Affine, factor:Percent) : Affine
  -> Affine(n = p.n, yValues = p.yValues, minValue = p.minValue, maxValue = p.maxValue,
           xValues = list<float>{  (2000 + ((p.xValues[i] - 2000) * (1.0 - factor))) | i in (1 .. p.n)}) ]

// improve : modify the factors without changing the dates
[improve(p:Affine, factor:Percent) : Affine
  -> Affine(n = p.n, 
            yValues = list<float>{ (p.yValues[i] * (1 + factor)) | i in (1 .. p.n)}, 
            minValue = p.minValue * (1 + factor), 
            maxValue = p.maxValue * (1 + factor),
            xValues = p.xValues) ]

// improve% : modify the factors without changing the dates
// special form so that % stays a percent
[improve%(x:Percent,factor:Percent) : Percent
  -> assert(factor <= 1.0),
     if (factor > 0.0) x + factor * (1.0 - x)
     else x + factor * x ]

[improve%(p:Affine, factor:Percent) : Affine
  -> Affine(n = p.n, 
            yValues = list<float>{ improve%(p.yValues[i], factor) | i in (1 .. p.n)}, 
            minValue = improve%(p.minValue, factor), 
            maxValue = improve%(p.maxValue, factor),
            xValues = p.xValues) ]


// tune a policy by changing one substitution
[tune(policy:list<Affine>,from:Supplier,to:Supplier,line:Affine) : list<Affine>
  -> let tr := getTransition(from,to), n := length(policy) in
       list<Affine>{ (if (i = tr.index) line else policy[i]) | i in (1 .. n) }]


// adjust a policy represented by an affine function: keep the dates, change the value by a factor
// destructive operation -> changes the affine / list function
[adjust(a:ListFunction,factor:Percent) : void
   -> for i in (1 .. a.n) a.yValues[i] :* factor ]       


// create a trade matrix
// inputs are export flows in billions of dollars, gdp in in trillons of dollars
[balanceOfTrade(l:list) : list<list<Percent>>
  -> list<list<Percent>>{ (let ec := c.economy in
                             list<Percent>{  (l[c.index][c2.index] / (ec.gdp * 1000.0)) 
                                             | c2 in Consumer }) |
                          c in Consumer} ]

// fraction of gdp that is not linked to external trade
[innerTrade(w:Block) : Percent
  -> let p := 1.0 in
       (for w2 in (Block but w)
          (p :- pb.trade[index(w)][index(w2 as Block)]),
        p)]



