// ********************************************************************
// *       GWDG: Global Warming Dynamic Games                         *
// *       copyright (C) 2009-2023 Yves Caseau                        *
// *       file: plot.cl - version GWDG3                             *
// ********************************************************************

// define the PlotTuple type
PlotTuple :: tuple(string,list<string>,list<float>,list<list<float>>)

// creat an empty plot tuple
[emptyPlot(name:string) : PlotTuple
   -> tuple(name,list<string>(),list<float>(),list<list<float>>())]

// start a plot tuple from the ouput of timeSample: Affine
[startPlot(name:string,serie:string,aff:Affine) : PlotTuple
   -> tuple(name,list<string>(serie),aff.xValues,list<list<float>>(aff.yValues))]


// add a plot to a plot tuple
[addPlot(plotTuple:PlotTuple,name:string,aff:Affine) : PlotTuple
   -> add(plotTuple[2],name),
      if (length(plotTuple[3]) = 0) 
         for x in aff.xValues add(plotTuple[3],x),
      add(plotTuple[4],aff.yValues),
      plotTuple]


// register a plot tuple
[registerPlot(x:any,y:PlotTuple) : void
   ->  //[0] will call plot with x = ~S and y = ~S // x,y,
       plot(x,y[1],y[2],y[3],y[4])]

M1 :: thing()
M2 :: thing()
M4 :: thing()

// this file contains plot files (similar to simul.cl
[pM1() 
 -> let plotTuple := emptyPlot("M1-inventory") in
      (for s in FiniteSupplier
         addPlot(plotTuple,string!(s.name),
                 timeSample(list<float>{s.inventories[i] | i in (1 .. pb.year)})),
       registerPlot(M1,plotTuple)),
    let plotTuple := emptyPlot("M1-capacities") in
        (for s in InfiniteSupplier
             addPlot(plotTuple,string!(s.name),
                     timeSample(list<float>{s.capacities[i] | i in (1 .. pb.year)})),
         registerPlot(M1,plotTuple)),
    let plotTuple := emptyPlot("M1-output") in
        (for s in Supplier
             addPlot(plotTuple,string!(s.name),
                     timeSample(list<float>{s.outputs[i] | i in (1 .. pb.year)})),
         registerPlot(M1,plotTuple))]   

// this version would be interesting with a log scale

[pM1-v2() 
 -> for s in FiniteSupplier 
       let plotTuple := startPlot("M1-" /+ string!(s.name),"inventory",
                 timeSample(list<float>{s.inventories[i] | i in (1 .. pb.year)})) in
         (addPlot(plotTuple,"outputs",
                 timeSample(list<float>{s.outputs[i] | i in (1 .. pb.year)})),
          registerPlot(s,plotTuple)),
    for s in InfiniteSupplier
       let plotTuple := startPlot("M1-" /+ string!(s.name),"capacities",
                 timeSample(list<float>{s.capacities[i] | i in (1 .. pb.year)})) in
         (addPlot(plotTuple,"outputs",
                 timeSample(list<float>{s.outputs[i] | i in (1 .. pb.year)})),
          registerPlot(s,plotTuple))]

[pM2() 
  -> let plotTuple := emptyPlot("M2-prices") in
       (for s in Supplier
            addPlot(plotTuple,string!(s.name),
                    timeSample(list<float>{s.sellPrices[i] | i in (1 .. pb.year)})),
        registerPlot(M2,plotTuple)),
      let plotTuple := emptyPlot("M2-cancel") in
         (for c in Consumer
                addPlot(plotTuple,string!(c.name),
                      timeSample(list<float>{cancelRatio(c,i) | i in (1 .. pb.year)})),
          registerPlot(M2,plotTuple)),
        let plotTuple := emptyPlot("M2-savings") in
           (for c in Consumer
                addPlot(plotTuple,string!(c.name),
                      timeSample(list<float>{savingRatio(c,i) | i in (1 .. pb.year)})),
            registerPlot(M2,plotTuple))]


// shows the economic output (by bock)
[pM4()
  -> let plotTuple := emptyPlot("M4-gdp") in
       (for c in Consumer
            addPlot(plotTuple,string!(c.name),
                    timeSample(list<float>{c.economy.results[i] | i in (1 .. pb.year)})),
        addPlot(plotTuple,"world",
                    timeSample(list<float>{pb.world.all.results[i] | i in (1 .. pb.year)})),
        registerPlot(M4,plotTuple)),
    let plotTuple := emptyPlot("M4-world"), e := pb.world.all  in
       (addPlot(plotTuple,"Growth investment",
                    timeSample(list<float>{e.investGrowth[i] | i in (1 .. pb.year)})),
        addPlot(plotTuple,"Energy investment",
                    timeSample(list<float>{e.investEnergy[i] | i in (1 .. pb.year)})),
        addPlot(plotTuple,"CO2 tax",
                    timeSample(list<float>{carbonTax(i) | i in (1 .. pb.year)})),
        registerPlot(M4,plotTuple))]

 
 // loads all the reports
 [claire/pM() 
  -> pM1(), pM2(),pM4()]