// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
// *       file: gtes.cl (Game-Theoretical Evolutionary Simulation)   *
// ********************************************************************

// this file contains a simple description of the best response algorithm
// based on local optimization of the tactical parameters
//   - Energy Transition, Sobriety, CarbonTax, CloseBorders
// this code is inspired from the RTMS project (Repeated Tenders Market Share)


// *****************************************************************************
// *    Part 1: KNUcones and Randomization                                      *
// *    Part 2: Meta-framework                                                 *
// *    Part 3: local moves and Optimization                                   *
// *    Part 4: Evolutionary Search for Nash Equilibrium (TBC)                 *                                     *
// *****************************************************************************

// note: this is higher order code (not diet, which does not belong to CCEM 

// KNU = Key Known Unknowns
KNU <: thing(
    description:string,
    measured-with:string,
    onto:any,          // the object or the class of objects designated by the KNU
    modify:property,   // the property that is modified by the KNU    
    kpi:lambda)        // formula to compute a proxy of the KNU once simulation is done

// a KNUcone produces an affine function between a min and max
KNUcone <: KNU(
  median:Affine,
  lower:Affine,
  higher:Affine)

// the second type of CNU is a factor that is used to modify a value that is
// a scalar, an affine, a substitution matrix etc.
KNUfactor <: KNU(
  median:float,
  lower:float,
  higher:float)


// a belief is a list of KNU, defined by their name, and associated values (between 0 and 1) 
// a belief is either produced by a script or GW2S GUI
Belief :: list<tuple(string,float)>

// ------------------------ KNUcones and KNUfactors are defined in scenario.cl ------------------------


// three adjustments methods
[factorize(lower:float,median:float,higher:float,x:float) : float
  ->  if (x = 0.5) median
      else if (x > 0.5) median + (higher - median) * (x - 0.5) / 0.5
      else median - (median - lower) * (0.5 - x) / 0.5 ]

// apply a KNU factor to a scalar
[applyKNU(v:float,k:KNUfactor,x:float) : float
  -> v * factorize(k.lower,k.median,k.higher,x) ]

// generates an affine from a cone
[getAffine(k:KNUcone,x:float) : Affine
   -> let m1 := 1e9, M1 := -1e9, nL := k.lower.n,
         l := list<float>{factorize(k.lower.yValues[i],k.median.yValues[i],k.higher.yValues[i],x) | i in (1 .. nL)} in
       (for v in l (m1 :min v, M1 :max v),
        Affine(n = nL, minValue = m1, maxValue = M1,
               xValues = k.lower.xValues, yValues = l)) ]

// apply a KNU factor to an affine
[applyKNU(a:Affine,k:KNUfactor,x:float) : Affine
  -> let f := factorize(k.lower,k.median,k.higher,x),
         l1 := list<float>{(f  * v) | v in a.yValues} in
      Affine( n = a.n, minValue = f * a.minValue, maxValue = f * a.maxValue,
              xValues = a.xValues, yValues = l1) ]

// apply a KNU factor to a substitution matrix (list of affines)
[applyKNU(l:list<Affine>,k:KNUfactor,x:float) : list<Affine>
  -> list<Affine>{applyKNU(a,k,x) | a in l} ]   

// ------------------------ use the KNU cones to try different scenarios ------------------------

// scripts produces a Belief that is applied
// script(c, <strat>, KNU, value, *)
[script(c:Consumer,s:Strategy,l:listargs) : Belief
  -> let lb := list<tuple(string,float)>(), k := unknown in
       (c.objective := s,
        for x in l
           case x (KNU  k := x,
                   float lb :add tuple(k.description,x)),
        lb)]

// apply a belief
[runBelief(b:Belief) : void
  -> for t in b 
       let s := t[1], v := t[2] in
         when k := some(k in KNU | k.description = s) in
           case k.onto (type_expression (for x in k.onto setValue(k,x,v)),
                        any setValue(k,k.onto,v))]

// assigns a value to a CCEM object x (slot modify) based on a KNU
[setValue(k:KNUcone,x:thing,v:float) : void
  -> write(k.modify,x,getAffine(k,v)) ]

[setValue(k:KNUfactor,x:thing,v:float) : void
  -> write(k.modify,x, applyKNU(read(k.modify,x),k,v)) ]

/* This fragment of code needs to be restored to create the link with G2WS later
// runKNU(l:list<float>) : void receives the list of float values for the KNUs (from the GUI)
// test median
[testMedian()
  -> runKNU(list<float>{0.5 | i in (1 .. 8)})]

// low solar and low transition
[testFirst()
  -> runKNU(list<float>(0.0,0.5,0.1,0.5,0.5,0.5,0.5,0.5))]
*/

// show the important KNU kpi for growth / demat tuning
[showKNU()
  -> for k in KNU showKNU(k)]

// generic KNU show
[showKNU(k:KNU)
  -> printf("~A, ~A: ~F2\n",k.description,k.measured-with, funcall(k.kpi,pb))]
    
// temperature raise at year y
[deltaT(y:Year) : float
  -> let e := pb.earth in
       (e.temperatures[y] - e.avgCentury) ] 

// KNU7 : trade barrier factors
[tradeBarrier() : Percent
   -> (pb.world.all.protectionismInFactor + pb.world.all.protectionismOutFactor) / 2.0 ]

// productivity Factor: used for KNU8
[pain2productivity() : float
  -> let s := 0.0, gsum := 0.0 in
       (for b in Block
          (s :+  b.gdp * pain2productivity(b),
           gsum :+ b.gdp),
        s / gsum) ]  // average knu2 weighted by gdp

[pain2productivity(b:Block) : float
  -> b.describes.productivityFactor]

  
// *****************************************************************************
// *    Part 2: Meta-framework                                                 *
// *****************************************************************************

OPTI:integer :: 2                  // TRACE/DEBUG verbosity for the optimization engine (global)
OPTI1:integer :: 5                 // TRACE/DEBUG verbosity for the optimization moves (local)

// defines the local opt landscape and the
Optimizer <: thing(
    properties: list<property>,             // list of properties to optimize
    pairs: list<tuple(property,property)>,  // pairs of properties to optimize together
    nSteps: integer = 5,                    // number of steps in the optimization loop
    nYears: integer,                         // number of years in the simulation
    nDichotomic: integer,        // number of dichotomic steps (was NUM1)
    nSampling: integer,         // number of sampling steps 
    n2opt: integer,             // number of 2opt loops 
    d2opt: integer,             //  number of dichochotomic increments : the higher the finer the tuning
    dCount:integer = 0)          // debug counter

// in CCEM, the player is a Consumer
Player :: Consumer

// for CCEM, BR (Best Resonse) optimizes EnergyTransition, Sobriety, CarbonTax, CloseBorders
BR :: Optimizer(
    properties = list<property>(taxFromPain,cancelFromPain),
    pairs = list<tuple(property,property)>(tuple(transitionStart,transitionFromPain),
                                           tuple(protectionismStart,protectionismFromPain),
                                           tuple(adaptStart,adaptFromPain)),
    nYears = 90,
    nDichotomic = 7,
    n2opt = 100,                     // number of 2opt loops
    d2opt = 7,                       // depth of 2 opt small moves
    nSampling = 10)

// adds bounds to properties
Minimum[p:property] : Percent := 0%
Maximum[p:property] : Percent := 100%
// specific bounds
(Maximum[taxFromPain] := 50%)

// core parametric method RunLoop runs the simulation and returns the score for a given player
[runLoop(o:Optimizer, c:Player) : float
  -> reinit(),
     iterate_run(o.nYears,false),
     satScore(c) ]

// *****************************************************************************
// *    Part 2: local moves & optimization                                     *
// *****************************************************************************


// ---------------------- generic optimization engine [float flavor] -------------------------
// [this is a reusable code fragment - source: project PSR Game - 2007 ======================]


NUM1:integer :: 5                  // number of steps in a loop (1/2, 1/4, ... 1/2^5) => precision
MULTI:integer :: 2                 // number of successive optimization loops (was OPT2)


// first approach : relative steps (=> stays in the 0% .. 100% range) ----------

// optimize a given slot in a set of two dichotomic steps
[optimize(o:Optimizer,c:Player,y:Tactics,p:property)
  -> //[OPTI] optimize ~S for ~S (~F%) // p,c,c.cursat, 
     let vref := read(p,y) in                   // where to start
         ( for i in (1 .. o.nDichotomic) optimize(o,c,y,p,float!(2 ^ (i - 1)),vref)),
     //[OPTI] best ~S for ~S is ~A => ~A // p,c,read(p,y),c.cursat 
]

// variant with finer tuning 
[fineOptimize(o:Optimizer,c:Player,y:Tactics,p:property,vref:float) : void
  ->  let vref := read(p,y) in                   // where to start
         (for i in (1 .. o.nDichotomic) optimize(o,c,y,p,float!(2 ^ (i + 2)),vref)) ]

DD:integer := 0   // debug counter
DGO:integer := 0
WHY:boolean :: false   // debug

// imported version with dichotomic search the seed value is problem dependant !
// it is used twice - when the value is 0, to boost the multiplicative increment loop (opt)
//                    when the value is very small, to boost the additive loop
// NEW: use vp as the reference value to pick ties (closest to original value)
SEED:float :: 0.2

[optimize(o:Optimizer,c:Player,y:Tactics,p:property,r:float,vref:float) : void
   -> //[OPTI1] optimize inner ~S for ~S (vref = ~F2) r=~F2 // p,c,vref,r,
      let vr := c.cursat, val := 0.0, dist := 0.0,
           vp := read(p,y),v0 := (if (vref > 0.0) vref else SEED),        // v0.4 do not waste cycles
           v1 := vp  - (v0 / r), v2 := vp + (v0 / r) in
        (if (v1 >= Minimum[p]) 
          (write(p,y,v1),
           val := runLoop(o,c),
           o.dCount :+ 1,
           //[OPTI1] try ~A (vs.~A) for ~S(~S) -> ~A (vs. ~A) [DD:~A] // v1,vp,p,c,val,vr,o.dCount,
           if (val > vr | (val = vr & abs(v1 - vref) < dist))
              (vp := v1, vr := val, dist := abs(v1 - vref))),
         if (v2 <= Maximum[p])
          (write(p,y,v2),
           val := runLoop(o,c),
           //[OPTI1] try ~A for ~S(~S) -> ~A // v2,p,c,val,
           if (val > vr | (val = vr & abs(v2 - vref) < dist))
              (vp := v2, vr := val, dist := abs(v2 - vref))),
         write(p,y,vp),
         c.cursat := vr) ]


// when the landscape is irregular, we use first a sampling approach
[sampling(o:Optimizer,c:Player,y:Tactics,p:property) : void
  -> let inc := (Maximum[p] - Minimum[p]) / o.nSampling,
         bestv := read(p,y), bests := c.cursat in
        (for i in (0 .. o.nSampling)
           let v := Minimum[p] + inc * i in
             (write(p,y,v),
              let vr := runLoop(o,c) in
                (//[OPTI1] sampling ~S for ~S: ~F% -> ~F3 // p,c,v,vr,
                 if (vr > bests) (bestv := v, bests := vr))),
          write(p,y,bestv),  // pick the best value
          //[OPTI] sampling ~S ended with ~S:~F% -> ~F3 // c,p,read(p,y),bests,
          c.cursat := bests)]
                    
// optimize a pair of propertues (p1,p2) for a player x
// we apply sampling to p1 and find the best p2, then we optimize p1 
[pairOptimize(o:Optimizer,c:Player,y:Tactics,p1:property,p2:property)
  ->  let inc := (Maximum[p1] - Minimum[p1]) / o.nSampling,
         bestv1 := read(p1,y), bestv2 := read(p2,y), bests := c.cursat in
        (for i in (0 .. o.nSampling)
           let v1 := Minimum[p1] + inc * i in
             (write(p1,y,v1),
             //[OPTI1] ===== Pair sampling ~S for ~S:~F% ================ // p1,c,v1,
              sampling(o,c,y,p2),
              let vr := runLoop(o,c) in
                (if (vr > bests) 
                    (bestv1 := v1, bestv2 := read(p2,y),bests := vr))),
          write(p1,y,bestv1),  // pick the best value for p1
          write(p2,y,bestv2),  // pick the best value for p2
          runLoop(o,c),        // resets cursat
         //[OPTI] === Pair sampling ended with ~S:~F% and ~S:~F% -> ~F4 // p1,read(p1,y),p2,read(p2,y),c.cursat,
         fineOptimize(o,c,y,p1,read(p1,y)),  // optimize p1
         fineOptimize(o,c,y,p2,read(p2,y)),  // optimize p2
         //[OPTI] === Pair optim(~S) ended with ~S:~F% and ~S:~F% -> ~F4 // c, p1,read(p1,y),p2,read(p2,y),c.cursat,
         nil)]
          


// ------------------------------- 2-opt ----------------------------------------------------------------------
OPTI2:integer :: 1

// this is a simple version of 2opt which works pretty well
[twoOpt(o:Optimizer,x:Player) : void
  -> for i in (1 .. o.n2opt) twoOpt(o,x,x.tactic),
     runLoop(o,x),
     //[0] --- end 2opt(~S) -> ~A% // x, x.cursat * 100.0
]

// random choice of a property
[randomProperty(o:Optimizer) : property
  -> let n := length(o.properties) + 2 * length(o.pairs), m := random(1,n) in
        (if (m <= length(o.properties)) 
            (o.properties[m] as property)  // pick a property
         else let a := (m + 1 - length(o.properties)) / 2, b := (m - length(o.properties)) mod 2 in
            (if (b = 0) o.pairs[a][1] as property 
             else o.pairs[a][2] as property))]


// randomized 2-opt, borrowed from SOCC, but smarter:once the first random move is made, try to fix it with optimize
// tries more complex moves which are sometimes necessary
// n is the number of loops
[twoOpt(o:Optimizer,c:Player,y:Tactics)
  -> let vr := c.cursat, val := 0.0 in
        (let p1 := randomProperty(o),
             p2 := randomProperty(o),
             v1 := read(p1,y), v2 := read(p2,y) in
           (if (p1 = p2) nil
            else let v1new := v1 * (1.0 + ((if random(true) 1.0 else -1.0) / float!(2 ^ random(1,o.d2opt)))) in
             (if (v1new >= Minimum[p1] & v1new <= Maximum[p1]) 
               ( write(p1,y,v1new),
              //[OPTI2] === shift: ~S(~S) = ~A vs ~ A // p1,c,get(p1,y),v1,
              if (get(p1,y) != v1) optimize(o,c,y,p2),
              val := c.cursat,
              //[OPTI] === try2opt [~A vs ~A] with ~S(~A<-~A) x ~S(~A<-~A) // val,vr,p1,get(p1,y),v1,p2,get(p2,y),v2
             )),
           if (val <= vr) (c.cursat := vr, write(p1,y,v1), write(p2,y,v2))
           else (vr := val,
                 //[OPTI2] *** improve ~A with ~S:~A x ~S:~A -> ~A // val,p1,get(p1,y),p2,get(p2,y), val
                 ))) ]

// test methods : regular, sampling, and 2opt
[topt(c:Player,p:property) : void
  -> write(p,c.tactic,(Minimum[p] + Maximum[p]) / 2.0),    // seed value
     c.cursat := runLoop(BR,c),
     optimize(BR,c,c.tactic,p) ]

[topt2(c:Player) : void
  -> let y := c.tactic in
       (time_set(),
        c.cursat := runLoop(BR,c),
        twoOpt(BR,c),
        time_show())]

// test sampling method
[topts(c:Player,p:property) : void
  -> let y := c.tactic in
       (c.cursat := runLoop(BR,c),
     //[OPTI] --- start sampling (~S) for ~S:~F% -> ~F4 // c,p,read(p,y),c.cursat,
     sampling(BR,c,c.tactic,p),
     //[OPTI] --- end sampling (~S) for ~S:~F% -> ~F4 // c,p,read(p,y),c.cursat,
     fineOptimize(BR,c,y,p,read(p,y)),
     //[OPTI] --- end post-optimize(~S) for ~S (~F%) -> ~F4 // p,c,read(p,y),c.cursat
    )]

// test pair method
[toptp(c:Player,p1:property,p2:property) : void
  -> pairOptimize(BR,c,c.tactic,p1,p2) ]

// simple look for BR for each consumer
[bestResponse(o:Optimizer,c:Consumer) : void
  ->  for p in o.properties
          (sampling(o,c,c.tactic,p),
           fineOptimize(o,c,c.tactic,p,read(p,c.tactic))),
     for tp in o.pairs
           pairOptimize(o,c,c.tactic,tp[1],tp[2]),
      // one round of 2opt
      twoOpt(o,c),
      //[0] --- end BestResponse(~S) -> ~A // c,c.cursat
   ]

// test Best Response
[topt(c:Consumer) : void
  -> time_set(),
     bestResponse(BR,c),
     time_show(),
     tacResults(c)]

// loop fine tuning (debug: normally it should not produce improvements)
[topt1(c:Consumer) : void
  -> for p in BR.properties fineOptimize(BR,c,c.tactic,p,read(p,c.tactic)),
     for tp in BR.pairs
        let p1 := tp[1], p2 := tp[2] in
           (fineOptimize(BR,c,c.tactic,p1,read(p1,c.tactic)),
            fineOptimize(BR,c,c.tactic,p2,read(p2,c.tactic))),
     //[0] --- end topt1(~S) -> ~A // c,c.cursat
]

// tacResults (tacr:shortcut) shows the satisfaction results and a summary of the tactical properties
[tacr(c:Consumer) : void
  -> tacResults(c)]
[tacResults(c:Consumer) : void
  -> c.cursat := satScore(c),
     printf("======== ~S strategy is ~S ==============\n", c, c.objective),
     printf("Satisfaction results for ~S: ~F% (adj. emissions = ~F1Gt, avg GDP = ~F1T$ (CAGR:~F2 %), avg pain = ~F%)\n",
            c, c.cursat, 
            average(list<float>{adjustForTrade(c,i,false) | i in (1 .. pb.year)}),
            average(list<float>{c.economy.results[i] | i in (1 .. pb.year)}),
            CAGR(c.economy.results[1], c.economy.results[pb.year],pb.year - 1),
            average(list<float>{c.painLevels[i] | i in (1 .. pb.year)})),
     printf("tax tactic: ~F% of pain -> ~F2T$ yearly average\n", c.tactic.taxFromPain,
              average(list<float>{c.carbonTaxes[i] | i in (1 .. pb.year)})),
     printf("cancel tactic: ~F% of pain -> ~F2PWh \n", c.tactic.cancelFromPain,
              average(list<float>{allCancel(c,i) | i in (1 .. pb.year)})),
     printf("transition tactic: start ~F%, then ~F% of pain, ~F3C° end temperature\n", c.tactic.transitionStart, 
             c.tactic.transitionFromPain,pb.earth.temperatures[pb.year]),
     printf("protectionism tactic: start ~F%, then ~F% of pain -> average import reduction ~F2 T$ \n", 
            c.tactic.protectionismStart, c.tactic.protectionismFromPain,
            average(list<float>{c.economy.reducedImports[i] | i in (1 .. pb.year)})),
     printf("adaptation tactic: start ~F%, then ~F% of pain -> ~F2 TS total spend, ~F2 T$ damages \n", c.tactic.adaptStart, 
             c.tactic.adaptFromPain, c.adapt.sums[pb.year],
             sum(list<float>{c.adapt.losses[i] | i in (1 .. pb.year)}))
    ]
      

// ***************************************************************~*************
// *    Part 3: Evolutionary Search for Nash Equilibrium (TBC in CCEM v8)      *                                     *
// *****************************************************************************
