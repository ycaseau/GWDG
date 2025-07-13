// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2025 Yves Caseau                        *
// *       file: game.cl                                              *
// ********************************************************************

// this file contains the five CCEM sub-models that determine interaction
// between players as well as the overall simulation engine 
// this code is shared under GWDG github (CCEM = Coupling Coarse Earth Models)
// notice that the comments of key methods starts with [X] where X is the number
// of the associated equation in the model description (http://modelccem.eu)

// ********************************************************************
// *    Part 1: Production model M1                                   *
// *    Part 2: Consumption model M2                                  *
// *    Part 3: Substitution model M3                                 *
// *    Part 4: Economy model M4                                      *
// *    Part 5: Ecology Redirection model M5                          *
// *    Part 6: Run-time model checking                               *
// ********************************************************************

// this code is instrumented for debug: two control variables for traces
TESTE:any :: unknown    // debug variable : focus on Energy supplier TESTE
TESTC:any :: unknown    // debug variable : focus on Consumer TESTC
TESTO:any :: unknown    // very termporay : set to Oil to debug oil supplier

// ********************************************************************
// *    Part 1: Production model M1                                   *
// ********************************************************************

SHOW1:integer :: 5        // verbosity for model M1 

// SPLIT version
DYNCAP:boolean :: true

// CCEM simplification : the use of getMaxCapacity is only here
[getOutput(s:FiniteSupplier,p:Price,y:Year) : float
     -> getSupply(s,p,inventoryToMaxCapacity(s,s.capacities[y],reserve(s,p,y)),y) ]


// to void oscillation, we average the previous max capacity and the new one
[getMaxCapacity(s:FiniteSupplier,y:Year) : Energy
  -> (expectedCapacity(s,y) + s.capacities[y - 1]) / 2 ]

// simpler for Clean energy
[getMaxCapacity(s:InfiniteSupplier,y:Year) : Energy
   -> expectedCapacity(s,y)  ]

// version of getOutput for clean energy using getSupply (CCEM v6 is Diet => no overloading)
[getOutput(s:InfiniteSupplier,p:Price,y:Year) : float
     -> getSupply(s,p,s.capacities[y],y) ]

// [1] compute what the output for x:Supplier would be at price p
// cMax is the capacity (max output for the year; based on inventory and investments of the past)
// the quadratic formula is necessary to adress "no money, no output" and the linear sensitivity around the
// origin (pRatio = 1 -> cProd + sensitivity = derivative around 1)
[getSupply(s:FiniteSupplier,p:Price,cMax:Energy,y:Year) : float
  -> let cProd := s.production * min(1.0, (cMax / s.capacityMax)),  // projected output considering capacity 
         pRatio := p / s.price,                                     // relative price vs p0
         f1 := min(cMax, max(0.0, cProd * 
                   (if (pRatio < 0.5) pRatio * (2 - s.sensitivity)
                    else 1 + (pRatio - 1) * s.sensitivity))) in 
        f1]  

// [2] CCEM 4 : formula is different for clean energy : supplier needs to sell all it can produce
// but expects a price that is proportional to the GDP (in a world of energy abundance) - modulo sensitivity
// note : in a world of restriction, price is driven by cancellation
[getSupply(s:InfiniteSupplier,p:Price,cMax:Energy,y:Year) : float
  -> let p0 := s.price,
         w := pb.world.all, 
         p1 := p0 * (1 + ((w.results[y - 1] / w.results[1]) - 1.0) * s.sensitivity),  // price is proportional to GDP
         pRatio := p / p1,                                    // relative price vs p0
         f1 := min(cMax, pRatio * (cMax / s.capacityFactor))  in     // linear formula
        f1]

// previous price
[prevPrice(x:Supplier,y:Year) : Price
   -> x.sellPrices[y - 1]]

// [5] previous price, average over 3/N years
// CCEM v6: average of past 10 years 
[prev3Price(x:Supplier,y:Year) : Price
    -> let ymin := max(y - 10, 1), ymax := y - 1 in
       sum(list{ x.sellPrices[i] | i in (ymin .. ymax) }) / (ymax - ymin + 1) ]


// previous max capacity : last year capacity + added capacity during year y 
[prevMaxCapacity(x:Supplier,y:Year) : Energy
   -> x.capacities[y - 1]  +  x.additions[y - 1] ]

// current max capacity should be proportional to inventory modulo the growth constraints
// we also take into account the quantity that was added through substitutions (cf. PrevMax uses additions)
// p is the average price of the last 3 years -> sets available inventory

// [3] regular version for fossile energies : tries to match the evolution of demand
// capacity is adjusted when the inventory is below the threshold level
[expectedCapacity(x:FiniteSupplier,y:Year) : Energy   
   -> let prev := prevMaxCapacity(x,y),
          I1 := x.inventories[y - 1],             // inventory with that price, minus gone
          rProd := prodGrowth(x,prev,y),          // what growth should be
          rGrowth := max(0.0, min(rProd, x.capacityGrowth)) in         // capacity growth follows conso but is bounded 
        inventoryToMaxCapacity(x,prev * (1.0 + rGrowth),I1)]

// reserve is the inventory minus what is already sold 
// the price used to get the inventory is a combination of proposed price and the previous price
[reserve(x:FiniteSupplier,p:Price,y:Year) : Energy   
   -> get(x.inventory,p) - x.gone]

// new in CCEM v6: the adaptation to low inventory is piecewise linear (to avoid oscillation)
[inventoryToMaxCapacity(x:FiniteSupplier,capacity:Energy, inventory:Energy) : Energy
   -> let ratio  := (inventory / x.threshold), cMax := x.capacityMax in
        (if (ratio > 1.0) capacity
         else if (ratio < 0.5)  min(capacity,ratio * cMax * 175%)           // when ratio gets small 
         else  min(capacity, cMax * (1.0 - (1 - ratio) * (1 - ratio) * 0.5))) ]     // when ratio is just smaller than 1
    

// this is a heuristic that needs to get adjusted, it says that the maxcapacity should be X% (110)
// of the net demand that was seen (net = needs - cancel) averaged over past 3 years
[prodGrowth(x:Supplier, prev:Energy, y:Year) : Energy
  ->  if (y <= 3) 2%  // first 3 years, we assume a 2% growth 
      else let s := (4 * x.netNeeds[y - 1] +  x.netNeeds[y - 2] - 2 * x.netNeeds[y - 2]) / 3.0 in
          (//(x = TESTE) prodInspect(x,prev,s,y),
           ((s * x.capacityFactor) / prev) - 1.0) ]

// debug inspection 
[prodInspect(x:Supplier, prev:Energy, s:Energy, y:Year) : void
  -> printf("[~A] >>> prev(~S)=~F2, 3 years is ~F2 Gtoe from ~A\n",year!(y),x,prev,s, 
                    list{x.netNeeds[i] | i in (max(2,y - 3) .. y - 1)})]


// [4] new version for clean energies -> growthPotential tells how much we could add
// capacity tries to match 110% of net demand (this should become a parameter, hard coded in test1.cl) 
[expectedCapacity(x:InfiniteSupplier,y:Year) : Energy   
   -> let prev := prevMaxCapacity(x,y),
          maxDelta := maxYearlyAdditions(x,y),         // how much we can add this year
          expected := prodGrowth(x,prev,y),            // what growth should be (fraction of prev)
          growth := max(0.0, min(expected  * prev, maxDelta)) in  // cap growth follows conso but is bounded 
        (prev + growth)] 

// how how huch capacity can be added this year, taking the transfer additions into account (CCEM v6)
[maxYearlyAdditions(x:InfiniteSupplier,y:Year) : Energy
   -> max(0.0, get(x.growthPotential,yearF(y)) - x.additions[y - 1])]

// The second step is to maximize the utility function over a price range from 0 to X, (that is
// with a capacity that does not increase more than 15%
// CCEM v6:  MaxCapacity(x:Supplier,y:Year) includes the added capacities -> historicized into capacities[y]
[computeCapacity(s:Supplier,y:Year) : void
  -> let cMax := getMaxCapacity(s,y) in
      (s.capacities[y] := cMax,    /// was : - s.addedCapacities[y - 1],
      //(s = TESTO) prodShow(s,y,cMax) 
      )]  
       
// debug : show production and capacity
[prodShow(s:Supplier,y:Year,cMax:Energy) : void
  -> printf("[~A] prodShow(~S) cMax=~F2(adds:~F2) @ avgprice:~F2); needs=~F2TWh\n",year!(y),s,
            s.capacities[y],s.additions[y - 1],prev3Price(s,y),sum(list{c.needs[y][s.index] | c in Consumer})),
     showMaxCapacity(s,y,cMax,prev3Price(s,y)),
     showOutput(s,y,cMax,prev3Price(s,y))]


// (CCEM doc, Oct 2022) There are two key aspects which are missing:
// - Strategy of the resource owner to speculate on current price versus expected value (versus the naïve linear output model)
// - Time delay between decision to extract a new resource and actual operation is long 
//    (over 10 years) versus the current capacity model that looks 3 years back

// ********************************************************************
// *    Part 2: Consumption model M2                                  *
// ********************************************************************

SHOW2:integer :: 5       // verbosity for model M2

// dematerialization rate is the sum of
//  (a) structural demat due to economy change (dematerialization & learning)
//  (b) active efficiency gains (at a cost : invest)
[dematerializationRate(c:Consumer,y:Year) : Percent
  -> (1 - get(c.economy.dematerialize,yearF(y))) * (1 - c.savingFactors[y - 1]) ]

// [1] computes the need - Step 1
// two ways: (a) direct application of economy/status
//           (b) memory: "dampening factor"
// Note: pop  growth comes from Emerging countries => mostly linear (KISS)
// GW4: the need are now localized (c.population & c.gdp)
[getNeed(c:Consumer,y:Year) : void
  -> let b := c.economy,
         c0 := sum(c.startNeeds),
         dmr := dematerializationRate(c,y),
         c2 := c0 * dmr * globalEconomyRatio(b,y) *  populationRatio(b,y) * (1.0 - b.disasterRatios[y - 1]) in   
      (//[SHOW2] === needs(~S) = ~F2 PWh vs ~F2 (gdp:~F%,pop:~F%) // c,c2,c0,globalEconomyRatio(b,y),populationRatio(b,y),
       //[SHOW2] [~A] computes ~S needs: ~F3 -> ~F2 (~F%) demat:~F% // year!(y),c,c0,c2,(c2 / c0),dmr,
       //[?] c2 > 0.0,
       //(TESTC = c) showNeeds(c,c2,b,y),
       //(TESTE != unknown) printf("--- ~S needs(~S) = ~F2\n",c,TESTE,c2 * ratio(c,TESTE)),
       c.needs[y] := list<Energy>{ (c2 * ratio(c,s)) | s in Supplier},
       if (y > 1)   // [4] execute transfers from subsitution capabilities setup at year y - 1
          for tr in pb.transitions transferNeed(c,y,tr,transferRate(  c,tr,y - 1) * c.needs[y][tr.from.index])) ]

// debug: show the needs
[showNeeds(c:Consumer,c2:Energy,b:Block,y:Year) : void
  -> printf("[~S] ~S needs = ~F2 (economy ~F%, export ~F%, import ~F%) x dmr=~F%\n",
            year!(y),c,c2,globalEconomyRatio(b,y),outerCommerceRatio(b,y),importReductionRatio(b,y),
            dematerializationRate(c,y))]

// version that may be called from the console
[showNeeds(c:Consumer,y:Year) : void
  -> let b := c.economy,
         c0 := sum(c.startNeeds),
         dmr := dematerializationRate(c,y),
         c2 := c0 * dmr * globalEconomyRatio(b,y) *  populationRatio(b,y) * (1.0 - b.disasterRatios[y - 1]) in
     showNeeds(c,c2,b,y)]

// GW4 : the economy dependency (gdp -> Gtoe) is made of local and export influence
// this is a multiplicative factor (applied to inital state)
[economyRatio(w:Block,y:Year) : Percent
   -> if (y = 2) (1 + w.startGrowth) 
      else (newMaxout(w,y) / w.gdp)]

  
// [3] export influence from other block to which w is exporting (assuming w does not protect its frontiers)  
// v5: changed economyRatio to w (the health of the importing economy)
// cf comments in log.cl this is a differential equation, what is returned is (1 + dx/x) 
//          dE/E = dLocal/Local x (Local/E = innerTrade) + dExport/Export x (Export/E) + dImport/Import x (Import / E)
// CCEMv6: simplification => we separate the MaxOut factor from trade impact
[globalEconomyRatio(w:Block,y:Year) : Percent
  -> economyRatio(w,y) * tradeRatio(w,y)]

// trade Ratio = 1 when no trade barriers are in place - used for needs (M2) and results (M4)
[tradeRatio(w:Block,y:Year) : Percent
   -> innerTrade(w) + outerCommerceRatio(w,y) + importReductionRatio(w,y) ]

// returns the new outTrade ration (fraction of GDP) because of trade barrier
// no trade barriers => returns (1 - innerTrade(w)) by construction
// CCEM v6 note: still expressed as a fraction of w.GDP
[outerCommerceRatio(w:Block,y:Year) : Percent
  -> sum(list<Percent>{  (pb.trade[index(w)][index(w2 as Block)] *  (1.0 + exportReductionRatio(w,w2,y))) |
                          w2 in (Block but w)}) ]

// reduction of exportation factor (w -> w2) because of w2 CBAM - always negative
[exportReductionRatio(w:Block, w2:Block,y:Year) : Percent
  -> min(0.0, (w2.openTrade[index(w as Block)] - 1.0) *  pb.world.protectionismOutFactor) ]
  
// opposite situation : w is impacted by imports from w2, because of its own barrier or 
// because w2 is doing poorly
[importReductionRatio(w:Block,y:Year) : Percent
  -> sum(list<Percent>{ (importTradeRatio(w,w2,y) * importReductionRatio(w,w2,y)) | 
                         w2 in (Block but w)}) ]

// trade from w2 -> w expressed as a fraction of w gdp (hence the 2nd term)
[importTradeRatio(w:Block, w2:Block,y:Year) : Percent 
  -> pb.trade[index(w2 as Block)][index(w)] * (w2.gdp / w.gdp)]

// reduction of importation factor (w2 -> w:import): this is a negative correction when openTrade is less than 1.0
[importReductionRatio(w:Block, w2:Block,y:Year) : Percent
  -> min(0.0, (w.openTrade[index(w2 as Block)] - 1.0) *  pb.world.protectionismInFactor) ]



// new in CCEM v6: we model the impact of warming on the population
// decline is both birth reductions (illnesses) and increased mortality
[populationEstimate(c:Consumer,y:Year) : Energy
  -> let pn := get(c.population,yearF(y)),
         birthrate := 1 / 80.0,
         decline := sum(list{(get(c.population,yearF(i)) * birthrate * c.painLevels[i] * c.populationFactor) |
                         i in (max(1,y - 80) .. (y - 1))}) in
         pn - decline]

// [2]  the second term is, as before, based on  growth
[populationRatio(b:Block,y:Year) : Percent
  -> let  c := b.describes,p0 := get(c.population,yearF(1)), 
          pn := populationEstimate(c,y) in
       (1 + c.popEnergy * (pn - p0) / p0)]
     
// tricky: assign energy needs proportionally ... then add substitution flows 
[ratio(c:Consumer,s:Supplier) : Percent
  -> let i := s.index in  (c.consumes[i] / sum(c.consumes)) ]

// transfer some energy need from one supplier to the next
// new in CCEM v7: efficiency gain may occur
[transferNeed(c:Consumer,y:Year,tr:Transition,q:Energy) : void  
  -> //(tr.from = TESTE) trace(0,">>>> Need transfer of ~F2Gtoe for ~S from ~S to ~S\n",q,c,tr.from,tr.to),
     c.needs[y][tr.from.index] :- q,
     c.needs[y][tr.to.index] :+ q * tr.efficiency%,
     c.eSavings[y][tr.from.index] :+ q * (1.0 - tr.efficiency%) ]

// [5] computes the need - Step 2 - for one precise supplier

// compute total demand for all consumers for a suplier s and price p
[totalDemand(y:Year,s:Supplier,p:Price) : Energy
   -> sum( list{howMuch(c,s,oilEquivalent(s,p + tax(c,s,y))) | c in Consumer}) ]

// carbon tax is based on co2 level reached the previous year
// in GW3, we add the acceleration pushed by societal reaction
// this returns a price in $ for 1 PWh (co2Factor adjusted)
// CinCO2 :: (12.0 / 44.0)  // one C for 2 O => no longer in use
// tax is CO2 equivalent ! 200$/t means per equivalent of CO2 ton
[tax(c:Consumer,s:Supplier,y:Year) : Price
  -> (if (y <= 2) 0.0
      else (get(c.carbonTax,pb.earth.co2Levels[y - 1]) + c.taxAcceleration) * s.co2Factor) ]

// this is what the consumer will pay 
[truePrice(c:Consumer,s:Supplier,y:Year) : Price
    -> s.sellPrices[y] + tax(c,s,y) ]

// when we compute cancellation, all threshold are defined with oilPrice
// this is a normalized (equivalent of oil, adjusted for price increase)
[oilEquivalent(s:Supplier,p:Price) : Price
  -> p * pb.oil.price / s.price]  

// [5] this is where we apply cancellation to find what the actual consumption is at a given oil-eq price
// notice that transfer were managed in the need
HOW:integer :: 5
[howMuch(c:Consumer,s:Supplier,p:Price) : Energy
  -> let cneed := c.needs[pb.year][s.index], x1 := getCancel(c,s,p), 
         x := max(0.0,(1.0 - x1)) in
         (//[HOW] ~S consumes ~S = ~S * (1 - ~F3) price ~F3 (x:~S)// c,cneed * x,cneed,x1,p,x,
          cneed * x) ]

// we got rid the "CancelThreat" in version 0.2 to KISS
// on the other hand, we had a supplier-sensitive factor to model (for coal !) => mimick price stability which we observe
// GW3: added the cancelAcceleration produced by M5 bu
[getCancel(c:Consumer,s:Supplier,p:Price) : Percent
  -> get(c.cancel,p) * (1.0 + (case s (FiniteSupplier c.cancelAcceleration, any 0.0))) ]

// reads the current transferRate
[transferRate(c:Consumer,tr:Transition,y:Year) : Percent
  -> (if (y = 0) 0.0 else c.transferRates[y][tr.index]) ]

// each production has a price (Invest = capacity increase / 20)
// we distribute the energy investment across the blocs using energy consumption as a ratio
// note: we call this once consomations are known
[recordCapacity(s:Supplier,y:Year) : void
   -> let p1 := s.sellPrices[y], p2 := prev3Price(s,y),
          addCapacity := max(0.0,s.capacities[y] - prevMaxCapacity(s,y)) in
        (//(s = TESTE) printf(">>>>> ~I",showOutput(s,y,p1)),
         (case s (FiniteSupplier s.inventories[y] := get(s.inventory,p1) - s.gone)),
         //(s = TESTO) printf(">>>>> inventory[~A] = ~F2 at price ~F2/~F2 avg\n",year!(y),s.inventories[y],p1,p2),
         //[DEBUG] add ~S capacity: +~F2 -> ~F2T$ // s,addCapacity,addCapacity * s.investPrice,
         let addInvest := addCapacity * s.investPrice * (1 - s.techFactor) ^ float!(y) in
           for b in Block
             (b.investCapacity[y] :+ addInvest * shareOfConsumption(s,b,y), // debug
              b.investEnergy[y] :+ addInvest * shareOfConsumption(s,b,y)))]

// share of energy consumption for a block
// we use the previous year to get the ratio (consumption is not known yet)
[shareOfConsumption(s:Supplier,b:Block,y:Year) : Percent
  -> b.describes.consos[y - 1][s.index] / sum(list{b2.describes.consos[y - 1][s.index] | b2 in Block}) ]


// [6] dichotomic search for the price that matches supply and demand the best
[disolve(pb:Problem,s:Supplier) : Price
  -> let v1 := tryPrice(pb,s,pb.priceRange[1]), v2 := tryPrice(pb,s,pb.priceRange[NIS]) in
        (//(v1 < 0.0  & v2 > 0.0) marketModelError(s,pb.year),
         dichotomy(pb,s,1,v1,NIS,v2)) ]

DIBUG:integer :: 5

// while i1 and i2 are not close enough, we split in the middle and see which one we keep (i1:overdemand, i2: oversupply)
[dichotomy(pb:Problem,s:Supplier,i1:integer,v1:Price,i2:integer,v2:Price) : Price
  -> //[DIBUG] --- dichotomy [~A(~F2): ~F2, ~A(~F2): ~F2] // i1,pb.priceRange[i1],v1,i2,pb.priceRange[i2],v2,
     if (i2 <= i1 + 1) 
       (//[DIBUG] === end of dicho(~S) @ ~F2 -> delta =~F2:~A or ~F2 // s,pb.priceRange[i1],v1,i1,v2,
        if (abs(v1) < abs(v2)) pb.priceRange[i1] else pb.priceRange[i2])
     else let i3 := (i1 + i2) / 2, v3 := tryPrice(pb,s,pb.priceRange[i3]) in
        (//[DIBUG] pivot = ~A => ~F2 // i3,v3,
         if (v3 >= 0.0) dichotomy(pb,s,i3,v3,i2,v2)   
         else dichotomy(pb,s,i1,v1,i3,v3)) ]

// try a price and return Demand - supply (hence very low price gives a positive value and high price a negative one)
[tryPrice(pb:Problem,s:Supplier,p:Price) : Price
  -> let y := pb.year,
         demand := totalDemand(y,s,p),
         supply := getOutput(s,p,y) in
        ( demand - supply)]

// balance production and consumption (M2)
// production is defined by price / consumption is allocated to each consumer proportionnally 
// to reach a perfect prod/conso balance
BALANCE:integer :: 5
[balanceEnergy(s:Supplier,y:Year) : void 
  ->  let production := getSupply(s,s.sellPrices[y], expectedCapacity(s,y),y),   // s production for this year at price p
         listConsos := list<Energy>{ howMuch(c,s,oilEquivalent(s,truePrice(c,s,y))) | c in Consumer},
         total := sum(listConsos) in
        (//[BALANCE] [~A] BALANCE(~S) produces ~F2 Gtep @ ~F2 T$ versus consos = ~F2 // year!(y),s,production,s.sellPrices[y],total,
         //[BALANCE] --- list HowMuch: ~S // listConsos,
         //(s = TESTO) showSensitivity(s,y),
         for c in Consumer
            c.consos[y][s.index] := listConsos[c.index] * (production / total)) ]


// ********************************************************************
// *    Part 3: Substitution model M3                                 *
// ********************************************************************

// M3 captures the answer to 
// « How fast can we substitute one form of primary energy to another ? »

SHOW3:integer :: 5                      // verbosity for model M3

// [1] record the actual substitution - use substitution matrix
// each operation may update the Percent because of monotonicity
// cancel is deduced from the actual conso to ensure need = conson + cancel
[record(c:Consumer,s:Supplier,y:Year)
  -> let i := s.index,
         cneed := c.needs[y][i] , 
         p := truePrice(c,s,y),         // equilibrium price was found with solve() in simul.cl; truePrice includes tax
         oep := oilEquivalent(s,p),     // oil equivalent price to read cancel 
         missed := cneed - c.consos[y][s.index],      // consumption that is actually cancelled
         x := missed / cneed  in       // actual cancel ratio
       (if (s = TESTO) trace(5,"DEBUG [~A] cancel(~S,~S) is ~F% (at oep = ~F2) versus ~F%(x10)\n",
                             year!(y),c,s,x * 10.0,oep,10.0 * getCancel(c,s,oep)),
        // c.sellPrices[y][s.index] := p,
        // trace(0,"LOOP sell price for ~S = ~F2\n",s,p),
        saves(c,s,y),   
        cancels(c,s,y,missed),
        if (tax(c,s,y) >= PMAX * 80%) error("Carbon Tax got too high ~S",tax(c,s,y)),           
        // compute the transferRate for next years, based on current price, look at all transfer starting from s
        for tr in s.from updateRate(c,s,tr,y,cneed * (1.0 - x)),
        //[DEBUG] --- record qty(~S) @ ~F3 = ~F3 vs ~F3 [need = ~F3 ] // c,p,cneed * (1.0 - x),howMuch(c,s,p),cneed,
        s.netNeeds[y] :+ cneed,                            // "real" needs 
        consumes(c,s,y,c.consos[y][s.index])) ]            // registers the energy consumption of c for s
                

// [2] cancellation : registers an energy consumption cancellation
[cancels(c:Consumer,s:Supplier,y:Year,x:Energy) : void
 -> c.economy.cancels[y] :+ x,
    c.cancel%[y][s.index] := x / c.needs[y][s.index]  ]                              // record all cancels
         
// [4] [6]  consumes : register the CO2 and register the energy
[consumes(c:Consumer,s:Supplier,y:Year,x:Energy) : void
   -> if (s = TESTE) 
          trace(1,"[~A] ~S consumes ~F2 of ~S [need = ~F2 reduced-> ~F2] \n", year!(y),c,x,s,c.needs[y][s.index],howMuch(c,s,truePrice(c,s,y))),
      // c.consos[y][s.index] := x was set in balanceEnergy
      pb.earth.co2Emissions[y] :+ (x * s.co2Factor),   
      c.co2Emissions[y] :+ (x * s.co2Factor),
      //(c = TESTC) trace(1,"electricity(~S) = ~F2 PWhs from ~S (at ~F%) \n",c,x * eRatio(c,s),s,eRatio(c,s)),
      c.ePWhs[y] :+ x * eRatio(c,s),
      //[DEBUG] {~S} carbonTax adds ~F2 of ~S(Gt) x ~F2 (tax) = ~F2 // c,x,s,tax(c,s,y), tax(c,s,y) * x,
      c.carbonTaxes[y] :+ tax(c,s,y) * x / 1000.0,      // [4] tax in T$, energy in PWh
      c.economy.totalConsos[y] :+ x,                    // conso = true consumption
      c.economy.inputs[y] :+ x,                         // input = conso + efficiency gains 
      s.gone :+ x,                                      // store consumption
      s.outputs[y] :+ x ]                               // store production

[eCheck(c:Consumer,y:Year) : Energy
  -> sum(list{(c.consos[y][s.index] * eRatio(c,s)) | s in Supplier})]

// part of the cost of new energy is linked to the cost of steel
[steelFactor(s:Supplier,y:Year) : float
   -> let pf := s.steelFactor in   // part of steel in energy production price
        (1 - pf) + pf * (pb.world.steelPrices[y - 1] / pb.world.steelPrices[1]) ]


// Voluntary (efficiency) saavings, that are driven by investment
// s.savingFactors[y - 1] is the current policy level (set by M5)
[saves(c:Consumer,s:Supplier,y:Year) : void
   ->  let i := s.index,
           cneed := c.needs[y][i], 
           ftech := (1 - s.techFactor) ^ float!(y),
           w1 := c.savingRates[y - 1],                                          // last year's saving (as a %)
           w2 := max(w1, min( w1 + c.yearlySaving, c.savingFactors[y - 1])) in  // new target (cannot grow too fast)
         (//[DEBUG] [~A] ~S saves ~S% of ~S (was ~S%) --- // year!(y),c,w2,s,w1,
          c.savings[y][i] := w1 * cneed,                         // [2] record all savings
          c.savingRates[y] := w2,                             // new saving rate
          //[DEBUG] ~S invest for ~S ~F1T$ to get ~F1Gtoe savings // c,s,(w2 - w1) * cneed * s.investPrice * ftech,(w2 - w1) * cneed,
          c.economy.investEnergy[y] :+                       // [5] invest to save
             (w2 - w1) * cneed * s.investPrice * ftech * steelFactor(s,y))]

// all enery saved by efficiency gains triggered by policies    
[sumSavings(c:Consumer,y:Year) : Energy
  -> sum(list{ (c.savings[y][s.index]) | s in Supplier}) ]

[sumESavings(c:Consumer,y:Year) : Energy
    -> sum(list{ (c.eSavings[y][s.index]) | s in Supplier}) ]

// getTransferRate: reads the substitution matrix and multiply by c.transtionFactors[y - 1]
[getTransferRate(c:Consumer,tr:Transition,y:Year) : Percent
  -> c.transitionFactors[y - 1] * get(c.subMatrix[tr.index],yearF(y)) ]

// [3] [6] monotonic update of the transferRate substitute a fraction from one energy source to another
// note the monotonic behavior, we return the actual Percentage !
// in v0.3 we
[updateRate(c:Consumer,s1:Supplier,tr:Transition,y:Year,consumed:Energy) 
   -> let i := tr.index, s2 := tr.to,
          ftech := (1 - s2.techFactor) ^ float!(y),
          adapt := (1.0 + tr.adaptationFactor),       // CCEM v7 : adaptation from s1 to s2 requires invests
          w1 := transferRate(c,tr,y - 1),                         // transfer last year
          w2 := max(w1, getTransferRate(c,tr,y)),     // transfer expected for this year (monotonic !)
          w3 := applyMaxGrowthRate(w1,w2,s2,y) in                        // modulo capacity growth constraints (look-ahead)
         (c.substitutions[y][i] := w1 * consumed,                    // actual substitution (rate of previous year)
          c.transferRates[y][i] := min(1.0,w3),                                // record new transfer level (for next year)
          s2.addedCapacity :+ (w3 - w1) * consumed,                              // s2 capacity is increased ...
          s2.additions[y] :+ (w3 - w1) * consumed,                       // ... keep a history of addition for s2
          //[SHOW3] [~A] ~S transfers ~F1 PWh from ~S to ~S, rate:= ~F% [matrix ->~F%, max:~F%] maxFlow(~S):~F2 // year!(y),c,w1 * consumed,s1,s2,w3,getTransferRate(c,tr,y),maxTransferRate(s2,y),s2,maxTransferFlow(s2,y),
          //[SHOW3]  => capacity(~S) rises by ~F2 (~F% -> ~F%) [sum:~F2] // s2,(w3 - w1) * consumed, w1, w3,s2.additions[y],
          c.transferFlows[y][i] :+ (w3 - w1) * consumed,                  // record the flow
          c.ePWhs[y] :+ (w1 * consumed) * eTransferRatio(c,tr),       // [6] electricity in PWh
          c.eDeltas[y] :+ (w1 * consumed) * eTransferRatio(c,tr),     // for debug
          //(s2 = TESTE | c = TESTC) showUpdate(c,s1,s2,tr,y,consumed,w1,w3),
          //[5] ~S: transfer(~S) invest ~F3T$ to get ~F3PWh moved // c,tr,(w3 - w1) * consumed * s2.investPrice,(w3 - w1) * consumed,
          c.economy.investTransition[y] :+                     // dual booking to track transition investments
              (w3 - w1) * consumed * s2.investPrice * ftech * steelFactor(s1,y) * adapt,
          c.economy.investEnergy[y] :+                        // invest to substitute (the cost for this added capacity)
              (w3 - w1) * consumed * s2.investPrice * ftech * steelFactor(s1,y) * adapt)]

// show the update of the transfer rate
[showUpdate(c:Consumer,s1:Supplier,s2:Supplier,tr:Transition,y:Year,consumed:Energy,w1:Energy,w3:Energy) : void
  -> trace(TALK,"[~A:~F2] ~S transfer ~F2 PWh(~F%) [~F% now on -> add ~F3] of ~S to ~S [matrix ->~F%]\n",
            year!(y),s2.addedCapacity,c,w1 * consumed,w1,w3,(w3 - w1) * consumed, s1,tr.to, 
            getTransferRate(c,tr,y)),
     trace(SHOW3,"[~A] this generates invest of ~F1G$ for ~F1PWh\n",year!(y),
                  (w3 - w1) * consumed * s1.investPrice,  (w3 - w1) * consumed)]
        
// [6] gwdg : when using the static eRatio of 2010, we make an error that we must fix (using an approximate formula)
// r1: elecRate of s1, e2: elecRate of s2, h: heatRate of tr
// CCEM v7: take the efficiency into account (less energy required in electric mode : cf part 2)
[eTransferRatio(c:Consumer,tr:Transition) : Percent
  -> let s1 := tr.from, s2 := tr.to, h := tr.heat%,
         r1 := 1.0 - s1.heat%, r2 := 1.0 - s2.heat%, alpha := 1.0 - h in
       (if (c = TESTC)
           trace(5,"electricity for ~S, transfer(~S:~F%->~S:~F%) corrects rate = ~F% (alpha:~F%)\n",
                  c,s1,r1,s2,r2,(1 - r1) * (1 - alpha),alpha), 
        tr.efficiency% * (1 - r1) * (1 - alpha)) ]

// GW5 : to take the capacity growth into account, we need to compute the max growth rate expressed for the transfer flow,
// computes the max capacity growth as a percentage of the complete max flow (all other s2 to s, all blocks)
// w1 is the current rate, w2 is the expected rate, we apply the same proportional reduction factor so that the actual transfer flow meets the constraint
[applyMaxGrowthRate(w1:Percent, w2:Percent,s:Supplier, y:Year) : Percent
  ->  w1 + (w2 - w1) * min(1.0, maxTransferRate(s,y)) ]

// computes the max capacity growth as a percentage of the complete max flow (all other s2 to s, all blocks)
// w1 is the current rate, w2 is the expected rate, we apply the same proportional reduction factor so that the actual transfer flow meets the constraint
[maxTransferRate(s:FiniteSupplier, y:Year) : Percent
  -> let f := maxTransferFlow(s,y) in 
       (if (f > 0.0) (s.capacityGrowth * prevMaxCapacity(s,pb.year) / f) else 0.0) ]     

// for Clean, s.growthPotential is the max PWh that we can add in a year
[maxTransferRate(s:InfiniteSupplier, y:Year) : Percent
  -> let f := maxTransferFlow(s,y) in 
       (if (f > 0.0) (get(s.growthPotential,yearF(pb.year)) / f) else 0.0) ]

// maxTransferFlow is the sum of all transfer rates (from all s2 to s) at the max possible level from the existing one (y  -1)
// note the look-ahead pattern: the code is similar to updateRate (without the capacity constraint)
// approximate : since c.consos is not known yet, we use the previous year's consos
[maxTransferFlow(s:Supplier, y:Year) : Energy
  -> let e := 0.0 in 
       (for tr in pb.transitions
          (if (tr.to = s)
             for c in Consumer
                let w1 := transferRate(c,tr,y - 1),
                    w2 := max(w1, c.transitionFactors[y - 1] * getTransferRate(c,tr,y)) in
                  e :+ (w2 - w1) * c.consos[y - 1][tr.from.index]),
        e) ]

// ********************************************************************
// *    Part 4: Economy model M4                                      *
// ********************************************************************

// M4 represents the question: 
// « which GDP is produced from investment, technology, energy and workforce ? »
SHOW4:integer :: 5        // verbosity for model M4

// computes the economy for a given year -> 4 blocs then consolidate
[getEconomy(y:Year) 
  -> for b in Block checkBalance(b.describes,y),
     for s in Supplier checkTransfers(s,y),
     for b in Block consumes(b,y),
     let e := pb.world.all in
       (consolidate(e,y),
        steelPrice(y),
        for b in Block steelConsumption(b,y),
        pb.world.all.ironConsos[y] := sum(list{b.ironConsos[y] | b in Block}),
        //[SHOW4] --- steel price in ~A is ~F2 $/t // year!(y),pb.world.steelPrices[y],
        agroOutput(y),
        //[SHOW4] --- agro output in ~A is ~F2 Gt // year!(y),pb.world.wheatOutputs[y],
        //[SHOW4] --- PNB = ~F2T$ from actual energy ~F1Gtoe, Inv=~F2 (was ~F2) // e.results[y],e.totalConsos[y],e.investGrowth[y],e.investGrowth[y - 1],
        e)]    

// [1] this computes the maxout expected at year y based on previous year, poopulation growth and growth invest
// we use the heuristic (expected damage on GDP) that we differentiate between two years and multiply by 3 to 
// compensate the integration factor (GDP growing and disaster ratio growing, so final compound effect needs to be multiplied by 3)
[newMaxout(b:Block,y:Year) : Price
  -> (b.maxout[y - 1] * (1 - pb.world.decay) * populationGrowth(b,y)  + b.investGrowth[y - 1] * get(b.roI,yearF(y))) ]

// [4] differential : one year versus the previous one
// in CCEM v5, we take into account the effect of pain
[populationGrowth(w:Block,y:Year) : Percent
  -> let c := w.describes in 
        (populationEstimate(w.describes,y) / populationEstimate(w.describes,y - 1)) *
         (if (y = 2) 1.0 
          else  (productivityLoss(c,y - 1) / productivityLoss(c,y - 2))) ]

// the loss of productivity is a linear function of the pain level
[productivityLoss(c:Consumer,y:Year) : Percent
  -> let p := c.painLevels[y] in (1.0 - p * c.productivityFactor)]

// read the loss factor from the KNU and apply a correction factor (0.7) because of investment propagation
// in v7 we reduce the damages through adaptation
[disasterRatio(c:Consumer,t:float,y:Year) : Percent
   -> 0.7 * get(c.disasterLoss,t - pb.earth.avgCentury) *     // damages based on temperature
      (1.0 - c.adapt.levels[y - 1]) ]                          // efficiency computed in M5

// [2] [3] very simple economical equation of a regional economy (Block)
// note : in GW3 we have one world economy, in GW4 we may separate
// (a) we take the inverst into account to comput w.maxout
// (b) we take the energy consumption cancellation into account
// (c) we take the GW distasters into account
[consumes(b:Block,y:Year) : void
  -> let e := pb.earth, 
         iv := b.investGrowth[y - 1],      // last year invest
         t := e.temperatures[y - 1],
         disasterFactor := disasterRatio(b.describes,t,y) in   // [2] earth factor : loss of productive capacity
       (b.disasterRatios[y] := disasterFactor,
        b.maxout[y] := newMaxout(b,y),             // produce this year's growth (max gdp)
        pb.totalInvest :+ b.investGrowth[y - 1],                          // book keeping for average RoI: (1) invest
        pb.totalGrowth :+ b.investGrowth[y - 1] * get(b.roI,yearF(y)),   // book keeping for average RoI: (1) invest
        b.tradeFactors[y] := tradeImportFactors(b,y),     // import trade factor (protectionism)
        e.gdpLosses[y] :+ b.maxout[y] * disasterFactor,                     // [2] record the loss of gdp
        let c := b.describes, f := c.adapt.levels[y - 1], 
            avoidLosses := b.maxout[y] * disasterFactor * f / (1.0 - f)  in
            (e.adaptGains[y] :+ avoidLosses,
             c.adapt.losses[y] := b.maxout[y] * disasterFactor,                // [2] record the losses due to adaptation
             c.adapt.gains[y] := avoidLosses),                         // [2] record the avoided losses thanks to adaptation
        //[SHOW4] --- Growth for ~S -> ~F2T$, invest(~F2) x roi (~F2) -> +~F2T$,  // b, b.maxout[y], iv, get(b.roI,yearF(y)), iv * get(b.roI,yearF(y)),
        //[SHOW4] --- temperature is now ~F2, loss is ~F% // t,get(b.describes.disasterLoss,t - e.avgCentury),
        b.lossRatios[y] := impactFromCancel(b,y),                       // [3] economy factor: loss of energy -> cancellation
        b.results[y] := b.maxout[y] * (1.0 - disasterFactor) * (1.0 - b.lossRatios[y]) * tradeRatio(b,y),  // [4] economy factor: loss of energy -> cancellation
        trace(DEBUG,"[~A] ~S maxout is ~F2 and result is ~F2 ========\n",year!(y),b,b.maxout[y],b.results[y]),
        trace(DEBUG,"[~A] ~S lossRatio ~F2 and other is ~F2 ========\n",year!(y),b,b.lossRatios[y],tradeRatio(b,y)),
        //(TESTC = b.describes) showTrade(b,y),
        computeInvest(b,y)) ]

// [6] computes the invest for a block
// CCEM v7: adaptation reduces partially the investment
[computeInvest(b:Block,y:Year) : void
   -> let  iv := b.investGrowth[y - 1],      // last year invest
           invE := b.investEnergy[y],        // sum of energy invests this year for transition and energy growth
           r1 := b.results[y - 1],  
           r2 := b.results[y], 
           ix := 0.0,
           invAdapt := b.describes.adapt.spends[y - 1] in // note: we could add * pb.world.adaptGrowthLoss in
         (//[SHOW4] M4: ~S invest ~F% of GDP (grows from ~F2T$ to ~F2T$ = ~F%), target=~F% // b.describes, (iv / r1), r1, r2, (r2 - r1) / r2, b.iRevenue,
          ix := r2 * b.iRevenue *             // [6] fraction of economy is gone (r1 -> r2)
                 (1.0 - b.lossRatios[y]) *    // managing the social consequence of this loss reduces the ability to invest
                 (1.0 - marginReduction(b.describes,y)),    // margin reduction -> invest reduction
          //[SHOW4] M4: this year inverst = ~F2T$ from ~F2(max)[x]~F%(margin) // ix, r2 * b.iRevenue,marginReduction(b.describes,y),
          invE := max(0.0, invE - sum(list{c.carbonTaxes[y] | c in Consumer})),
          pb.totalEInvest :+ invE,            // book keeping for total Energy Investx
          b.investGrowth[y] := (ix - invE - invAdapt)) ]

// book keeping (store in M4 for easier debugging)
[tradeImportFactors(w:Block, y:Year) : list<Percent>
  -> list<Percent>{ w.openTrade[index(w2 as Block)] | w2 in Block } ]

// [5] GW4: fraction of the maxoutput that is used for a block (vs cancelled)
// 1.0 if no impact, 0 if 100% cancelled
// cancel rate is transformed into impact for each zone, modulo redistribution policy
[impactFromCancel(b:Block,y:Year) : Percent 
   ->  let s_energy := 0.0, s_cancel := 0.0, s_control := 0.0, c := b.describes,
           conso := sum(c.consos[y]),
           cancel := sumCancels(c,y), 
           ratio := (cancel / (conso + cancel)),
           ratio_with_r := (1.0 - c.redistribution) * get(c.cancelImpact,ratio) + 
                                 c.redistribution * ratio in
              (//[SHOW4] --- impact from cancel is ~F%  from ~F% (cancel ratio) // ratio_with_r, ratio,
               ratio_with_r) ]

// computes the margin impact of energy price increase, weighted avertage over energy sources
// KISS principle for CCEM v6: use the same cancel curves (cancel and cancelImpact) for forced 
// sobriety (activity stops) and margin reduction
[marginReduction(c:Consumer,y:Year) : Percent
   -> let s_energy := 0.0, margin_impact := 0.0, s_price := 0.0 in
        (for s in Supplier
            let p := truePrice(c,s,y),
                oep := oilEquivalent(s,p),
                conso := c.consos[y][s.index] in
              (s_energy :+ conso,
               s_price :+ conso * oep,
               margin_impact :+ conso * get(c.cancelImpact,get(c.cancel,oep))),
         let mi :=  margin_impact / s_energy in
          (//[SHOW4] --- ~S margin impact of ~F%, from energy price ~F1$ // c, mi, s_price / s_energy,
          c.economy.marginImpacts[y] := mi,
          mi)) ]

// debug
[showTrade(b:Block,y:Year) : void
  -> printf("[~S] ~S maxout = ~F2 (ImportRatio ~F%, ExportRatio ~F%)\n",
             year!(y),b,b.maxout[y],importReductionRatio(b,y),outerCommerceRatio(b,y))]

// note: the techfactor is only applied to energy, because the model does not account for other resources
// (water, metals, ...). The assumption is that adding more control loops (with duality of finite resources 
//  and recycling / savings with tech) would simply add complexity.      

// computes the cancel ratio for one zone
[cancelRatio(c:Consumer,y:Year) : Percent 
   -> let conso := c.economy.totalConsos[y],
          cancel := c.economy.cancels[y] in
        (cancel / (conso + cancel)) ]
 
// [7] computes the steel consumption from gdp
STEEL:integer :: 5
[steelConsumption(b:Block,y:Year) : void
   -> b.ironConsos[y] := (b.results[y] / get(b.ironDriver,yearF(y))),
      trace(STEEL,"---- steel for ~S: conso = ~F2 from output = ~F2 @ ~F2$/t \n",
            b, b.ironConsos[y], b.results[y], pb.world.steelPrices[y]) ]
       

// [7] computes the steel price 
[steelPrice(y:Year) : void
   -> let w := pb.world in
        (w.steelPrices[y] := w.steelPrice * (avgOilEquivalent(y) / avgOilEquivalent(1)) *
                             (get(w.energy4steel,yearF(y)) / get(w.energy4steel,yearF(1))))]


// ********************************************************************
// *    Part 5: Ecology Redirection model M5                          *
// ********************************************************************

// M5 answers the question 
// « What kinds of redirection should we expect from the IPCCs global warming consequences ?»
// three outpout : acceletaration of CO2tax, 

SHOW5:integer :: 5        // verbosity for model M5

// In CCEMv7 the pain is reduced through the adaptation level
[painFromWarming(e:Earth,c:Consumer,y:Year) : Percent
  -> get(e.painClimate,get(e.warming,e.co2Levels[y])) * (1.0 - c.adapt.levels[y - 1])]

// [1] [2] [3] even simpler : computes the CO2 and the temperature,
// then (M5) apply the pain to re-evaluate the reactions
[react(e:Earth,y:Year) : void
   -> let x := e.co2Levels[y - 1] in // previous CO2 level
         (e.co2Levels[y] := x + e.co2Emissions[y] * e.co2Ratio,    // simplified in model v5
          e.co2Cumuls[y] := e.co2Cumuls[y - 1] + e.co2Emissions[y], // [1] cumulated CO2
          //[SHOW5] [~A] --- +C=~F2 -> co2=~F2 // year!(y),e.co2Emissions[y],e.co2Levels[y],
          e.temperatures[y] := e.avgTemp - get(e.warming,e.co2PPM) + get(e.warming,e.co2Levels[y]),
           // applies pain to each political bloc
          for c in Consumer
            let pain_energy := painFromCancel(c,y),       // [3] pain drivers
                pain_results := painFromResults(c,y),
                pain_warming := painFromWarming(e,c,y),
                pain := pain_warming + pain_energy + pain_results in // [4] use the painProfile factors
             (//[SHOW5] pain for ~S=~F2  ~F2(co2)+ ~F2(cancel)+ ~F2(gdp) // c,pain,get(e.painClimate,get(e.warming,e.co2Levels[y])),painFromCancel(c,y),painFromResults(c,y),
              c.painLevels[y] := pain,        
              c.painEnergy[y] := pain_energy,
              c.painResults[y] := pain_results,
              c.painWarming[y] := pain_warming,
              redirection(c,y,pain)),
          computeProtectionism(y),
          computeAdaptation(y)) ]

// [5] computes the redirection for a consumer from pain level
MAXTAX :: 5000.0
MAXTR :: 150.0     // max transition acceleration compared to best plan
[redirection(c:Consumer,y:Year,pain:Percent) : void
  ->  c.satisfactions[y] := computeSatisfaction(c,y),
      c.taxAcceleration := MAXTAX * c.tactic.taxFromPain * pain,
      c.cancelAcceleration := c.tactic.cancelFromPain * pain,
      c.transitionFactors[y] := min(MAXTR, c.tactic.transitionStart + c.tactic.transitionFromPain * pain),
      c.savingFactors[y] := min(c.maxSaving,c.tactic.savingStart + c.tactic.savingFromPain * pain),
      //[SHOW5] sets taxAcceleration to ~F% and cancelAccelation to ~F% // c.taxAcceleration,c.cancelAcceleration,
      c.protectionismFactor := c.tactic.protectionismStart + c.tactic.protectionismFromPain * pain,
      c.adapt.investFactor := min(c.tactic.adaptMax,c.tactic.adaptStart + c.tactic.adaptFromPain * pain)]

      
// [6] once the "alpha" factors have been set, we compute the protectionism level ()
// note that we protect based on the difference between co2/Energy and the existance of a similar level of CO2 tax
[computeProtectionism(y:Year) : void
  -> let w := pb.world in
        (for c1 in Consumer
           let w1 := c1.economy, alpha := c1.protectionismFactor in
              (// book-keeping first, then compute the new values for protectionism
               for c2:Consumer in (Consumer but c1)
                 let co2perE1 := cDensity(c1,y),  co2perE2 := cDensity(c2,y), w2 := c2.economy,
                     ctax1 := taxRate(c1,y), ctax2 := taxRate(c2,y) in
                    (w1.reducedImports[y] :- (w2.results[y] *               // w2 exports to w1
                       pb.trade[index(w2)][index(w1)] * importReductionRatio(w1,w2,y)),
                     //[5] [~A] CP(~S,~S) -> ~S(~S) ~S; tx ~S ~S // y, c1,c2, co2perE1, c1.consos[y], co2perE2, ctax1, ctax2,
                     w1.openTrade[c2.index] := 1 - min(1.0,
                                alpha * max(0.0,(co2perE2 - co2perE1) / (0.001 + co2perE1)) *
                                                     max(0.0,(ctax1 - ctax2) / (0.001 + ctax1))),
                     //[5] CP(~S,~S) <- ~S // c1,c2,w1.openTrade[c2.index],
                     if (alpha > 0.0)
                       trace(2,"protectionism for ~S(tax:~F2) -> ~S(tax:~F2) = ~F% from co2/GDP ~F% and ~F% [~F%]\n",
                             c1,ctax1,c2,ctax2,w1.openTrade[c2.index],co2perE1,co2perE2,alpha))))]

// cDensity = density in CO2 of energy consumption
[cDensity(c:Consumer,y:Year) : Price
  -> c.co2Emissions[y] / sum(c.consos[y]) ]

// carbon tax rate for a consumer : divide the money by the fossil fuel consumption
// return $ / Gtep
[taxRate(c:Consumer,y:Year) : Price
  -> let t := c.carbonTaxes[y] in 
      (if (t > 0.0) 1000.0 * (t / perMWh(sum(list{ c.consos[y][s.index] | s in FiniteSupplier})))
       else 0.0) ]        
 
// [3] level of pain derived from cancelRate
[painFromCancel(c:Consumer,y:Year) : Percent
   -> let cr := cancelRatio(c,y), pain := get(pb.earth.painCancel,cr) in
        (//[SHOW5] --- pain from cancel for ~S is ~F% from cancel ratio ~F% // c, pain, cr,
          (pain * (1 - c.redistribution))) ]

// [3] level of pain derived from Economy resuts
// we measure the gowth of a product (GDP/p * material) and compare it to the expected growth using the
// "painGrowth" table (a meta parameter that is set by the user)
[economyScale(c:Consumer,y:Year) : float
   -> let w := pb.world, pn := get(c.population,yearF(y)), b := c.economy in
     (b.results[y] / pn) * 
          ((w.wheatOutputs[y] / w.wheatOutputs[1]) + (b.ironConsos[y] / b.ironConsos[1])) ]

[painFromResults(c:Consumer,y:Year) : Percent
   -> let w := pb.world.all,
          r1 := economyScale(c,y - 1), r2 := economyScale(c,y),
          growth := (r2 - r1) / r1 in 
        (//[SHOW5] --- pain from results for ~S is ~F% from growth ~F% // c, get(pb.earth.painGrowth,growth), growth,
         get(pb.earth.painGrowth,growth)) ]

// [7] computes the wheat crops output
Gt2km2 :: 11.6e-3    // transform m2/MWh into millionskm2/Gtep
[agroOutput(y:Year) : void
   -> let w := pb.world, e := pb.earth,
          newClean := max(0.0,pb.clean.capacities[y] - pb.clean.capacities[y - 1]),
          prevSurface := w.agroSurfaces[y - 1],
          efficiencyRatio := get(w.agroEfficiency, avgOilEquivalent(y) ) * get(w.bioHealth,e.temperatures[y - 1]) *
                             get(w.cropYield,yearF(y)) in
        (w.energySurfaces[y] := w.energySurfaces[y - 1] +  (newClean * get(w.landImpact,yearF(y)) * Gt2km2),
         w.agroSurfaces[y] := (w.agroLand - w.energySurfaces[y]) * 
                              get(w.lossLandWarming,pb.earth.co2Levels[y]),
         w.wheatOutputs[y] := w.wheatProduction * 
                              (w.agroSurfaces[y] / w.agroLand) * efficiencyRatio,
         trace(SHOW5,"[~A] ~F2 Gt wheat from ~F% surface ratio and ~F% efficiency \n",
               year!(y),w.wheatOutputs[y],w.agroSurfaces[y] / w.agroLand,efficiencyRatio))]
        

// avgOilEquivalent(y) is the equivalent oil price for each energy source weighted by production
[avgOilEquivalent(y:Year) : Price
  -> let p := 0.0, o := 0.0 in
       (for s in Supplier

        (p :+ oilEquivalent(s,s.sellPrices[y]) * s.outputs[y],
            o :+ s.outputs[y]),
         p / o) ]

// computes the 3P satisfaction level of a consumer versus its objective
// (1)  Planet: versus C02 with a linear interpolation
// (2)  Profit: versus expected GPD growth (CAGR)
// (3)  People : using pain levels for economy, energy and climate
[computeSatisfaction(c:Consumer,y:Year) : Percent
  -> let strat := c.objective, 
         co2Target := pb.earth.co2Levels[1] + (strat.targetCO2 - pb.earth.co2Levels[1]) * (y / 90.0),
         cagrCO2 := ((adjustForTrade(c,y,false) / adjustForTrade(c,1,false)) ^ (1 / float!(y - 1))) - 1.0,    // negative 
         cagrEco := ((c.economy.results[y] / c.economy.results[1]) ^ (1 / float!(y - 1))) - 1.0,
         sat1 := 1.0 - max(0.0, min(1.0, (strat.targetCO2 - cagrCO2) * -10.0)), // CO2 satisfaction
         sat2 := 1.0 - max(0.0, min(1.0, (strat.targetGDP - cagrEco) * 10.0)), // Economy satisfaction
         sat3 := max(0.0, 1.0 - c.painLevels[y]),
         sat := (strat.weightCO2 * sat1 + strat.weightEconomy * sat2 + strat.weightPeople * sat3) in
        (//[SHOW5] --- satisfaction for ~S is ~F% // c, sat,
         trace(2,"[~A] ~S:~S ~F1T*, ~F1Gt -> = ~F1T*, ~F1Gt\n",year!(y),c,c.objective,
                c.economy.results[1],adjustForTrade(c,1,false),c.economy.results[y],adjustForTrade(c,y,false)),
         trace(2,"satisfaction(~S) = ~F% from (~F%:~F3 %CADR,~F%:~F3 %CAGR,~F%:~F%pain)\n", c,sat,
               sat1,100.0 * cagrCO2,sat2,100.0 * cagrEco,sat3,c.painLevels[y]),
         sat) ]

// CCEMv7: Adjusted For Trade emissions
[adjustForTrade(c:Consumer,y:Year,talk?:boolean) : float
  -> let x := c.co2Emissions[y] in
       (// add exports
        for z in (Consumer but c)
          (if talk? //[0] ~S -> ~S: add ~F3 (~F3 kg/kWh) // z,c,z.co2Emissions[y] * importTradeFraction(c.economy,z.economy,y),(z.co2Emissions[y] / z.economy.results[y]),
           x :+  z.co2Emissions[y] * importTradeFraction(c.economy,z.economy,y)),
        // remove exports
        for z in (Consumer but c)
          (x :- c.co2Emissions[y] * importTradeFraction(z.economy,c.economy,y)),
        if talk? //[0] [~A] ~S adjusted for trade emissions: ~F3 -> ~F3 // year!(y),c,c.co2Emissions[y],x,
        x)]

// adjusted imports from w2 to w, as a fraction of w2 gdp
// first term is import (w2 -> w) , second term is protectionism reduction factor
[importTradeFraction(w:Block, w2:Block,y:Year) : Percent
  -> pb.trade[index(w2 as Block)][index(w)] * (1.0 + importReductionRatio(w,w2,y))]

// simple estimate : CO2 density of GDP
[co2Density(c:Consumer,y:Year) : Price
  -> let e := c.economy, 
         co2 := c.co2Emissions[y], 
         gdp := e.results[y] in
       (if (gdp > 0.0) (1000.0 * co2 / gdp) else 0.0) ]

// CCEM v7: Adaptation
// adaptationLevel is read from the investment levels that defines the "insurance" protection
// the driver is the ratio (adaptation spending / dommage+3)
[computeAdaptation(y:Year) : void
   ->  for c in Consumer
        (if (c.adapt.levels[y - 1] < c.adapt.efficiency.maxValue)   // adaptation still has benefits
            c.adapt.spends[y] := c.economy.investGrowth[y] * c.adapt.investFactor,    // adaptation spending as a fraction of investments
     	   c.adapt.sums[y] := c.adapt.sums[y - 1]+ c.adapt.spends[y],                                // cummulative
         let dommage := c.economy.results[y] * get(c.disasterLoss,3.0),
             investRatio := c.adapt.sums[y] / dommage in 
           (//[5] [~A] adaptation ~F2T$ > ~F2T$ for ~S -> ~F% of dommage ~F2 // year!(y),c.adapt.spends[y],c.adapt.sums[y],c,investRatio,dommage,
            c.adapt.levels[y] := get(c.adapt.efficiency,investRatio))) ]


// ********************************************************************
// *    Part 6: Run-time model checking                               *
// ********************************************************************

// debug: explain the reasonning
[showOutput(x:Supplier,y:Year,cMax:Energy,p:Price) : void
  -> let cProd := x.production * min(1.0, (cMax / x.capacityMax)),  // projected output considering capacity
         pRatio := p / x.price in              // relative price vs last year
     printf("[~A] output(~S)@~F2=~F2 {max:~F2, projected:~F2} (pratio: ~F% => ~F% & ~F%)\n",
            year!(y),x,p,getOutput(x,p,cMax,y),cMax,cProd,pRatio,
            pRatio * (2 - x.sensitivity), (1 + (pRatio - 1) * x.sensitivity))]

// shortcut is not diet
// [showOutput(x:Supplier,p:Price) : void
// -> showOutput(x,pb.year,x.capacities[pb.year],p) ]

// debug: explain the reasonning for max capacity (finite case)
[showMaxCapacity(x:FiniteSupplier,y:Year,cMax:Energy,p:Price) : void
  -> let prev := prevMaxCapacity(x,y),
         I1 := x.inventories[y - 1],                   // inventory with that price, minus gone
         rProd := prodGrowth(x,prev,y),          // what growth should be
         rGrowth := max(0.0, min(rProd, x.capacityGrowth)),
         c := inventoryToMaxCapacity(x,prev * (1.0 + rGrowth),I1) in
   (printf("[~A] >>> inventory(~S) = ~F2 = ~F2(~F2$) - ~F2 (gone)\n",year!(y),x,I1,get(x.inventory,p),p,x.gone),
    printf("[~A] >>> max capacity(~S@~F2)=~F2->(prev:~F2) (inventory ratio: ~F% & rProd = ~F% => rGrowth=~F%) Gtep {was:~F2}\n",
            year!(y),x,p,c,prev,(I1 / x.threshold), rProd, rGrowth,x.capacities[y - 1])) ]


[showMaxCapacity(x:InfiniteSupplier,y:Year,cMax:Energy,p:Price) : void
  -> let  prev := prevMaxCapacity(x,y) - x.additions[y - 1],   // we want to apply maxDelta to all
          maxDelta := maxYearlyAdditions(x,y),       // how huch capacity can be added this year
          rProd := prodGrowth(x,prev,y),          // what growth should be
          growth := max(0.0, min(rProd * prev, maxDelta)) in  // cap growth follows conso but is bounded 
         printf("[~A] >>> max capacity(~S@~F2)=~F2  (rProd=~F%,maxD=~F2 => growth=~F2) Gtep {was:~F2}\n",
            year!(y),x,p,prev + growth, rProd, maxDelta, growth, prev) ]

// Dynamic Balance checks for M4 
// debug function: show the energy balance of a consumer (need -> conso + cancel)
// we keep it for the time being to avoid new bugs ...
// V7 note: savings are not checked since they are removed from needs (eSavings and savings)
[checkBalance(c:Consumer,y:Year) : void
  -> let c1 := sumNeeds(c,y),
         c2 := sumConsos(c,y),
         c3 := sumCancels(c,y),
         csum := c2 + c3 in
       (//[5] checkBalance(~S) -> ~F% (need:~F2,cconso:~F2)// c,abs((c1 - csum) / csum),c1,csum,
        if (abs((c1 - csum) / csum) > 1%) // debug: was 1%)
         (trace(0,"[~S] BALANCE(~S): need ~F2 vs ~F2 {~F%} (consos:~F%, cancels:~F%)\n",
                 year!(y),c,c1, csum,abs((c1 - csum) / csum),c2 / csum,c3 / csum),
          for s in Supplier checkBalance(c,s,y))) ]

// sensitivity - Delta price / delta Volume (ratios)
[showSensitivity(s:Supplier,y:Year) : void
  -> let p0 := s.sellPrices[y], p1 := p0 * 105%,
         v0 := getOutput(s,p0,y), v1 := getOutput(s,p1,y),
         d0 := totalDemand(y,s,p0), d1 := totalDemand(y,s,p1) in
       (printf("[~A] Supply sensitivity(~S)@~F2: ~F% production ~F2TWh \n", 
               year!(y),s,p0,((v1 - v0) / v0) / ((p1 - p0) / p0),v0),
        printf("[~A] Demand sensitivity(~S)@~F2: ~F% demand ~F2TWh \n", 
               year!(y),s,p0,((d1 - d0) / d0) / ((p1 - p0) / p0),d0))]

// four utilities
[sumNeeds(c:Consumer,y:Year) : float 
   -> sum(c.needs[y])]

[sumConsos(c:Consumer,y:Year) : float 
   -> sum(c.consos[y])]

[sumCancels(c:Consumer,y:Year) : Energy
  -> sum(list{ (c.needs[y][s.index] * c.cancel%[y][s.index]) | s in Supplier}) ]


// more precise debug function: balance for a consumer and a supplier
[checkBalance(c:Consumer,s:Supplier,y:Year) : void
  -> let c1 := c.needs[y][s.index],
         c2 := c.consos[y][s.index],
         c3 := c.needs[y][s.index] * c.cancel%[y][s.index],
         csum := c2 + c3 in
       (trace(SHOW4,"[~S] --- BALANCE(~S,~S): need ~F2 vs ~F2 (consos:~F%, cancels:~F%)\n",
             year!(y),c,s,c1, csum,c2 / csum,c3 / csum)) ]

// checks that transfers are consistent (delta capacities versus current levels of transfers)
[checkTransfers(s:Supplier,y:Year) : void
   -> s.addedCapacities[y] := s.addedCapacity,      // book keeping for debug (this log slot could be removed later)
      let delta1 := s.addedCapacity - s.addedCapacities[y - 1],
          delta2 := 0.0 in
        (for tr in pb.transitions
           (if (tr.to = s)
              for c in Consumer
                (if (s = TESTE) 
                   trace(5,"check ~S transfer ~F3 PWh from ~S to ~S\n",c, transferAmount(tr,c,y),tr.from,tr.to),
                 delta2 :+ transferAmount(tr,c,y))),
         if ((abs(delta2 - delta1) / s.addedCapacity) >= 0.1%)
             trace(0,"[~S] ---- TRANSFERS @ ~S: delta1 = ~F2 (~F3 - ~F3) vs delta2 = ~F2\n", year!(y),
                     s,delta1,s.addedCapacity,s.addedCapacities[y - 1],delta2)) ]
        
// additional transfer amounts for a transition
[transferAmount(tr:Transition,c:Consumer,y:Year) : Energy
  -> c.transferFlows[y][tr.index] ]


// call when there is a market model error and no equilibrium can be found
[marketModelError(s:Supplier,y:Year) : void
  ->  //[0] ********************** IMPOSSIBLE TO SOLVE MARKET EQUATION [~S] ********************** // s,
      pb.prodCurve := list<Price>{ getOutput(s,pb.priceRange[i],y) | i in (1 .. NIS)},
      pb.needCurve := list<Price>{ totalDemand(y,s,pb.priceRange[i]) | i in (1 .. NIS)},
      // lookNeed(s),    // debug option
      printf("prod Curve is ~S\n",pb.prodCurve),
      printf("need Curve is ~S\n",pb.needCurve),
      error("stop error with solve(~S)",s) ]


