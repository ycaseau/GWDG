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
// *    Part 1: Meta-framework                                                 *
// *    Part 2: local moves and Optimization                                   *
// *    Part 3: Evolutionary Search for Nash Equilibrium (TBC)                 *                                     *
// *****************************************************************************

// *****************************************************************************
// *    Part 1: Meta-framework                                                 *
// *****************************************************************************

OPTI:integer :: 1                  // TRACE/DEBUG verbosity

// defines the local opt landscape and the
Optimizer <: thing(
    properties: list<property>,  // list of properties to optimize
    nSteps: integer,             // number of steps in the optimization loop
    nYears: integer,             // number of years in the simulation
    nDichotomic: integer,        // number of dichotomic steps (was NUM1)
    n2opt: integer,            // number of 2opt loops 
    dCount:integer = 0)          // debug counter

// in CCEM, the player is a Consumer
Player :: Consumer

// for CCEM, BR (Best Resonse) optimizes EnergyTransition, Sobriety, CarbonTax, CloseBorders
BR :: Optimizer(
    properties = list<property>(taxFromPain,cancelFromPain,transitionStart,transitionFromPain,
                                protectionismStart,protectionismFromPain),
    nYears = 90,
    nDichotomic = 5)

// core parametric method RunLoop runs the simulation and returns the score for a given player
[runLoop(o:Optimizer, c:Player) : float
  -> reinit(World,Oil,Clean),
     iterate_run(o.nSteps),
     satScore(c) ]

// *****************************************************************************
// *    Part 2: local moves & optimization                                     *
// *****************************************************************************


// ---------------------- generic optimization engine [float flavor] -------------------------
// [this is a reusable code fragment - source: project PSR Game - 2007 ======================]


NUM1:integer :: 5                  // number of steps in a loop (1/2, 1/4, ... 1/2^5) => precision
MULTI:integer :: 2                 // number of successive optimization loops (was OPT2)


// optimise the tactic component y for a player x
[optimize(o:Optimizer, x:Player) : void
  -> for i in (1 .. o.nSteps)
        for p in p.properties optimize(o,x,x.tactic,p),
     //[OPTI] --- end optimize(~S) -> ~A \n",x,x.cursat
]

// first approach : relative steps (=> stays in the 0% .. 100% range) ----------

// optimize a given slot in a set of two dichotomic steps
[optimize(o:Optimizer,c:Player,y:Tactics,p:property)
  -> let vref := read(p,y) in                            // original value before optimization
         for i in (1 .. o.nSteps) optimize(o,c,y,p,float!(2 ^ (i - 1)),vref),
     //[OPTI] best ~S for ~S is ~A => ~A\n", p,c,read(p,y), c.cursat
]

DD:integer := 0   // debug counter
DGO:integer := 0
WHY:boolean :: false   // debug

// the seed value is problem dependant !
// it is used twice - when the value is 0, to boost the multiplicative increment loop (opt)
//                    when the value is very small, to boost the additive loop
// NEW: use vp as the reference value to pick ties (closest to original value)
SEED:float :: 1.0

[optimize(o:Optimizer,c:Player,y:Tactics,p:property,r:float,vref:float) : void
   ->  let vr := c.cursat, val := 0.0, dist := 0.0,
           vp := read(p,y),v0 := (if (vp > 0.0) vp else SEED),        // v0.4 do not waste cycles
           v1 := vp / (1.0 +  (1.0 / r)), v2 := vp * (1.0 + (1.0 / r)) in
        (write(p,y,v1),
         if (v1 >= 0.0) val := runLoop(o,c),
         o.dCount :+ 1,
         //[OPTI] try ~A (vs.~A) for ~S(~S) -> ~A (vs. ~A) [DD:~A] // v1,vp,p,c,val,vr,o.dCount,
         if (val > vr | (val = vr & abs(v1 - vref) < dist))
            (vp := v1, vr := val, dist := abs(v1 - vref)),
         write(p,y,v2),
         val := runLoop(o,c),
         //[OPTI] try ~A for ~S(~S) -> ~A // v2,p,c,val,
         if (val > vr | (val = vr & abs(v2 - vref) < dist))
            (vp := v2, vr := val, dist := abs(v2 - vref)),
         write(p,y,vp),
         c.cursat := vr) ]


// ------------------------------- 2-opt ----------------------------------------------------------------------
OPTI2:integer :: 1


// this is a simple version of 2opt which works pretty well
[twoOpt(o:Optimizer,x:Player) : void
  -> for i in (1 .. o.n2opt) twoOpt(o,x,x.tactic),
     runLoop(s),
     //[OPTI2] --- end 2opt(~S) -> ~A% // x, x.cursat * 100.0
]


// randomized 2-opt, borrowed from SOCC, but smarter:once the first random move is made, try to fix it with optimize
// tries more complex moves which are sometimes necessary
// n is the number of loops
[twoOpt(o:Optimizer,c:Player,y:Tactics)
  -> let vr := c.cursat, val := 0.0 in
        (let p1 := (random(y.properties) as property),
             p2 := (random(y.properties) as property),
             v1 := read(p1,y), v2 := read(p2,y) in
           (if (p1 = p2) nil
            else let v1new := v1 * (1.0 + ((if random(true) 1.0 else -1.0) / float!(2 ^ random(1,5)))) in
             (write(p1,y,v1new),
              //[OPTI2] === shift: ~S(~S) = ~A vs ~ A // p1,c,get(p1,y),v1,
              if (get(p1,y) != v1) optimize(o,c,y,p2),
              val := c.cursat,
              //[OPTI] === try2opt [~A vs ~A] with ~S(~A<-~A) x ~S(~A<-~A) // val,vr,p1,get(p1,y),v1,p2,get(p2,y),v2
             ),
           if (val <= vr) (c.cursat := vr, write(p1,y,v1), write(p2,y,v2))
           else (vr := val,
                 //[OPTI2] *** improve ~A with ~S:~A x ~S:~A -> ~A // val,p1,get(p1,y),p2,get(p2,y), val
                 ))) ]


// simple look for BR for each consumer
[bestResponse(o:Optimizer) : void
  -> for c in Consumer optimize(o,c)]

// *****************************************************************************
// *    Part 3: Evolutionary Search for Nash Equilibrium (TBC)                 *                                     *
// *****************************************************************************
