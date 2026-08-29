// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2026 Yves Caseau                        *
// *       file: web.cl                                               *
// ********************************************************************

// this file contains our experimentations with the web server
// it produces the curves that will be displayed in the plotters
// it links with the sliders two way: provide value/explanation and react
// current version (August 2026) is CCEM v9 with 16 sliders

NYEARS :: 90
NKNUS :: 8             // number of global 
NTACTICS :: 8          // number of sliders that are attached to zones

// ZoneOfChoice is the current zone (for policy making) or World
ZoneOfChoice:thing := unknown

// ********************************************************************
// *    Part 1: Datasets for plotters                                 *
// *    Part 2: Slider values                                         *
// *    Part 3: Callback and MVPs                                     *
// *    Part 4: Explanations for sliders                              *
// ********************************************************************

 // leverages the structure table plots[x:(class U thing)] : set<tuple>
 //  table[x] = {t1, t2, t3} where x is a named thing, and ti are time series (list of floats)
 // used with the following CLAIRE interface
 // plot(tag:any,title:string,labels:list,listX:list,listY:list)

 // CCEM v9: some datasets are zone specific, depending on the variable ZoneOfChoice
  
// datasets for the input ------------------------------------------------------

// energy by Supplier (cummulative : cplot vs plot; index = 1 means input) 
[dataset-energy()
    -> cplot(1,addPrefix("energy"),
               addPrefix("energy in PWh (yearly)"),
               list{string!(s.name) | s in Supplier},
               list<float>{yearF(i) | i in (1 .. pb.year)},
           let c := ZoneOfChoice in
             case c
               (Consumer list{ list<float>{c.consos[i][s.index] | i in (1 .. pb.year)} | s in Supplier},
                any list{ list<float>{s.outputs[i] | i in (1 .. pb.year)} | s in Supplier}))]

// energy by zones (cummulative)
[dataset-consos()
   ->  cplot(1, "zones PWh","energy consumption by zonees",list{string!(c.name) | c in Consumer},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{sumConsos(c,i) | i in (1 .. pb.year)} | c in Consumer}) ]   

// fossil fuel inventories
[dataset-inventories()
    ->  plot(1,"inventories","fossil fuel inventories in Gt",
             list{string!(s.name) | s in FiniteSupplier},
             list<float>{yearF(i) | i in (1 .. pb.year)},
             list{ list<float>{s.inventories[i] | i in (1 .. pb.year)} | s in FiniteSupplier})]

// information about energy transition
[dataset-transitions()
     -> plot(1,addPrefix("transition"),
               addPrefix("energy flow changes in PWh"),
               list("cancel","savings","total","CO2/Kwh"),
               list<float>{yearF(i) | i in (1 .. pb.year)},
           let c := ZoneOfChoice in
             case c
               (Consumer list(list<float>{c.economy.cancels[i] | i in (1 .. pb.year)},
                              list<float>{sumSavings(c,i) | i in (1 .. pb.year)},
                              list<float>{sum(c.consos[i]) | i in (1 .. pb.year)},
                              list<float>{getCo2KWh(c,i) | i in (1 .. pb.year)}),
                any  list(list<float>{pb.world.all.cancels[i] | i in (1 .. pb.year)},
                          list<float>{allSaving(i) | i in (1 .. pb.year)},
                          list<float>{pb.world.all.totalConsos[i] | i in (1 .. pb.year)},
                          list<float>{co2KWh(i) | i in (1 .. pb.year)})))]

[dataset-prices()
    ->  plot(1,"prices","prices in $/KWh",list{string!(s.name) | s in Supplier},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{s.sellPrices[i] | i in (1 .. pb.year)} | s in Supplier})]

// add charts that represent the policies: carbon tax, energy invest , adapation spending, sobriety
[dataset-policies()
     -> plot(1,"policies","current zone policies",
                list("CO2 tax (T$)","energy (T$)","adaptation (T$)","sobriety (PWh)"),
                list<float>{yearF(i) | i in (1 .. pb.year)},
           list(list<float>{zocCarbonTax(i) | i in (1 .. pb.year)},
                list<float>{zocEnergyInvest(i) | i in (1 .. pb.year)},
                list<float>{zocAdaptation(i) | i in (1 .. pb.year)},
                list<float>{zocSobriety(i) | i in (1 .. pb.year)}))]

// dataset about electricity and electrification
[dataset-electricity()
    ->  plot(1,"electricity","electricity estimate in TWh and electrification ratio %",
             list("electricity","clean TWh","electrification","fossil transfer"),
             list<float>{yearF(i) | i in (1 .. pb.year)},
             list( list<float>{sum(list{c.ePWhs[i] | c in Consumer}) | i in (1 .. pb.year)},
                   list<float>{sum(list{c.consos[i][Clean.index] | c in Consumer})| i in (1 .. pb.year)},
                   list<float>{(100.0 * electrification%(i)) | i in (1 .. pb.year)},
                   list<float>{(100.0 * transferToClean%(i)) | i in (1 .. pb.year)}))]

// when a dataset is zone specific, we use the ZoneOfChoice variable to select the zone
[addPrefix(s:string) : string
  -> let c := ZoneOfChoice in
        (case c
          (Consumer string!(c.name) /+ " - " /+ s,
           any s))]


// dataset for the output --------------------------------------------------------

// main chart with the 4 KPIs
[dataset-results() 
   ->  plot(2,"results","simulation results",list("GDP(T$)","Energy(PWh)","CO2(Gt)","Temperature x 10"),
          list<float>{yearF(i) | i in (1 .. pb.year)},
          list(list<float>{pb.world.all.results[i] | i in (1 .. pb.year)},
               list<float>{pb.world.all.totalConsos[i] | i in (1 .. pb.year)},
               list<float>{pb.earth.co2Emissions[i] | i in (1 .. pb.year)},
               list<float>{(10.0 * pb.earth.temperatures[i]) | i in (1 .. pb.year)}))]


// world economy chart
[dataset-world-economy()
   ->  plot(2, "world economy","economy - GDP in constant T$",list{string!(c.name) | c in Consumer},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{c.economy.results[i] | i in (1 .. pb.year)} | c in Consumer}) ]   

// localized economy chart, supports the analysis of lost GDP : damageloss, energyLoss, productivityLoss
[dataset-economy()
   ->  cplot(2, addPrefix("economy"),
                addPrefix("economy - GDP analysis"),
                list("GDP","damageloss","energyLoss","productivityLoss"),
                list<float>{yearF(i) | i in (1 .. pb.year)},
           let c := ZoneOfChoice in
             case c
               (Consumer list(list<float>{c.economy.results[i] | i in (1 .. pb.year)},
                              list<float>{ damageLoss(c,i) | i in (1 .. pb.year)},
                              list<float>{ energyLoss(c,i)| i in (1 .. pb.year)},
                              list<float>{ laborLoss(c,i)| i in (1 .. pb.year)}),
                any  list(list<float>{ pb.world.all.results[i] | i in (1 .. pb.year)},
                          list<float>{ pb.earth.gdpLosses[i]| i in (1 .. pb.year)},
                          list<float>{ sum(list{energyLoss(c,i) | c in Consumer}) | i in (1 .. pb.year)},
                          list<float>{ sum(list{laborLoss(c,i) | c in Consumer}) | i in (1 .. pb.year)})))]

// outcomes: gdp, investment, steel, wheat
[dataset-outcomes()
   ->  plot(2, "outcomes","outcomes material & imaterial",list("Invest (100G$)","Steel(Gt)","Wheat(Gt)"),
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list(list<float>{(pb.world.all.investGrowth[i] / 10.0) | i in (1 .. pb.year)},
                list<float>{steelConso(i) | i in (1 .. pb.year)},
                list<float>{pb.world.wheatOutputs[i] | i in (1 .. pb.year)}))]

// add current dollars as a cummulative
[dataset-current()
   ->  cplot(2, "current GDP","economy - GDP in current T$",list{string!(c.name) | c in Consumer},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{gdp$(c,i) | i in (1 .. pb.year)} | c in Consumer}) ]   

// CCEMv9: population chart by zone
[dataset-population()
   -> plot(2, addPrefix("population"),
              addPrefix("population characteristics"),
              list((if (ZoneOfChoice = pb.world) "total(100M)" else "total (10M)"),"active %","average age","birth rate"),
              list<float>{yearF(i) | i in (1 .. pb.year)},
           let c := ZoneOfChoice in
             case c
               (Consumer list(list<float>{ (100.0 * populationEstimate(c,i)) | i in (1 .. pb.year)},
                              list<float>{ (100.0 * activePop%(c,i)) | i in (1 .. pb.year)},
                              list<float>{ averageAge(c,i) | i in (1 .. pb.year)},
                              list<float>{ birthRate(c,i) | i in (1 .. pb.year)}),
                any  list(list<float>{ (10.0 * worldPopulation(i))| i in (1 .. pb.year)},
                          list<float>{ (100.0 * worldActive%(i)) | i in (1 .. pb.year)},
                          list<float>{ worldAverageAge(i) | i in (1 .. pb.year)},
                          list<float>{ worldBirthRate(i) | i in (1 .. pb.year)})))]

// CCEMv9: pain by zone, by categories (energy, GDP, replacement, warming)
// note that since painResult is amortized over 3 years (game.cl), it may be less than AI pain
[dataset-pain()
   ->   cplot(2, addPrefix("pain"),
                addPrefix("pain analysis"),
                list("energy","GDP","replacement","warming"),
                list<float>{yearF(i) | i in (1 .. pb.year)},
            let c := ZoneOfChoice in
             case c
               (Consumer list(list<float>{ c.painEnergy[i] | i in (1 .. pb.year)},
                              list<float>{ max(0.0,c.painResults[i] - painFromAIReplacement(c,i)) | i in (1 .. pb.year)},
                              list<float>{ painFromAIReplacement(c,i) | i in (1 .. pb.year)},
                              list<float>{ c.painWarming[i] | i in (1 .. pb.year)}),
                any  list(list<float>{ averageEnergyPain(i) | i in (1 .. pb.year)},
                          list<float>{ averageResultsPain(i) | i in (1 .. pb.year)},
                          list<float>{ averageReplacementPain(i) | i in (1 .. pb.year)},
                          list<float>{ averageWarmingPain(i) | i in (1 .. pb.year)})))]

[paindebug(c:Consumer) : void
  -> trace(0,"~S pain analysis: GDP = ~S\n AI=~S\n",c,
                list<float>{ (100.0 * (c.painResults[i] - painFromAIReplacement(c,i))) | i in (1 .. pb.year)},
                list<float>{ (100.0 * painFromAIReplacement(c,i)) | i in (1 .. pb.year)})]
                              
         
// earth chart
[dataset-earth()
   ->  plot(2, "earth","Earth and Global Warming",list("CO2(ppm/100)","Temperature","loss(%)","warming pain(%)"),
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list(list<float>{(pb.earth.co2Levels[i] / 100.0) | i in (1 .. pb.year)},
                list<float>{pb.earth.temperatures[i] | i in (1 .. pb.year)},
                list<float>{(100.0 * pb.world.all.disasterRatios[i]) | i in (1 .. pb.year)},
                list<float>{(100.0 * averageWarmingPain(i)) | i in (1 .. pb.year)}))]

// satisfaction
[dataset-satisfaction()
   ->  plot(2, "satisfaction","satisfaction in %",list{string!(c.name) | c in Consumer},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{c.satisfactions[i] | i in (1 .. pb.year)} | c in Consumer})]

// we keep the factors from the Kaya equation since it is a classic
[dataset-kaya()
  ->  plot(2,"Kaya","Kaya equation parameters",list("Pop.(10M)","gCO2/KWh","e-ratio/10","GDP/p(100$)"),
          list<float>{yearF(i) | i in (1 .. pb.year)},
          list(list<float>{(worldPopulation(i) * 100.0) | i in (1 .. pb.year)},
               list<float>{co2KWh(i) | i in (1 .. pb.year)},
               list<float>{(10.0 * energyIntensity(i)) | i in (1 .. pb.year)},
               list<float>{(10.0 * gdpp(i)) | i in (1 .. pb.year)}))]

// updatePlots
[updatePlots() : void
  -> dataset-energy(),
     dataset-consos(),
     dataset-inventories(),
     dataset-transitions(),
     dataset-prices(),
     dataset-electricity(),
     dataset-policies(),
     dataset-results(),
     dataset-world-economy(),
     dataset-economy(),
     dataset-current(),
     dataset-outcomes(),
     dataset-population(),
     dataset-pain(),
     dataset-earth(),
     dataset-satisfaction(),
     dataset-kaya()]

// used twice: the energy loss and the damage loss (once energy loss is applied)
[energyLoss(c:Consumer,y:Year) : float
  -> let b := c.economy in (b.maxout[y] * b.lossRatios[y])]
[damageLoss(c:Consumer,y:Year) : float
  -> let b := c.economy in (b.maxout[y] * (1.0 - b.lossRatios[y]) * b.disasterRatios[y])]
[laborLoss(c:Consumer,y:Year) : float
  -> let b := c.economy in 
       (if (y = 1) 1.0 else b.maxout[y - 1] * (1.0 - decay(b,y)) * (1.0 - productionDecline(b,y)))]

// average active pop ratio (for the world) 
[worldActive%(y:Year) : float
  -> sum(list{(activePop%(c,y) * populationEstimate(c,y)) | c in Consumer}) / worldPopulation(y) ]
[worldAverageAge(y:Year) : float
  -> sum(list{(averageAge(c,y) * populationEstimate(c,y)) | c in Consumer}) / worldPopulation(y) ]

// birth rate for a Zone, per thousand people 
[birthRate(c:Consumer,y:Year) : float
  -> let pop := get(c.populationEstimate,yearF(y)),
         popPrev := get(c.populationEstimate,yearF(y - 1)),
         deathRate := get(c.deathRates,yearF(y)) / 1000.0,     // data: per 1000 people
         births := (pop - popPrev) + popPrev * deathRate in
        (1000.0 * births / pop)]

[worldBirthRate(y:Year) : float
  -> sum(list{(birthRate(c,y) * populationEstimate(c,y)) | c in Consumer}) / worldPopulation(y) ]

// worldwide average pain by population
[averageEnergyPain(y:Year) : float
   -> sum(list{(c.painEnergy[y] * populationEstimate(c,y)) | c in Consumer}) / worldPopulation(y) ]
[averageResultsPain(y:Year) : float
   -> sum(list{((c.painResults[y] - painFromAIReplacement(c,y)) * populationEstimate(c,y)) | c in Consumer}) / worldPopulation(y) ]
[averageReplacementPain(y:Year) : float
   -> sum(list{(painFromAIReplacement(c,y) * populationEstimate(c,y)) | c in Consumer}) / worldPopulation(y) ]
[averageWarmingPain(y:Year) : float
   -> sum(list{(c.painWarming[y] * populationEstimate(c,y)) | c in Consumer}) / worldPopulation(y) ]

// ********************************************************************                    
// *    Part 2: Slider values                                         *
// ********************************************************************          

// default values for tactics - this vector is dependent on NTACTICS
[defaultKnuValues() : list<integer>
  -> list<integer>(50,50,50,50,0,50,50,0)]

// default values for tactics - this vector is dependent on NTACTICS
[defaultTacticValues() : list<integer>
  -> list<integer>(0,0,0,50,0,0,0,50)]

// Note: in CCEM v7, KNUs are complex objects (higher-order, hence not diet CLAIRE, hence no JavaScript generation)
// Thus we go for a simpler strategy : for each KNU, 
//     0.5 is the default value, 0.0 is the minimum (reduce by a factor), 1.0 is the maximum (grow by a factor)

// we need two sets of methods x two flavors (KNU, Tactic)
// - get_X_slider(i:integer) returns the value of the slider for the KNU or Tactic i (to be passe to GUI)
// - set_X_slider(i,v) sets the values of the sliders from GUI

// this object is used to store the slider values and the default values when we start
SliderStorage <: thing(
    naturalGas:FiniteSupplier, // natural gas supplier
    knus:list<integer> = list<integer>(0),                       // KNU sliders => 50% is the median choixe
    tactics:list<integer> = list<integer>(0),                     // Tactic sliders => needs to read from zone of choice
    zones:list<list<integer>> = list<list<integer>>{list<integer>(0) | c in Consumer}, // Tactic sliders for each zone
    defaultOilReserve:Affine,
    defaultGasReserve:Affine,
    defaultCleanGrowth:Affine,
    defaultSubstitution:list<list<Affine>>,    // for each Customer, 3 subMaxtrix line to clean
    defaultDamages:list<Affine>, 
    defaultPainClimate:StepFunction,
    defaultAdaptation:list<Affine>,
    defaultDematerialization:list<Affine>,
    defaultPopulationImpact:float,
    aiFactors:list<Percent> = list<Percent>(10%) )

SliderStore :: SliderStorage()

// KNU slider map:
// 1:Oil&Gas,2:Renewables,3:Electrification,4:Damages,5:Adaptation,6:Productivity,7:Dematerialization,8:PopulationImpact

// initialization of the slider store
// no storage necessary for the direct values: RoI, Population, Productivity
// this could change in v9, if we want a time sensitive approach (with an affine)
[initStorage(x:SliderStorage) : void
  -> //[0] ========= INITIALIZATION OF THE SLIDER STORE (v9) =========,
     x.zones := list<list<integer>>{defaultTacticValues() | c in Consumer},
     x.defaultOilReserve := pb.oil.inventory,
     x.defaultGasReserve := x.naturalGas.inventory,
     x.defaultCleanGrowth := pb.clean.growthPotential,
     x.defaultDematerialization := list<Affine>{y.economy.dematerialize | y in Consumer},
     x.defaultSubstitution := list<list<Affine>>{
       list<Affine>(y.subMatrix[3],y.subMatrix[5],y.subMatrix[6]) | y in Consumer},
     x.defaultDamages := list<Affine>{y.disasterLoss | y in Consumer},
     x.defaultPainClimate := pb.earth.painClimate,
     x.defaultAdaptation := list<Affine>{y.adapt.efficiency | y in Consumer},
     x.aiFactors := list<float>{y.tactic.aiReplaceFactor | y in Consumer},
     x.defaultPopulationImpact := 0%]


// how to translate two tactical slots (Start and FromPain) into a single slider
[readSliderPair(v1:float,v2:float) : Percent
   -> (if (v1 = 0.0) v2 / 2.0        // when the slider value is less than 50, pFrom is the reference
       else 50% + (v1 - 50%))]

// Dual methods: between 0% and 50% we play with from Pain, then we increase Start and decrease FromPain  
// because this is a diet fragment, the code is not as cute (generic)  
[writeSliderPair1(v:Percent) : Percent
    -> (if (v < 50%) 0.0 else ((v - 50%) * 2.0))]
[writeSliderPair2(v:Percent) : Percent
    -> (if (v < 50%) v * 2.0 else ((100% - v) * 2.0))]

// sets the sliders to the existing position
[setSliderValues() : void
    -> //[0] ==== call sliders with ~S and ~S and ~S ==== // ZoneOfChoice,SliderStore.knus,SliderStore.tactics,
       sliders(string!(ZoneOfChoice.name),
               SliderStore.knus,
               SliderStore.tactics)]

// useful for debug : read the current global KNU values (not the sliders) from the store
[readKnuValues() : list
    -> let c := Consumer.instances[2] in
          list(pb.oil.inventory,
               FiniteSupplier.instances[3].inventory,
               c.subMatrix[3],
               c.disasterLoss,
               c.productivityFactor,
               c.adapt.efficiency,
               c.economy.dematerialize,
               c.populationFactor)]
  
// init slider values (Zone of Choice = World) 
[initStoreSliderValues() : void
    -> SliderStore.knus := defaultKnuValues(),
       SliderStore.tactics := defaultTacticValues()]

// gets the tactical slider values from the current zone 
[readSliderTacticValues() : void
    -> if (ZoneOfChoice = World) 
            SliderStore.tactics := defaultTacticValues() // default values for the world
       else let x := ZoneOfChoice.tactic in
         storeTacticValues(false,list<integer>(
               integer%(x.taxFromPain),
               integer%(readSliderPair(x.adaptStart,x.adaptFromPain)),
               integer%(ZoneOfChoice.tactic.aiReplaceFactor),
               integer%(readSliderPair(x.transitionStart,x.transitionFromPain)),
               integer%(readSliderPair(x.savingStart,x.savingFromPain)),
               integer%(x.cancelFromPain),
               integer%(readSliderPair(x.protectionismStart,x.protectionismFromPain)),
               integer%(x.roiAdjustment)))]

// CCEM v9: when we store a new set of values for tactic sliders, we record in zones
[storeTacticValues(allZones:boolean,l:list<integer>) : void
    -> SliderStore.tactics := l,
       if (allZones) (for c in Consumer SliderStore.zones[c.index] := l)
       else SliderStore.zones[(ZoneOfChoice as Consumer).index] := l ]
      
// creates a scalar factor from the slider input : // 0% -> 0.3, 50% -> 1, 100% -> 3.0 
// 50% = neutral, 0% = reduce by a factor of 3.33, 100% = increase by a factor of 3 
// todo: make 30% and 300% explicit parameters  
[scalarFactor(x:integer) : Percent
     -> if (x < 50) 0.3 + (0.7 * (float!(x) / 50.0))
        else 1.0 + (2.0 * ((float!(x) - 50.0) / 50.0))]

// simple translation into a percentage - and reverse translation into a percentage (for the GUI)
[percent(x:integer) : Percent
    -> float!(x) / 100.0]
[integer%(x:Percent) : integer
    -> integer!(100.0 * x) ]


// sets slider values from the GUI : ls1 has NKNUS values, ls2 has NTACTICS values
[writeSliderValues(ls1:list<integer>, ls2:list<integer>) : void
    -> SliderStore.knus := ls1,
       storeTacticValues(ZoneOfChoice = World,ls2),
       writeKnuValues(ls1), // write the KNU slider values
       if (ZoneOfChoice = World)
          for c in Consumer writeTacticValues(c.tactic,ls2,true) // write the Tactic slider values for all zones in the world
       else writeTacticValues(ZoneOfChoice.tactic,ls2,false)]    // write the Tactic slider values

// write the Tactic slider values
[writeTacticValues(x:Tactics, ls2:list<integer>,allZones:boolean) : void
  -> //[0] we need to set the tactics for the zone ~S from ~S // x.tacticFrom.name,ls2,
     assert(length(ls2) = NTACTICS),
     x.taxFromPain := percent(ls2[1]),
     x.adaptStart := writeSliderPair1(percent(ls2[2])),
     x.adaptFromPain := writeSliderPair2(percent(ls2[2])),
     if not(allZones) x.aiReplaceFactor := percent(ls2[3]),
     x.transitionStart := writeSliderPair1(percent(ls2[4])),
     x.transitionFromPain := writeSliderPair2(percent(ls2[4])),
     x.savingStart := writeSliderPair1(percent(ls2[5])),
     x.savingFromPain := writeSliderPair2(percent(ls2[5])),
     x.cancelFromPain := percent(ls2[6]),
     x.protectionismStart := writeSliderPair1(percent(ls2[7])),
     x.protectionismFromPain := writeSliderPair2(percent(ls2[7])),
     x.roiAdjustment := -20% + 40% * percent(ls2[8])]       // varies between -20% and +20% (direct input from the slider)
     

 // write the KNU slider values
 // ls1(list of KNUs): Oil&Gas,Renewable,Electrification,Damages,Adaptation,Productivity,EnergyDensity,PopulationImpact
 [writeKnuValues(ls1:list<integer>) : void
    -> let l1 := list<float>{scalarFactor(i) | i in ls1} in
        (//[0] creates beliefs from the orginal KNUs (in SliderStore) modulated by ~A // l1,
         assert(length(ls1) = NKNUS),
         pb.oil.inventory := scalarProduct(SliderStore.defaultOilReserve, l1[1]),
         SliderStore.naturalGas.inventory := scalarProduct(SliderStore.defaultGasReserve, l1[1]),
         pb.clean.growthPotential := scalarProduct(SliderStore.defaultCleanGrowth, l1[2]),
         pb.earth.painClimate := boundedProduct(SliderStore.defaultPainClimate, l1[4],0%,80%),
         // update substitution matrix according to green energy (transitions 3,5 and 6)
         for c in Consumer
            (c.subMatrix[3] := boundedProduct(SliderStore.defaultSubstitution[c.index][1], l1[3],0%,90%),
             c.subMatrix[5] := boundedProduct(SliderStore.defaultSubstitution[c.index][2], l1[3],0%,90%),
             c.subMatrix[6] := boundedProduct(SliderStore.defaultSubstitution[c.index][3], l1[3],0%,90%)),
         for c in Consumer
            (c.disasterLoss := boundedProduct(SliderStore.defaultDamages[c.index], l1[4],0%,95%),
             c.productivityFactor := percent(ls1[5]),            // not calibrated yet => direct input
             c.adapt.efficiency := boundedProduct(SliderStore.defaultAdaptation[c.index], l1[6],20%,70%),
             c.economy.dematerialize := scalarProduct(SliderStore.defaultDematerialization[c.index], dematFactor(ls1[7])),
             c.populationFactor := percent(ls1[8]))) ]     // direct input (could be a time-sensitive correction)

// demat is sensitive: the scalar factor should not be higher than 1.7             
[dematFactor(x:integer) : float
   -> if (x < 50) scalarFactor(x)
      else 1.0 + (0.7 * ((float!(x) - 50.0) / 50.0))]

// reset sliders to the default values
// note the direct values for RoI:8,Population:9,Productivity:6total
[resetSliders() : void
   -> storeResetSliders(),
      //[0] reset the sliders for ~S to ~S // ZoneOfChoice, SliderStore.knus /+ SliderStore.tactics,
      sliders(string!(ZoneOfChoice.name), SliderStore.knus, SliderStore.tactics) ]

// this is the local part of the resetSliders() method, which can be tested independently      
[storeResetSliders() : void
    -> let ls1 := defaultKnuValues(), 
           ls2 := defaultTacticValues() in
         (//[0] =================== SLIDER RESET =================,
          SliderStore.knus := ls1,
          storeTacticValues(true, ls2),
          writeKnuValues(ls1),    
          for c in Consumer 
             (ls2[3] := integer%(SliderStore.aiFactors[c.index]),
              writeTacticValues(c.tactic,ls2,false)))]
        
// read policies for ZoneOfChoice (world or Consumer)
[zocCarbonTax(i:Year) : Price
   -> if (ZoneOfChoice = World) sum(list<float>{c.economy.carbonTaxAmounts[i] | c in Consumer})
      else (ZoneOfChoice as Consumer).economy.carbonTaxAmounts[i]]

[zocEnergyInvest(i:Year) : Price
   -> if (ZoneOfChoice = World) sum(list<float>{stableEnergyInvest(c,i) | c in Consumer})
      else stableEnergyInvest(ZoneOfChoice as Consumer,i)]
// we take the average over 3 years to smooth the curve and avoid spikes (c.energyInvest is a spot variable)
[stableEnergyInvest(c:Consumer,i:Year) : Price
  -> let n1 := max(1,i - 2), n2 := i in
        sum(list<float>{c.economy.investEnergy[j] | j in (n1 .. n2)}) / 3.0 ]


[zocAdaptation(i:Year) : Price
   -> if (ZoneOfChoice = World) sum(list<float>{c.adapt.spends[i] | c in Consumer})
      else (ZoneOfChoice as Consumer).adapt.spends[i]]

[zocSobriety(i:Year) : Price
   -> if (ZoneOfChoice = World) sum(list<float>{c.economy.sobriety[i] | c in Consumer})
      else (ZoneOfChoice as Consumer).economy.sobriety[i]]

// ********************************************************************          
// *    Part 3:  Callback and MVPs                                    *
// ********************************************************************  

// idempotent init for GUI data
[initGUI() : void
  -> if (ZoneOfChoice = unknown) 
       (ZoneOfChoice := World,
        SliderStore.naturalGas := FiniteSupplier.instances[3], // default natural gas supplier
        initStorage(SliderStore))]
     
// loads all the data
NWEB:integer := 10
[mvp1(n:integer)
  -> go(n),
     NWEB := n,
     initGUI(),
     updatePlots(),
     //[0] ======  initialized the GUI plots via CLSERVE [v: ~A]========= // verbose(),
     initStoreSliderValues(),
     //[0] ======  initialized the GUI sliders via CLSERVE =========,
     setSliderValues(),
     trace(0,"===== CCEM is ready, website is active =====\n")]

[mvp1()
  -> mvp1(NYEARS)] // default value for NWEB

// single recompute loop
[recompute()
  -> reinit(),
     verbose() := 0,
     go(NWEB),
     verbose() := 1,
     updatePlots()]

// callback from CLSERVE  (not diet, but not used by G2WS.js)
// always returns a list of 12 slider values
// if s is a list, it is assumed to be the new slider values
// if s is a tuple[Consumer, list], s[1] is assumed to be the zone of choice
// if s is a string, it is assumed to be "reset"
[callback(s:string) : any
    ->  printf("==== callback from CLSERVE with context |~S| =====\n",s),
        let l := eval(read(s)),lr := nil in
          (if (l = "config") getSliderValues()     // simple case : returns the string 
           else (case l 
             (tuple let zname := l[1], lslider := l[2] in 
                       (//[0] recognized a zone change ~S (from ~S) with sliders ~S // zname, ZoneOfChoice, lslider,
                        if (ZoneOfChoice != World) 
                          writeTacticValues(ZoneOfChoice.tactic, 
                                            list<integer>{lslider[i] | i in ((NKNUS + 1) .. (NKNUS + NTACTICS))},
                                            false),
                        ZoneOfChoice := zname,
                        readSliderTacticValues(),
                        updatePlots()),         // some plots are zone dependent since CCEM v9
              list   (writeSliderValues(list<integer>{l[i] | i in (1 .. NKNUS)}, 
                                        list<integer>{l[i] | i in ((NKNUS + 1) .. (NKNUS + NTACTICS))}),
                       //[0] runs a new simulation with new slider values //,
                       recompute()), // update the plots with the new values
              string (//[0] >>>>>>>>>> recognized a string command ~S // l,
                      if (l = "reset") resetSliders()
                      else putSliderValues(l),
                      //[0] >>>>>>>>>> call recompute //,
                      recompute()), 
               any printf("=== Callback DESIGN ERROR with ~S:~S\n",l,owner(l))),
               //[0] happy callback(~A) -> ~A // s, SliderStore.knus /+ SliderStore.tactics,
               list(string!(ZoneOfChoice.name), 
                     SliderStore.knus /+ SliderStore.tactics,
                     listExplanations())))]

// returns the current slider values as a string
// hopefully, this is a diet fragment (no higher-order, no list comprehension)
// write in in CLAIRE to avoid both Go and Javascript implementation for g2ws
[getSliderValues() : string
  -> let l1 := SliderStore.knus, l2 := SliderStore.zones, result := "list(list(" in
         (for i in (1 .. NKNUS) 
             (result :/+ string!(l1[i]),
              if (i < NKNUS) result :/+ ","),
          result :/+ "),list(",
          for c in Consumer
             (result :/+ "list(" /+ string!(c.name) /+ ",list(",
              for i in (1 .. NTACTICS) 
                  (result :/+ string!(l2[c.index][i]),
                   if (i < NTACTICS) result :/+ ","),
              result :/+ "))",
              if (c.index < size(Consumer)) result :/+ ","),
          result /+ "))")]
     
// reverse function: we get the slider values as a string, and we need to parse it and 
// set the sliders accordingly - for all zones 
// we reset ZoneOfChoice to World  
// note that we cannot use eval(read(l)) because we want a diet fragment, 
// and we need to parse it in CLAIRE (no higher-order, no list comprehension)
[putSliderValues(l:string) : integer
  -> //[0] >>> putSliderValues called (~S) // l,
     let i := 1, s := l in    // where we start reading
      (s := skip(s,"list(",2),  // skip two "list("")
       for i in (1 .. NKNUS) 
          (SliderStore.knus[i] := readSliderInteger(s),
           //[5] read KNU slider ~S with value ~S // i,SliderStore.knus[i],
           s := getSkip(s,',')),
      s := skip(s,"list(",2),
      for i in (1 .. size(Consumer)) 
         (let c := Consumer.instances[i] in
            (s := getSkip(s,','),    // consumes the zone name
             s := skip(s,"list(",1),   // get to the start of the integer list
             for j in (1 .. NTACTICS) 
                (SliderStore.zones[c.index][j] := readSliderInteger(s),
                //[0] read Tactic slider ~S for zone ~S with value ~S // j,c.name,SliderStore.zones[c.index][j],  
                 s := skipSliderInteger(s)),
             writeTacticValues(c.tactic,SliderStore.zones[c.index],false)),
             if (i != size(Consumer)) s := skip(s,"),list(",1)),  // get to the next zone"),
      1)]                   // 1 is a success code for the JS version


// skip a pattern, throw an exception if the pattern is not found
[skip(s:string, pattern:string, n:integer) : string
  -> for i in (1  .. n) s := skip(s,pattern),
     s]

[skip(s:string, pattern:string) : string
  -> if (substring(s,1,length(pattern)) != pattern) 
        error("skip DESIGN ERROR with ~S and ~S\n",s,pattern)
     else substring(s, length(pattern) + 1, length(s))]

// look for a character in a string, return the substring after it
[getSkip(s:string, pattern:char) : string 
  -> let p := get(s,pattern) in
        (if (p = 0) error("getSkip DESIGN ERROR with ~S and ~S\n",s,pattern)
         else substring(s,p + 1,length(s)))]

// read an integer from a string, up to the next comma or ")"         
[readSliderInteger(s:string) : integer
  -> let p1 := get(s,','), p2 := get(s,')') in
        (if (p1 = 0 & p2 = 0) error("readSliderInteger DESIGN ERROR with ~S\n",s)
         else if (p1 = 0) integer!(substring(s,1,p2 - 1))
         else if (p2 = 0) integer!(substring(s,1,p1 - 1))
         else integer!(substring(s,1,min(p1,p2) - 1))) ]

// same but just skip
[skipSliderInteger(s:string) : string
  -> let p1 := get(s,','), p2 := get(s,')') in
        (if (p1 = 0 & p2 = 0) error("skipSliderInteger DESIGN ERROR with ~S\n",s)
         else substring(s,min(p1,p2) + 1,length(s))) ]

/* kind of stupid because char is not in Diet CLAIRE (Javascript) yet
// this is a naive version of get@(string, char) 
[getChar(s:string, pattern:string) : integer
  -> let i := 1, n := length(s), v := 0 in
       (for i in (1 .. n) (if (substring(s,i,i) = pattern) break(v := i)),
        v)] */
          
 /* non diet version            
 [putSliderValuesOld(l:string) : void
  -> //[0] >>> putSliderValues called (~S) // l,
      let ls := eval(read(l)) in
          (//[0] --- the command ls is a ~S // owner(ls),
           case ls 
            (list let l1 := ls[1], lcdr := ls[2] in
                (assert(length(l1) = NKNUS),
                 SliderStore.knus := list<integer>{l1[i] | i in (1 .. NKNUS)},
                 writeKnuValues(list<integer>{l1[i] | i in (1 .. NKNUS)}),
                 ZoneOfChoice := World,
                 for ll3 in lcdr
                    let c := ll3[1], l2 := ll3[2] in
                      (//[0] >>> writeSliderValues for zone ~S with values ~S // c,l2,
                       assert(length(l2) = NTACTICS),
                       SliderStore.zones[c.index] := list<integer>{l2[i] | i in (1 .. NTACTICS)},
                       writeTacticValues(c.tactic, list<integer>{l2[i] | i in (1 .. NTACTICS)}, false)),
                 SliderStore.tactics := defaultTacticValues()),
             any error("writeSliderValues DESIGN ERROR with ~S -> ~S\n",l,owner(ls))))]
*/
                
// ********************************************************************          
// *    Part 4:  Explanations for sliders                             *
// ********************************************************************  

// produce a list of KPIs that are used to explain the sliders
// Oil&Gas,Renewable,Electrification,Damages,Adaptation,Productivity,Density,RoI,Population
[listExplanations() : list<string>
  -> list<string>(
       toString(startReserves(pb.oil) + startReserves(SliderStore.naturalGas)),
       toString(pb.clean.outputs[41]) /+ "/" /+ toString(maxCleanGrowth(41)),
       toString(100.0 * fossilToCleanMax()),
       toString(100.0 * avgDisasterLoss(91)),
       toString(100.0 * avgLaborLoss(91)),
       toString(100.0 * avgAdaptationProtect(91)),
       toString(avgDematerialize(91)),
       toString(100.0 * avgPopulationDecline(91))) /+   // population decline caused by warming and pains
      (if (ZoneOfChoice = World) 
          list<string>(toString(worldAverageTax()),
                       toString(totalAdaptation()),
                       "inactive(World)",
                       toString(totalEInvest()),
                       toString(100.0 * totalSharedSavings()),
                       toString(100.0 * avgSobriety%()),
                       toString(totalCBAM()),
                       toString(worldPopulation(91)))
       else list<string>(
             toString(averageTax(ZoneOfChoice)),
             toString(sumAdaptation(ZoneOfChoice)),
             toString(aiGain(ZoneOfChoice,91)),
             toString(sumEInvest(ZoneOfChoice)),
             toString(100.0 * sharedSavings(ZoneOfChoice)),
             toString(100.0 * sobriety%(ZoneOfChoice)),
             toString(sumCBAM(ZoneOfChoice)),
             toString(populationEstimate(ZoneOfChoice,91))))]

// reserve at simulation start time
[startReserves(s:FiniteSupplier) : float
  -> get(s.inventory,get(s.equilibriumPrice,yearF(1)))]

// maximum percentage of fossil energy that could be transitioned to clean, weightes by consumption
[fossilToCleanMax() : Percent 
  -> let sump := 0.0, sumc := 0.0 in
     (for c in Consumer
        (sump :+ fossilToCleanMax(c) * sum(c.consumes),
         sumc :+ sum(c.consumes)),
      sump / sumc)]  // weighted by consumption

// for one Consumer, look at the 3 fossil sources : Oil, Gas,Coal and associated transitions (3,5,6)
// weighted by the actual consumption at year 1
[fossilToCleanMax(c:Consumer) : Percent
  -> let sump := 0.0, sumc := 0.0 in
     (for s in FiniteSupplier
        let cs := c.consumes[s.index], tr := getTransition(s,pb.clean) in
          (sump :+ (cs * get(c.subMatrix[tr.index],yearF(NYEARS))) ,
           sumc :+ cs),
      sump / sumc)]  // weighted by consumption

// produce a nice string (needs to be diet)
[toString(x:any) : string
  -> case x (integer string!(x),
             float string!(x,1),
             any "unknown")]       

// max Clean Growth from 2010 to 2050q
[maxCleanGrowth(y:Year) : float
  -> sum(list<float>{get(pb.clean.growthPotential,yearF(i)) | i in (1 .. 40)})]
// useful to debug
[cleanGrowthRate(y:Year) : Percent
  -> (pb.clean.outputs[y] - pb.clean.outputs[1]) / maxCleanGrowth(y)]

// average Dematerialization at year y
[avgDematerialize(y:Year) : float
  -> CAGR( pb.world.all.totalConsos[1] / pb.world.all.results[1],
           pb.world.all.totalConsos[y] / pb.world.all.results[y] ,y - 1)]

// average Disaster Loss at year y for +3C
[avgDisasterLoss(y:Year) : float
  -> let s := 0.0, gsum := 0.0 in
       (for c in Consumer
          (s :+ get(c.disasterLoss,3.0) * c.economy.results[y],
           gsum :+ c.economy.results[y]),
        if (gsum = 0.0) 0.0 else s / gsum)] // average disaster loss weighted by GDP

// average Productivity Loss at year y
[avgLaborLoss(y:Year) : float
  -> let s := 0.0, gsum := 0.0 in
       (for c in Consumer
          (s :+ c.painLevels[y] * c.productivityFactor * c.economy.results[y],
           gsum :+ c.economy.results[y]),
        if (gsum = 0.0) 0.0 else s / gsum)] // average productivity loss weighted by GDP

// average Adaptation at year y 
[avgAdaptationProtect(y:Year) : float
  -> let s := 0.0, gsum := 0.0 in
       (for c in Consumer
          (s :+ c.adapt.levels[y] * c.economy.results[y],
           gsum :+ c.economy.results[y]),
        if (gsum = 0.0) 0.0 else s / gsum)] // average adaptation efficiency weighted by GDP

// population decline as a percentage of the population at year y, caused by warming and pains      
[populationDecline(c:Consumer,y:Year) : Percent
  -> let pn := get(c.populationEstimate,yearF(y)),
         birthrate := 1 / 80.0,
         decline := sum(list{(get(c.populationEstimate,yearF(i)) * birthrate * 
                              c.painLevels[i] * c.populationFactor) |
                             i in (max(1,y - 80) .. (y - 1))}) in
         decline / pn]

// worldwide average population decline as a percentage 
[avgPopulationDecline(y:Year) : Percent
  -> sum(list{(populationDecline(c,y) * populationEstimate(c,y)) | c in Consumer}) / worldPopulation(y)]

// sum of the carbon tax for a zone collected from year 1 to pb.year
// unit is $/tCO2
[averageTax(c:Consumer) : float
  -> average(list<float>{(c.economy.carbonTaxAmounts[i] * 1000.0 / c.co2Emissions[i]) | i in (1 .. pb.year)})]

[worldAverageTax() : float
  -> average(list<float>{averageTax(c) | c in Consumer})]

// sum import reduction because of CBAM
[sumCBAM(c:Consumer) : float
  -> sum(list<float>{c.economy.reducedImports[i] | i in (1 .. pb.year)})]

[totalCBAM() : float
  -> sum(list<float>{sumCBAM(c) | c in Consumer})]

// sum of adaptation costs for a zone collected from year 1 to pb.year, yearly average
[sumAdaptation(c:Consumer) : float
  -> sum(c.adapt.sums) / yearF(NYEARS)]

[totalAdaptation() : float
  -> sum(list<float>{sumAdaptation(c) | c in Consumer})]

// sum of energy investments for a zone collected from year 1 to pb.year
[sumEInvest(c:Consumer) : float
  -> sum(list<float>{c.economy.investEnergy[i] | i in (1 .. pb.year)})]

[totalEInvest() : Price
  -> sum(list<float>{sumEInvest(c) | c in Consumer})]

// sum of savings for a zone collected from year 1 to pb.year
[sharedSavings(c:Consumer) : Percent
  -> let sv := sum(list<float>{sum(c.savings[i]) | i in (1 .. pb.year)}),
         total := sum(list<float>{c.economy.totalConsos[i] | i in (1 .. pb.year)}) in
         sv / total]

// same computation for the world, weighted by consumption
[totalSharedSavings() : float
  -> let sv := sum(list<float>{sum(list<float>{sum(c.savings[i]) | i in (1 .. pb.year)}) | c in Consumer}),
         total := sum(list<float>{pb.world.all.totalConsos[i] | i in (1 .. pb.year)}) in
         sv / total]

// sum of voluntary cancellations (sobriety) for a zone collected from year 1 to pb.year
[sobriety%(c:Consumer) : Percent
  -> let sc := sum(list<float>{c.economy.sobriety[i] | i in (1 .. pb.year)}),
         total := sum(list<float>{c.economy.totalConsos[i] | i in (1 .. pb.year)}) in
         sc / total]

[avgSobriety%() : Percent
  -> let sc := sum(list<float>{sum(list<float>{c.economy.sobriety[i] | i in (1 .. pb.year)}) | c in Consumer}),
         total := sum(list<float>{pb.world.all.totalConsos[i] | i in (1 .. pb.year)}) in
         sc / total]

// gain in GDP because of AI replacement for a zone
[aiGain(c:Consumer,y:Year) : float
  -> c.economy.results[y] * (1 - laborProductionFactor(c.economy, y)) * c.tactic.aiReplaceFactor]

// test reset
[testr(n:integer)
  -> initGUI(),
     storeResetSliders(),   // only works with the CLSERVE callback, not with diet CLAIRE
     reinit(),
     go(n)]

// full independent test of web.cl : 
[webtest()
  -> go(90),
     let v1 := pb.world.all.results[91] in
       (//[0] ======  test reset =========,
        testr(90),
        let v2 := pb.world.all.results[91] in
            (//[0] test reset: ~S = ~S // v1,v2,
             assert(v2 = v1)),
        assert(length(SliderStore.knus) = NKNUS),
        assert(length(SliderStore.tactics) = NTACTICS),
        readSliderTacticValues(),
        let l1 := getSliderValues() in printf("the config is ~S\n",l1),
        let l2 := listExplanations() in printf("the explanations are ~S\n",l2),
        ZoneOfChoice := some(c in Consumer | true),
        printf("the explanations for ~S are ~A\n",ZoneOfChoice,list(ZoneOfChoice),listExplanations()),
        printf("========== test completed successfully =========\n"))]

// test that works with CLSERVE
[servertest()
   -> updatePlots(),
      putSliderValues(getSliderValues()),
      printf("========== server test completed successfully =========\n")]
