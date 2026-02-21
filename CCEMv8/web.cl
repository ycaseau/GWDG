// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2026 Yves Caseau                        *
// *       file: web.cl                                               *
// ********************************************************************

// this file contains our experimentations with the web server
// it produces the curves that will be displayed in the plotters
// it links with the sliders two way: provide value/explanation and react
// current version (Feb 2026) is CCEM v8 with 15 sliders

NYEARS :: 90

// ********************************************************************
// *    Part 1: Datasets for plotters                                 *
// *    Part 2: Slider values                                         *
// *    Part 3: Callback and MVPs                                     *
// ********************************************************************

 // leverages the structure table plots[x:(class U thing)] : set<tuple>
 //  table[x] = {t1, t2, t3} where x is a named thing, and ti are time series (list of floats)
 // used with the following CLAIRE interface
 // plot(tag:any,title:string,labels:list,listX:list,listY:list)
  
// datasets for the input ------------------------------------------------------

[dataset-energy()
    -> cplot(1,"energy","energy in PWh (yearly)",list{string!(s.name) | s in Supplier},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{s.outputs[i] | i in (1 .. pb.year)} | s in Supplier})]

// fossil fuel inventories
[dataset-inventories()
    ->  plot(1,"inventories","fossil fuel inventories in Gt",
             list{string!(s.name) | s in FiniteSupplier},
             list<float>{yearF(i) | i in (1 .. pb.year)},
             list{ list<float>{s.inventories[i] | i in (1 .. pb.year)} | s in FiniteSupplier})]


[dataset-transitions()
     -> plot(1,"transition","energy flow changes in PWh",
                list("cancel","savings","total","CO2/Kwh"),
                list<float>{yearF(i) | i in (1 .. pb.year)},
           list(list<float>{pb.world.all.cancels[i] | i in (1 .. pb.year)},
                list<float>{allSaving(i) | i in (1 .. pb.year)},
                list<float>{pb.world.all.totalConsos[i] | i in (1 .. pb.year)},
                list<float>{co2KWh(i) | i in (1 .. pb.year)}))]

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

// energy by zones (cummulative)
[dataset-consos()
   ->  cplot(1, "zones PWh","energy consumption by zonees",list{string!(c.name) | c in Consumer},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{allConso(c,i) | i in (1 .. pb.year)} | c in Consumer}) ]   

// dataset about electricity and electrification
[dataset-electricity()
    ->  plot(1,"electricity","electricity estimate in TWh and electrification ratio %",
             list("electricity","clean TWh","electrification","fossil transfer"),
             list<float>{yearF(i) | i in (1 .. pb.year)},
             list( list<float>{sum(list{c.ePWhs[i] | c in Consumer}) | i in (1 .. pb.year)},
                   list<float>{sum(list{c.consos[i][Clean.index] | c in Consumer})| i in (1 .. pb.year)},
                   list<float>{(100.0 * electrification%(i)) | i in (1 .. pb.year)},
                   list<float>{(100.0 * transferToClean%(i)) | i in (1 .. pb.year)}))]


// dataset for the output --------------------------------------------------------

// main chart with the 4 KPIs
[dataset-results() 
   ->  plot(2,"results","simulation results",list("GDP(T$)","Energy(PWh)","CO2(Gt)","Temperature x 10"),
          list<float>{yearF(i) | i in (1 .. pb.year)},
          list(list<float>{pb.world.all.results[i] | i in (1 .. pb.year)},
               list<float>{pb.world.all.totalConsos[i] | i in (1 .. pb.year)},
               list<float>{pb.earth.co2Emissions[i] | i in (1 .. pb.year)},
               list<float>{(10.0 * pb.earth.temperatures[i]) | i in (1 .. pb.year)}))]

// add kaya
[dataset-kaya()
  ->  plot(2,"Kaya","Kaya equation parameters",list("Population","gCO2/KWh","e-intensity (kWh/$) / 10","GDP/p (100$)"),
          list<float>{yearF(i) | i in (1 .. pb.year)},
          list(list<float>{worldPopulation(i) | i in (1 .. pb.year)},
               list<float>{co2KWh(i) | i in (1 .. pb.year)},
               list<float>{(10.0 * energyIntensity(i)) | i in (1 .. pb.year)},
               list<float>{(10.0 * gdpp(i)) | i in (1 .. pb.year)}))]

// economy chart
[dataset-economy()
   ->  plot(2, "economy","economy - GDP in constant T$",list{string!(c.name) | c in Consumer},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{c.economy.results[i] | i in (1 .. pb.year)} | c in Consumer}) ]   

// add current dollars as a cummulative
[dataset-current()
   ->  cplot(2, "current GDP","economy - GDP in current T$",list{string!(c.name) | c in Consumer},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{gdp$(c,i) | i in (1 .. pb.year)} | c in Consumer}) ]   

// earth chart
[dataset-earth()
   ->  plot(2, "earth","earth - CO2 in Gt",list("CO2(ppm/100)","Temperature","loss(%)","warming pain(%)"),
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list(list<float>{(pb.earth.co2Levels[i] / 100.0) | i in (1 .. pb.year)},
                list<float>{pb.earth.temperatures[i] | i in (1 .. pb.year)},
                list<float>{(100.0 * pb.world.all.disasterRatios[i]) | i in (1 .. pb.year)},
                list<float>{(100.0 * averageWarmingPain(i)) | i in (1 .. pb.year)}))]

// outcomes: gdp, investment, steel, wheat
[dataset-outcomes()
   ->  plot(2, "outcomes","outcomes material & imaterial",list("Invest (100G$)","Steel(Gt)","Wheat(Gt)"),
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list(list<float>{(pb.world.all.investGrowth[i] / 10.0) | i in (1 .. pb.year)},
                list<float>{steelConso(i) | i in (1 .. pb.year)},
                list<float>{pb.world.wheatOutputs[i] | i in (1 .. pb.year)}))]


// satisfaction
[dataset-satisfaction()
   ->  plot(2, "satisfaction","satisfaction in %",list{string!(c.name) | c in Consumer},
           list<float>{yearF(i) | i in (1 .. pb.year)},
           list{ list<float>{c.satisfactions[i] | i in (1 .. pb.year)} | c in Consumer})]


// updatePlots
[updatePlots() : void
  -> dataset-energy(),
     dataset-inventories(),
     dataset-transitions(),
     dataset-consos(),
     dataset-prices(),
     dataset-electricity(),
     dataset-policies(),
     dataset-results(),
     dataset-kaya(),
     dataset-economy(),
     dataset-current(),
     dataset-earth(),
     dataset-outcomes(),
     dataset-satisfaction()]

// ********************************************************************                    
// *    Part 2: Slider values                                         *
// ********************************************************************          

// Note: in CCEM v7, KNUs are complex objects (higher-order, hence not diet CLAIRE, hence no JavaScript generation)
// Thus we go for a simpler strategy : for each KNU, 
//     0.5 is the default value, 0.0 is the minimum (reduce by a factor), 1.0 is the maximum (grow by a factor)

// we need two sets of methods x two flavors (KNU, Tactic)
// - get_X_slider(i:integer) returns the value of the slider for the KNU or Tactic i (to be passe to GUI)
// - set_X_slider(i,v) sets the values of the sliders from GUI

// this object is used to store the slider values and the default values when we start
SliderStorage <: thing(
    naturalGas:FiniteSupplier, // natural gas supplier
    knus:list<integer> = list<integer>(50,50,50,50,0,50,50,28,0), // KNU sliders => 50% is the median choixe
    tactics:list<integer> = list<integer>(0,0,0,0,0,0), // Tactic sliders => needs to read from zone of choice
    defaultOilReserve:Affine,
    defaultGasReserve:Affine,
    defaultCleanGrowth:Affine,
    defaultSubstitution:list<list<Affine>>,    // for each Customer, 3 subMaxtrix line to clean
    defaultDamages:list<Affine>,
    defaultAdaptation:list<Affine>,
    defaultDematerialization:list<Affine>,
    defaultPopulationImpact:float)

SliderStore :: SliderStorage()

// KNU slider map:
// 1:Oil&Gas,2:Renewables,3:Electrification,4:Damages,5:Adaptation,6:Productivity,7:Dematerialization,8:RoI,9:Population

// initialization of the slider store
// no storage necessary for the direct values: RoI, Population, Productivity
// this could change in v9, if we want a time sensitive approach (with an affine)
[initStorage(x:SliderStorage) : void
  -> //[0] ========= INITIALIZATION OF THE SLIDER STORE =========,
     x.defaultOilReserve := pb.oil.inventory,
     x.defaultGasReserve := x.naturalGas.inventory,
     x.defaultCleanGrowth := pb.clean.growthPotential,
     x.defaultDematerialization := list<Affine>{y.economy.dematerialize | y in Consumer},
     x.defaultSubstitution := list<list<Affine>>{
       list<Affine>(y.subMatrix[3],y.subMatrix[5],y.subMatrix[6]) | y in Consumer},
     x.defaultDamages := list<Affine>{y.disasterLoss | y in Consumer},
     x.defaultAdaptation := list<Affine>{y.adapt.efficiency | y in Consumer},
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
     
// ZoneOfChoice is the current zone (for policy making) or World
ZoneOfChoice:thing := unknown

// sets the sliders to the existing position
[setSliderValues() : void
    -> sliders(string!(ZoneOfChoice.name),
               SliderStore.knus,
               SliderStore.tactics)]

// gets the tactical slider values from the current zone 
[readSliderValues() : void
    -> if (ZoneOfChoice = World) 
            SliderStore.tactics := list<integer>(0,0,0,50,0,0) // default values for the world
       else let x := ZoneOfChoice.tactic in
         SliderStore.tactics := list<integer>(
               integer!(100.0 * x.taxFromPain),
               integer!(100.0 * readSliderPair(x.protectionismStart,x.protectionismFromPain)),
               integer!(100.0 * readSliderPair(x.adaptStart,x.adaptFromPain)),
               integer!(100.0 * readSliderPair(x.transitionStart,x.transitionFromPain)),
               integer!(100.0 * readSliderPair(x.savingStart,x.savingFromPain)),
               integer!(100.0 * x.cancelFromPain))]
      

// creates a scalar factor from the slider input : // 0% -> 0.3, 50% -> 1, 100% -> 3.0    
[scalarFactor(x:integer) : Percent
     -> if (x < 50) 0.3 + (0.7 * (float!(x) / 50.0))
        else 1.0 + (2.0 * ((float!(x) - 50.0) / 50.0))]

// simple translation into a percentage
[percent(x:integer) : Percent
    -> float!(x) / 100.0]

// sets slider values from the GUI : ls1 has 9 values, ls2 has 6 values
[writeSliderValues(ls1:list<integer>, ls2:list<integer>) : void
    -> SliderStore.knus := ls1,
       SliderStore.tactics := ls2,
       writeKnuValues(ls1), // write the KNU slider values
       if (ZoneOfChoice = World)
          for c in Consumer writeTacticValues(c.tactic,ls2) // write the Tactic slider values for all zones in the world
       else writeTacticValues(ZoneOfChoice.tactic,ls2)]    // write the Tactic slider values

// write the Tactic slider values
[writeTacticValues(x:Tactics, ls2:list<integer>) : void
  -> //[0] we need to set the tactics for the zone ~S from ~S // x.tacticFrom.name,ls2,
     x.taxFromPain := percent(ls2[1]),
     x.protectionismStart := writeSliderPair1(percent(ls2[2])),
     x.protectionismFromPain := writeSliderPair2(percent(ls2[2])),
     x.adaptStart := writeSliderPair1(percent(ls2[3])),
     x.adaptFromPain := writeSliderPair2(percent(ls2[3])),
     x.transitionStart := writeSliderPair1(percent(ls2[4])),
     x.transitionFromPain := writeSliderPair2(percent(ls2[4])),
     x.savingStart := writeSliderPair1(percent(ls2[5])),
     x.savingFromPain := writeSliderPair2(percent(ls2[5])),
     x.cancelFromPain := percent(ls2[6]) ]

 // write the KNU slider values
 // ls1(list of KNUs): Oil&Gas,Renewable,Electrification,Damages,Adaptation,Productivity,Density,RoI,Population
 [writeKnuValues(ls1:list<integer>) : void
    -> let l1 := list<float>{scalarFactor(i) | i in ls1} in
        (//[0] creates beliefs from the orginal KNUs (in SliderStore) modulated by ~A // l1,
         pb.oil.inventory := scalarProduct(SliderStore.defaultOilReserve, l1[1]),
         SliderStore.naturalGas.inventory := scalarProduct(SliderStore.defaultGasReserve, l1[1]),
         pb.clean.growthPotential := scalarProduct(SliderStore.defaultCleanGrowth, l1[2]),
         pb.world.returnOnInvestment := percent(ls1[8]),   // direct input (could be a time-sensitive correction)
         // update substitution matrix according to green energy (transitions 3,5 and 6)
         for c in Consumer
            (c.subMatrix[3] := boundedProduct(SliderStore.defaultSubstitution[c.index][1], l1[3],0%,90%),
             c.subMatrix[5] := boundedProduct(SliderStore.defaultSubstitution[c.index][2], l1[3],0%,90%),
             c.subMatrix[6] := boundedProduct(SliderStore.defaultSubstitution[c.index][3], l1[3],0%,90%)),
         for c in Consumer
            (c.economy.dematerialize := boundedProduct(SliderStore.defaultDematerialization[c.index], l1[7],0%,95%),
             c.disasterLoss := boundedProduct(SliderStore.defaultDamages[c.index], l1[4],0%,95%),
             c.productivityFactor := percent(ls1[5]),            // not calibrated yet => direct input
             c.populationFactor := percent(ls1[9]),
             c.adapt.efficiency := boundedProduct(SliderStore.defaultAdaptation[c.index], l1[6],30%,80%))) ]


// reset sliders to the default values
// note the direct values for RoI:8,Population:9,Productivity:6
[resetSliders() : void
    -> let ls1 := list<integer>(50,50,50,50,50,0,50,28,0), ls2 := list<integer>(0,0,0,50,0,0) in
         (//[0] =================== SLIDER RESET =================,
          SliderStore.knus := ls1,
          SliderStore.tactics := ls2,
          writeKnuValues(ls1),    
          for c in Consumer writeTacticValues(c.tactic,list<integer>(0,0,0,50,0,0)),
          sliders(string!(ZoneOfChoice.name), SliderStore.knus, SliderStore.tactics)) ]
        
// read policies for ZoneOfChoice (world or Consumer)
[zocCarbonTax(i:Year) : Price
   -> if (ZoneOfChoice = World) sum(list<float>{c.carbonTaxes[i] | c in Consumer})
      else (ZoneOfChoice as Consumer).carbonTaxes[i]]

[zocEnergyInvest(i:Year) : Price
   -> if (ZoneOfChoice = World) sum(list<float>{c.economy.investEnergy[i] | c in Consumer})
      else (ZoneOfChoice as Consumer).economy.investEnergy[i]]

[zocAdaptation(i:Year) : Price
   -> if (ZoneOfChoice = World) sum(list<float>{c.adapt.spends[i] | c in Consumer})
      else (ZoneOfChoice as Consumer).adapt.spends[i]]

[zocSobriety(i:Year) : Price
   -> if (ZoneOfChoice = World) sum(list<float>{c.economy.sobriety[i] | c in Consumer})
      else (ZoneOfChoice as Consumer).economy.sobriety[i]]

// ********************************************************************          
// *    Part 3: Explanations and MVPs                                 *
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
     //[0] ======  initializes the GUI constants via CLSERVE =========,
     readSliderValues(),
     setSliderValues()]

[mvp1()
  -> mvp1(NYEARS)] // default value for NWEB


// callback from CLSERVE
// always returns a list of 12 slider values
// if s is a list, it is assumed to be the new slider values
// if s is a tuple[Consumer, list], s[1] is assumed to be the zone of choice
// if s is a string, it is assumed to be "reset"
[callback(s:string) : any
    ->  printf("==== callback from CLSERVE with context ~S =====\n",s),
        let l := eval(read(s)) in
          (case l 
             (tuple let zname := l[1], lslider := l[2] in 
                       (//[0] recognized a zone change ~S (from ~S) with sliders ~S // zname, ZoneOfChoice, lslider,
                        if (ZoneOfChoice != World) 
                          writeTacticValues(ZoneOfChoice.tactic, list<integer>{lslider[i] | i in (7 .. 12)}),
                        ZoneOfChoice := zname,
                        readSliderValues(),
                        trace(0,"read ~S from ~S\n",SliderStore.tactics,ZoneOfChoice)),                 // read the sliders from the zone of choice
              list   (writeSliderValues(list<integer>{l[i] | i in (1 .. 9)}, 
                                        list<integer>{l[i] | i in (10 .. 15)}),
                       //[0] runs a new simulation with the 6 KNU factors for ~A years // NWEB,
                       reinit(),
                       go(NWEB),
                       updatePlots()), // update the plots with the new values
               string (resetSliders(),
                       reinit(),
                       go(NWEB),
                       updatePlots()), // reset the sliders to the default values
               any printf("=== Callback DESIGN ERROR with ~S:~S\n",l,owner(l))),
          //[0] happy callback(~A) -> ~A // s, SliderStore.knus /+ SliderStore.tactics,
          list(string!(ZoneOfChoice.name), 
               SliderStore.knus /+ SliderStore.tactics,
               listExplanations()))]



// produce a list of KPIs that are used to explain the sliders
// Oil&Gas,Renewable,Electrification,Damages,Adaptation,Productivity,Density,RoI,Population
[listExplanations() : list<string>
  -> list<string>(
       toString(startReserves(pb.oil) + startReserves(SliderStore.naturalGas)),
       toString(pb.clean.outputs[41]) /+ "/" /+ toString(maxCleanGrowth(41)),
       toString(100.0 * fossilToCleanMax()),
       toString(100.0 * avgDisasterLoss(91)),
       toString(100.0 * avgProductivityLoss(91)),
       toString(100.0 * avgAdaptation(91)),
       toString(avgDematerialize(91)),
       toString(pb.world.returnOnInvestment),
       toString(some(x in Consumer | true).populationFactor)) /+
      (if (ZoneOfChoice = World) 
          list<string>(toString(worldAverageTax()),toString(totalCBAM()),toString(totalAdaptation()),
                       toString(totalEInvest()),toString(totalSavings()),toString(totalCancels()))
       else list<string>(
       toString(averageTax(ZoneOfChoice)),
       toString(sumCBAM(ZoneOfChoice)),
       toString(sumAdaptation(ZoneOfChoice)),
       toString(sumEInvest(ZoneOfChoice)),
       toString(sumSavings(ZoneOfChoice)),
       toString(sumCancels(ZoneOfChoice))))]

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

// max Clean Growth from 2010 to 2050
[maxCleanGrowth(y:Year) : float
  -> sum(list<float>{get(pb.clean.growthPotential,yearF(i)) | i in (1 .. 40)})]

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
[avgProductivityLoss(y:Year) : float
  -> let s := 0.0, gsum := 0.0 in
       (for c in Consumer
          (s :+ c.painLevels[y] * c.productivityFactor * c.economy.results[y],
           gsum :+ c.economy.results[y]),
        if (gsum = 0.0) 0.0 else s / gsum)] // average productivity loss weighted by GDP

// average Adaptation at year y 
[avgAdaptation(y:Year) : float
  -> let s := 0.0, gsum := 0.0 in
       (for c in Consumer
          (s :+ c.adapt.levels[y] * c.economy.results[y],
           gsum :+ c.economy.results[y]),
        if (gsum = 0.0) 0.0 else s / gsum)] // average adaptation efficiency weighted by GDP

// sum of the carbon tax for a zone collected from year 1 to pb.year
// unit is $/tCO2
[averageTax(c:Consumer) : float
  -> average(list<float>{(c.carbonTaxes[i] * 1000.0 / c.co2Emissions[i]) | i in (1 .. pb.year)})]

[worldAverageTax() : float
  -> average(list<float>{averageTax(c) | c in Consumer})]

// sum import reduction because of CBAM
[sumCBAM(c:Consumer) : float
  -> sum(list<float>{c.economy.reducedImports[i] | i in (1 .. pb.year)})]

[totalCBAM() : float
  -> sum(list<float>{sumCBAM(c) | c in Consumer})]

// sum of adaptation costs for a zone collected from year 1 to pb.year
[sumAdaptation(c:Consumer) : float
  -> c.adapt.sums[pb.year]]

[totalAdaptation() : float
  -> sum(list<float>{sumAdaptation(c) | c in Consumer})]

// sum of energy investments for a zone collected from year 1 to pb.year
[sumEInvest(c:Consumer) : float
  -> sum(list<float>{c.economy.investEnergy[i] | i in (1 .. pb.year)})]

[totalEInvest() : Price
  -> sum(list<float>{sumEInvest(c) | c in Consumer})]

// sum of savings for a zone collected from year 1 to pb.year
[sumSavings(c:Consumer) : float
  -> sum(list<float>{sum(c.savings[i]) | i in (1 .. pb.year)})]

[totalSavings() : float
  -> sum(list<float>{sumSavings(c) | c in Consumer})]

// sum of cancellations for a zone collected from year 1 to pb.year
[sumCancels(c:Consumer) : float
  -> sum(list<float>{c.economy.cancels[i] | i in (1 .. pb.year)})]

[totalCancels() : float
  -> sum(list<float>{sumCancels(c) | c in Consumer})]

// test reset
[testr(n:integer)
  -> initGUI(),
     resetSliders(),
     reinit(),
     go(n)]




