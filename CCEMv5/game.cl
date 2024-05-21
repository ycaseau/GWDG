// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
// *       file: game.cl                                              *
// ********************************************************************

// this file contains the five CCEM sub-models that determine interaction
// between players as well as the overall simulation engine 
// this code is shared under GWDG github (CCEM = Coupling Coarse Earth Models)

// ********************************************************************
// *    Part 1: Production model M1                                   *
// *    Part 2: Consumption model M2                                  *
// *    Part 3: Substitution model M3                                 *
// *    Part 4: Economy model M4                                      *
// *    Part 4: Ecology Redirection model M5                          *
// ********************************************************************

TESTE:any :: unknown    // debug variable : focus on Energy supplier TESTE
TESTC:any :: unknown    // debug variable : focus on Consumer TESTC

// ********************************************************************
// *    Part 1: Production model M1                                   *
// ********************************************************************

SHOW1:integer :: 5        // verbosity for model M1

// compute what the output for x:Supplier would be at price p
// OCCAM version -> we do not model the price strategy (lower to increase revenue), nor do model 
// really simple version : linear bounded by Cmax
//    linear -> p = x.price (origin) ->  p.production (origin)   &   x.sensitivity
//    capped by cMax (see below, given as a parameter)
[getOutput(s:FiniteSupplier,p:Price,cMax:Energy,y:Year) : float
  -> let cProd := s.production * min(1.0, (cMax / s.capacityMax)),  // projected output considering capacity 
         pRatio := p / s.price,                                     // relative price vs p0
         f1 := min(cMax, max(0.0, cProd * (1 + (pRatio - 1) * s.sensitivity))) in     // linear formula
        f1]     

// CCEM 4 : formula is different for clean energy : supplier needs to sell all it can produce
// but expects a price that is proportional to the GDP (in a world of energy abundance) - modulo sensitivity
// note : in a world of restriction, price is driven by cancellation
[getOutput(s:InfiniteSupplier,p:Price,cMax:Energy,y:Year) : float
  -> let cProd := s.production, p0 := s.price,
         w := pb.world.all, 
         p1 := p0 * (1 + ((w.results[y - 1] / w.results[1]) - 1.0) * s.sensitivity),  // price is proportional to GDP
         pRatio := p / p1,                                    // relative price vs p0
         f1 := min(cMax, pRatio * (cMax / s.horizonFactor))  in     // linear formula
        f1]

// debug: explain the reasonning
[showOutput(x:Supplier,y:Year,p:Price) : void
  -> let cMax := capacity(x,y,prev3Price(x,y)),         // max capacity for that price
         cProd := x.production * min(1.0, (cMax / x.capacityMax)),  // projected output considering capacity
         pRatio := p / x.price in              // relative price vs last year
     printf("[~A] output(~S)@~F2=~F2 {max:~F2, projected:~F2} (pratio: ~F%)\n",
            year!(y),x,p,getOutput(x,p,cMax,y),cMax,cProd,pRatio) ]

// previous price
[prevPrice(x:Supplier,y:Year) : Price
   -> x.sellPrices[y - 1]]

// previous price, average over 3 years
[prev3Price(x:Supplier,y:Year) : Price
   -> if (y = 2) x.price 
      else if (y = 3) (x.sellPrices[y - 1] + 2 * x.price) / 3.0
      else (4 * x.sellPrices[y - 1] + x.sellPrices[y - 2] - 2 * x.sellPrices[y - 3]) / 3.0 ]

// previous max capacity (includes additions from transfers)
[prevMaxCapacity(x:Supplier,y:Year) : Energy
   -> x.capacities[y - 1] + x.addedCapacities[y - 1]]

// current max capacity should be proportional to inventory modulo the growth constraints
// we also take into account the quantity that was added through substitutions (cf. PrevMax uses additions)
// p is the average price of the last 3 years -> sets available inventory

// regular version for fossile energies : tries to match the evolution of demand
// capacity is adjusted when the inventory is below the threshold level
[capacity(x:FiniteSupplier,y:Year,p:Price) : Energy   
   -> let prev := prevMaxCapacity(x,y),
          I1 := get(x.inventory,p) - x.gone,      // inventory with that price, minus gone
          I0 := x.threshold,                      // threshold inventory : I1 < I0 => reduce capacity proportionally
          rProd := prodGrowth(x,prev,y),          // what growth should be
          rGrowth := max(0.0, min(rProd, x.capacityGrowth)) in         // capacity growth follows conso but is bounded 
        min(prev * (1.0 + rGrowth),  x.capacityMax * (I1 / I0)) ]
   
// this is a heuristic that needs to get adjusted, it says that the maxcapacity should be X% (110)
// of the net demand that was seen (net = needs - savings & cancel) averaged over past 3 years
[prodGrowth(x:Supplier, prev:Energy, y:Year) : Energy
  ->  if (y <= 3) 5%  // first 3 years, we assume a 5% growth 
      else let s := (4 * x.netNeeds[y - 1] +  x.netNeeds[y - 2] - 2 * x.netNeeds[y - 2]) / 3.0 in
          (if (x = TESTE)
            printf("[~A] >>> prev(~S)=~F2, 3 years is ~F2 Gtoe from ~A\n",year!(y),x,prev,s, 
                    list{x.netNeeds[i] | i in (max(2,y - 3) .. y - 1)}),
          ((s / prev) * x.horizonFactor - 1.0)) ]

// new version for clean energies -> growthPotential tells how much we could add
// capacity tries to match 110% of net demand (this should become a parameter, hard coded in test1.cl) 
[capacity(x:InfiniteSupplier,y:Year,p:Price) : Energy   
   -> let prev := prevMaxCapacity(x,y),
          maxDelta := get(x.growthPotential,yearF(y)),        // how huch capacity can be added for this average price
          expected := prodGrowth(x,prev,y),            // what growth should be (fraction of prev)
          growth := max(0.0, min(expected  * prev, maxDelta)) in  // cap growth follows conso but is bounded 
        (prev + growth)] 


// debug: explain the reasonning for max capacity (finite case)
[showMaxCapacity(x:FiniteSupplier,y:Year,p:Price) : void
  -> let prev := prevMaxCapacity(x,y),
         I1 := get(x.inventory,p) - x.gone,      // inventory with that price, minus gone
         I0 := get(x.inventory,0.0),
         rProd := prodGrowth(x,prev,y),          // what growth should be
         rGrowth := max(0.0, min(rProd, x.capacityGrowth)),
         c := min(prev * (1.0 + rGrowth), x.capacityMax * (I1 / I0)) in
   (printf("[~A] >>> max capacity(~S@~F2)=~F2 (inventory ratio: ~F% & rProd = ~F% => rGrowth=~F%) Gtep {was:~F2}\n",
            year!(y),x,p,c,(I1 / I0), rProd, rGrowth,prev)) ]

[showMaxCapacity(x:InfiniteSupplier,y:Year,p:Price) : void
  -> let  prev := prevMaxCapacity(x,y),
          maxDelta := get(x.growthPotential,yearF(y)) ,        // how huch capacity can be added for this average price
          rProd := prodGrowth(x,prev,y),          // what growth should be
          growth := max(0.0, min(rProd * prev, maxDelta)) in  // cap growth follows conso but is bounded 
         printf("[~A] >>> max capacity(~S@~F2)=~F2  (rProd=~F%,maxD=~F2 => growth=~F2) Gtep {was:~F2}\n",
            year!(y),x,p,prev + growth, rProd, maxDelta, growth, prev) ]

// The second step is to maximize the utility function over a price range from 0 to X, (that is
// with a capacity that does not increase more than 15%
[getProd(s:Supplier,y:Year) : void
  -> let cMax := capacity(s,y,prev3Price(s,y)) in             // max capacity for this year, based on 3 prev average
        (s.capacities[y] := cMax - s.addedCapacities[y - 1],        // capacity can go down (fields that are not productive are closed)
         if (s = TESTE) 
           (printf("[~A] compute prod(~S) cmax=~F2 @price:~F2)\n",year!(y),s,cMax,prev3Price(s,y)),
            showMaxCapacity(s,y,prev3Price(s,y)),
            showOutput(s,y,prev3Price(s,y))),
         for p in (1 .. NIS)
           pb.prodCurve[p] := getOutput(s,pb.priceRange[p],cMax,y)) ]


// (CCEM doc, Oct 2022) There are two key aspects which are missing:
// - Strategy of the resource owner to speculate on current price versus expected value (versus the naïve linear output model)
// - Time delay between decision to extract a new resource and actual operation is long 
//    (over 10 years) versus the current capacity model that looks 3 years back

// ********************************************************************
// *    Part 2: Consumption model M2                                  *
// ********************************************************************

SHOW2:integer :: 5       // verbosity for model M2

// computes the need - Step 1
// two ways: (a) direct application of economy/status
//           (b) memory: "dampening factor"
// note the "need" does not take savings into account since they'll be added
// Note: pop  growth comes from Emerging countries => mostly linear (KISS)
// GW4: the need are now localized (c.population & c.gdp)
[getNeed(c:Consumer,y:Year) : void
  -> let b := c.economy,
         c0 := sum(c.startNeeds),
         dmr := 1 - get(b.dematerialize,yearF(y)),
         c2 := c0 * dmr * globalEconomyRatio(b,y) *  populationRatio(b,y) * (1.0 - b.disasterRatios[y - 1]) in   
      (//[SHOW2] === needs(~S) = ~F2 PWh vs ~F2 (gdp:~F%,pop:~F%) // c,c2,c0,globalEconomyRatio(b,y),populationRatio(b,y),
       //[SHOW2] [~A] computes ~S needs: ~F3 -> ~F2 (~F%) demat:~F% // year!(y),c,c0,c2,(c2 / c0),dmr,
       if (TESTC = c) printf("[~S] ~S needs = ~F2 (economy ~F%, export ~F%, import ~F%)\n",
                             year!(y),c,c2,globalEconomyRatio(b,y),exportReductionRatio(b,y),importReductionRatio(b,y)),
       if (TESTE != unknown) printf("--- ~S needs(~S) = ~F2\n",c,TESTE,c2 * ratio(c,TESTE)),
       c.needs[y] := list<Energy>{ (c2 * ratio(c,s)) | s in Supplier},
       if (y > 1)   // execute transfers from subsitution capabilities setup at year y - 1
          for tr in pb.transitions transferNeed(c,y,tr,transferRate(  c,tr,y - 1) * c.needs[y][tr.from.index])) ]

// GW4 : the economy dependency (gdp -> Gtoe) is made of local and export influence
// this is a multiplicative factor (applied to inital state)
[economyRatio(w:Block,y:Year) : Percent
   -> if (y = 2) 1.02 
      else (newMaxout(w,y) / w.gdp)]

// local influence is GDP weighted by inner zone trade
[localEconomyRatio(w:Block,y:Year) : Percent
  -> economyRatio(w,y) * innerTrade(w)]
  
// export influence from other block to which w is exporting (assuming w does not protect its frontiers)  
// v5: changed economyRatio to w (the health of the importing economy)
// cf comments in log.cl this is a differential equation, what is returned is (1 + dx/x) 
//          dE/E = dLocal/Local x (Local/E = innerTrade) + dExport/Export x (Export/E) + dImport/Import x (Import / E)
[globalEconomyRatio(w:Block,y:Year) : Percent
  -> localEconomyRatio(w,y) + outerCommerceRatio(w,y) + importReductionRatio(w,y) ]

// returns the weighted sum of growth that is associated to exports (from x to other w2 that are growing, modulo trade barriers )
[outerCommerceRatio(w:Block,y:Year) : Percent
  -> sum(list<Percent>{ (economyRatio(w2,y) * pb.trade[index(w)][index(w2 as Block)] *          // from w to w2
                           (1.0 + exportReductionRatio(w,w2,y))) |
                        w2 in (Block but w)}) ]

// previous methods the total outerCommerce = growth (1 - exportReductionRatio)
// this methods returns only the export reduction
[exportReductionRatio(w:Block,y:Year) : Percent
  -> sum(list<Percent>{ (economyRatio(w2,y) * pb.trade[index(w)][index(w2 as Block)] *      // w to w2 
                               exportReductionRatio(w,w2,y)) | 
                         w2 in (Block but w)}) ]                                           

// reduction of exportation factor (w -> w2) because of w2 CBAM - always negative
[exportReductionRatio(w:Block, w2:Block,y:Year) : Percent
  -> min(0.0, (w2.openTrade[index(w as Block)] - 1.0) *  pb.world.protectionismOutFactor) ]

// opposite situation : w is impacted by imports from w2, because of its own barrier or because w2 is doing poorly
[importReductionRatio(w:Block,y:Year) : Percent
  -> sum(list<Percent>{ (importTradeRatio(w,w2,y) * importReductionRatio(w,w2,y)) | 
                         w2 in (Block but w)}) ]

// trade from w2 -> w expressed as a fraction of w gdp (hence the 3rd term)
[importTradeRatio(w:Block, w2:Block,y:Year) : Percent 
  -> economyRatio(w,y) * pb.trade[index(w2 as Block)][index(w)] * (w2.gdp / w.gdp)]

// reduction of importation factor (w2 -> w:import): this is a negative correction when openTrade is less than 1.0
[importReductionRatio(w:Block, w2:Block,y:Year) : Percent
  -> min(0.0, (w.openTrade[index(w2 as Block)] - 1.0) *  pb.world.protectionismInFactor) ]

// book keeping
[tradeImportFactors(w:Block, y:Year) : list<Percent>
  -> list<Percent>{ w.openTrade[index(w2 as Block)] | w2 in (Block but w) } ]
                        
[index(w:Block) : integer 
  -> w.describes.index]

// new in GWDG : integrate a CBAM factor - reduction of trade   

// the second term is, as before, based on  growth
[populationRatio(b:Block,y:Year) : Percent
  -> let  c := b.describes,p0 := get(c.population,yearF(1)), pn := get(c.population,yearF(y)) in
       (1 + c.popEnergy * (pn - p0) / p0)]

 // differential : one year versus the previous one
 // in CCEM v5, we take into account the effect of pain
[populationGrowth(w:Block,y:Year) : Percent
  -> (populationRatio(w,y) / populationRatio(w,y - 1)) *
    (if (y = 2) 1.0 
     else let c := w.describes in (productivityLoss(c,y - 1) / productivityLoss(c,y - 2))) ]

// the loss of productivity is a linear function of the pain level
[productivityLoss(c:Consumer,y:Year) : Percent
  -> let p := c.painLevels[y] in (1.0 - p * c.productivityFactor)]
     
// tricky: assign energy needs proportionally ... then add substitution flows 
[ratio(c:Consumer,s:Supplier) : Percent
  -> let i := s.index in  (c.consumes[i] / sum(c.consumes)) ]

// transfer some energy need from one supplier to the next
[transferNeed(c:Consumer,y:Year,tr:Transition,q:Energy) : void  
  -> if (tr.from = TESTE) trace(0,">>>> Need transfer of ~F2Gtoe for ~S from ~S to ~S\n",q,c,tr.from,tr.to),
     c.needs[y][tr.from.index] :- q,
     c.needs[y][tr.to.index] :+ q] 

// computes the need - Step 2 - for one precise supplier
// (a) relative needs for + current Carbon tax (the carbon shifts the demand curve)
// (b) record the qty that would be bought for a list of price
[getNeed(c:Consumer,s:Supplier,y:Year) : void
  -> let t := tax(c,s,y) in    
       (//[5] tax(~S, ~S) = ~A // c,s,t,
        for p in (1 .. NIS)
          pb.needCurve[p] :+ howMuch(c,s,oilEquivalent(s,pb.priceRange[p] + t))) ]

// carbon tax is based on co2 level reached the previous year
// in GW3, we add the acceleration pushed by societal reaction
// this returns a price in $ for 1 PWh (co2Factor adjusted)
CinCO2 :: (12.0 / 44.0)  // one C for 2 O
[tax(c:Consumer,s:Supplier,y:Year) : Price
  -> (if (y <= 2) 0.0
      else (get(c.carbonTax,pb.earth.co2Levels[y - 1]) + c.taxAcceleration) * s.co2Factor * CinCO2) ]

// this is what the consumer will pay 
[truePrice(c:Consumer,s:Supplier,y:Year) : Price
    -> s.sellPrices[y] + tax(c,s,y) ]

// when we compute cancellation or savings, all threshold are defined with oilPrice
// this is a normalized (equivalent of oil, adjusted for price increase)
[oilEquivalent(s:Supplier,p:Price) : Price
  -> p * pb.oil.price / s.price]  

// this is where we apply the different s-curves to find what the actual consumption is at a given price
// notice that savings does not depend on the dynamic price and that transfer were managed in the need
HOW:integer :: 5
[howMuch(c:Consumer,s:Supplier,p:Price) : Energy
  -> let cneed := c.needs[pb.year][s.index], x1 := getCancel(c,s,p), x2 := prevSaving(c,s), 
         x := max(0.0,1.0 - (x1 + x2)) in
         (//[HOW] ~S consumes ~S = ~S * (1 - ~F3/~F3) price ~F3 (x:~S)// c,cneed * x,cneed,x1,x2,p,x,
          cneed * x) ]

// we got rid the "CancelThreat" in version 0.2 to KISS
// on the other hand, we had a supplier-sensitive factor to model (for coal !) => mimick price stability which we observe
// GW3: added the cancelAcceleration produced by M5 bu
[getCancel(c:Consumer,s:Supplier,p:Price) : Percent
  -> get(c.cancel,p) * (1.0 + (case s (FiniteSupplier c.cancelAcceleration, any 0.0))) ]

// savings level at the moment for s  (based on savings level of past year)
// note that actual saving is monotonic because we invest and keep saving at the level from the past
[prevSaving(c:Consumer,s:Supplier) : Percent
  -> let y := pb.year in c.savings[y - 1][s.index]]

// reads the current transferRate
[transferRate(c:Consumer,tr:Transition,y:Year) : Percent
  -> (if (y = 0) 0.0 else c.transferRates[y][tr.index]) ]

// each production has a price (Invest = capacity increase / 20)
// we distribute the energy investment across the blocs using energy consumption as a ratio
// note: we call this once consomations are known
[recordCapacity(s:Supplier,y:Year) : void
   -> let p1 := s.sellPrices[y], p2 := prev3Price(s,y),
          addCapacity := max(0.0,s.capacities[y] - prevMaxCapacity(s,y))  in
        (if (s = TESTE) printf(">>>>> ~I",showOutput(s,y,p1)),
         (case s (FiniteSupplier s.inventories[y] := get(s.inventory,p2) - s.gone)),
         //[DEBUG] add ~S capacity: +~F2 -> ~F2T$ // s,addCapacity,addCapacity * s.investPrice,
         let addInvest := addCapacity * s.investPrice in
           for b in Block
             b.investEnergy[y] :+ addInvest * shareOfConsumption(s,b,y))]

// share of energy consumption for a block
// we use the previous year to get the ratio (consumption is not known yet)
[shareOfConsumption(s:Supplier,b:Block,y:Year) : Percent
  -> b.describes.consos[y - 1][s.index] / sum(list{b2.describes.consos[y - 1][s.index] | b2 in Block}) ]


// our cute "solve" - find the intersection of the two curves
// find the price that
//  (1) minimize the distance between the two curves
//  (2) if there are ties : pick the highest price ! ( maximize the profits of the seller)
// three cases:
//  (a) there is an intersection -> find the price
//  (b) production is much higher -> satisfy the demand at lowest price
//  (c) production is too small -> prices should go higher
// currently: raise an error in case (c)
[solve(p:Problem, s:Supplier) : Price
   -> let v0 := 1e10, p0 := 0.0, i0 := 1 in
        (for i in (1 .. NIS)
           let x := pb.priceRange[i],
               v := p.prodCurve[i] - p.needCurve[i] in
              (p.debugCurve[i] := v,
               assert(p.prodCurve[i] >= 0.0),
               assert(p.needCurve[i] >= 0.0),
               if (v > 0.0 & v < v0) (v0 := v, p0 := x, i0 := i)),
        //[SHOW2] solve(~S) -> price = ~A : delta = ~F2, qty = ~F2  // s, p0,v0,p.prodCurve[i0],
        if (s = TESTE) 
           (printf("*** total demand for ~S is ~F2  => ~S\n", s, sum(list{c.needs[pb.year][s.index] | c in Consumer}),list{list(c,howMuch(c,s,p0)) | c in Consumer}),
            printf("solve(~S) -> price=~A : delta=~F2, qty=~F2, need= ~F2, tax=~F2\n",s, p0,v0,p.prodCurve[i0],p.needCurve[i0],avgTax(s,pb.year)),
            for c in Consumer 
                 printf("Cancel/save(~S) = ~F%/~F%; ",
                         c,getCancel(c,s,oilEquivalent(s,p0) + avgTax(s,pb.year)),prevSaving(c,s)),
            printf("@ oil=~F2\n",oilEquivalent(s,p0) + avgTax(s,pb.year))),
        if (p0 = 0.0) 
            (//[0] ********************** IMPOSSIBLE TO SOLVE MARKET EQUATION [~S] ********************** // s,
             // lookProd(s),    // debug option
             // lookNeed(s),    // debug option
             printf("prod Curve is ~S\n",p.prodCurve),
             printf("need Curve is ~S\n",p.needCurve),
             error("stop error with solve(~S)",s)),
        p0) ]

// balance production and consumption
// production is defined by price / consumption is allocated to each consumer proportionnally 
// to reach a perfect prod/conso balance
[balanceEnergy(s:Supplier,y:Year) : void 
  -> let production := getOutput(s,s.sellPrices[y], capacity(s,y,prev3Price(s,y)),y),   // s production for this year at price p
         listConsos := list<Price>{ howMuch(c,s,truePrice(c,s,y)) | c in Consumer},
         total := sum(listConsos) in
        (//[DEBUG] [~A] BALANCE(~S) produces ~F2 Gtep @ ~F2 T$ versus consos = ~F2 // year!(y),s,production,s.sellPrices[y],total,
         //[DEBUG] --- list HowMuch: ~S // listConsos,
         for c in Consumer
            c.consos[y][s.index] := listConsos[c.index] * (production / total)) ]


// ********************************************************************
// *    Part 3: Substitution model M3                                 *
// ********************************************************************

// M3 captures the answer to 
// « How fast can we substitute one form of primary energy to another ? »

SHOW3:integer :: 5                      // verbosity for model M3

// record the actual savings and substitution - use substitution matrix
// each operation may update the Percent because of monotonicity
// cancel is deduced from the actual conso to ensure need = conson + savings + cancel
[record(c:Consumer,s:Supplier,y:Year)
  -> let i := s.index,
         cneed := c.needs[y][i] , 
         p := truePrice(c,s,y),         // equilibrium price was found with solve() in simul.cl; truePrice includes tax
         oep := oilEquivalent(s,p),     // oil equivalent price to read cancel and savings
         w1 := prevSaving(c,s),         // previous savings
         w2 := get(c.saving,yearF(y)),   // policy fraction of consumption that is saved through better efficiency
         missed := cneed * (1.0 - w1) - c.consos[y][s.index],      // consumption that is actually cancelled
         x := missed / cneed  in       // actual cancel ratio
       (//[DEBUG] DEBUG [~A] cancel(~S,~S) is ~F% (at oep = ~F2) versus~F%, savings=~F% // year!(y),c,s,x,oep,getCancel(c,s,oep),w1,
        cancels(c,s,y,missed),
        saves(c,s,y,w2),                
        // compute the transferRate for next years, based on current price, look at all transfer starting from s
        for tr in s.from updateRate(c,s,tr,y,cneed * (1.0 - (x + w1))),
        //[DEBUG] --- record qty(~S) @ ~F3 = ~F3 vs ~F3 [need = ~F3 ] // c,p,cneed * (1.0 - (x + w1)),howMuch(c,s,p),cneed,
        s.netNeeds[y] :+ cneed * (1.0 - w1),               // "real" need since savings are substitution 
        consumes(c,s,y,c.consos[y][s.index])) ]            // registers the energy consumption of c for s
                

// cancellation : registers an energy consumption cancellation
[cancels(c:Consumer,s:Supplier,y:Year,x:Energy) : void
 -> c.economy.cancels[y] :+ x,
    c.cancel%[y][s.index] := x / c.needs[y][s.index]  ]                              // record all savings
         
// consumes : register the CO2 and register the energy
[consumes(c:Consumer,s:Supplier,y:Year,x:Energy) : void
   -> if (s = TESTE) 
          trace(1,"[~A] ~S consumes ~F2 of ~S [need = ~F2 reduced-> ~F2] \n", year!(y),c,x,s,c.needs[y][s.index],howMuch(c,s,truePrice(c,s,y))),
      // c.consos[y][s.index] := x was set in balanceEnergy
      pb.earth.co2Emissions[y] :+ (x * s.co2Factor),   
      c.co2Emissions[y] :+ (x * s.co2Factor),
      if (c = TESTC)
          trace(1,"electricity(~S) = ~F2 PWhs from ~S (at ~F%) \n",c,x * eRatio(c,s),s,eRatio(c,s)),
      c.ePWhs[y] :+ x * eRatio(c,s),
      //[DEBUG] {~S} carbonTax adds ~F2 of ~S(Gt) x ~F2 (tax) = ~F2 // c,x,s,tax(c,s,y), tax(c,s,y) * x,
      c.carbonTaxes[y] :+ tax(c,s,y) * x / 1000.0, // tax in T$, energy in PWh
      c.economy.totalConsos[y] :+ x,                        // conso = true consumption
      c.economy.inputs[y] :+ x,                        // input = conso + efficiency gains (savings)
      s.gone :+ x,                                      // store consumption
      s.outputs[y] :+ x ]                               // store production


// saves a given amount of energy (always increasing) - hence we return the actual percent
// note that it would be nice to add a delay (more than a year)
// GW3: c.saving is a policy table that is assumed to be increasing
[saves(c:Consumer,s:Supplier,y:Year,w:Percent) : void
   ->  let i := s.index,
           cneed := c.needs[y][i], 
           ftech := (1 - s.techFactor) ^ float!(y),
           w1 := c.savings[y - 1][i],                   // last year's saving (as a %)
           w2 := max(w1, w) in                          // expected value = f(p) + memory (increasing)
         (//[DEBUG] [~A] ~S saves ~S% of ~S (was ~S%) --- // year!(y),c,w2,s,w1,
          c.economy.inputs[y] :+ w * cneed,                  // actual value creation
          c.savings[y][i] := w2,                              // record all savings
          //[DEBUG] ~S invest for ~S ~F1T$ to get ~F1Gtoe savings // c,s,(w2 - w1) * cneed * s.investPrice * ftech,(w2 - w1) * cneed,
          c.economy.investEnergy[y] :+                       // invest to save
             (w2 - w1) * cneed * s.investPrice * ftech * steelFactor(s,y))]

// part of the cost of new energy is linked to the cost of steel
[steelFactor(s:Supplier,y:Year) : float
   -> let pf := s.steelFactor in   // part of steel in energy production price
        (1 - pf) + pf * (pb.world.steelPrices[y - 1] / pb.world.steelPrices[1]) ]

// getTransferRate: reads the substitution matrix and multiply by c.transtionFactors[y - 1]
[getTransferRate(c:Consumer,tr:Transition,y:Year) : Percent
  -> c.transitionFactors[y - 1] * get(c.subMatrix[tr.index],yearF(y)) ]

// monotonic update of the transferRate substitute a fraction from one energy source to another
// note the monotonic behavior, we return the actual Percentage !
// in v0.3 we
[updateRate(c:Consumer,s1:Supplier,tr:Transition,y:Year,cneed:Energy) 
   -> let i := tr.index, s2 := tr.to,
          ftech := (1 - s2.techFactor) ^ float!(y),
          w1 := transferRate(c,tr,y - 1),                         // transfer last year
          w2 := max(w1, c.transitionFactors[y - 1] * getTransferRate(c,tr,y)),     // transfer expected for this year (monotonic !)
          w3 := min(w2,w1 + maxGrowthRate(s2)) in                 // modulo capacity growth constraints
         (c.substitutions[y][i] := w1 * cneed,                    // actual substitution (rate of previous year)
          c.transferRates[y][i] := w3,                                // record new transfer level (for next year)
          s2.addedCapacity :+ (w3 - w1) * cneed,                              // s2 capacity is increased ...
          s2.additions[y] :+ (w3 - w1) * cneed,                       // ... keep a history of addition for s2
          //[SHOW3] [~A] ~S transfers ~F1 PWh from ~S to ~S [matrix ->~F%] // year!(y),c,w1 * cneed,s1,s2,getTransferRate(c,tr,y),
          c.transferFlows[y][i] :+ (w3 - w1) * cneed,                  // record the flow
          c.ePWhs[y] :- (w1 * cneed) * eTransferRatio(c,s1,s2,tr.heat%),       // electricity in PWh
          c.eDeltas[y] :+ (w1 * cneed) * eTransferRatio(c,s1,s2,tr.heat%),     // for debug
          if (s2 = TESTE | c = TESTC) 
             (trace(TALK,"[~A:~F2] ~S transfer ~F2 PWh(~F%) [~F% now on -> add ~F3] of ~S to ~S [matrix ->~F%]\n",year!(y),s2.addedCapacity,
                    c,w1 * cneed,w1,w3,(w3 - w1) * cneed, s1,tr.to, getTransferRate(c,tr,y)),
              trace(SHOW3,"[~A] this generates invest of ~F1G$ for ~F1PWh\n",year!(y),
                           (w3 - w1) * cneed * s1.investPrice,
                           (w3 - w1) * cneed)),
          //[DEBUG] transfer(~S) invest ~F1T$ to get ~F1Gtoe savings// tr,(w3 - w1) * cneed * s1.investPrice * ftech,(w3 - w1) * cneed,    
          c.economy.investEnergy[y] :+                               // invest to substitute (the cost for this added capacity)
              (w3 - w1) * cneed * s1.investPrice * ftech * steelFactor(s1,y))]

// gwdg : when using the static eRatio of 2010, we make an error that we must fix
// r1: elecRate of s1, e2: elecRate of s2, h: heatRate of tr
[eTransferRatio(c:Consumer,s1:Supplier,s2:Supplier,h:Percent) : Percent
  -> let r1 := 1.0 - s1.heat%, r2 := 1.0 - s2.heat%, alpha := 1.0 - h in
       (if (c = TESTC)
           trace(5,"electricity for ~S, transfer(~S:~F%->~S:~F%) corrects rate = ~F% (alpha:~F%)\n",
                  c,s1,r1,s2,r2,(r1  - r2 * alpha),alpha), 
        (r1  - r2 * alpha)) ]


// computes the max capacity growth as a percentage
[maxGrowthRate(s:FiniteSupplier) : Percent
  -> s.capacityGrowth]          

[maxGrowthRate(s:InfiniteSupplier) : Percent
  -> get(s.growthPotential,yearF(pb.year)) / prevMaxCapacity(s,pb.year) ]


// ********************************************************************
// *    Part 4: Economy model M4                                      *
// ********************************************************************

// M4 represents the question: 
// « which GDP is produced from investment, technology, energy and workforce ? »
SHOW4:integer :: 5        // verbosity for model M4

// debug function: show the energy balance of a consumer (need -> conso + savings + cancel)
// we keep it for the time being to avoid new bugs ...
[checkBalance(c:Consumer,y:Year) : void
  -> let c1 := sumNeeds(c,y),
         c2 := sumConsos(c,y),
         c3 := sumCancels(c,y),
         c4 := sumSavings(c,y),
         csum := c2 + c3 + c4 in
       (if (abs((c1 - csum) / csum) > 1%) // debug: was 1%)
         (trace(0,"[~S] BALANCE(~S): need ~F2 vs ~F2 {~F%} (consos:~F%, cancels:~F%, savings:~F%)\n",
             year!(y),c,c1, csum,abs((c1 - csum) / csum),c2 / csum,c3 / csum, c4 / csum),
          for s in Supplier checkBalance(c,s,y))) ]


// four utilities
[sumNeeds(c:Consumer,y:Year) : float 
   -> sum(c.needs[y])]

[sumConsos(c:Consumer,y:Year) : float 
   -> sum(c.consos[y])]

[sumCancels(c:Consumer,y:Year) : Energy
  -> sum(list{ (c.needs[y][s.index] * c.cancel%[y][s.index]) | s in Supplier}) ]

[sumSavings(c:Consumer,y:Year) : Energy
  -> sum(list{ (c.needs[y][s.index] * c.savings[y][s.index]) | s in Supplier}) ]

// more precise debug function: balance for a consumer and a supplier
[checkBalance(c:Consumer,s:Supplier,y:Year) : void
  -> let c1 := c.needs[y][s.index],
         c2 := c.consos[y][s.index],
         c3 := c.needs[y][s.index] * c.cancel%[y][s.index],
         c4 := c.needs[y][s.index] * c.savings[y][s.index],
         csum := c2 + c3 + c4 in
       (trace(SHOW4,"[~S] --- BALANCE(~S,~S): need ~F2 vs ~F2 (consos:~F%, cancels:~F%, savings:~F%)\n",
             year!(y),c,s,c1, csum,c2 / csum,c3 / csum, c4 / csum)) ]

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

// this computes the maxout expected at year y based on previous year, poopulation growth and growth invest
// we use the heuristic (expected damage on GDP) that we differentiate between two years and multiply by 3 to 
// compensate the integration factor (GDP growing and disaster ratio growing, so final compound effect needs to be multiplied by 3)
[newMaxout(b:Block,y:Year) : Price
  -> (b.maxout[y - 1] * populationGrowth(b,y)  + b.investGrowth[y - 1] * get(b.roI,yearF(y))) *
       (1.0 - max(0.0,3.0 * (b.disasterRatios[y] - b.disasterRatios[y - 1])))]

// very simple economical equation of the world :)
// note : in GW3 we have one world economy, in GW4 we may separate
// (a) we take the inverst into account to comput w.maxout
// (b) we take the energy consumption cancellation into account
// (c) we take the GW distasters into account
[consumes(b:Block,y:Year) : void
  -> let e := pb.earth, 
         t := e.temperatures[y - 1],
         iv := b.investGrowth[y - 1],        // last year's invest ...
         invE := b.investEnergy[y] in        // cummulated energy investment for this year
       (b.disasterRatios[y] := max(b.disasterRatios[y - 1],
                  get(b.describes.disasterLoss,t - e.avgCentury)),        // earth factor : loss of productive capacity
        b.maxout[y] := newMaxout(b,y),               // produce this year's growth (max gdp)
        b.tradeFactors[y] := tradeImportFactors(b,y),     // import trade factor (protectionism)
        e.gdpLosses[y] :+ b.maxout[y] * b.disasterRatios[y],  // record the loss of gdp
        trace(5,"==> ~S: maxOut ratio is ~F% -> ~F2T$ (cummul expected : ~F2T$)\n",
            b, b.disasterRatios[y], b.maxout[y] * max(0.0,b.disasterRatios[y] - b.disasterRatios[y - 1]), b.maxout[y] * b.disasterRatios[y]),
        //[SHOW4] --- Growth for ~S -> ~F2T$, invest(~F2) x roi (~F2) -> +~F2T$,  // b, b.maxout[y], iv, get(b.roI,yearF(y)),iv * get(b.roI,yearF(y)),
        //[SHOW4] --- temperature is now ~F2, loss is ~F% // t,get(b.describes.disasterLoss,t - e.avgCentury),
        b.lossRatios[y] := impactFromCancel(b,y),                       // economy factor: loss of energy -> cancellation
        b.results[y] := b.maxout[y] * (1.0 - b.lossRatios[y]) * 
                        (1.0 + importReductionRatio(b,y) + exportReductionRatio(b,y)),
        if (TESTC = b.describes) printf("[~S] ~S mxout = ~F2 (ImportRatio ~F%, ExportRatio ~F%)\n",
                                        year!(y),b,b.maxout[y],importReductionRatio(b,y),exportReductionRatio(b,y)),
        let r1 := b.results[y - 1],  r2 := b.results[y], ix := 0.0 in
         (//[SHOW4] M4: ~S invest ~F% of GDP (grows from ~F2T$ to ~F2T$ = ~F%), target=~F% // b.describes, (iv / r1), r1, r2, (r2 - r1) / r2, b.iRevenue,
          ix := r2 * b.iRevenue *             // fraction of economy is gone (r1 -> r2)
                 (1.0 - b.lossRatios[y]) *    // managing the social consequence of this loss reduces the ability to invest
                 (1.0 - marginReduction(b.describes,y)),    // margin reduction -> invest reduction
          invE := max(0.0, invE - sum(list{c.carbonTaxes[y] | c in Consumer})),
          b.investGrowth[y] := (ix - invE))) ]

// GW4: fraction of the maxoutput that is used for a block (vs cancelled)
// 1.0 if no impact, 0 if 100% cancelled
// cancel rate is transformed into impact for each zone, modulo redistribution policy
[impactFromCancel(b:Block,y:Year) : Percent 
   ->  let s_energy := 0.0, s_cancel := 0.0, s_control := 0.0, c := b.describes,
           conso := sum(c.consos[y]),
           cancel := sumCancels(c,y), 
           saving := sumSavings(c,y),
           ratio := (cancel / (conso + cancel + saving)),
           ratio_with_r := (1.0 - c.redistribution) * get(c.cancelImpact,ratio) + 
                                 c.redistribution * ratio in
              (//[SHOW4] --- impact from cancel is ~F%  from ~F% (cancel ratio) // ratio_with_r, ratio,
               ratio_with_r) ]

// computes the margin impact of energy price increase, weighted avertage over energy sources
[marginReduction(c:Consumer,y:Year) : Percent
   -> let s_energy := 0.0, margin_impact := 0.0, s_price := 0.0 in
        (for s in Supplier
            let p := truePrice(c,s,y),
                oep := oilEquivalent(s,p),
                conso := c.consos[y][s.index] in
              (s_energy :+ conso,
               s_price :+ conso * oep,
               margin_impact :+ conso * get(c.marginImpact,oep)),
         let mi :=  margin_impact / s_energy in
          (//[SHOW4] --- ~S margin impact of ~F%, from energy price ~F1$ // c, mi, s_price / s_energy,
          c.economy.marginImpacts[y] := mi,
          mi)) ]


// note: the techfactor is only applied to energy, because the model does not account for other resources
// (water, metals, ...). The assumption is that adding more control loops (with duality of finite resources 
//  and recycling / savings with tech) would simply add complexity.      

// computes the cancel ratio for one zone
[cancelRatio(c:Consumer,y:Year) : Percent 
   -> let conso := c.economy.totalConsos[y],
          cancel := c.economy.cancels[y] in
        (cancel / (conso + cancel)) ]
 
// computes the steel consumption from gdp
[steelConsumption(b:Block,y:Year) : void
   -> b.ironConsos[y] := (b.results[y] / get(b.ironDriver,yearF(y))),
      trace(SHOW4,"---- steel for ~S: conso = ~F2 from output = ~F2 @ ~F2$/t \n",
            b, b.ironConsos[y], b.results[y], pb.world.steelPrices[y]) ]
       

// computes the steel price 
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

// even simpler : computes the CO2 and the temperature,
// then (M5) apply the pain to re-evaluate the reactions
[react(e:Earth,y:Year) : void
   -> let x := e.co2Levels[y - 1] in // previous CO2 level
         (e.co2Levels[y] := x + e.co2Emissions[y] * e.co2Ratio,    // simplified in model v5
          //[SHOW5] [~A] --- +C=~F2 -> co2=~F2 // year!(y),e.co2Emissions[y],e.co2Levels[y],
          e.temperatures[y] := e.avgTemp - get(e.warming,e.co2PPM) + get(e.warming,e.co2Levels[y]),
           // applies pain to each political bloc
          for c in Consumer
            let pain_energy := painFromCancel(c,y),
                pain_results := painFromResults(c,y),
                pain_warming := get(e.painClimate,get(e.warming,e.co2Levels[y])),
                pain := pain_warming + pain_energy + pain_results in // should use the painProfile factors
             (//[SHOW5] pain for ~S=~F2  ~F2(co2)+ ~F2(cancel)+ ~F2(gdp) // c,pain,get(e.painClimate,get(e.warming,e.co2Levels[y])),painFromCancel(c,y),painFromResults(c,y),
              c.painLevels[y] := pain,
              c.painEnergy[y] := pain_energy,
              c.painResults[y] := pain_results,
              c.painWarming[y] := pain_warming,
              redirection(c,y,pain)),
          computeProtectionism(y)) ]

// computes the redirection for a consumer from pain level
MAXTAX :: 5000.0
MAXTR :: 150.0     // max transition acceleration compared to best plan
[redirection(c:Consumer,y:Year,pain:Percent) : void
  ->  c.satisfactions[y] := computeSatisfaction(c,y),
      c.taxAcceleration := MAXTAX * c.taxFromPain * pain,
      c.cancelAcceleration := c.cancelFromPain * pain,
      c.transitionFactors[y] := min(MAXTR, c.transitionStart + c.transitionFromPain * pain),
      //[SHOW5] sets taxAcceleration to ~F% and cancelAccelation to ~F% // c.taxAcceleration,c.cancelAcceleration,
      c.protectionismFactor := c.protectionismStart + c.protectionismFromPain * pain ]

      
// once the "alpha" factors have been set, we compute the protectionism level ()
// note that we protect based on the difference between co2/GDP and the existance of a similar level of CO2 tax
[computeProtectionism(y:Year) : void
  -> let w := pb.world in
        (for c1 in Consumer
           let w1 := c1.economy, alpha := c1.protectionismFactor in
              (for c2:Consumer in (Consumer but c1)
                 let co2perE1 := c1.co2Emissions[y] / sum(c1.consos[y]), 
                     co2perE2 := c2.co2Emissions[y] / sum(c2.consos[y]),
                     ctax1 := taxRate(c1,y), ctax2 := taxRate(c2,y) in
                    (w1.openTrade[c2.index] := 1 - min(1.0,
                                alpha * max(0.0,(co2perE2 - co2perE1) / co2perE1) *
                                                     max(0.0,(ctax1 - ctax2) / (0.001 + ctax1))),
                     if (alpha > 0.0)
                       trace(1,"protectionism for ~S(tax:~F2) -> ~S(tax:~F2) = ~F% from co2/GDP ~F% and ~F%\n",
                             c1,ctax1,c2,ctax2,w1.openTrade[c2.index],co2perE1,co2perE2))))]

// carbon tax rate for a consumer : divide the money by the fossil fuel consumption
// return $ / Gtep
[taxRate(c:Consumer,y:Year) : Price
  -> let t := c.carbonTaxes[y] in 
      (if (t > 0.0) 1000.0 * (t / perMWh(sum(list{ c.consos[y][s.index] | s in FiniteSupplier})))
       else 0.0) ]        
 
// level of pain derived from cancelRate
[painFromCancel(c:Consumer,y:Year) : Percent
   -> let cr := cancelRatio(c,y), pain := get(pb.earth.painCancel,cr) in
        (//[SHOW5] --- pain from cancel for ~S is ~F% from cancel ratio ~F% // c, pain, cr,
          (pain * (1 - c.redistribution))) ]

// level of pain derived from cancelRate
// notes: 
//   - redistriction policy only applies to energy - because of the "one world economy" assumption
//   - we should factor in the 

[painFromResults(c:Consumer,y:Year) : Percent
   -> let w := pb.world.all,
          r1 := w.results[y - 1], 
          r2 := w.results[y],
          growth := (r2 - r1) / r1 in 
        (//[SHOW5] --- pain from results for ~S is ~F% from growth ~F% // c, get(pb.earth.painGrowth,growth), growth,
         get(pb.earth.painGrowth,growth)) ]

// computes the wheat crops output
Gt2km2 :: 11.6e-3    // trabnsform m2/MWh into millionskm2/Gtep
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

// computes the satisfaction level of a consumer versus its objective
// we estimate the 2100 value for GDP, CO2 and pain with a linear interpolation
[computeSatisfaction(c:Consumer,y:Year) : Percent
  -> let strat := c.objective, 
         gdpTarget := c.economy.results[1] * ((1.0 + strat.targetGdp) ^ float!(y - 1)),
         co2Target := pb.earth.co2Levels[1] + (strat.targetCO2 - pb.earth.co2Levels[1]) * (y / 90.0),
         painTarget := c.painLevels[1] + (strat.targetPain - c.painLevels[1]) * (y / 90.0),
         sat1 := 1.0 - (abs(c.economy.results[y] - gdpTarget) / gdpTarget),
         sat2 := 1.0 - (abs(pb.earth.co2Levels[y] - co2Target) / co2Target),
         sat3 :=  1.0 - (c.painLevels[y] - painTarget),
         sat :=  strat.weightGDP * sat1 + strat.weightCO2 * sat2 + strat.weightPain * sat3 in
        (//[SHOW5] --- satisfaction for ~S is ~F% // c, sat,
         //[5] satisfaction(~S) = ~F% from (~F%:~F1, ~F%:~F1 , ~F%:~F1) // c,sat,sat1,gdpTarget,sat2,co2Target,sat3,painTarget,
         sat) ] 
