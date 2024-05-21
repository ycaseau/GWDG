// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
// *       file: simul.cl                                             *
// ********************************************************************

// this file contains the overall simulation engine

// ********************************************************************
// *    Part 1: Piece-wise Affine functions                           *
// *    Part 2: Tables may be handy (1980s style)                     *
// *    Part 3: Outpout with histograms                               *
// *    Part 4: Model Showback                                        *
// *    Part 5: Experiments                                           *
// ********************************************************************

// ********************************************************************
// *    Part 1: Piece-wise Affine functions                           *
// ********************************************************************

// this is a reusable library :) -----------------------------------------------

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
     else if (x > 9.99) fP2(9.99,i)
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

// test print the energy conso - we print this table in GToe (for upwards compatibility)
[eTable() 
  -> startTable(10,add(list<string>{string!(s.name) | s in Supplier},"total")),
     for c in Consumer
        (lineTable(string!(c.name) /+ "-2010",10,
             add(list<float>{perMWh(c.consumes[s.index]) | s in Supplier},
                 sum(list{perMWh(c.consumes[s.index]) | s in Supplier}))),
         lineTable(string!(c.name) /+ "-" /+ string!(year!(pb.year)),10,
             add(list<float>{perMWh(c.consos[pb.year][s.index]) | s in Supplier},
                 perMWh(c.economy.totalConsos[pb.year]))),
         separation(10,size(Supplier) + 1)),
     lineTable("total-2010",10,
             add(list<float>{sum(list{perMWh(c.consumes[s.index])| c in Consumer}) | s in Supplier},
                sum(list{ sum(list{ perMWh(c.consumes[s.index]) | c in Consumer}) | s in Supplier}))),
     lineTable("total-" /+ string!(year!(pb.year)),10,
             add(list<float>{sum(list{perMWh(c.consos[pb.year][s.index]) | c in Consumer}) | s in Supplier},
                sum(list{ sum(list{ perMWh(c.consos[pb.year][s.index]) | c in Consumer}) | s in Supplier}))),
     separation(10,size(Supplier) + 1) ]

// ********************************************************************
// *    Part 3: Outpout with histograms                               *
// ********************************************************************

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

// zoom:
[zoom()
 ->  let PMAX2 := 100 in
       (pb.priceRange := list<float>{float!(PMIN + ((PMAX2 * sqr(i)) / sqr(NIS + 1)) )
                                 | i in (2 .. (NIS + 1))},
        PMAX2) ]

        
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
  -> printf("------------------ gdp [~I] -------------------\n",princ(pb.comment,40)),
     display(timeSample(list<float>{pb.world.all.results[i] | i in (1 .. pb.year)})),
     printf("------------------ energy consumption ------------------------------------------------\n"),
     display(timeSample(list<float>{pb.world.all.totalConsos[i] | i in (1 .. pb.year)})),
     printf("------------------ wheat production ------------------------------------------------\n"),
     display(timeSample(list<float>{pb.world.wheatOutputs[i] | i in (1 .. pb.year)})),
     printf("------------------ co2 emission -------------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.earth.co2Emissions[i] | i in (1 .. pb.year)})),
     printf("------------------ co2 ppm -------------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.earth.co2Levels[i] | i in (1 .. pb.year)})),
     printf("------------------ temperature -------------------------------------------------------------\n"),
     display(timeSample(list<float>{pb.earth.temperatures[i] | i in (1 .. pb.year)})) ]



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
     display(timeSample(list<float>{c.carbonTaxes[i]| i in (1 .. pb.year)}))]

// specific focus on pain
[pain(c:Consumer) : void
  -> printf("------------------ Cancel levels for ~S [~I] ---\n",c,princ(pb.comment,40)),
     display(timeSample(list<float>{allCancel(c,i) | i in (1 .. pb.year)})),
     printf("------------------ gdp  -----------------------------------------------------------\n"),
     display(timeSample(list<float>{c.economy.results[i] | i in (1 .. pb.year)})),
     printf("------------------ co2/inhabitant for ~S ------------------------------------\n",c),
     display(timeSample(list<float>{co2PerPerson(c,i) | i in (1 .. pb.year)})),
     printf("------------------ resulting pain for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painLevels[i]| i in (1 .. pb.year)})),
     printf("------------------ pain from results for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painResults[i]| i in (1 .. pb.year)})),
     printf("------------------ pain from sobriety for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painEnergy[i]| i in (1 .. pb.year)})),
     printf("------------------ resulting pain from warming for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painWarming[i]| i in (1 .. pb.year)})),
     printf("------------------ satisfaction ~S (%) -------------------------------------\n",c),
     display(timeSample(list<float>{c.satisfactions[i]| i in (1 .. pb.year)})) ]


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
     

// co2 emission per person (in tons) for zone c, following Hannah Ritchie 
[co2PerPerson(c:Consumer,i:Year) : float
 -> let p := get(c.population,yearF(i)) in
      c.co2Emissions[i] / p ]



// ********************************************************************
// *    Part 4: Model Showback                                        *
// ********************************************************************

// test all to make sure that the code works (before compilling)
[testM()
  -> sM1(),
     sM2(),
     sM3(),
     sM4(),
     sM5(),
     hM1(),
     hM2(),
     hM3(),
     hM4(),
     hM5(),
     knus()]


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
  -> printf("****************** M4 model ********************\n"),
     printf("GDP in 2010: ~F0 G$  with total energy consumption of ~F2 GToe\n",pb.world.all.gdp * 1000,
            sum(list{x.production | x in Supplier})),
     for b in Block sM4(b),
     printf("Technology Acceleration factor (reduce energy) = ~F%\n",pb.world.techFactor) ]

[sM4(b:Block)
  ->   printf("~S: ~F0 G$ investments in 2010: ~F0 G$ with expected ROI=~F% -> systemic growth:~F%\n",b.describes,b.gdp * 1000,
               b.investG * 1000, get(b.roI,2010.0), get(b.roI,2010.0) * (b.investG / b.gdp)),
       printf("--- Invest = ~F% of GDP \n",b.iRevenue) ]


// show our hypothesis for Ecological Redirection (M5)
[sM5()
  -> let g := some(e in Earth | true) in
       (printf("****************** M5 model for ~S ********************\n",g),
        printf("in 2010, there was ~F1 Gt of CO2 added on ~S, at a concentration of ~F1 ppm\n",
                g.co2Add,g,g.co2PPM),
       // printf("current growth in PPM is ~F2, resulting from absorption over ~F2 Gt/y\n",
       //         g.co2Ratio * (g.co2Add - g.co2Neutral), g.co2Neutral),
        printf("current growth in PPM is ~F2, resulting from absorption ratio ~F%\n",
               g.co2Ratio * g.co2Add, g.co2Ratio),
        printf("IPCC model abstraction (PPM -> +T): ~S\n",g.warming),
        for c in Consumer printf("L2:GW disaster loss (+T -> -%GDP): ~I\n", c,printTP(.disasterLoss)),
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

// shows the energy consumption for a consumer, its savings and the resulting pain
[hM2(c:Consumer) 
  -> let ny := NY in
    (NY := 15,
     printf("------------------ satisfaction ~S(%) - average = ~F% --------------------------\n",
            c,average(list<float>{c.satisfactions[i] | i in (1 .. pb.year)})),
     display(timeSample(list<float>{c.satisfactions[i]| i in (1 .. pb.year)})),
     printf("------------------ consommation ~S -------------------------------------------\n",c),
     display(timeSample(list<float>{allConso(c,i) | i in (1 .. pb.year)})),
     printf("------------------ cancel ratio for ~S --------------------------\n",c),
     display(timeSample(list<float>{cancelRatio(c,i) | i in (1 .. pb.year)})),
     printf("------------------ pain from sobriety for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painEnergy[i]| i in (1 .. pb.year)})),
     printf("------------------ resulting pain for ~S  - average = ~F% --------------------------\n",
           c,average(list<float>{c.painLevels[i]| i in (1 .. pb.year)})),
     display(timeSample(list<float>{c.painLevels[i]| i in (1 .. pb.year)})),
     NY := ny)]

      
[hM3()
  -> let ny := NY in
    (NY := 15,
     for tr in pb.transitions
          (printf("------------------ transition in PWh for ~S -------------------------------------------\n",tr.tag),
           display(timeSample(list<Energy>{actualEnergy(tr,i) | i in (1 .. pb.year)}))),
    printf("--------------------- CO2 intensity of energy (gCO2/KWh) ------------------------------\n"),
    display(timeSample(list<float>{co2KWh(i) | i in (1 .. pb.year)})),
    NY := ny,
    tTable())]

// shows the energy transition for a consumer, its savings and the resulting pain
[hM3(c:Consumer) 
  -> let ny := NY in
    (NY := 15,
     printf("------------------ satisfaction ~S(%) - average = ~F% --------------------------\n",
            c,average(list<float>{c.satisfactions[i] | i in (1 .. pb.year)})),
     display(timeSample(list<float>{c.satisfactions[i]| i in (1 .. pb.year)})),
     printf("------------------ total transition for ~S  -------------------------------------\n",c),
     display(timeSample(list<float>{  sum(list<float>{ c.substitutions[i][t.index] | t in pb.transitions})
                                      | i in (1 .. pb.year)})),
     printf("------------------ CO2 emissions for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.co2Emissions[i]| i in (1 .. pb.year)})),
     printf("------------------ pain from sobriety for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painEnergy[i]| i in (1 .. pb.year)})),
     printf("------------------ resulting pain for ~S  - average = ~F% --------------------------\n",
           c,average(list<float>{c.painLevels[i]| i in (1 .. pb.year)})),
     display(timeSample(list<float>{c.painLevels[i]| i in (1 .. pb.year)})),
     NY := ny)]

// zoom on some transitions that produce s (Energy)
[hM3(c:Consumer,s:Supplier)
  -> let ny := NY in
    (NY := 15,
     printf("------------------ transition for ~towards ~S  -------------------------------------\n",c,s),
     for tr in pb.transitions
       (if (tr.to = s)
          (printf("------------------ [~A] transition ~S for ~S -------------------------------------------\n",tr.index,tr.tag,c),
           display(timeSample(list<Percent>{c.transferRates[i][tr.index]  | i in (1 .. pb.year)})),
           display(timeSample(list<Energy>{ c.substitutions[i][tr.index] | i in (1 .. pb.year)})))),
     NY := ny)]
    
// show all the transition (GToe for debug - compare with M4))
[tTable() 
  -> printf("warning: all figures are in GToe\n"),
     startTable(10,list<string>{label(t) | t in pb.transitions}),
     for c in Consumer
        (lineTable(string!(c.name),10,
             list<float>{perMWh(c.substitutions[pb.year][t.index]) | t in pb.transitions}),
         separation(10,size(pb.transitions))),
     lineTable("total",10,
         list<float>{sum(list{perMWh(c.substitutions[pb.year][t.index]) | c in Consumer}) | t in pb.transitions}),
     separation(10,size(pb.transitions))]

// debug version : for one Supplier and one year
[tTable(s:Supplier,y:Year) 
  -> let ltr := list{t in pb.transitions | t.to = s},
         total := list<float>{0.0 |  t in ltr} in
    (printf("Transition table for ~S in ~I, additions from ~F2 to ~F2 -> ~F2 net\n",
             s,y,s.addedCapacities[y - 1],s.addedCapacities[y],s.addedCapacities[y] - s.addedCapacities[y - 1]),
     startTable(10,add(list<string>{label(t) | t in ltr},"total")),
     for c in Consumer
        let ltv := list<float>{ c.transferFlows[y][t.index] | t in ltr} in
           (lineTable(string!(c.name),10, add(ltv,sum(ltv))),
            for i in (1 .. size(ltr)) total[i] :+ ltv[i],
            separation(10,1 + size(ltr))),
     lineTable("total",10,add(total ,sum(total))),
     separation(10,1 + size(ltr))) ]

// show all the savings
[sTable() 
  -> startTable(10,list<string>{string!(name(s)) |s in Supplier}),
     for c in Consumer
        (lineTable(string!(c.name),10,
             list<float>{(c.needs[pb.year][s.index] * c.savings[pb.year][s.index]) |
                   s in Supplier}),
         separation(10,size(Supplier)))]

// show electricity production
[elTable()
  -> let lyears := list{(1 + (i - 1) * (pb.year - 1) / 9) | i in (1 .. 10)} in
        (startTable(8,list<string>{string!(year!(i)) | i in lyears}),
         for c in Consumer
          (lineTable(string!(c.name),8,
                     list<float>{c.ePWhs[i] | i in lyears}),
           lineTable(string!(c.name) /+ "%",8,
                    list<float>{(100.0 * c.ePWhs[i] / allConso(c,i)) | i in lyears}),
           // debug code (look at the corrections for transfers)
           //lineTable(string!(c.name) /+ "del",8,
           //          list<float>{c.eDeltas[i] | i in lyears}),
           separation(8,length(lyears))),
          lineTable("total",8,list<float>{ sum(list{c.ePWhs[i] | c in Consumer}) | i in lyears}),
          separation(8,length(lyears)))]

// prod by supplier
[elProd() 
 -> startTable(10,add(list<string>{string!(s.name) | s in Supplier},"total")),
     for c in Consumer
        (lineTable(string!(c.name) /+ "2010" ,10,
             add(list<float>{(c.consos[1][s.index] * eRatio(c,s)) | s in Supplier},
                 sum(list{(c.consos[1][s.index] * eRatio(c,s)) | s in Supplier}))),
         lineTable(string!(c.name) ,10,
             add(list<float>{(c.consos[pb.year][s.index] * eRatio(c,s)) | s in Supplier},
                 sum(list{(c.consos[pb.year][s.index] * eRatio(c,s)) | s in Supplier}))),
          separation(10,size(Supplier) + 1))]
     
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

// hM4(c:Consumer) show the satisfaction and the factors (pain) for one zone
[hM4(c:Consumer)
  -> let ny := NY in
    (NY := 15,
     printf("------------------ satisfaction ~S(%) - average = ~F% --------------------------\n",
            c,average(list<float>{c.satisfactions[i] | i in (1 .. pb.year)})),
     display(timeSample(list<float>{c.satisfactions[i]| i in (1 .. pb.year)})),
     printf("------------------ gdp for ~S in T$ ----------------------------------------\n",c),
     display(timeSample(list<float>{c.economy.results[i] | i in (1 .. pb.year)})),
     printf("------------------ trade flow openness for ~S (%) --------------------------------\n",c),
     display(timeSample(list<float>{average(c.economy.tradeFactors[i]) | i in (1 .. pb.year)})),
     printf("------------------ resulting pain for ~S  - average = ~F% --------------------------\n",
           c,average(list<float>{c.painLevels[i]| i in (1 .. pb.year)})),
     printf("------------------ resulting pain from warming for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painWarming[i]| i in (1 .. pb.year)})),
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
                     list<float>{perMWh(b.totalConsos[i]) | i in lyears}),
           lineTable(string!(b.describes.name) /+ "-density",8,
                     list<float>{energyIntensity(b.describes,i) |  i in lyears}),
           lineTable(string!(b.describes.name) /+ "-cancel",8,
                     list<float>{cancelRatio(b.describes,i) |  i in lyears}),
           separation(8,length(lyears))),
         lineTable("total",8,list<float>{ perMWh(pb.world.all.totalConsos[i]) | i in lyears}),
         separation(8,length(lyears)))]


// zoom for one zone, shows the conso for each supplier
[eTable(c:Consumer)
  -> let lyears := list{(1 + (i - 1) * (pb.year - 1) / 9) | i in (1 .. 10)} in
        (startTable(8,list<string>{string!(year!(i)) | i in lyears}),
         for s in Supplier
          (lineTable(string!(s.name),8,
                     list<float>{perMWh(c.consos[i][s.index]) | i in lyears}),
           separation(8,length(lyears))),
         lineTable("total",8,list<float>{ perMWh(sumConsos(c,i)) | i in lyears}),
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
     display(timeSample(list<float>{pb.world.all.disasterRatios[i] | i in (1 .. pb.year)})),
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

// hM5(c:Consumer) show the satisfaction and the factors (pain) for one zone
[hM5(c:Consumer)
  -> let ny := NY in
    (NY := 15,
     printf("------------------ satisfaction ~S(%) - average = ~F% --------------------------\n",
            c,average(list<float>{c.satisfactions[i] | i in (1 .. pb.year)})),
     display(timeSample(list<float>{c.satisfactions[i]| i in (1 .. pb.year)})),
     printf("------------------ resulting pain for ~S  - average = ~F% --------------------------\n",
           c,average(list<float>{c.painLevels[i]| i in (1 .. pb.year)})),
     printf("------------------ resulting pain from warming for ~S  ----------------------------------------\n",c),
     display(timeSample(list<float>{c.painWarming[i]| i in (1 .. pb.year)})),
     printf("------------------ CO2 tax ~S (T$) -------------------------------------------\n",c),
     display(timeSample(list<float>{c.carbonTaxes[i]| i in (1 .. pb.year)})),
     NY := ny)]

// New for end of 2023 : six KNU = Key kNown Unknowns
[knus()
  -> printf("KNU1 = max clean energy per decade = ~F1 PWh/ 10 years\n",knu1()),
     printf("KNU2 = energy intensity decrease = ~F% (CAGR 2010-2050)\n",knu2()),
     printf("KNU3 = negative long-term elasticity energy demand to price = ~F%\n",knu3()),
     printf("KNU4 = approx electrification of energy = ~F% in 2050\n",knu4()),
     printf("KNU5 = average worldwide ReturnOnInvest = ~F% (2010-2050)\n",knu5()),
     printf("KNU6 = SCC estimate based on GW impact at +~F1C: ~F% => ~F1 $/t\n",
            deltaT(pb.year),avgImpact(deltaT(pb.year)), knu6())]

// these are  approximate KPI that best describe the Known Unknowns and for which we have external references

// IRINA speaks of +20 PWh / 7 years, I believe that +10PWh is more realistic
[knu1() : float
  -> let c := pb.clean in
       sum(list{get(c.growthPotential,y) | y in (2020 .. 2029) }) ]   // GTep to PWh

// Energy intensity has shown a decreaqse of 1.5% per year in the past 20 years
[knu2() : float
  -> let s := 0.0, gsum := 0.0 in
       (for b in Block
          (s :+  b.gdp * knu2(b),
           gsum :+ b.gdp),
        s / gsum) ]  // average knu2 weighted by gdp

// computes the CAGR of energy intensity for a block
[knu2(b:Block) : Percent
  -> let ratio := (1 - get(b.dematerialize,2050.0)) ^ (1 / 40.0)  in
       (1 - ratio) ]
[knu2s() 
  -> for b in Block printf("knu2 for ~S = ~F%\n",b.describes,knu2(b)) ]


// long-term elasticity is obtained by reading the cancel values between 800$ and 1600$ (-30% expected)
[knu3() : float
  -> let s := 0.0, gsum := 0.0 in
       (for c in Consumer
          (s :+  c.economy.gdp * knu3(c),
           gsum :+ c.economy.gdp),
        s / gsum) ]  // average kn3 weighted by gdp

[knu3(c:Consumer) : float
  -> let f1 := (1 - get(c.cancel,1600.0)), f2 := (1 - get(c.cancel,800.0)) in
       (f1 - f2) / f2 ]  // long term elasticity (price to cancel)

// electrification is seen as the sum of legacy (10%) and clean energy as made possible by the transition matrix
// this is a crude proxy, pending for a better model in CCEM v0.5
[knu4() : float
  -> let s := 0.0, gsum := 0.0 in
       (for c in Consumer
          (s :+  startConso(c) * knu4(c),
           gsum :+ startConso(c)),
        s / gsum) ]  // average kn3 weighted by energy conso

[knu4(c:Consumer) : Percent
  -> let f% := fossilConso(c) / startConso(c), e% := c.consumes[pb.clean.index] / startConso(c) in
        (//[5] start with ~F% fossile and ~F% clean // f%, e%,
         e% :+ get(c.subMatrix[3],2050.0) * f%,    // Oil -> clean
         e% :+ get(c.subMatrix[5],2050.0) * f%,    // Coal -> clean
         e% :+ get(c.subMatrix[6],2050.0) * f%,    // Gas -> clean
         10% + e%)]

[startConso(c:Consumer) : float
  -> sum(list{c.consumes[s.index] | s in Supplier})]

[fossilConso(c:Consumer) : float
  -> sum(list{c.consumes[i] | i in (1 .. 3)})]

// ReturnOnInvest is the average of the ROI for each block
[knu5() : float
  -> let s := 0.0, gsum := 0.0 in
       (for b in Block
          (s :+  b.gdp * knu5(b),
           gsum :+ b.gdp),
        s / gsum) ]  // average knu2 weighted by gdp

[knu5(b:Block) : float
  -> (get(b.roI,2020.0) + get(b.roI,2050.0)) / 2.0]
[knu5s() 
  -> for b in Block printf("knu5 for ~S = ~F%\n",b.describes,knu5(b)) ]

// the pseudo SCC is the marginal loss of GDP from now to 2100 with a +3C warming hypothesis
// we use two auxiliary Earth slots that are updated though the simulation : co2emissions and gdpLosses 
[knu6() : float
  -> let e := pb.earth,
         sCO2 := sum(list{e.co2Emissions[y] | y in (1 .. pb.year)}),
         sLoss := sum(list{e.gdpLosses[y] | y in (1 .. pb.year)}) in
       (sLoss / sCO2) * 1000.0  ]  // $/t

// temperature raise at year y
[deltaT(y:Year) : float
  -> let e := pb.earth in
       (e.temperatures[y] - e.avgCentury) ] 

// average impact of a +XC warming
[avgImpact(x:float) : float
  -> let e := pb.earth, s := 0.0, sgdp := 0.0 in
       (for c in Consumer
          (sgdp :+ c.economy.gdp,
           s :+ c.economy.gdp * get(c.disasterLoss,x)),
         s / sgdp) ]  



// ------------------------- our reusable trick -------------------------

// test1: simplest model
// we load a file of interpreted code
(#if (compiler.active? = false | compiler.loading? = true)
     (load(Id(*where* / ("gwdgv" /+ string!(Version)) / "input")),
      load(Id(*where* / ("gwdgv" /+ string!(Version)) / "scenario")))
  else nil
)
