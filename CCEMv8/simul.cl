// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2025 Yves Caseau                        *
// *       file: simul.cl                                             *
// ********************************************************************

// this file contains the overall simulation engine

// ********************************************************************
// *    Part 1: Time-step simulation                                  *
// *    Part 2: Simulation & Results                                  *
// *    Part 3: Experiment Init                                       *
// *    Part 4: KNU scripting, reset & Randomization                  *
// *    Part 5: Utility functions for input                           *
// ********************************************************************


// ********************************************************************
// *    Part 1: Time-step simulation                                  *
// ********************************************************************


YSTOP:integer :: 1000    // debug: control variable
YTALK:integer :: 1000

// one simulation stepsavingF
[run(p:Problem, talk?:boolean) : void
  -> let y := p.year + 1 in
       (pb.year := y,
        //[2] ==================================  [~A] =================================== // year!(y),
        if (y = YTALK | y = YSTOP) (DEBUG := 1, SHOW2 := 1),
        for c in Consumer getNeed(c,y),             // M2: overall need (all energies)
        for s in Supplier
           (//[SHOW2] ********* energy ~S : ~F2 PWh ********************************************* // s,sum(list{c.needs[y][s.index] | c in Consumer}),
            computeCapacity(s,p.year),                // M1: supply is governed by (max) capacity
            s.sellPrices[y] := disolve(p,s),          // M2: find the approximate equilibrium price
            balanceEnergy(s,y),                       // M2: sets consos and prod for perfect balance
            for c in Consumer record(c,s,y),          // M3: record the need of c for energy s
            recordCapacity(s,y)),                     // M2: compute investEnergy from growth and transfers
        //[SHOW4] ========== move to world economy (input = ~F2 PWh) ================ // sum(list{b.inputs[y] | b in Block}),
        getEconomy(y),                                  // M4: economy
        if (talk? & verbose() > 0)
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
   -> iterate_run(n,true) ]

[iterate_run(n:integer,talk?:boolean)
  -> if talk? time_set(),
     for i in (1 .. n) run(pb,talk?),
     if talk? 
        (time_show(),
         see()) ]
     
// combine for all suppliers  (used in hist(c:Consumer))
[allNeed(c:Consumer,y:Year) : float 
   -> sum(c.needs[y])]
[allCancel(c:Consumer,y:Year) : float 
   -> c.economy.cancels[y]]
[allConso(c:Consumer,y:Year) : float 
   -> sum(c.consos[y])]

// needed in web.cl (world sum of savings)   
[allSaving(y:Year) : float 
    -> sum(list{sumSavings(c,y) | c in Consumer})]

[steelConso(y:Year) : float
  -> sum(list{b.ironConsos[y] | b in Block})]

[carbonTax(y:Year) : float
  -> sum(list{c.carbonTaxes[y] | c in Consumer}) ]

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
     updateCharts(pb.year),
     sls()]

// update all the Charts (at the end of the simulation)
[updateCharts(y:Year) : void
   -> updateChartsEarth(pb.earth,y),
      for c in Consumer updateChartsConsumer(c,y),
      for s in Supplier updateChartsSupplier(s,y)]

// update the Charts for the earth
[updateChartsEarth(e:Earth,y:Year) : void
  ->  udapdateChart(e.charts.co2Levels,y, e.co2Levels),
      udapdateChart(e.charts.co2Emissions,y, e.co2Emissions),
      udapdateChart(e.charts.temperatures,y, e.temperatures),
      udapdateChart(e.charts.gdpLosses,y, e.gdpLosses)]

// update the Charts for a consumer
[updateChartsConsumer(c:Consumer,y:Year) : void
  -> for s in Supplier
       udapdateChart(c.charts.consos[s.index],y, list<float>{c.consos[i][s.index] | i in (1 .. y)}),
     udapdateChart(c.charts.needs,y, list<float>{allNeed(c,i) | i in (1 .. y)}),
     udapdateChart(c.charts.gdp,y, c.economy.results),
     udapdateChart(c.charts.cancel%,y, list<float>{cancelRatio(c,i) | i in (1 .. y)}),
     udapdateChart(c.charts.savings,y, list<float>{sumSavings(c,i) | i in (1 .. y)}),
     udapdateChart(c.charts.carbonTaxes,y, c.carbonTaxes),
     udapdateChart(c.charts.painLevels,y, c.painLevels)]

// update the Charts for a supplier
[updateChartsSupplier(s:Supplier,y:Year) : void
  -> udapdateChart(s.charts.outputs,y, s.outputs),
     udapdateChart(s.charts.sellPrices,y, s.sellPrices),
     case s (FiniteSupplier udapdateChart(s.charts.inventories,y, s.inventories)),
     udapdateChart(s.charts.capacities,y, s.capacities),
     udapdateChart(s.charts.rawNeeds,y, s.rawNeeds)]
     
// updates all the measures in a Tmeasure from a Charts
[udapdateChart(lm:Tmeasure,y:Year,lv:list<float>) : void
  -> for i in (1 .. y) add(lm[i],lv[i]) ]

// show the GDP with inflation
[seeGDP(y:Year) : void
  -> printf("[~A] current GDP = ~F2T$, ~I\n",year!(y),gdp$(y),
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

// transfert to clean ratio at a given year (weighted average by consos)
[transferToClean%(y:Year) : float
  -> let sum_w := 0.0, sum_p := 0% in
       (for c in Consumer
          let w := sum(c.consos[y]) in
             (for s in FiniteSupplier
                let tr := getTransition(s,pb.clean) in
                   (sum_w :+ w,
                    sum_p :+ (w * c.transferRates[y][tr.index]))),
        sum_p / sum_w)]

[see(x:Economy, y:Year) : void
  -> printf("[~A] ~S GDP=~F2T$(+~F1 %), invest=~F1T$, conso=~F2, steel:~F1Gt\n",year!(y),
            (case x (Block x.describes, any pb.world)),
            x.results[y], CAGR(x.results[1],x.results[y],y - 1),
            x.investGrowth[y], x.totalConsos[y],
            x.ironConsos[y], pb.world.wheatOutputs[y]),
    if (x = pb.world.all)
      (printf("[~A] steel consos: ~F2Gt at price ~F1$/t\n",year!(y),
              x.ironConsos[y], pb.world.steelPrices[y]),
       printf("[~A] agro production: ~F2Gt from surface ~F1\n",year!(y),
             pb.world.wheatOutputs[y], pb.world.agroSurfaces[y]))]

[see(x:Earth,y:Year)
  -> printf("--- CO2 at ~F2ppm, temperature = ~F1C (+~F1), tax = ~A\n",
             x.co2Levels[y], x.temperatures[y], warming(y),
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
  -> printf("~S: conso:~F2PWh ~Ivs need:~F2 ~I, elec:~F2\n",c,sum(c.consos[y]),pl2(c.consos[y]),
            sum(c.needs[y]),pl2(c.needs[y]),c.ePWhs[y]) ]

// prints a list of float with F2
[pl2(l:list) : void 
  -> for x:float in l printf("~F2 ",x)]

// worldwide population
[worldPopulation(y:Year) : float
  -> sum(list{populationEstimate(c,y) | c in Consumer}) ]

// ********************************************************************
// *    Part 3: Experiments                                           *
// ********************************************************************

// initialize all the simulation objects
// we want the time series *s[y]
[registerConstant(w:WorldClass,e:Supplier,c:Supplier) : void
  -> pb.world := w,
     pb.earth := Earth.instances[1],
     pb.oil := e,
     pb.clean := c]

// initialize all the simulation objects
// we want the time series *s[y]
[init() : void
  -> pb.priceRange := list<float>{(PMIN + (PMAX * sqr(i)) / sqr(NIS + 1)) 
                                 | i in (2 .. (NIS + 1))},
     pb.needCurve := list<float>{0.0 | x in (1 .. NIS)},
     pb.prodCurve := list<float>{0.0 | x in (1 .. NIS)},
     makeCharts(NIT),
     initialization()]
 //    initKNU()]

 // update all the Charts
[makeCharts(y:Year) : void
  -> pb.earth.charts := makeChartsEarth(y),
     for c in Consumer c.charts := makeChartsConsumer(y),
     for s in Supplier s.charts := makeChartsSupplier(y)]

// create an empty chart for the earth
[makeChartsEarth(y:Year) : ChartsEarth
  -> ChartsEarth( co2Levels = makeTmeasure(y),
                  temperatures = makeTmeasure(y),
                  co2Emissions = makeTmeasure(y),
                  gdpLosses = makeTmeasure(y)) ]

// create an empty chart for a consumer
[makeChartsConsumer(y:Year) : ChartsConsumer
  -> ChartsConsumer( consos = list<Tmeasure>{makeTmeasure(y) | s in Supplier},
                     gdp = makeTmeasure(y),
                     needs = makeTmeasure(y),
                     cancel% = makeTmeasure(y),
                     savings = makeTmeasure(y),
                     carbonTaxes = makeTmeasure(y),
                     painLevels = makeTmeasure(y)) ]

// create an empty chart for a supplier
[makeChartsSupplier(y:Year) : ChartsSupplier
  -> ChartsSupplier( outputs = makeTmeasure(y),
                     sellPrices = makeTmeasure(y),
                     inventories = makeTmeasure(y),
                     capacities = makeTmeasure(y),
                     rawNeeds = makeTmeasure(y)) ]
                     
                   

// reusable part (for init and reinit)
[initialization()
  -> pb.year := 1,
     init(pb.world),
     init(pb.earth),
     consolidate(),
     for s in Supplier init(s),
     for c in Consumer init(c),     // will init the economy block
     consolidate(pb.world.all,1)
    ]

 // reinit version (refresh data)   
[reinit() : void
   -> if known?(earth,pb) initialization()
      else init() ]

// supplier initialization (and reinit)
[init(s:Supplier) : void
  ->   s.outputs := list<Energy>{ 0.0 | i in (1 .. NIT)},
       s.outputs[1] := s.production,
       s.heat% := (s.production - CARNOT * sum(list{c.eSources[s.index] | c in Consumer})) / s.production,
       s.sellPrices := list<Price>{0.0 | i in (1 .. NIT)},
       s.sellPrices[1] := get(s.equilibriumPrice,yearF(1)),          // CCEM v8: replace s.price (@ORIGIN) 
       s.gone := 0.0,
       s.addedCapacity := 0.0,
       s.additions := list<Energy>{0.0 | i in (1 .. NIT)},
       s.addedCapacities := list<Energy>{0.0 | i in (1 .. NIT)},
       case s (FiniteSupplier 
                 (s.inventories := list<Energy>{0.0 | i in (1 .. NIT)},
                  s.inventories[1] := get(s.inventory,s.sellPrices[1]))),
       s.rawNeeds := list<Energy>{0.0 | i in (1 .. NIT)},
       s.capacities := list<Energy>{0.0 | i in (1 .. NIT)},
       s.capacityMax := s.capacityOrigin,
       s.capacities[1] := s.capacityOrigin]

// consumer initialization (and reinit)
// CCEMv6 : assumes that cancel is 0 at start (the code in game.cl is based on this)
[init(c:Consumer) : void
  -> c.startNeeds := list<Energy>{ c.consumes[s.index]  | s in Supplier },
     for s in Supplier 
        (if (get(c.cancel, oilEquivalent(s,s.sellPrices[1])) > 1%)
            error("CCEM models assumes that cancel(~S,~S) is 0 at start",c,s)),
     c.needs := list<list<Energy>>{ list<Energy>() | i in (1 .. NIT)},
     c.needs[1] := c.consumes,
     c.consos := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.consos[1] := c.consumes,
     c.sellPrices := list<list<Price>>{list<Price>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.cancel% := list<list<Percent>>{list<Percent>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.substitutions := list<list<Energy>>{list<Energy>{0.0 | tr in pb.transitions} | i in (1 .. NIT)},
     c.savingRates := list<Percent>{0% | i in (1 .. NIT)},
     c.savings := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.eSavings := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.transferRates := list<list<Energy>>{list<Percent>{0.0 | tr in pb.transitions} | i in (1 .. NIT)},
     c.transferFlows := list<list<Energy>>{list<Percent>{0.0 | tr in pb.transitions} | i in (1 .. NIT)},
     c.taxAcceleration := 0.0,
     c.cancelAcceleration := 0.0,
     c.yearlySaving := c.maxSaving / 90,                        // very crude : linear improvement over the century
     c.carbonTaxes := list<Price>{0.0 | i in (1 .. NIT)},
     c.painLevels := list<float>{0.0 | i in (1 .. NIT)},
     c.painWarming := list<float>{0.0 | i in (1 .. NIT)},
     c.painResults := list<float>{0.0 | i in (1 .. NIT)},
     c.painEnergy := list<float>{0.0 | i in (1 .. NIT)},
     c.co2Emissions := list<float>{0.0 | i in (1 .. NIT)}, 
     c.satisfactions := list<float>{0.0 | i in (1 .. NIT)},
     c.satisfactions[1] := 1.0,
     c.savingFactors := list<float>{0.0 | i in (1 .. NIT)},          // start at 0
     c.transitionFactors := list<float>{0.0 | i in (1 .. NIT)},      // start at 0%
     c.ePWhs := list<float>{0.0 | i in (1 .. NIT)}, 
     c.eDeltas := list<float>{0.0 | i in (1 .. NIT)}, 
     c.ePWhs[1] := sum(list{(c.consumes[s.index] * eRatio(c,s)) | s in Supplier}),
     c.co2Emissions[1] := sum(list{(c.consumes[s.index] * s.co2Factor) | s in Supplier}),
     initAdapt(c),
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
     x.sobriety := list<Energy>{0.0 | i in (1 .. NIT)},
     x.results := list<Price>{0.0 | i in (1 .. NIT)},
     x.results[1] := x.gdp,
     x.maxout := list<Price>{0.0 | i in (1 .. NIT)},
     x.maxout[1] := x.gdp,
     x.investGrowth := list<Price>{0.0 | i in (1 .. NIT)},
     x.investGrowth[1] := x.investG,
     x.investEnergy := list<Price>{0.0 | i in (1 .. NIT)},
     // debug - clean later
     x.investTransition := list<Price>{0.0 | i in (1 .. NIT)},
     x.investCapacity := list<Price>{0.0 | i in (1 .. NIT)},
     x.lossRatios := list<float>{0.0 | i in (1 .. NIT)},
     x.disasterRatios := list<float>{0.0 | i in (1 .. NIT)},
     x.investEnergy[1] := x.investE,
     x.ironConsos := list<float>{0.0 | i in (1 .. NIT)},
     x.reducedImports := list<Energy>{0.0 | i in (1 .. NIT)},
     x.marginImpacts :=  list<Percent>{0.0 | i in (1 .. NIT)} ]

[initAdapt(c:Consumer)
  -> let a := c.adapt in
        (a.levels := list<float>{0.0 | i in (1 .. NIT)},
         a.spends := list<float>{0.0 | i in (1 .. NIT)},
         a.losses := list<float>{0.0 | i in (1 .. NIT)},
         a.gains := list<float>{0.0 | i in (1 .. NIT)},
         a.sums := list<float>{0.0 | i in (1 .. NIT)}) ]

	
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
      e.sobriety[y] := sum(list{w.sobriety[y] | w in Block}),
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
      x.adaptGains := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Levels[1] := x.co2PPM,
      x.co2Emissions := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Emissions[1] := x.co2Add,
      x.co2Cumuls := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Cumuls[1] := x.co2Cumul]
   
// ********************************************************************
// *    Part 4: KNU scripting, reset & Randomization                  *
// ********************************************************************

// create a transition matrix for a sector
// assumes 0% at ORIGIN
// eg : SETM(list(2050,2100),
//                   list(list(Coal,list(Oil,0%,0%),list(Gas,100%,100%),list(Clean,0%,0%)),
//                        list(Oil,list(Gas,10%,20%),list(Clean,10%,30%)),
//                         list(Gas,list(Clean,20%,40%))))
[SETM(ldates:list,ldesc:list) : list<Affine>
  -> let n := length(ldates), larg := list<Affine>{unknown | tr in pb.transitions} in
       (for l in ldesc 
         let s1 := l[1], k := length(l as list) in   // k is at least 2
            (for w in (2 .. k) 
              let l2 := l[w], s2 := l2[1], tr := getTransition(s1,s2) in
              (//[5] tr=~S l2=~S in ~A // tr,l2,tr.index,
               larg[tr.index] := make_affine(list<float>(float!(ORIGIN)) /+ list<float>{float!(ldates[j]) | j in (1 .. n)},
                                             list<float>(0.0) /+ list<float>{l2[j + 1] | j in (1 .. n)}))),
        larg)]


// How to define the energy transition matrix from the sector KNUs
// ETM (Energy Transition Matrix) would be produced from the sector transition matrices and
// zone-specific transition speeds 
// example : => ETM(list(60%,80%,100%),list(Transport,20%),list(Industry,30%),list(Residential,20%))
// assertion: length(seed) = length(ldates)
[ETM(seed:list,sectors:list) : list<Affine>
  -> let ldates := nil, lweight := list<Percent>{0% | s in Sector} in
       (// process the sectors list (order independance + setup Other)
        for l:list in sectors 
           let s := (l[1] as Sector) in          // explicitation for diet purposes
               lweight[s.index] := l[2],
        lweight[size(Sector)] := 100% - sum(lweight),
        // checks that  the chronology is the same for all sectors
        for s in Sector                                   
           (if (length(ldates) = 0) ldates := s.subMatrix[1].xValues
            else assert(ldates = s.subMatrix[1].xValues)),
        assert(length(ldates) = length(seed)),
        // builds the linear combination of affines for each transition
        list<Affine>{ (let i := tr.index, n := length(ldates) in       
                        make_affine(ldates,
                           list<float>{ (seed[j] * 
                                         sum(list<float>{ (s.subMatrix[tr.index].yValues[j] * 
                                                           energyWeight(tr.from,s,lweight)) | s in Sector}))  
                                      | j in (1 .. n)}))
                     | tr in pb.transitions})]

// weight of sector s for energy e (percentage, the sum must be 100%)
// inputs are e, s, lweight (list of sector weight for zone)
[energyWeight(e:Supplier,s:Sector,lweight:list<Percent>) : Percent
  -> let v := lweight[s.index] * s.energy%[e.index],
         total := sum(list<float>{(lweight[s.index] * s.energy%[e.index]) | s in Sector}) in
        (v / total)]

// creates an Affine function that increases according to CAGR given for some decades (cummulated decrease of energy)
// ex: USDemat :: densityCurve(1980,list(2020,1.7%),list(2050,1.5%),list(2100,1.2%))
[densityCurve(start:integer,l:listargs) : Affine
   -> let date := start, ldate := list<float>(float!(date)), 
          value := 0.0, lvalue := list<float>(value) in
        (for item in l 
           let end := item[1], cagr := item[2], n:integer := (end - date) / 10 in
             (for i in (1 .. n) 
                (date :+ 10,
                 ldate :add float!(date),
                 value := 1.0 - ((1.0 - value) / ((1.0 + cagr) ^ 10.0)),
                 lvalue :add value)),
          make_affine(ldate, lvalue)) ]

// creates an elasticity Affine function from the starting price of Oil and short / long-term elasticity
// the Affine gives for a price the fraction of energy consumption that is canceled
// ex: USCancel :: elasticityCurve(35.0,5%,30%)
// Note: there must be a coherence between PMAX, ELASMAX, start and % of reduction.
ELASMAX :: 5
[elasticityCurve(start:Price,shortTerm:Percent,longTerm:Percent) : Affine
  -> let price := start, lprices := list<float>(price),
         value := 0.0, lvalues := list<float>(value) in
       (price :* 2,
        lprices :add price,
        value := 1.0 - ((1.0 - value) / (1.0 + shortTerm)),
        lvalues :add value,
        for i in (1 .. ELASMAX) 
          (price :* 2,
           lprices :add price,
           assert(price <= PMAX),
           value := 1.0 - ((1.0 - value) / (1.0 + longTerm)),
           if (i = ELASMAX) value := 0.99,             // a way to make the model stable (max price => no consumption)
           lvalues :add value),
        make_affine(lprices, lvalues)) ]



// creates the KNU storage (memory of initial values of KNU)
KNUstore :: KNUstorage()

// init the store for values that will be mofidied by the KNU sliders
[initKNU()
  -> KNUstore.dematerializes := list<Affine>{b.dematerialize | b in Block},
     KNUstore.subMatrices := list<list<Affine>>{c.subMatrix | c in Consumer},
     KNUstore.cancels := list<Affine>{c.cancel | c in Consumer},
     KNUstore.roIs := list<Affine>{b.roI | b in Block}]
     
 //    

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

// improve% : modify the factors without changing the dates - additive version
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

// multiplicative version  x -> x * (1 + factor)  (factor = 0% => idempotent)
[multiply%(x:Percent,factor:Percent) : Percent
  -> assert(factor <= 1.0),
      min(1.0, x * (1 + factor))]

[multiply%(p:Affine, factor:Percent) : Affine
  -> Affine(n = p.n, 
            yValues = list<float>{ multiply%(p.yValues[i], factor) | i in (1 .. p.n)}, 
            minValue = multiply%(p.minValue, factor), 
            maxValue = multiply%(p.maxValue, factor),
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
[balanceOfTrade(lt:list,lgdp:list) : list<list<Percent>>
  -> list<list<Percent>>{ (let ec := c.economy in
                             list<Percent>{  (lt[c.index][c2.index] / (lgdp[c.index] * 1000.0)) 
                                             | c2 in Consumer }) |
                          c in Consumer} ]

// fraction of gdp that is not linked to external trade
[innerTrade(w:Block) : Percent
  -> let p := 1.0 in
       (for w2 in (Block but w)
          (p :- pb.trade[index(w)][index(w2 as Block)]),
        p)]



