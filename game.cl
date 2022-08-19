// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2022 Yves Caseau                        *
// *       file: game.cl                                              *
// ********************************************************************

// this file contains the four sub-models that determine interaction
// between players as well as the overall simulation engine

// ********************************************************************
// *    Part 1: Production model M1                                   *
// *    Part 2: Consumption model M2                                  *
// *    Part 3: Substitution model M3                                 *
// *    Part 4: Economy model M4                                      *
// ********************************************************************

TESTE:any :: unknown    // debug variable : focus on Energy supplier TESTE

// ********************************************************************
// *    Part 1: Production model M1                                   *
// ********************************************************************
UTI:integer :: 5

sellPrice(s:Supplier,y:Year) : Price => (if (y = 0) s.price else s.sellPrices[y])
getPNB(y:Year) : Price
   -> (if (y = 0) pb.economy.pnb else pb.economy.results[y])

// compute what the output for x:Supplier would be at price p
// OCCAM version -> we do not model the price strategy (lower to increase revenue or), nor do model 
// the "min capacity" (yield unstable price drops) and we do not take the year into account (avoid cummulated approx errors)
//   (1) step 1: compute capacity(for a price) - 
//   (2) step 2 : linear formula adjusted so that p0 -> capacity0 x varition(capacity)
//                capped between 0 and cMax   
//   (3) 80% is linear, 20% is hyperbolic
[getOutput2(x:Supplier,p:Price,cMax:Energy) : float
  -> let cProd := x.production * (cMax / x.capacityMax),     // initial production modulo capacity variation
         pRatio := p / x.price,                              // relative price vs p0
         f1 := min(cMax, max(0.0, cProd * (1 + (pRatio - 1) * x.sensitivity))),        // linear formula
         delta := 2 * (cMax - x.production),
         f2 := x.production - (delta / 2) + delta * (pRatio / (1 + pRatio)) in         // hyperbola (pratio = 1 -> production, asympt : CMax)
      (0.8 * f1 + 0.2 * f2) ]

[getOutput(x:Supplier,p:Price,cMax:Energy) : float
  -> let cProd := x.production * (cMax / x.capacityMax),     // initial production modulo capacity variation
         pRatio := p / x.price,                              // relative price vs p0
         f1 := min(cMax, max(0.0, cProd * (1 + (pRatio - 1) * x.sensitivity))) in     // linear formula
        f1]     
        
// debug: explain the reasonning
[showOutput(x:Supplier,y:Year,p:Price) : void
  -> let cMax := capacity(x,y,prev3Price(x,y)),         // max capacity for that price
         cProd := x.production * (cMax / x.capacityMax),  // projected output considering capacity
         pRatio := p / x.price in              // relative price vs last year
     printf("[~A] output(~S)@~F2=~F2 {max:~F2, projected:~F2} (pratio: ~F%)\n",
            year!(y),x,p,getOutput(x,p,cMax),cMax,cProd,pRatio) ]

// previous price
[prevPrice(x:Supplier,y:Year) : Price
   -> if (y = 1) x.price else sellPrice(x, y - 1) ]

// previous price, average over 3 years
[prev3Price(x:Supplier,y:Year) : Price
   -> if (y = 1) x.price 
      else if (y = 2) (sellPrice(x, y - 1) + 2 * x.price) / 3.0
      else if (y = 3) (sellPrice(x, y - 1) + sellPrice(x, y - 2) + x.price) / 3.0
      else (sellPrice(x, y - 1) + sellPrice(x, y - 2) + sellPrice(x, y - 3)) / 3.0 ]

// previous max capacity
[prevMaxCapacity(x:Supplier,y:Year) : Energy
   -> if (y = 1) x.capacityMax else x.capacities[y - 1] ]

// current max capacity should be proportional to inventory modulo the growth constraints
// we also take into account the quantity that was added through substitutions (x.added)
// p is the average price of the last 3 years -> sets available inventory
StepWise:float :: 3.0        // one-third of the target growth at each step (avoid oscillations)
[capacity(x:Supplier,y:Year,p:Price) : Energy
   -> let I1 := get(x.inventory,p) - x.gone,      // inventory with that price, minus gone
          I0 := get(x.inventory,0),               // inventory at t0
          rProd := (if (y <= 2) 1.0 else (x.netNeeds[y - 1] / x.outputs[y - 2])),  // what growth should be
          rGrowth := max(0.0, min((rProd - 1.0) / StepWise, x.capacityGrowth)) in         // cap growth follows conso but is bounded 
        x.added + min(prevMaxCapacity(x,y) * (1.0 + rGrowth),  x.capacityMax * (I1 / I0)) ]
   
// debug: explain the reasonning
[showMaxCapacity(x:Supplier,y:Year,p:Price) : void
  -> let I1 := get(x.inventory,p) - x.gone,      // inventory with that price, minus gone
         I0 := get(x.inventory,0),
         rProd := (if (y <= 2) 1.0 else (x.netNeeds[y - 1] / x.outputs[y - 2])),   // prev growth
         rGrowth := max(0.0, min((rProd - 1.0) / StepWise, x.capacityGrowth)),
         c := min(prevMaxCapacity(x,y) * (1.0 + rGrowth), x.capacityMax * (I1 / I0)) in
    printf("[~A] max capacity(~S@~F2)=~F2 (inventory ratio: ~F% & rProd = ~F% => rGrowth=~F%) + added:~F2 Gtep {~F2}\n",
            year!(y),x,p,c,(I1 / I0), rProd, rGrowth, x.added,prevMaxCapacity(x,y)) ]

// The second step is to maximize the utility function over a price range from 0 to X, (that is
// with a capacity that does not increase more than 15%
[getProd(x:Supplier,y:Year) : void
  -> let cMax := capacity(x,y,prev3Price(x,y)) in             // max capacity for this year, based on 3 prev average
        (x.capacities[y] := cMax,   // capacity can go down (fields that are not productive are closed)
         if (x = TESTE) 
           (printf("[~A] compute prod(~S) cmax=~F2 @price:~F2)\n",year!(y),x,cMax,prev3Price(x,y)),
            showMaxCapacity(x,y,prev3Price(x,y)),
            showOutput(x,y,prev3Price(x,y))),
         for p in (1 .. NIS)
           pb.prodCurve[p] := getOutput(x,pb.priceRange[p],cMax)) ]

// ********************************************************************
// *    Part 2: Consumption model M2                                  *
// ********************************************************************

SHOW2:integer :: 5        // verbosity for model M2


// computes the need - Step 1
// two ways: (a) direct application of economy/status
//           (b) memory: "dampening factor"
// note the "need" does not take savings into account since they'll be added
// Note: growth comes from Emerging countries => mostly linear (KISS)
[getNeed(c:Consumer,y:Year) : void
  -> let w := pb.economy,
         p0 := get(w.population,2010), pn := get(w.population,2010 + y),
         c0 := sum(c.startNeeds),
         c2 := (c0 * (if (y = 1) 1.02 else (w.maxout[y - 1] / w.pnb)) *   // pnb growth
                    (1 + c.popEnergy * (pn - p0) / p0)) in               // pop growth
      (//[SHOW2] === needs(~S) = ~F2 GTep vs ~F2 (pnb:~F%,pop:~F%) // c,c2,c0,(if (y = 1) 1.02 else (w.maxout[y - 1] / w.pnb)),(1 + c.popEnergy * (pn - p0) / p0)),
       //[TALK] [~A] computes ~S needs: ~F2 -> ~F2 (~F%) // year!(y),c,c0,c2,(c2 / c0),
       if (TESTE != unknown) printf("--- ~S needs(~S) = ~F2\n",c,TESTE,c2 * ratio(c,TESTE)),
       c.needs[y] := list<Energy>{ (c2 * ratio(c,s)) | s in Supplier},
       if (y > 1)   // execute transfers from subsitution capabilities setup at year y - 1
            (transferNeed(c,y,1,2,c.substitutions[y][1] * c.consos[y - 1][1]),
             transferNeed(c,y,1,3,c.substitutions[y][2] * c.consos[y - 1][1]),
             transferNeed(c,y,2,3,c.substitutions[y][3] * c.consos[y - 1][2])))]
  
// tricky: assign energy needs proportionally ... then add substitution flows 
[ratio(c:Consumer,s:Supplier) : Percent
  -> let i := s.index in  (c.consumes[i] / sum(c.consumes)) ]

// tranfer some energy need from one supplier to the next
[transferNeed(c:Consumer,y:Year,i1:integer,i2:integer,q:Energy) : void  
  -> c.needs[y][i1] :+ q,
     c.needs[y][i2] :- q] 

// computes the need - Step 2 - for one precise supplier
// (a) relative needs for + current Carbon tax (the carbon shifts the demand curve)
// (b) record the qty that would be bought for a list of price
[getNeed(c:Consumer,s:Supplier,y:Year) : void
  -> c.need := c.needs[y][s.index],
     let t := tax(c,s,y) in    
       (//[DEBUG] tax(~S, ~S) = ~A // c,s,t,
        for p in (1 .. NIS)
          pb.needCurve[p] :+ howMuch(c,s,oilEquivalent(s,pb.priceRange[p] + t))) ]

// carbon tax is based on co2 level reached the previous year
// in GW3, we add the acceleration pushed by societal reaction
[tax(c:Consumer,s:Supplier,y:Year) : Price
  -> (if (y <= 2) 0.0
      else (get(c.carbonTax,pb.earth.co2Levels[y - 1]) * s.co2Factor) * (1.0 + c.taxAcceleration)) ]

// this is what the consumer will pay 
[truePrice(c:Consumer,s:Supplier,y:Year) : Price
    -> sellPrice(s,y) + tax(c,s,y) ]

// when we compute cancellation, savings or subtistition, all threshold are defined with oilPrice
// this is a normalized (equivalent of oil, adjusted for price increase)
[oilEquivalent(s:Supplier,p:Price) : Price
  -> p * pb.oil.price / s.price]  

// this is where we apply the different s-curves to find what the actual consumption is at a given price
// notice that savings does not depend on the dynamic price and that transfer were managed in the need
// c.need is a temporary variable that is set at c.needs[y][s.index],
HOW:integer :: 5
[howMuch(c:Consumer,s:Supplier,p:Price) : Energy
  -> let x1 := getCancel(c,s,p), x2 := prevSaving(c,s), 
         x := max(0.0,1.0 - (x1 + x2)) in
         (//[HOW] ~S consumes ~S = ~F2 * (1 - ~F3/~F3) price ~F3 // c,c.need * x,c.need,x1,x2,p,
          c.need * x) ]

// we got rid the "CancelThreat" in version 0.2 to KISS
// on the other hand, we had a supplier-sensitive factor to model (for coal !) => mimick price stability which we observe
// GW3: added the cancelAcceleration produced by M5
[getCancel(c:Consumer,s:Supplier,p:Price) : Percent
  -> get(c.cancel,p) * s.cancelFactor * (1.0 + c.cancelAcceleration)]

// savings level at the moment for s  (based on savings level of past year)
// note that actual saving is monotonic because we invest and keep saving at the level from the past
[prevSaving(c:Consumer,s:Supplier) : Percent
  -> let y := pb.year in
       (if (y = 1) 0.0 else c.savings[y - 1][s.index])]

// reads the substitution matrix only if the price of the second is lower
// otherwise, apply a correction factor
[readMatrix(c:Consumer,s:Supplier,i2:integer,p:Price) : Percent
  -> let s2 := supplier!(i2),
         p2 := sellPrice(s2,pb.year - 1), 
         p3 := p2 * 60%  in
        (if (p > p2) get(c.subMatrix[i2],p) 
         else if (p > p3) get(c.subMatrix[i2],p) * ((p - p3) / (p2 - p3))
         else 0.0) ]


// each production has a price (Invest = capacity increase / 20)
[record(s:Supplier,y:Year) : void
   -> let p1 := s.sellPrices[y], p2 := prev3Price(s,y)  in
        (if (s = TESTE) printf(">>>>> ~I",showOutput(s,y,p1)),
         s.inventories[y] := get(s.inventory,p2) - s.gone,
         pb.economy.investEnergy[y] :+  max(0.0,s.capacities[y] - prevMaxCapacity(s,y)) * p1 / 20.0) ]


// ********************************************************************
// *    Part 3: Substitution model M3                                 *
// ********************************************************************

SHOW3:integer :: 5                      // verbosity for model M3

// record the actual savings and substitution - use substitution matrix
// each operation may update the Percent because of monotonicity
[record(c:Consumer,s:Supplier,y:Year)
  -> let i := s.index,
         p := truePrice(c,s,y),    // equilibrium price was found with solve() in simul.cl; truePrice includes tax
         x := getCancel(c,s,p),  // fraction of consumption that is gone
         w := get(c.saving,p),   // fraction of consumption that is saved through better efficiency
         z := 0.0 in    
       (cancels(c,s,y,c.need * x),
        w := saves(c,s,y,w),       // monotonicity may change w ...
        let f := (1.0 - (x + w)) in      // this is actuallu conso / need
         (// execute the three substitution flows (1 ->2, 1->3 and 2-> 3)
          if (i = 1) 
            (z := makeSubstitution(c,s,Supplier.instances[2],y,1,readMatrix(c,s,1,p) * f),    // flows of substitution
             z :+ makeSubstitution(c,s,Supplier.instances[3],y,2,readMatrix(c,s,2,p) * f))
          else if (i = 2)  z := makeSubstitution(c,s,Supplier.instances[3],y,3,readMatrix(c,s,3,p) * f),  
          //[SHOW3] --- record qty(~S) @ ~F3 = ~F3 vs ~F3 [need = ~F3 ] // c,p,c.need * (1.0 - (x + w + z * f)),howMuch(c,s,p),c.need,
          s.netNeeds[y] :+ c.need * (1.0 - (w + z * f)),              // "real" need since savings are substitution are irreversible
          consumes(c,s,y, c.need * (1.0 - (x + w + z * f))))) ]       // this energy was taken into account
        

// cancellation : registers an energy consumption cancellation
[cancels(c:Consumer,s:Supplier,y:Year,x:Energy) : void
 -> pb.economy.cancels[y] :+ x,
    c.cancels[y][s.index] := x]                              // record all savings
         
// consumes : register the CO2 and register the energy
[consumes(c:Consumer,s:Supplier,y:Year,x:Energy) : void
   -> //[SHOW3] [~A] ~S consumes ~F2 of ~S --- // year!(y),c,x,s,
      c.consos[y][s.index] := x,
      pb.earth.co2Emissions[y] :+ (x * s.co2Factor),
      c.carbonTaxes[y] :+ tax(c,s,y) * (x * s.co2Factor) / 1000.0, // tax in T$, energy in GTep
      pb.economy.consos[y] :+ x,                        // conso = true consumption
      pb.economy.inputs[y] :+ x,                        // input = conso + efficiency gains (savings)
      s.gone :+ x,                                      // store consumption
      s.additions[y] := s.added,                        // level of substitution at this time
      s.outputs[y] :+ x ]                               // store production

// saves a given amount of energy (always increasing) - hence we return the actual percent
[saves(c:Consumer,s:Supplier,y:Year,w:Percent) : Percent
   ->  let i := s.index,
           ftech := (1 - pb.economy.techFactor) ^ float!(y),
           w1 := (if (y = 1) 0.0 else c.savings[y - 1][i]),   // last year's saving (as a %)
           w2 := max(w1, w) in                                // expected value = f(p) + memory (increasing)
         (//[SHOW3] [~A] ~S saves ~S% of ~S (was ~S%) --- // year!(y),c,w2,s,w1,
          pb.economy.inputs[y] :+ w * c.need,                  // actual value creation
          c.savings[y][i] := w2,                               // record all savings
          pb.economy.investEnergy[y] :+                         // invest to save
             (w2 - w1) * c.need * s.price * s.savingFactor * ftech,
          w2)]


// substitute a fraction from one energy source to another
// note the monotonic behavior, we return the actual Percentage !
[makeSubstitution(c:Consumer,s1:Supplier,s2:Supplier,y:Year,i:integer,w:Percent) : Percent
   -> let ftech := (1 - pb.economy.techFactor) ^ float!(y),
          w1 := (if (y < 2) 0.0 else c.substitutions[y - 1][i]),      // transfer last year
          w2 := max(w1, w) in                                         // transfer for this year (monotonic !)
         (s2.added :+ (w2 - w1) * c.need,                             // adjust extra s2 capacity
          c.substitutions[y][i] := w2,                                // record transfer level
          c.needs[y][s2.index] :+ w2 * c.need,                        // actual transfer to s2
          if (s2 = TESTE) 
              trace(0,"[~A] ~S substitutes ~F2GTep:~F% of ~S to ~S (was ~F%, total ~F2Gtep) \n",
                    year!(y),c,w2 * c.need,w2,s1,s2,w1,s2.added),
          pb.economy.investEnergy[y] :+                               // invest to substitute
              (w2 - w1) * c.need * s1.price * s1.substitutionFactor * ftech,
          w)]

// ********************************************************************
// *    Part 4: Economy model M4 & M5                                 *
// ********************************************************************

SHOW4:integer :: 5        // verbosity for model M4

// very simple economical equation of the world :)
// (a) we take the inverst into account to comput w.maxout
// (b) we take the energy consumption cancellation into account
[consumes(w:Economy,y:Year) : void
  -> let x1 := (if (y = 1) w.pnb else w.maxout[y - 1]),
         iv := (if (y = 1) w.investG else w.investGrowth[y - 1]),     // last year's invest ...
         x2 := x1 + iv * w.roI,                                       // produce this year's growth (x2 = max pnb)
         invE := w.investEnergy[y] in
       (//[SHOW4] --- Growth -> ~F2T$, invest x roi -> ~F2 : +~F2,  // x2, iv, iv * w.roI,
        w.maxout[y] := x2,
        w.results[y] := x2 * cancelRatio(y),
        let r1 :=  (if (y = 1) w.pnb else w.results[y - 1]), 
            r2 := w.results[y], ix := 0.0 in
         (//[SHOW4] will compute with r1=~F2, r2=~F2, %1=~F%, %2=~F% // r1, r2, w.iRevenue, w.iGrowth,
          ix := r2 * w.iRevenue + (r2 - r1) * w.iGrowth,        // total amount of invest, from pnb and pnb acceleration
          //[TALK] --- PNB = ~F2T$, Inv=~F2 (was ~F2) IE:~F2 // r2,(ix - w.investEnergy[y]),iv,w.investEnergy[y],
          invE := max(0.0, invE - sum(list{c.carbonTaxes[y] | c in Consumer})),
          w.investGrowth[y] := (ix - invE))) ]

// faction of the maxoutput that is used (vs cancelled)
[cancelRatio(y:Year) : Percent 
   -> if (y = 0) 1.0    // this should be checked, depends on the values
      else (pb.economy.inputs[y] / (pb.economy.inputs[y] + pb.economy.cancels[y])) ]

SHOW5:integer :: 5        // verbosity for model M5

// even simpler : computes the CO2 and the temperature,
// then (M5) apply the pain to re-evaluate the reactions
[react(e:Earth,y:Year) : void
   -> let x := (if (y = 1) e.co2Total else e.co2Levels[y - 1]) in // previous CO2 level
         (e.co2Levels[y] := x + (e.co2Emissions[y] - e.co2Neutral) * e.co2Ratio,
          //[SHOW5] [~A] --- +C=~A -> co2=~A // y + 2010,e.co2Emissions[y],e.co2Levels[y],
          e.temperatures[y] := e.avgTemp + get(e.warming,e.co2Levels[y]),
           // applies pain to each political bloc
          for c in Consumer
            let pain := get(e.painClimate,e.co2Levels[y]) + painFromCancel(c,y) + painFromResults(c,y) in
             (//[SHOW5] pain for ~S is ~F2(co2) + ~F2(cancel) + ~F2(pnb) // c,get(e.painClimate,e.co2Levels[y]),painFromCancel(c,y),painFromResults(c,y),
              c.painLevels[y] := pain,
              c.taxAcceleration := c.taxFromPain * pain,
              c.cancelAcceleration := c.cancelFromPain * pain)) ]

// level of pain derived from cancelRate
[painFromCancel(c:Consumer,y:Year) : Percent
   -> let cr := cancelRatio(y), pain := get(pb.earth.painCancel,1 - cr) in
          (pain * (1 - c.redistribution)) ]

// level of pain derived from cancelRate
[painFromResults(c:Consumer,y:Year) : Percent
   -> let w := pb.economy,
          r1 :=  (if (y = 1) w.pnb else w.results[y - 1]), 
          r2 := w.results[y],
          growth := (r2 - r1) / r1 in 
        (get(pb.earth.painGrowth,growth) * (1 - c.redistribution)) ]




