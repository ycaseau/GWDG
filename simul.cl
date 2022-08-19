// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2022 Yves Caseau                        *
// *       file: simul.cl                                             *
// ********************************************************************

// this file contains the overall simulation engine

// ********************************************************************
// *    Part 1: Piece-wise Affine functions                           *
// *    Part 2: Time-step simulation                                  *
// *    Part 3: Simulation & Results                                  *
// *    Part 4: Experiments                                           *
// ********************************************************************

// ********************************************************************
// *    Part 1: Piece-wise Affine functions                           *
// ********************************************************************

// this is a reusable library :) -----------------------------------------------

// print a float in fixed number of characters -------------------------------
[fP(x:float,i:integer) : void
  -> if (x >= 10.0) 
        let n := integer!(log(x) / log(10.0)) in 
           (princ(x,i - (n + 2)),
            if (i = (n + 2)) princ(" "))
     else princ(x,i - 2) ]

// returns the value of the affine function for a given point between m and M
[get(a:Affine,x:float) : float
  -> let i := 0 in
       (for j in (1 .. a.n)
         (if (a.xValues[j] > x) break(i := j)),
        if (i = 0) a.yValues[a.n]       // x is bigger than all x Values
        else if (i = 1) a.yValues[1]    // x is smaller than all x value
        else let x1 := a.xValues[i - 1], x2 := a.xValues[i],
                 y1 := a.yValues[i - 1], y2 := a.yValues[i] in
               (y1 + (y2 - y1) * (x - x1) / (x2 - x1))) ]

[get(a:ListFunction,x:integer) : float 
  -> get(a,float!(x)) ]

// returns the value of the step function for a given point between m and M : easier !
[get(a:StepFunction,x:float) : float
  -> let i := 0 in
       (for j in (1 .. a.n)
         (if (a.xValues[j] > x) break(i := j)),
        if (i = 0) a.yValues[a.n]       // x is bigger than all x Values
        else if (i = 1) a.yValues[1]    // x is smaller than all x value
        else a.yValues[i - 1]) ]        // easier for step-wise functions :)

// this is a cool trick : prints an affine curve on a character terminal as nicely
// as we can - reproduces the behavior of a line printer
NX :: 85
NY :: 30
[display(a:ListFunction) : void
 -> let m1:float := a.xValues[1], M1 := a.xValues[a.n],
        m2:float := a.minValue, M2 := a.maxValue,
        lv := list<integer>{scale(get(a,m1 + (M1 - m1) * (float!(i) / float!(NX))),m2,M2,NY) | i in (0 .. NX)},
        l* := list<boolean>{false | i in (0 .. NX)},     // see which y-values are touched - l*[c] = true <=> print something
        c := 0 in
      (princ("\n"),
       for i in (1 .. a.n)
         let y := scale(a.xValues[i],m1,M1,NX) in l*[y + 1] := true,
       for u in (0 .. NY)
         let y := NY - u,
             i := matchY(a,m2,M2,y) in
            (if (i != 0) fP(a.yValues[i],5) else princ("     "),
             if (u = 0) princ(" ^") else princ(" |"),
             for v in (0 .. NX)
               (if (lv[v + 1] = y)
                   (if l*[v + 1] princ("+") else princ("o"))
                else princ(" ")),
             princ("\n")),
       printf("      +~I>\n       ",(for i in (1 .. NX) princ("-"))),
       for i in (0 .. NX) (if l*[i + 1] princ("^") else princ(" ")),
       princ("\n       "),
       for i in (0 .. NX)
         let j := matchX(a,m1,M1,i) in         // assumption : we have printed already c chars
            (if (j != 0 & c <= 0)
                (fP(a.xValues[j],5), princ(" "), c := 5)            // forbid printing for 6 chars
             else (if (c > 0) c :- 1 else princ(" "))),
       princ("\n")) ]


// retreive a value (x-i, y-i) such that the scale value of y-i is u and returns i
[matchY(a:ListFunction,m:float,M:float,v:integer) : integer
 -> let u := 0 in
      (for i in (1 .. a.n)
        (if (scale(a.yValues[i],m,M,NY) = v)
             break(u := i)),
       u) ]

// retreive a value whose scale value is u
[matchX(a:ListFunction,m:float,M:float,v:integer) : integer
 -> let u := 0 in
      (for i in (1 .. a.n)
        (if (scale(a.xValues[i],m,M,NX) = v)
             break(u := i)),
       u) ]
       
// scale: returns the integer coordinates associated to a float between m and M
[scale(v:float,m:float,M:float,N:integer) : integer
  -> if (m = M) 0 else integer!((v - m) / (M - m) * N) ]

// print a table in a proper format
// [tables(title:string, l:list<tuple<string,Affine>>, total?:boolean) : void]
//  -> ]


// accelerate : change the price thresholds to accelerate a policy
[accelerate(policy:list<Affine>, factor:Percent) : list<Affine>
  -> let l := list<Affine>() in
       list<Affine>{ Affine(n = p.n, yValues = p.yValues, minValue = p.minValue, maxValue = p.maxValue,
                       xValues = list<float>{  (p.xValues[i] * (1.0 - factor)) | i in (1 .. p.n)}) |
                     p in policy}]

// ********************************************************************
// *    Part 2: Time-step simulation                                  *
// ********************************************************************

YSTOP:integer :: 1000    // debug: control variable
YTALK:integer :: 1000

// one simulation step
[run(p:Problem) : void
  -> let y := p.year + 1 in
       (pb.year := y,
        //[TALK] ==================================  [~A] =================================== // year!(y),
        if (y = YTALK | y = YSTOP) (DEBUG := 1, SHOW2 := 1),
        for c in Consumer getNeed(c,y),             // overall need (all energies)
        for s in Supplier
           (//[SHOW2] ********* energy ~S : ~F2 GTep ********************************************* // s,sum(list{c.needs[y][s.index] | c in Consumer}),
            getProd(s,p.year),                      // set first vector = supply
            resetNeed(p),                           // reset second vector to 0
            for c in Consumer getNeed(c,s,y),       // computes the need of c for energy s
            if (y = YSTOP & s = TESTE) (lookProd(s), lookNeed(s)),
            s.sellPrices[y] := solve(p,s),
            for c in Consumer record(c,s,y),
            record(s,y)),
        //[SHOW4] ========== move to world economy (input = ~F2 GTep) ================ // p.economy.inputs[y],
        consumes(p.economy,y),                                  // economy
        //[TALK] [~A] pnb = ~F2T$ from ~F2 energy // year!(y), pb.economy.results[y], pb.economy.consos[y],
        react(p.earth,y),                                    // CO2 + carbon tax
        if (y = YSTOP) error("stop at YSTOP")) ]

// debug for one supplier
[run(s:Supplier) : void
  -> let y := pb.year + 1 in
       (pb.year := y,
        SHOW2 := 1,
        for c in Consumer getNeed(c,y),             // overall need (all energies)
        //[SHOW2] --- energy ~S : ~A ----------------------- // s,sum(list{c.needs[y][s.index] | c in Consumer}),
        getProd(s,pb.year),                      // set first vector = supply
        lookProd(s),
        resetNeed(pb),                           // reset second vector to 0
        for c in Consumer getNeed(c,s,y),       // computes the need of c for energy s
        s.sellPrices[y] := solve(pb,s),
        lookNeed(s),
        for c in Consumer record(c,s,y),
        record(s,y),
        see(s)) ]

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
           (printf("*** total demand for ~S is ~F2\n", s, sum(list{c.needs[pb.year][s.index] | c in Consumer})),
            printf("solve(~S) -> price=~A : delta=~F2, qty=~F2, tax=~F2\n",s, p0,v0,p.prodCurve[i0],avgTax(s,pb.year)),
            for c in Consumer 
                 printf("Cancel/save(~S) = ~F%/~F%; ",
                         c,getCancel(c,s,oilEquivalent(s,p0) + avgTax(s,pb.year)),prevSaving(c,s)),
            printf("@ oil=~F2\n",oilEquivalent(s,p0) + avgTax(s,pb.year))),
        if (p0 = 0.0) 
            (//[0] ********************** IMPOSSIBLE TO SOLVE MARKET EQUATION [~S] ********************** // s,
             lookProd(s),
             lookNeed(s),
             error("stop error with solve(~S)",s)),
        p0) ]


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
         l1 := list<float>{float!(year!(i)) | i in (1 .. nL)} in
       (for v in l (m1 :min v, M1 : max v),
        Affine(n = length(l), minValue = m1, maxValue = M1,
               xValues = l1, yValues = l)) ]

// usefull tools for debugging : show the production / needs histograms ------
B:Affine :: unknown
[lookProd(s:Supplier)
 -> //[0] ------------------------- PROD[~S] = f(price) ------------------------------- // s,
    B := priceSample(pb.prodCurve),
    display(B) ]

[lookNeed(s:Supplier)
 -> //[0] ------------------------- NEED[~S] = f(price) ------------------------------- // s,
    B := priceSample(pb.needCurve),
    display(B) ]

[lookDebug()
 -> //[0] ------------------------- VALUE = f(price) ------------------------------ //,
    B := priceSample(pb,pb.debugCurve),
    display(B) ]

// show the result of a simulation
[hist(s:Supplier) : void
  -> printf("------------------ inventory  ~S [~I] -------\n",s,princ(pb.comment,40)),
     display(timeSample(list<float>{s.inventories[i] | i in (1 .. pb.year)})),
     printf("------------------ prices (w/o tax)  ~S ------------------------------------------\n",s),
     display(timeSample(list<float>{s.sellPrices[i] | i in (1 .. pb.year)})),
     printf("------------------ outputs  ~S ---------------------------------------------------\n",s),
     display(timeSample(list<float>{s.outputs[i] | i in (1 .. pb.year)})),
     printf("------------------ capacity ~S ---------------------------------------------------\n",s),
     display(timeSample(list<float>{s.capacities[i] | i in (1 .. pb.year)})),
     if (s.index > 1) (printf("------------------ addition through substitution ~S --------------\n",s),
                       display(timeSample(list<float>{s.additions[i] | i in (1 .. pb.year)}))) ]

// show the world history
[hist()
  -> printf("------------------ pnb [~I] --------------------\n",princ(pb.comment,40)),
     display(timeSample(list<float>{pb.economy.results[i] | i in (1 .. pb.year)})),
     printf("------------------ energy ----------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.economy.consos[i] | i in (1 .. pb.year)})),
     printf("------------------ co2 -------------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.earth.co2Levels[i] | i in (1 .. pb.year)})) ]

// show a consumer (energy to PNB point of view)
[hist(c:Consumer) : void
  -> printf("------------------ need ~S (GTep) [~I] ---\n",c,princ(pb.comment,40)),
     display(timeSample(list<float>{allNeed(c,i) | i in (1 .. pb.year)})),
     printf("------------------ cancels ~S -----------------------------------------------\n",c),
     display(timeSample(list<float>{allCancel(c,i) | i in (1 .. pb.year)})),
     printf("------------------ savings ~S -----------------------------------------------\n",c),
     display(timeSample(list<float>{allSaving(c,i) | i in (1 .. pb.year)})),
     printf("------------------ consommation ~S -------------------------------------------\n",c),
     display(timeSample(list<float>{allConso(c,i) | i in (1 .. pb.year)})),
     printf("------------------ CO2 tax ~S (T$) -------------------------------------------\n",c),
     display(timeSample(list<float>{c.carbonTaxes[i]| i in (1 .. pb.year)})) ]

// specific focus on pain
[pain(c:Consumer) : void
  -> printf("------------------ Cancel levels for ~S [~I] ---\n",c,princ(pb.comment,40)),
     display(timeSample(list<float>{allCancel(c,i) | i in (1 .. pb.year)})),
     printf("------------------ pnb  -----------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.economy.results[i] | i in (1 .. pb.year)})),
     printf("------------------ co2 -------------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.earth.co2Levels[i] | i in (1 .. pb.year)})),
     printf("------------------ resulting pain for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painLevels[i]| i in (1 .. pb.year)})) ]


// world wide analysis of pnb from energy 
[hist(e:Economy) : void
  -> printf("------------------ pnb  --------------------------\n"),
     display(timeSample(list<float>{e.results[i] | i in (1 .. pb.year)})),
     printf("------------------ Investments for Energy --------------------------\n"),
     display(timeSample(list<float>{e.investEnergy[i] | i in (1 .. pb.year)})),
     printf("------------------ energy --------------------------\n"),
     display(timeSample(list<float>{e.consos[i] | i in (1 .. pb.year)})),
     printf("------------------ savings --------------------------\n"),
     display(timeSample(list<float>{allSaving(i) | i in (1 .. pb.year)})),
     printf("------------------ cancels --------------------------\n"),
     display(timeSample(list<float>{e.cancels[i] | i in (1 .. pb.year)})),
     printf("------------------ max pnb with full energy ---------------\n"),
     display(timeSample(list<float>{e.maxout[i] | i in (1 .. pb.year)}))]
     
// display 3 substitution flows
[subst() : void
  -> printf("------------------ Oil to Coal  --------------------------\n"),
     display(timeSample(list<float>{allSubstitution(i,1) | i in (1 .. pb.year)})),
     printf("------------------ Oil to clean --------------------------\n"),
     display(timeSample(list<float>{allSubstitution(i,1) | i in (1 .. pb.year)})),
     printf("------------------ Coal to Clean --------------------------\n"),
     display(timeSample(list<float>{allSubstitution(i,1) | i in (1 .. pb.year)})) ]

/* show the energy consumtions
[energy()
  -> table("energy consumtion by supplier type",
           list{list(string!(s.name), 
                     timeSample(list<float>{s.outputs[i] | i in (1 .. pb.year)})) | s in Supplier},
           true)] */

// combine for all suppliers
[allNeed(c:Consumer,y:Year) : float -> sum(c.needs[y])]
[allCancel(c:Consumer,y:Year) : float -> sum(c.cancels[y])]
[allSaving(c:Consumer,y:Year) : float -> sum(c.savings[y])]
[allConso(c:Consumer,y:Year) : float -> sum(c.consos[y])]
[allSaving(y:Year) : float -> sum(list{allSaving(c,y) | c in Consumer})]
[allSubstitution(y:Year,i:(1 .. 3)) : float 
   -> sum(list{c.substitutions[y][i] | c in Consumer})]

// ********************************************************************
// *    Part 3: Simulation & Results                                  *
// ********************************************************************


// see() shows the situation for a give year
[see() : void
  -> printf("************************************************************************************\n"),
     printf("*          Simulation results in Year ~A                                         *\n", year!(pb.year)),
     printf("*          ~I    *\n",princ(pb.comment,66)),
     printf("************************************************************************************\n"),
     see(pb.economy, pb.year),
     see(pb.earth, pb.year),
     for s in Supplier see(s,pb.year),
     for c in Consumer see(c,pb.year) ]


[see(x:Economy, y:Year) : void
  -> printf("[~A] PNB = ~F1, invest = ~F1, conso = ~S\n",year!(y),
            x.results[y], x.investGrowth[y], x.consos[y]) ]

[see(x:Earth,y:Year)
  -> printf("--- CO2 at ~F2, temperature = ~F1, tax = ~A\n",
             x.co2Levels[y], x.temperatures[y],
             list{get(c.carbonTax,x.co2Levels[y]) | c in Consumer}) ]

[see(s:Supplier,y:Year) : void
  -> printf("~S: price = ~F2, inventory = ~F2, prod = ~F2\n",
            s,s.sellPrices[y],get(s.inventory,s.sellPrices[y]) - s.gone,s.outputs[y]) ]

[see(c:Consumer,y:Year) : void
  -> printf("~S: conso(GTep) ~I vs need ~I \n",c,pl2(c.consos[y]),pl2(c.needs[y])) ]

// prints a list of float with F2
[pl2(l:list) : void 
  -> for x in l printf("~F2 ",x)]

// display() shows the end result

// ********************************************************************
// *    Part 4: Experiments                                           *
// ********************************************************************


[init(p:Problem,e:Supplier) : void
  -> p.earth := Earth.instances[1],
     p.oil := e,
     p.economy := Economy.instances[1],
     p.priceRange := list<float>{float!(50 + ((PMAX * sqr(i)) / sqr(NIS + 1)) )
                                 | i in (2 .. (NIS + 1))},
     p.debugCurve := list<float>{0.0 | x in (1 .. NIS)},
     p.needCurve := list<float>{0.0 | x in (1 .. NIS)},
     p.prodCurve := list<float>{0.0 | x in (1 .. NIS)},
     init(pb.earth),
     init(pb.economy),
     for s in Supplier init(s),
     for c in Consumer init(c) ]

[init(s:Supplier) : void
  ->   s.outputs := list<Energy>{ 0.0 | i in (1 .. NIT)},
       s.sellPrices := list<Price>{0.0 | i in (1 .. NIT)},
       s.gone := 0.0,
       s.added := 0.0,
       s.additions := list<Energy>{0.0 | i in (1 .. NIT)},
       s.inventories := list<Energy>{0.0 | i in (1 .. NIT)},
       s.netNeeds := list<Energy>{0.0 | i in (1 .. NIT)},
       s.capacities := list<Energy>{0.0 | i in (1 .. NIT)}]

[init(c:Consumer) : void
  -> c.startNeeds := list<Energy>{ (c.consumes[s.index] / (1.0 - get(c.cancel,s.price))) |
                                   s in Supplier },
     c.needs := list<list<Energy>>{ list<Energy>() | i in (1 .. NIT)},
     c.consos := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.cancels := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.savings := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.substitutions := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.carbonTaxes := list<Price>{0.0 | i in (1 .. NIT)},
     c.painLevels := list<float>{0.0 | i in (1 .. NIT)}] 
     
[init(x:Economy) : void
  -> x.startConso := sum(list{sum(c.consumes) | c in Consumer}),
     x.consos := list<Energy>{0.0 | i in (1 .. NIT)},
     x.inputs := list<Energy>{0.0 | i in (1 .. NIT)},
     x.cancels := list<Energy>{0.0 | i in (1 .. NIT)},
     x.results := list<Price>{0.0 | i in (1 .. NIT)},
     x.maxout := list<Price>{0.0 | i in (1 .. NIT)},
     x.investGrowth := list<Price>{0.0 | i in (1 .. NIT)},
     x.investEnergy := list<Price>{0.0 | i in (1 .. NIT)} ]

[init(x:Earth) : void
   -> x.temperatures := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Levels := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Emissions := list<float>{0.0 | i in (1 .. NIT)} ]

// ------------------------- our reusable trick -------------------------

// test1: simplest model
// we load a file of interpreted code
(#if (compiler.active? = false | compiler.loading? = true)
     (load(Id(*where* / ("gwdgv" /+ string!(Version)) / "test1")))
  else nil
)
