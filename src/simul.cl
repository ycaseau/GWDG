// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
// *       file: simul.cl                                             *
// ********************************************************************

// this file contains the overall simulation engine

// ********************************************************************
// *    Part 1: Piece-wise Affine functions                           *
// *    Part 2: Time-step simulation                                  *
// *    Part 3: Simulation & Results                                  *
// *    Part 4: Model Showback                                        *
// *    Part 5: Experiments                                           *
// ********************************************************************

// ********************************************************************
// *    Part 1: Piece-wise Affine functions                           *
// ********************************************************************

// this is a reusable library :) -----------------------------------------------

// print a float in fixed number of characters -------------------------------
[fP(x:float,i:integer) : void
  -> if (x < 0.0) (princ("-"),fP(-(x),i - 1))
     else if (x >= 10.0) 
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
NY:integer :: 30
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

// tune a policy by changing one substitution
[tune(policy:list<Affine>,from:Supplier,to:Supplier,line:Affine) : list<Affine>
  -> let tr := getTransition(from,to), n := length(policy) in
       list<Affine>{ (if (i = tr.index) line else policy[i]) | i in (1 .. n) }]


// adjust a policy represented by an affine function: keep the dates, change the value by a factor
// destructive operation -> changes the affine / list function
[adjust(a:ListFunction,factor:Percent) : void
   -> for i in (1 .. a.n) a.yValues[i] :* factor ]       

// ********************************************************************
// *    Part 2: Tables may be handy (1980s style)                     *
// ********************************************************************

// fixed size princ
[fP(s:string,n:integer)
 -> let m := length(s) in
      (if (m > n) princ(slice(s,1,n))
       else (whitespace(n - m), princ(s))) ]

[whitespace(n:integer)
  -> for i in (1 .. n) princ(" ")]

// fixed size princ with 2 digits
[fP2(x:float,i:integer) : void
  -> if (x >= 10.0) 
        let n := integer!(log(x) / log(10.0)) in 
           (whitespace(i - 4 - n),
            princ(x,2),
            if (i = (n + 2)) princ(" "))
     else (if (x < 0.0) whitespace(i - 5)
           else whitespace(i - 4), 
           princ(x,2)) ]

// starts a table
[startTable(n:integer,l:list<string>)
  -> princ("\n"),
     separation(n,length(l)),
     printf("|~I",whitespace(n)),
     for x in l (princ("|"), fP(x,n)),
     princ("|\n"),
     separation(n,length(l))]
    
// adds a separation line (1 + m columns of size n)
[separation(n:integer,m:integer) 
  -> printf("+~I",separation(n)),
     for i in (1 .. m) (princ("+"), separation(n)),
     princ("+\n")]

[separation(n:integer)
  -> for i in (1 .. n) princ("-")]

// adds a line of floats
[lineTable(title:string,n:integer,l:list<float>)
  -> printf("|~I",fP(title,n)),
     for x in l (princ("|"), fP2(x,n)),
     princ("|\n")]

// test print the energy conso 
[eTable() 
  -> startTable(10,add(list<string>{string!(s.name) | s in Supplier},"total")),
     for c in Consumer
        (lineTable(string!(c.name) /+ "-2010",10,
             add(list<float>{c.consumes[s.index] | s in Supplier},
                 sum(list{c.consumes[s.index] | s in Supplier}))),
         lineTable(string!(c.name) /+ "-" /+ string!(year!(pb.year)),10,
             add(list<float>{c.consos[pb.year][s.index] | s in Supplier},
                 c.economy.totalConsos[pb.year])),
         separation(10,size(Supplier) + 1)),
     lineTable("total-2010",10,
             add(list<float>{sum(list{c.consumes[s.index] | c in Consumer}) | s in Supplier},
                sum(list{ sum(list{ c.consumes[s.index] | c in Consumer}) | s in Supplier}))),
     lineTable("total-" /+ string!(year!(pb.year)),10,
             add(list<float>{sum(list{c.consos[pb.year][s.index] | c in Consumer}) | s in Supplier},
                sum(list{ sum(list{ c.consos[pb.year][s.index] | c in Consumer}) | s in Supplier}))),
     separation(10,size(Supplier) + 1) ]

// ********************************************************************
// *    Part 3: Time-step simulation                                  *
// ********************************************************************

YSTOP:integer :: 1000    // debug: control variable
YTALK:integer :: 1000

// one simulation step
[run(p:Problem) : void
  -> let y := p.year + 1 in
       (pb.year := y,
        //[TALK] ==================================  [~A] =================================== // year!(y),
        if (y = YTALK | y = YSTOP) (DEBUG := 1, SHOW2 := 1),
        for c in Consumer getNeed(c,y),             // M2: overall need (all energies)
        for s in Supplier
           (//[SHOW2] ********* energy ~S : ~F2 GTep ********************************************* // s,sum(list{c.needs[y][s.index] | c in Consumer}),
            getProd(s,p.year),                      // M1: set first vector = supply
            resetNeed(p),                           // reset second vector to 0
            for c in Consumer getNeed(c,s,y),       // computes the need of c for energy s
            if (y = YSTOP & s = TESTE) (lookProd(s), lookNeed(s)),
            s.sellPrices[y] := solve(p,s),          // M2: find the approximate equilibrium price
            balanceEnergy(s,y),                     // M2: sets consos and prod for perfect balance
            for c in Consumer record(c,s,y),        // M3: record the need of c for energy s
            recordCapacity(s,y)),                   // M2: compute investEnergy
        //[SHOW4] ========== move to world economy (input = ~F2 GTep) ================ // sum(list{b.inputs[y] | b in Block}),
        getEconomy(y),                                  // M4: economy
        if (TALK > 0)
         printf("[~A] gdp = ~F2T$ from ~F2 energy at ~I\n",year!(y), pb.world.all.results[y], pb.world.all.inputs[y],
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


// we want to understand the price (at the current time) for a supplier
// computes the two curves (production and need)
[lookSolve(s:Supplier)
  -> getProd(s,pb.year),
     resetNeed(pb),
     for c in Consumer getNeed(c,s,pb.year),
     solve(pb,s),
     lookProd(s),
     lookNeed(s) ]

// show the result of a simulation
[hist(s:Supplier) : void
  -> case s 
       (FiniteSupplier 
          (printf("------------------ inventory  ~S [~I] -------\n",s,princ(pb.comment,40)),
           display(timeSample(list<float>{s.inventories[i] | i in (1 .. pb.year)})))),
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
  -> printf("------------------ gdp [~I] --------------------\n",princ(pb.comment,40)),
     display(timeSample(list<float>{pb.world.all.results[i] | i in (1 .. pb.year)})),
     printf("------------------ energy consumption ------------------------------------------------\n"),
     display(timeSample(list<float>{pb.world.all.totalConsos[i] | i in (1 .. pb.year)})),
     printf("------------------ wheat production ------------------------------------------------\n"),
     display(timeSample(list<float>{pb.world.all.wheatOutputs[i] | i in (1 .. pb.year)})),
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
     printf("------------------ gdp ~S -------------------------------------------\n",c),
     display(timeSample(list<float>{c.economy.results[i] | i in (1 .. pb.year)})),
     printf("------------------ CO2 tax ~S (T$) -------------------------------------------\n",c),
     display(timeSample(list<float>{c.carbonTaxes[i]| i in (1 .. pb.year)})) ]

// specific focus on pain
[pain(c:Consumer) : void
  -> printf("------------------ Cancel levels for ~S [~I] ---\n",c,princ(pb.comment,40)),
     display(timeSample(list<float>{allCancel(c,i) | i in (1 .. pb.year)})),
     printf("------------------ gdp  -----------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.world.all.results[i] | i in (1 .. pb.year)})),
     printf("------------------ co2 -------------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.earth.co2Levels[i] | i in (1 .. pb.year)})),
     printf("------------------ resulting pain for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painLevels[i]| i in (1 .. pb.year)})) ]


// world wide analysis of gdp from energy 
[hist(e:Economy) : void
  ->  printf("------------------ energy --------------------------\n"),
     display(timeSample(list<float>{e.totalConsos[i] | i in (1 .. pb.year)})),
     printf("------------------ savings --------------------------\n"),
     display(timeSample(list<float>{allSaving(i) | i in (1 .. pb.year)})),
     printf("------------------ cancels --------------------------\n"),
     display(timeSample(list<float>{e.cancels[i] | i in (1 .. pb.year)})),
     printf("------------------ max gdp with full energy ---------------\n"),
     display(timeSample(list<float>{e.maxout[i] | i in (1 .. pb.year)}))]
     

// combine for all suppliers  (used in hist(c:Consumer))
[allNeed(c:Consumer,y:Year) : float 
   -> sum(c.needs[y])]
[allCancel(c:Consumer,y:Year) : float 
   -> sum(c.economy.cancels[y])]
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

// cancel and saving ratios
[cancelRatio(c:Consumer,y:Year) : Percent 
    -> sumCancels(c,y) / sumNeeds(c,y)]
[savingRatio(c:Consumer,y:Year) : Percent 
    -> sumSavings(c,y) / sumNeeds(c,y)]

// actual transfer in GTep (world wide)
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
// *    Part 3: Simulation & Results                                  *
// ********************************************************************


// see() shows the situation for a given year
[see() : void
  -> printf("************************************************************************************\n"),
     printf("*          Simulation results in Year ~A                                         *\n", year!(pb.year)),
     printf("*          ~I    *\n",princ(pb.comment,66)),
     printf("************************************************************************************\n"),
     see(pb.world.all, pb.year),
     see(pb.earth, pb.year),
     for s in Supplier see(s,pb.year),
     for c in Consumer see(c,pb.year),
     for c in Consumer see(c.economy,pb.year)]


[see(x:Economy, y:Year) : void
  -> printf("[~A] ~S PNB=~F1, invest=~F1, conso=~F2, steel:~F1Gt\n",year!(y),
            (case x (Block x.describes, any pb.world)),
            x.results[y], x.investGrowth[y], x.totalConsos[y],
            x.ironConsos[y], pb.world.wheatOutputs[y]),
    if (x = pb.world)
      (printf("[~A] steel consos: ~F1Gt, wheat: ~F1Gt at prince ~F1$/t\n",year!(y),
              x.ironConsos[y], x.steelPrices[y]),
       printf("[~A] agro production: ~F1Gt from surface ~F1\n",year!(y),
             x.wheatOutputs[y], x.agroSurfaces[y]))]

[see(x:Earth,y:Year)
  -> printf("--- CO2 at ~F2, temperature = ~F1, tax = ~A\n",
             x.co2Levels[y], x.temperatures[y],
             list{get(c.carbonTax,x.co2Levels[y]) | c in Consumer}) ]

[see(s:FiniteSupplier,y:Year) : void
  -> printf("~S: price = ~F2(~F%), inventory = ~F2, prod = ~F2\n",
            s,s.sellPrices[y],s.sellPrices[y] / s.sellPrices[1],
            get(s.inventory,s.sellPrices[y]) - s.gone,s.outputs[y]) ]

[see(s:InfiniteSupplier,y:Year) : void
  -> printf("~S: price = ~F2(~F%), capacity growth potential = ~F2, prod = ~F2\n",
            s,s.sellPrices[y],s.sellPrices[y] / s.sellPrices[1],
            get(s.growthPotential,s.sellPrices[y]),s.outputs[y]) ]


[see(c:Consumer,y:Year) : void
  -> printf("~S: conso(GTep) ~I vs need ~I \n",c,pl2(c.consos[y]),pl2(c.needs[y])) ]

// prints a list of float with F2
[pl2(l:list) : void 
  -> for x in l printf("~F2 ",x)]

// display() shows the end result

// todo : add the two obvious losses: energy loss and damages, with temp, CO2ppm,
// Energy investment, clean energy%
[progress(s:string)
 -> nil]

[worldPopulation(y:Year) : float
  -> sum(list{get(b.population,y) | b in Block}) ]

// ********************************************************************
// *    Part 4: Model Showback                                        *
// ********************************************************************

// -------------- sMx() show the initial values for each component model M_x ---------------------

// show what we think of our energy sources
[sM1() 
  -> for x in Supplier sM1(x)]

[sM1(x:FiniteSupplier)
 -> printf("************** M1 model for ~S ******************\n",x),
    printf("inventory in GToe= ~S\n",x.inventory),
    printf("price in 2010 = ~F2 $/Toe\n",x.price),
    printf("production = ~F2 GTep in 2010, max growth at ~F%\n",x.production,x.capacityGrowth) ]

[sM1(x:InfiniteSupplier)
 -> printf("************** M1 model for ~S ******************\n",x),
    printf("capacity to expand (add in GToe/yr)= ~S\n",x.growthPotential),
    printf("price in 2010 = ~F2 $/Toe\n",x.price),
    printf("production = ~F2 GTep in 2010\n",x.production) ]


// show what we think of energy consumers
[sM2() 
   -> for x in Consumer sM2(x)]
        

[sM2(x:Consumer) 
  -> printf("********** M2 model for ~S (consumption unit: GToe) [% of world] ***********\n",x),
     printf("consumes "),
    for y in Supplier
      printf("~S:~F2 [~F%],",
             y, x.consumes[y.index],x.consumes[y.index] / y.production),
    printf("\n% cancellation as price grows = ~I\n",printPP(x.cancel)),
    printf("% savings (negawatt) as f(year) = ~I\n",printYP(x.saving)) ] 

// print an affine (price to %) and (year to %)
[printRP(x:Affine) : void
  -> for i in (1 .. x.n) printf("~F% @ ~F0$ ",x.yValues[i],x.xValues[i]) ]

[printYP(x:Affine) : void
  -> for i in (1 .. x.n)  printf("~F% in ~F1 ",x.yValues[i],x.xValues[i]) ]      

[printPP(x:ListFunction) : void
  -> for i in (1 .. x.n) printf("~F%:~F% ",x.xValues[i],x.yValues[i]) ]

[printTP(x:ListFunction) : void
  -> for i in (1 .. x.n) printf("~F1C°->~F% ",x.xValues[i],x.yValues[i]) ]

// show our energy transition plan
[sM3() 
  -> let Europe := some(y in Consumer | string!(y.name) = "EU"),
         US := some(y in Consumer | string!(y.name) = "US") in
         (for x in Supplier sM3(Europe,x,Europe.subMatrix),
          for x in Supplier sM3(US,x,US.subMatrix)) ]


[sM3(y:Consumer, x:Supplier,m:list<Affine>)
  -> let n := x.index in
       (if (n < 4)
          (printf("****************** ~S M3 model for ~S ********************\n",y,x),
           for i in ((n + 1) .. 4)
            let y := some(z in Supplier | z.index = i) in
              (printf("~S to ~S = f(p): ~I \n",x,y,printYP(m[n + i - 2]))))) ]


// show the caracteristics of M4 : economy
[sM4()
  -> let w := some(e in Economy | true) in
       (printf("****************** M4 model for ~S ********************\n",w),
        printf("World GDP in 2010: ~F0 G$  with total energy consumption of ~F2 GToe\n",w.gdp * 1000,
              sum(list{x.production | x in Supplier})),
        printf("World investments in 2010: ~F0 G$ with expected ROI=~F% -> systemic growth:~F%\n",
               w.investG * 1000, w.roI, w.roI * (w.investG / w.gdp)),
        printf("Invest = ~F% of GDP + ~F% of GDP growth\n",w.iRevenue, w.iGrowth),
        printf("Technology Acceleration factor (reduce energy) = ~F%\n",w.techFactor)) ]


// show our hypothesis for Ecological Redirection (M5)
[sM5()
  -> let g := some(e in Earth | true) in
       (printf("****************** M5 model for ~S ********************\n",g),
        printf("in 2010, there was ~F1 Gt of CO2 added on ~S, at a concentration of ~F1 ppm\n",
                g.co2Add,g,g.co2PPM),
        printf("current growth in PPM is ~F2, resulting from absorption over ~F2 Gt/y\n",
                g.co2Ratio * (g.co2Add - g.co2Neutral), g.co2Neutral),
        printf("IPCC model abstraction (PPM -> +T): ~S\n",g.warming),
        printf("L2:GW disaster loss (+T -> -%GDP): ~I\n", printTP(g.disasterLoss)),
        printf("L1:pain from GW (+T -> pain%): ~I\n", printTP(g.painClimate)),
        printf("L1:pain from recession (-GDP% -> pain%): ~I\n", printPP(g.painGrowth)),
        printf("L3:pain from energy shortage to activity loss (-energy% -> pain%): ~I\n", printPP(g.painCancel))) ]
        
//  ------------ hMx() shows the simulation output (histograms) for each component models -----------------------------------

[hM1() 
 -> let ny := NY in
    (NY := 15,
    for s in FiniteSupplier 
     (printf("------------------ inventory  ~S [~I] -------\n",s,princ(pb.comment,40)),
      display(timeSample(list<float>{s.inventories[i] | i in (1 .. pb.year)})),
      printf("------------------ outputs  ~S ---------------------------------------------------\n",s),
      display(timeSample(list<float>{s.outputs[i] | i in (1 .. pb.year)}))),
    for s in InfiniteSupplier 
     (printf("------------------ capacity  ~S [~I] -------\n",s,princ(pb.comment,40)),
      display(timeSample(list<float>{s.capacities[i] | i in (1 .. pb.year)})),
      printf("------------------ outputs  ~S ---------------------------------------------------\n",s),
      display(timeSample(list<float>{s.outputs[i] | i in (1 .. pb.year)}))),
    NY := ny)]
     
[hM2()  
  -> let ny := NY in
    (NY := 15,
     for s in Supplier   
       ( printf("------------------ outputs  ~S ---------------------------------------------------\n",s),
         display(timeSample(list<float>{s.outputs[i] | i in (1 .. pb.year)})),
         printf("------------------ prices (w/o tax)  ~S ------------------------------------------\n",s),
         display(timeSample(list<float>{s.sellPrices[i] | i in (1 .. pb.year)}))),
     for c in Consumer
       (  printf("------------------ cancel ratio for ~S --------------------------\n",c),
          display(timeSample(list<float>{cancelRatio(c,i) | i in (1 .. pb.year)})),
          printf("------------------ savings ratio for ~S --------------------------\n",c),
          display(timeSample(list<float>{savingRatio(c,i) | i in (1 .. pb.year)}))),
    NY := ny,
    eTable())]    
      
[hM3()
  -> let ny := NY in
    (NY := 15,
     for tr in pb.transitions
          (printf("------------------ transition in GToe for ~S ---------------------------------------------------\n",tr.tag),
           display(timeSample(list<Energy>{actualEnergy(tr,i) | i in (1 .. pb.year)}))),
    printf("--------------------- CO2 intensity of energy (gCO2/KWh) ------------------------------------\n"),
    display(timeSample(list<float>{co2KWh(i) | i in (1 .. pb.year)})),
    NY := ny,
    tTable())]
    


// show all the transition
[tTable() 
  -> startTable(10,list<string>{label(t) | t in pb.transitions}),
     for c in Consumer
        (lineTable(string!(c.name),10,
             list<float>{c.substitutions[pb.year][t.index] | t in pb.transitions}),
         separation(10,size(pb.transitions)))]

// show all the savings
[sTable() 
  -> startTable(10,list<string>{string!(name(s)) |s in Supplier}),
     for c in Consumer
        (lineTable(string!(c.name),10,
             list<float>{(c.needs[pb.year][s.index] * c.savings[pb.year][s.index]) |
                   s in Supplier}),
         separation(10,size(Supplier)))]
     
[label(x:Transition) : string
  -> string!(x.from.name) /+ ">" /+ string!(x.to.name) ]

// look at the economy: gdp, invest and co2tax
[hM4()
  -> let ny := NY, e := pb.world.all in
    (NY := 15,
     printf("------------------ gdp  --------------------------\n"),
     display(timeSample(list<float>{e.results[i] | i in (1 .. pb.year)})),
     printf("------------------ Growth Investments  --------------------------\n"),
     display(timeSample(list<float>{e.investGrowth[i] | i in (1 .. pb.year)})),
     printf("------------------ Investments for Energy --------------------------\n"),
     display(timeSample(list<float>{e.investEnergy[i] | i in (1 .. pb.year)})),
     printf("------------------ economy loss due to lack of energy (%) -------------------------------------------------------------\n"),
     display(timeSample(list<float>{e.lossRatios[i] | i in (1 .. pb.year)})),
      printf("------------------ steel output  --------------------------\n"),
     display(timeSample(list<float>{steelConso(i) | i in (1 .. pb.year)})),
     printf("------------------ CO2 tax ~S (T$) -------------------------------------------\n",e),
     display(timeSample(list<float>{carbonTax(i)| i in (1 .. pb.year)})),
     gTable(),
     NY := ny)]

  // gTable() shows the gdp and investments for each block
  [gTable()
    -> let lyears := list{(1 + (i - 1) * (pb.year - 1) / 9) | i in (1 .. 10)} in
        (startTable(8,list<string>{string!(year!(i)) | i in lyears}),
         for b in Block
          (lineTable(string!(b.describes.name) /+ "-gdp",8,
                     list<float>{b.results[i] | i in lyears}),
           lineTable(string!(b.describes.name) /+ "-invG",8,
                     list<float>{b.investGrowth[i] |  i in lyears}),
          lineTable(string!(b.describes.name) /+ "-imp%",8,
                     list<float>{b.marginImpacts[i] |  i in lyears}),
           separation(8,length(lyears))),
         lineTable("total",8,list<float>{ pb.world.all.results[i] | i in lyears}),
         separation(8,length(lyears)))]

  // dTable show the energy consumption for each block, the density and the cancel rate
  [dTable()
    -> let lyears := list{(1 + (i - 1) * (pb.year - 1) / 9) | i in (1 .. 10)} in
        (startTable(8,list<string>{string!(year!(i)) | i in lyears}),
         for b in Block
          (lineTable(string!(b.describes.name) /+ "-cons",8,
                     list<float>{b.totalConsos[i] | i in lyears}),
           lineTable(string!(b.describes.name) /+ "-density",8,
                     list<float>{energyIntensity(b.describes,i) |  i in lyears}),
           lineTable(string!(b.describes.name) /+ "-cancel",8,
                     list<float>{cancelRatio(b.describes,i) |  i in lyears}),
           separation(8,length(lyears))),
         lineTable("total",8,list<float>{ pb.world.all.totalConsos[i] | i in lyears}),
         separation(8,length(lyears)))]
   
// zoom for one zone, shows the conso for each supplier
[eTable(c:Consumer)
  -> let lyears := list{(1 + (i - 1) * (pb.year - 1) / 9) | i in (1 .. 10)} in
        (startTable(8,list<string>{string!(year!(i)) | i in lyears}),
         for s in Supplier
          (lineTable(string!(s.name),8,
                     list<float>{c.consos[i][s.index] | i in lyears}),
           separation(8,length(lyears))),
         lineTable("total",8,list<float>{ sumConsos(c,i) | i in lyears}),
         separation(8,length(lyears)))]

  // look at T(co2), pains, loss and reaction (cancel & tax acceleration)
  [hM5()
  -> let ny := NY in
    (NY := 15,
     printf("------------------ co2 -------------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.earth.co2Levels[i] | i in (1 .. pb.year)})),
     printf("------------------ temperature -------------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.earth.temperatures[i] | i in (1 .. pb.year)})),
     printf("------------------ loss due to natural disaster (%) -------------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.earth.lossRatios[i] | i in (1 .. pb.year)})),
     printf("------------------ wheat output (worldwide) ----------------------------------------------------\n"),
     display(timeSample(list<float>{pb.world.wheatOutputs[i] | i in (1 .. pb.year)})),
     printf("------------------ average pain (worldwide) ----------------------------------------------------\n"),
     display(timeSample(list<float>{averagePain(i) | i in (1 .. pb.year)})),
     printf("------------------ average economic pain (worldwide) ----------------------------------------------------\n"),
     display(timeSample(list<float>{averageEconomyPain(i) | i in (1 .. pb.year)})),
     printf("------------------ average energy pain (worldwide) ----------------------------------------------------\n"),
     display(timeSample(list<float>{averageEnergyPain(i) | i in (1 .. pb.year)})),
     printf("------------------ average warming pain (worldwide) ----------------------------------------------------\n"),
     display(timeSample(list<float>{averageWarmingPain(i) | i in (1 .. pb.year)})),
     NY := ny)]

// ********************************************************************
// *    Part 5: Experiments                                           *
// ********************************************************************

// initialize all the simulation objects
// we want the time series *s[y]
[init(w:WorldEconomy,e:Supplier,c:Supplier) : void
  -> pb.world := w,
     pb.earth := Earth.instances[1],
     pb.oil := e,
     pb.clean := c,
     pb.priceRange := list<float>{float!(50 + ((PMAX * sqr(i)) / sqr(NIS + 1)) )
                                 | i in (2 .. (NIS + 1))},
     pb.debugCurve := list<float>{0.0 | x in (1 .. NIS)},
     pb.needCurve := list<float>{0.0 | x in (1 .. NIS)},
     pb.prodCurve := list<float>{0.0 | x in (1 .. NIS)},
     init(pb.world),
     init(pb.earth),
     consolidate(),
     for s in Supplier init(s),
     for c in Consumer init(c),     // will init the economy block
     consolidate(w.all,1)
    ]

[init(s:Supplier) : void
  ->   s.outputs := list<Energy>{ 0.0 | i in (1 .. NIT)},
       s.outputs[1] := s.production,
       s.sellPrices := list<Price>{0.0 | i in (1 .. NIT)},
       s.sellPrices[1] := s.price,
       s.gone := 0.0,
       s.added := 0.0,
       s.additions := list<Energy>{0.0 | i in (1 .. NIT)},
       case s (FiniteSupplier 
                 (s.inventories := list<Energy>{0.0 | i in (1 .. NIT)},
                  s.inventories[1] := get(s.inventory,s.price))),
       s.netNeeds := list<Energy>{0.0 | i in (1 .. NIT)},
       s.capacities := list<Energy>{0.0 | i in (1 .. NIT)},
       s.capacities[1] := s.capacityMax]

[init(c:Consumer) : void
  -> c.startNeeds := list<Energy>{ (c.consumes[s.index] / (1.0 - get(c.cancel,s.price))) |
                                   s in Supplier },
     c.needs := list<list<Energy>>{ list<Energy>() | i in (1 .. NIT)},
     c.needs[1] := c.consumes,
     c.consos := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.consos[1] := c.consumes,
     c.cancel% := list<list<Percent>>{list<Percent>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.savings := list<list<Energy>>{list<Energy>{0.0 | s in Supplier} | i in (1 .. NIT)},
     c.substitutions := list<list<Energy>>{list<Energy>{0.0 | tr in pb.transitions} | i in (1 .. NIT)},
     c.transferRates := list<list<Energy>>{list<Percent>{0.0 | tr in pb.transitions} | i in (1 .. NIT)},
     c.taxAcceleration := 0.0,
     c.cancelAcceleration := 0.0,
     c.carbonTaxes := list<Price>{0.0 | i in (1 .. NIT)},
     c.painLevels := list<float>{0.0 | i in (1 .. NIT)},
     c.painWarming := list<float>{0.0 | i in (1 .. NIT)},
     c.painResults := list<float>{0.0 | i in (1 .. NIT)},
     c.painEnergy := list<float>{0.0 | i in (1 .. NIT)},
     initBlock(c)]

 // init for the world economy
 [init(w:WorldEconomy) : void
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
     x.investEnergy[1] := x.investE,
     x.ironConsos := list<float>{0.0 | i in (1 .. NIT)},
     x.marginImpacts :=  list<Percent>{0.0 | i in (1 .. NIT)} ]

[initBlock(c:Consumer)
   -> let w := c.economy in
         (init(w),
          w.ironConsos[1] := (w.gdp / get(w.ironDriver,year!(1))),
          w.totalConsos[1] := sum(c.consumes),
          w.describes := c,
          w.openTrade := list<Percent>{100%  | w2 in Block}) ]
      
// consolidation of the world economy : init version
[consolidate()
   -> let e := pb.world.all in
         (e.gdp = sum(list{w.gdp | w in Block}), 
          e.investG = sum(list{w.investG | w in Block}),
          e.investE = sum(list{w.investE | w in Block}))]

// consolidation for a given year
[consolidate(e:Economy, y:Year)
   -> e.totalConsos[y] := sum(list{w.totalConsos[y] | w in Block}),
      e.inputs[y] := sum(list{w.inputs[y] | w in Block}),
      e.cancels[y] := sum(list{w.cancels[y] | w in Block}),
      e.results[y] := sum(list{w.results[y] | w in Block}),
      e.maxout[y] :=  sum(list{w.maxout[y] | w in Block}),
      e.investGrowth[y] :=  sum(list{w.investGrowth[y] | w in Block}),
      e.investEnergy[y] :=  sum(list{w.investEnergy[y] | w in Block}),
      // computes the weighted loss ratio for blocks
      let loss := 0.0, result := 0.0 in
         (for w in Block
            (result :+ w.results[y],
             loss :+ w.results[y] * w.lossRatios[y]),
          e.lossRatios[y] := loss / result)]

[init(x:Earth) : void
   -> x.temperatures := list<float>{0.0 | i in (1 .. NIT)},
      x.temperatures[1] := x.avgTemp,
      x.lossRatios := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Levels := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Levels[1] := x.co2PPM,
      x.co2Emissions := list<float>{0.0 | i in (1 .. NIT)},
      x.co2Emissions[1] := x.co2Add ]

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
          (p :- pb.trade[index(w)][index(w2)]),
        p)]

// ------------------------- our reusable trick -------------------------

// test1: simplest model
// we load a file of interpreted code
(#if (compiler.active? = false | compiler.loading? = true)
     (load(Id(*where* / ("gwdgv" /+ string!(Version)) / "input")))
  else nil
)
