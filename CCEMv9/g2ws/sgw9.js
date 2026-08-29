/***** CLAIRE Compilation of module sgw9 into Javascript for node.js 
       [version 4.1.8 / safety 3] Saturday 08-29-2026 09:03:52 *****/

const kernel = require('./ClaireKernel')


// class file for Charts in module sgw9 // 
//  forward definition of chartsclass Charts extends kernel.ClaireObject{ 
   
  constructor() { 
    super()
    } 
  
  } 


// class file for ChartsEarth in module sgw9 // 
//  what we want to record for the Earthclass ChartsEarth extends Charts{ 
   
  constructor() { 
    super()
    this.co2Emissions = []
    this.co2Levels = []
    this.temperatures = []
    this.gdpLosses = []
    } 
  
  } 


// class file for ChartsSupplier in module sgw9 // 
//  GDP losses
//  what we want to record for the Suppliersclass ChartsSupplier extends Charts{ 
   
  constructor() { 
    super()
    this.inventories = []
    this.outputs = []
    this.sellPrices = []
    this.rawNeeds = []
    this.capacities = []
    } 
  
  } 


// class file for ChartsConsumer in module sgw9 // 
//  capacities
//  what we want to record for the Consumersclass ChartsConsumer extends Charts{ 
   
  constructor() { 
    super()
    this.needs = []
    this.gdp = []
    this.consos = []
    this.carbonTaxAmounts = []
    this.cancel_Z = []
    this.savings = []
    this.painLevels = []
    } 
  
  } 


// class file for ListFunction in module sgw9 // 
//  ********************************************************************
//  *    Part 1: Supply side: Energy Production                        *
//  ********************************************************************
//  we need to manipulate simple curves - in version 0.3 we use both step- and  piece-wise linear
//  functions, defined by a list of pairs (x,f(x))class ListFunction extends kernel.ClaireObject{ 
   
  constructor() { 
    super()
    this.xValues = []
    this.yValues = []
    this.minValue = 0
    this.maxValue = 0
    this.n = 0
    } 
  
  // ----- class method self_print @ ListFunction ------------- 
  SelfPrint () { 
    kernel.print_any(this.isa)
    kernel.PRINC("(")
    var i  = 1
    var g0079  = this.n
    while (i <= g0079) { 
      if (i != 1) { 
        kernel.PRINC(" ")
        } 
      kernel.princ_float9(this.xValues[i-1],2)
      kernel.PRINC(":")
      kernel.princ_float9(this.yValues[i-1],2)
      i = (i+1)
      } 
     kernel.PRINC(")")
    } 
  
  // ----- class method diet_copy @ ListFunction ------------- 
  //  diet version of copy for a ListFunction (used in scalarProduct and boundedProduct)  DietCopy () { 
    var Result 
    if (this.isa.IsIn(C_Affine) == true) { 
      var g0080  = this
      var _CL_obj  = (new Affine()).Is(C_Affine)
      _CL_obj.n = g0080.n
      Result = _CL_obj
      } else {
      var _CL_obj  = (new StepFunction()).Is(C_StepFunction)
      _CL_obj.n = this.n
      Result = _CL_obj
      } 
    return Result
    } 
  
  // ----- class method adds @ ListFunction ------------- 
  //  adds a constant for a ListFunction  Adds (x) { 
    var Result 
    var l2  = this.DietCopy()
    l2.xValues = this.xValues
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0082  = this.n
      while (i <= g0082) { 
        kernel.add_list(i_bag,(this.yValues[i-1]+x))
        i = (i+1)
        } 
      va_arg2 = i_bag
      l2.yValues = va_arg2
      } 
    l2.minValue = (this.minValue+x)
    l2.maxValue = (this.maxValue+x)
    Result = l2
    return Result
    } 
  
  // ----- class method scalarProduct @ ListFunction ------------- 
  //  simple scalar product for a ListFunction  ScalarProduct (x) { 
    var Result 
    var l2  = this.DietCopy()
    l2.xValues = this.xValues
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0087  = this.n
      while (i <= g0087) { 
        kernel.add_list(i_bag,(this.yValues[i-1]*x))
        i = (i+1)
        } 
      va_arg2 = i_bag
      l2.yValues = va_arg2
      } 
    l2.minValue = (this.minValue*x)
    l2.maxValue = (this.maxValue*x)
    Result = l2
    return Result
    } 
  
  // ----- class method boundedProduct @ ListFunction ------------- 
  //  hyperbolic
  //  bounded multiplication for a ListFunction
  //  scalarProduct but the factor is adjusted so that maxValue is still between the bounds  BoundedProduct (x,minVal,maxVal) { 
    var Result 
    var factor  = (boundedMultiply(this.maxValue,x,minVal,maxVal)/this.maxValue)
    Result = this.ScalarProduct(factor)
    return Result
    } 
  
  // ----- class method adjust @ ListFunction ------------- 
  //  adjust a policy represented by an affine function: keep the dates, change the value by a factor
  //  destructive operation -> changes the affine / list function  Adjust (factor) { 
    var i  = 1
    var g0090  = this.n
    while (i <= g0090) { 
      this.yValues[i-1]=(this.yValues[i-1]*factor)
      i = (i+1)
      } 
    } 
  
  } 


// class file for StepFunction in module sgw9 // 
//  StepFunction is the simplestclass StepFunction extends ListFunction{ 
   
  constructor() { 
    super()
    this.xValues = []
    this.yValues = []
    this.minValue = 0
    this.maxValue = 0
    this.n = 0
    } 
  
  // ----- class method CAGR @ StepFunction ------------- 
  //  this would make gw0 non diet
  //  [get(a:Affine,x:integer) : float 
  //    -> get(a,float!(x)) ]
  //  compounded growth from a growth rate Stepfunction (assumes that a(y) returns the growth rate)  CAGR (origin,y) { 
    var Result 
    var v  = 1
    var i  = (origin+1)
    var g0091  = y
    while (i <= g0091) { 
      v = (v*(1+this.Get(yearF(i))))
      i = (i+1)
      } 
    Result = v
    return Result
    } 
  
  // ----- class method get @ StepFunction ------------- 
  //  returns the value of the step function for a given point between m and M : easier !  Get (x) { 
    var Result 
    var i  = 0
    var j  = 1
    var g0094  = this.n
    while (j <= g0094) { 
      if (this.xValues[j-1] > x) { 
        i = j
        break // loop = tuple("niet", any)
        } 
      j = (j+1)
      } 
    Result = ((i == 0) ? 
      this.yValues[this.n-1] :
      ((i == 1) ? 
        this.yValues[0] :
        this.yValues[(i-1)-1]))
    return Result
    } 
  
  } 


// class file for Affine in module sgw9 // 
//  Affine uses a linear interpolation  class Affine extends ListFunction{ 
   
  constructor() { 
    super()
    this.xValues = []
    this.yValues = []
    this.minValue = 0
    this.maxValue = 0
    this.n = 0
    } 
  
  // ----- class method get @ Affine ------------- 
  //  returns the value of the affine function for a given point between m and M  Get (x) { 
    var Result 
    var i  = 0
    var j  = 1
    var g0095  = this.n
    while (j <= g0095) { 
      if (this.xValues[j-1] > x) { 
        i = j
        break // loop = tuple("niet", any)
        } 
      j = (j+1)
      } 
    if (i == 0) { 
      Result = this.yValues[this.n-1]
      }  else if (i == 1) { 
      Result = this.yValues[0]
      } else {
      var x1  = this.xValues[(i-1)-1]
      var x2  = this.xValues[i-1]
      var y1  = this.yValues[(i-1)-1]
      var y2  = this.yValues[i-1]
      Result = (y1+(((y2-y1)*(x-x1))/(x2-x1)))
      } 
    return Result
    } 
  
  // ----- class method accelerate @ Affine ------------- 
  Accelerate (factor) { 
    var Result 
    var _CL_obj  = (new Affine()).Is(C_Affine)
    _CL_obj.n = this.n
    _CL_obj.yValues = this.yValues
    _CL_obj.minValue = this.minValue
    _CL_obj.maxValue = this.maxValue
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0096  = this.n
      while (i <= g0096) { 
        kernel.add_list(i_bag,(2000+((this.xValues[i-1]-2000)*(1-factor))))
        i = (i+1)
        } 
      va_arg2 = i_bag
      _CL_obj.xValues = va_arg2
      } 
    Result = _CL_obj
    return Result
    } 
  
  // ----- class method improve @ Affine ------------- 
  //  improve : modify the factors without changing the dates  Improve (factor) { 
    var Result 
    var _CL_obj  = (new Affine()).Is(C_Affine)
    _CL_obj.n = this.n
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0097  = this.n
      while (i <= g0097) { 
        kernel.add_list(i_bag,(this.yValues[i-1]*(1+factor)))
        i = (i+1)
        } 
      va_arg2 = i_bag
      _CL_obj.yValues = va_arg2
      } 
    _CL_obj.minValue = (this.minValue*(1+factor))
    _CL_obj.maxValue = (this.maxValue*(1+factor))
    _CL_obj.xValues = this.xValues
    Result = _CL_obj
    return Result
    } 
  
  // ----- class method improve% @ Affine ------------- 
  Improve_Z (factor) { 
    var Result 
    var _CL_obj  = (new Affine()).Is(C_Affine)
    _CL_obj.n = this.n
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0098  = this.n
      while (i <= g0098) { 
        kernel.add_list(i_bag,improve_Z_float(this.yValues[i-1],factor))
        i = (i+1)
        } 
      va_arg2 = i_bag
      _CL_obj.yValues = va_arg2
      } 
    _CL_obj.minValue = improve_Z_float(this.minValue,factor)
    _CL_obj.maxValue = improve_Z_float(this.maxValue,factor)
    _CL_obj.xValues = this.xValues
    Result = _CL_obj
    return Result
    } 
  
  // ----- class method multiply% @ Affine ------------- 
  Multiply_Z (factor) { 
    var Result 
    var _CL_obj  = (new Affine()).Is(C_Affine)
    _CL_obj.n = this.n
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0099  = this.n
      while (i <= g0099) { 
        kernel.add_list(i_bag,multiply_Z_float(this.yValues[i-1],factor))
        i = (i+1)
        } 
      va_arg2 = i_bag
      _CL_obj.yValues = va_arg2
      } 
    _CL_obj.minValue = multiply_Z_float(this.minValue,factor)
    _CL_obj.maxValue = multiply_Z_float(this.maxValue,factor)
    _CL_obj.xValues = this.xValues
    Result = _CL_obj
    return Result
    } 
  
  } 


// class file for Transition in module sgw9 // 
//  in GW3 we create transition objects (s1 -> s2) to make the code easier to read !class Transition extends kernel.ClaireObject{ 
   
  constructor() { 
    super()
    this.index = 1
    this.efficiency_Z = 1
    this.heat_Z = 0
    this.adaptationFactor = 0
    } 
  
  // ----- class method self_print @ Transition ------------- 
  SelfPrint () { 
    kernel.PRINC("(")
    kernel.print_any(this.from)
    kernel.PRINC("->")
    kernel.print_any(this.to)
    kernel.PRINC("):")
     kernel.princ_integer(this.index)
    } 
  
  // ----- class method transferAmount @ Transition ------------- 
  //  additional transfer amounts for a transition  TransferAmount (c,y) { 
    return  c.transferFlows[y-1][this.index-1]
    } 
  
  // ----- class method actualEnergy @ Transition ------------- 
  //  actual transfer in PWh (world wide)  ActualEnergy (y) { 
    var Result 
    var g0100  = 0
    for (const g0103 of C_Consumer.descendants){ 
      for (const g0102 of g0103.instances){ 
        var g0101  = g0102.substitutions[y-1][this.index-1]
        g0100 = (g0100+g0101)
        } 
      } 
    Result = g0100
    return Result
    } 
  
  } 


// class file for Supplier in module sgw9 // 
//  an energy supplier is defined by its inventory and the way it can be brought
//  to market (price-wise = strategy & production-wise = constraints)class Supplier extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.index = 1
    this.production = 0
    this.capacityOrigin = 0
    this.investPrice = 0
    this.co2Factor = 0
    this.co2Kwh = 0
    this.from = []
    this.steelFactor = 0
    this.heat_Z = 0
    this.capacityFactor = 1.1
    this.techFactor = 0
    this.capacityMax = 0
    this.outputs = []
    this.sellPrices = []
    this.gone = 0
    this.addedCapacity = 0
    this.addedCapacities = []
    this.additions = []
    this.rawNeeds = []
    this.capacities = []
    } 
  
  // ----- class method getTransition @ Supplier ------------- 
  //  finds a transition  GetTransition (s2) { 
    var Result 
    var x 
    var tr_some  = null
    for (const tr of this.from){ 
      if (tr.to == s2) { 
        tr_some = tr
        break // loop = tuple("niet", any)
        } 
      } 
    x = tr_some
    if (kernel.owner_any(x).IsIn(C_Transition) == true) { 
      var g0104  = x
      Result = g0104
      } else {
      Result = kernel.MakeError("no transition exists from ~S to ~S",[this,s2]).Close()
      } 
    return Result
    } 
  
  // ----- class method getSupply @ Supplier ------------- 
  //  [1] [2] compute what the output for x:Supplier would be at price p
  //  CCEM v8 is much simpler since equilibriumPrice is a KNU  GetSupply (p,cMax,y) { 
    var Result 
    var cProd  = (this.production*(cMax/this.capacityOrigin))
    var pRatio  = (p/this.equilibriumPrice.Get(yearF(y)))
    Result = ((cMax <= (cProd*pRatio)) ? 
      cMax :
      (cProd*pRatio))
    return Result
    } 
  
  // ----- class method forwardMaxCapacity @ Supplier ------------- 
  //  what we expect from previous year: last year capacity + added capacity during year y (decision of y-1)  ForwardMaxCapacity (y) { 
    return  (this.capacities[(y-1)-1]+this.additions[(y-1)-1])
    } 
  
  // ----- class method prodGrowth @ Supplier ------------- 
  //  when ratio is just smaller than 1
  //  this is a heuristic that needs to get adjusted, it says that the maxcapacity should be X% (110)
  //  of the net demand that was seen (net = needs - cancel) averaged over past 3 years
  //  the three year average used used by averaging two linear interpolation (2f(n-1) - f(n-2))  ProdGrowth (prev,y) { 
    var Result 
    if (y <= 3) { 
      Result = 0.02
      } else {
      var s  = ((((7*this.rawNeeds[(y-1)-1])-(2*this.rawNeeds[(y-2)-1]))-this.rawNeeds[(y-3)-1])/4)
      Result = (((s*this.capacityFactor)/prev)-1)
      } 
    return Result
    } 
  
  // ----- class method prodInspect @ Supplier ------------- 
  //  debug inspection   ProdInspect (prev,s,y) { 
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] >>> prev(")
    kernel.print_any(this)
    kernel.PRINC(")=")
    kernel.printFDigit_float(prev,2)
    kernel.PRINC(", 3 years is ")
    kernel.printFDigit_float(s,2)
    kernel.PRINC(" Gtoe from ")
    var arg_1 
    var i_bag  = []
    var i  = ((2 <= (y-3)) ? 
      (y-3) :
      2)
    var g0110  = (y-1)
    while (i <= g0110) { 
      kernel.add_list(i_bag,this.rawNeeds[i-1])
      i = (i+1)
      } 
    arg_1 = i_bag
    kernel.princ_list(arg_1)
     kernel.PRINC("\n")
    } 
  
  // ----- class method computeCapacity @ Supplier ------------- 
  //  The second step is to maximize the utility function over a price range from 0 to X, (that is
  //  with a capacity that does not increase more than 15%
  //  CCEM v6:  MaxCapacity(x:Supplier,y:Year) includes the added capacities -> historicized into capacities[y]  ComputeCapacity (y) { 
    var cMax  = this.GetMaxCapacity(y)
    this.capacities[y-1]=cMax
    this.capacityMax = ((this.capacityMax <= cMax) ? 
      cMax :
      this.capacityMax)
    } 
  
  // ----- class method oilEquivalent @ Supplier ------------- 
  //  when we compute cancellation, all threshold are defined with oilPrice
  //  this is a normalized (equivalent of oil, adjusted for price increase)  OilEquivalent (p) { 
    return  ((p*C_pb.oil.sellPrices[0])/this.sellPrices[0])
    } 
  
  // ----- class method recordCapacity @ Supplier ------------- 
  //  each production has a price (Invest = capacity increase / 20)
  //  we distribute the energy investment across the blocs using energy consumption as a ratio
  //  note: we call this once consomations are known  RecordCapacity (y) { 
    var p1  = this.AveragePrice(y,3)
    var addCapacity  = kernel.max_float(0,(this.capacities[y-1]-this.ForwardMaxCapacity(y)))
    if (this.isa.IsIn(C_FiniteSupplier) == true) { 
      var g0111  = this
      g0111.inventories[y-1]=(g0111.inventory.Get(p1)-g0111.gone)
      } 
    
    var addInvest  = ((addCapacity*this.investPrice)*kernel._exp_float((1-this.techFactor),y))
    for (const g0112 of C_Block.descendants){ 
      for (const b of g0112.instances){ 
        b.investCapacity[y-1]=(b.investCapacity[y-1]+(addInvest*this.ShareOfConsumption(b,y)))
        b.investEnergy[y-1]=(b.investEnergy[y-1]+(addInvest*this.ShareOfConsumption(b,y)))
        } 
      } 
    } 
  
  // ----- class method averagePrice @ Supplier ------------- 
  //  in CCEMv9, we reintroduce an average to avoid oscillation  (average over n=3 years)  AveragePrice (y,n) { 
    var Result 
    var n1  = ((1 <= ((y-n)+1)) ? 
      ((y-n)+1) :
      1)
    var n2  = y
    var sum 
    var g0121  = 0
    var g0123  = n1
    var g0124  = n2
    while (g0123 <= g0124) { 
      var g0122  = this.sellPrices[g0123-1]
      g0121 = (g0121+g0122)
      g0123 = (g0123+1)
      } 
    sum = g0121
    Result = (sum/((n2-n1)+1))
    return Result
    } 
  
  // ----- class method shareOfConsumption @ Supplier ------------- 
  //  share of energy consumption for a block
  //  we use the previous year to get the ratio (consumption is not known yet)  ShareOfConsumption (b,y) { 
    var Result 
    var arg_1 
    var g0125  = 0
    for (const g0128 of C_Block.descendants){ 
      for (const g0127 of g0128.instances){ 
        var g0126  = g0127.describes.consos[(y-1)-1][this.index-1]
        g0125 = (g0125+g0126)
        } 
      } 
    arg_1 = g0125
    Result = (b.describes.consos[(y-1)-1][this.index-1]/arg_1)
    return Result
    } 
  
  // ----- class method balanceEnergy @ Supplier ------------- 
  BalanceEnergy (y) { 
    var production  = this.GetSupply(this.sellPrices[y-1],this.ExpectedCapacity(y),y)
    var listConsos 
    var c_bag  = []
    for (const g0129 of C_Consumer.descendants){ 
      for (const c of g0129.instances){ 
        kernel.add_list(c_bag,c.HowMuch(this,this.OilEquivalent(c.TruePrice(this,y))))
        } 
      } 
    listConsos = c_bag
    var total 
    var g0130  = 0
    for (const g0131 of listConsos){ 
      g0130 = (g0130+g0131)
      } 
    total = g0130
    
    
    for (const g0132 of C_Consumer.descendants){ 
      for (const c of g0132.instances){ 
        c.consos[y-1][this.index-1]=(listConsos[c.index-1]*(production/total))
        } 
      } 
    } 
  
  // ----- class method maxTransferFlow @ Supplier ------------- 
  //  maxTransferFlow is the sum of all transfer rates (from all s2 to s) at the max possible level from the existing one (y  -1)
  //  note the look-ahead pattern: the code is similar to updateRate (without the capacity constraint)
  //  approximate : since c.consos is not known yet, we use the previous year's consos  MaxTransferFlow (y) { 
    var Result 
    var e  = 0
    for (const tr of C_pb.transitions){ 
      if (tr.to == this) { 
        for (const g0133 of C_Consumer.descendants){ 
          for (const c of g0133.instances){ 
            var w1  = c.TransferRate(tr,(y-1))
            var w2  = kernel.max_float(w1,c.GetTransferRate(tr,y))
            e = (e+((w2-w1)*c.consos[(y-1)-1][tr.from.index-1]))
            } 
          } 
        } 
      } 
    Result = e
    return Result
    } 
  
  // ----- class method priceDeltaRate @ Supplier ------------- 
  //  new in v9: we modulate the max transfer rate based on the price delta between s1 and s2
  //  if control parameter is 100%, we cut the transfer if price increas is 50%  PriceDeltaRate (s2,y) { 
    var Result 
    var p1  = this.sellPrices[(y-1)-1]
    var p2  = s2.sellPrices[(y-1)-1]
    Result = (1-kernel.max_float(0,kernel.min_float(1,((((p2-p1)/p1)*2)*C_pb.transferPriceSensitivity))))
    return Result
    } 
  
  // ----- class method showProduction @ Supplier ------------- 
  //  debug : show production and capacity  ShowProduction (y,cMax) { 
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] prodShow(")
    kernel.print_any(this)
    kernel.PRINC(") cMax=")
    kernel.printFDigit_float(this.capacities[y-1],2)
    kernel.PRINC("(adds:")
    kernel.printFDigit_float(this.additions[(y-1)-1],2)
    kernel.PRINC("); needs=")
    var arg_1 
    var g0134  = 0
    for (const g0137 of C_Consumer.descendants){ 
      for (const g0136 of g0137.instances){ 
        var g0135  = g0136.economy.needs[y-1][this.index-1]
        g0134 = (g0134+g0135)
        } 
      } 
    arg_1 = g0134
    kernel.printFDigit_float(arg_1,2)
     kernel.PRINC("TWh\n")
    } 
  
  // ----- class method showOutput @ Supplier ------------- 
  //  debug: explain the reasonning of supplier equation (getOutput)  ShowOutput (y,cMax,p) { 
    var cProd  = (this.production*(cMax/this.capacityOrigin))
    var pRatio  = (p/this.equilibriumPrice.Get(yearF(y)))
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] output(")
    kernel.print_any(this)
    kernel.PRINC(")@")
    kernel.printFDigit_float(p,2)
    kernel.PRINC("=")
    kernel.printFDigit_float(this.GetOutput(p,y),2)
    kernel.PRINC(" {max:")
    kernel.printFDigit_float(cMax,2)
    kernel.PRINC(", projected:")
    kernel.printFDigit_float(cProd,2)
    kernel.PRINC("} (pratio: ")
    kernel.printFDigit_float((pRatio*100),1)
    kernel.PRINC("%")
    kernel.PRINC(")\n")
    } 
  
  // ----- class method checkTransfers @ Supplier ------------- 
  //  checks that transfers are consistent (delta capacities versus current levels of transfers)  CheckTransfers (y) { 
    this.addedCapacities[y-1]=this.addedCapacity
    var delta1  = (this.addedCapacity-this.addedCapacities[(y-1)-1])
    var delta2  = 0
    for (const tr of C_pb.transitions){ 
      if (tr.to == this) { 
        for (const g0138 of C_Consumer.descendants){ 
          for (const c of g0138.instances){ 
            if (this == C_TESTE) { 
              
              } 
            delta2 = (delta2+tr.TransferAmount(c,y))
            } 
          } 
        } 
      } 
    if ((kernel.abs_float((delta2-delta1))/this.addedCapacity) >= 0.001) { 
      kernel.tformat("[~S] ---- TRANSFERS @ ~S: delta1 = ~F2 (~F3 - ~F3) vs delta2 = ~F2\n",0,[year_I(y),
        this,
        delta1,
        this.addedCapacity,
        this.addedCapacities[(y-1)-1],
        delta2])
      } 
    } 
  
  // ----- class method marketModelError @ Supplier ------------- 
  //  call when there is a market model error and no equilibrium can be found  MarketModelError (y) { 
    kernel.tformat("********************** IMPOSSIBLE TO SOLVE MARKET EQUATION [~S] ********************** \n",0,[this])
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0139  = C_NIS
      while (i <= g0139) { 
        kernel.add_list(i_bag,this.GetOutput(C_pb.priceRange[i-1],y))
        i = (i+1)
        } 
      va_arg2 = i_bag
      C_pb.prodCurve = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0140  = C_NIS
      while (i <= g0140) { 
        kernel.add_list(i_bag,totalDemand(y,this,C_pb.priceRange[i-1]))
        i = (i+1)
        } 
      va_arg2 = i_bag
      C_pb.needCurve = va_arg2
      } 
    kernel.PRINC("prod Curve is ")
    kernel.print_any(C_pb.prodCurve)
    kernel.PRINC("\n")
    kernel.PRINC("need Curve is ")
    kernel.print_any(C_pb.needCurve)
    kernel.PRINC("\n")
     kernel.MakeError("stop error with solve(~S)",[this]).Close()
    } 
  
  // ----- class method avgTax @ Supplier ------------- 
  //  average tax   AvgTax (y) { 
    var Result 
    var w1  = 0
    var w2  = 0
    for (const g0141 of C_Consumer.descendants){ 
      for (const c of g0141.instances){ 
        w1 = (w1+(c.Tax(this,y)*c.economy.needs[y-1][this.index-1]))
        w2 = (w2+c.economy.needs[y-1][this.index-1])
        } 
      } 
    Result = (w1/w2)
    return Result
    } 
  
  // ----- class method updateChartsSupplier @ Supplier ------------- 
  //  update the Charts for a supplier  UpdateChartsSupplier (y) { 
    udapdateChart(this.charts.outputs,y,this.outputs)
    udapdateChart(this.charts.sellPrices,y,this.sellPrices)
    if (this.isa.IsIn(C_FiniteSupplier) == true) { 
      var g0142  = this
      udapdateChart(g0142.charts.inventories,y,g0142.inventories)
      } 
    udapdateChart(this.charts.capacities,y,this.capacities)
     udapdateChart(this.charts.rawNeeds,y,this.rawNeeds)
    } 
  
  // ----- class method init @ Supplier ------------- 
  //  supplier initialization (and reinit)  Init () { 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0145  = C_NIT
      while (i <= g0145) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.outputs = va_arg2
      } 
    this.outputs[0]=this.production
    { 
      var va_arg2 
      var arg_1 
      var arg_2 
      var arg_3 
      var g0146  = 0
      for (const g0149 of C_Consumer.descendants){ 
        for (const g0148 of g0149.instances){ 
          var g0147  = g0148.eSources[this.index-1]
          g0146 = (g0146+g0147)
          } 
        } 
      arg_3 = g0146
      arg_2 = (C_CARNOT*arg_3)
      arg_1 = (this.production-arg_2)
      va_arg2 = (arg_1/this.production)
      this.heat_Z = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0150  = C_NIT
      while (i <= g0150) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.sellPrices = va_arg2
      } 
    this.sellPrices[0]=this.equilibriumPrice.Get(yearF(1))
    this.gone = 0
    this.addedCapacity = 0
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0151  = C_NIT
      while (i <= g0151) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.additions = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0152  = C_NIT
      while (i <= g0152) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.addedCapacities = va_arg2
      } 
    if (this.isa.IsIn(C_FiniteSupplier) == true) { 
      var g0153  = this
      { 
        var va_arg2 
        var i_bag  = []
        var i  = 1
        var g0154  = C_NIT
        while (i <= g0154) { 
          kernel.add_list(i_bag,0)
          i = (i+1)
          } 
        va_arg2 = i_bag
        g0153.inventories = va_arg2
        } 
      g0153.inventories[0]=g0153.inventory.Get(g0153.sellPrices[0])
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0155  = C_NIT
      while (i <= g0155) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.rawNeeds = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0156  = C_NIT
      while (i <= g0156) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.capacities = va_arg2
      } 
    this.capacityMax = this.capacityOrigin
     this.capacities[0]=this.capacityOrigin
    } 
  
  // ----- class method energyWeight @ Supplier ------------- 
  //  weight of sector s for energy e (percentage, the sum must be 100%)
  //  inputs are e, s, lweight (list of sector weight for zone)  EnergyWeight (s,lweight) { 
    var Result 
    var v  = (lweight[s.index-1]*s.energy_Z[this.index-1])
    var total 
    var g0157  = 0
    for (const g0160 of C_Sector.descendants){ 
      for (const g0159 of g0160.instances){ 
        var g0158  = (lweight[g0159.index-1]*g0159.energy_Z[this.index-1])
        g0157 = (g0157+g0158)
        } 
      } 
    total = g0157
    Result = (v/total)
    return Result
    } 
  
  } 


// class file for FiniteSupplier in module sgw9 // 
//  keep track of max capacity
//  two subclasses with two capacity model
//  This is the regular one for fossile fuels : finite inventory = f(price)class FiniteSupplier extends Supplier{ 
   
  constructor(name) { 
    super(name)
    this.index = 1
    this.production = 0
    this.capacityOrigin = 0
    this.investPrice = 0
    this.co2Factor = 0
    this.co2Kwh = 0
    this.from = []
    this.steelFactor = 0
    this.heat_Z = 0
    this.capacityFactor = 1.1
    this.techFactor = 0
    this.capacityMax = 0
    this.outputs = []
    this.sellPrices = []
    this.gone = 0
    this.addedCapacity = 0
    this.addedCapacities = []
    this.additions = []
    this.rawNeeds = []
    this.capacities = []
    this.capacityGrowth = 0
    this.threshold = 0
    this.inventories = []
    } 
  
  // ----- class method getOutput @ FiniteSupplier ------------- 
  //  verbosity for model M1 
  //  CCEM simplification : the use of getSupply is only here
  //  v8: one unique getSupply equation [1][2] but different formulas for cMax  GetOutput (p,y) { 
    return  this.GetSupply(p,this.InventoryToMaxCapacity(this.capacities[y-1],this.Reserve(p,y)),y)
    } 
  
  // ----- class method getMaxCapacity @ FiniteSupplier ------------- 
  //  CCEM v8 is simpler both for fossil and clean energy  GetMaxCapacity (y) { 
    return  this.ExpectedCapacity(y)
    } 
  
  // ----- class method expectedCapacity @ FiniteSupplier ------------- 
  //  current max capacity should be proportional to inventory modulo the growth constraints
  //  we also take into account the quantity that was added through substitutions (cf. PrevMax uses additions)
  //  p is the average price of the last 3 years -> sets available inventory
  //  [3] regular version for fossile energies : tries to match the evolution of demand
  //  capacity is adjusted when the inventory is below the threshold level  ExpectedCapacity (y) { 
    var Result 
    var prev  = this.ForwardMaxCapacity(y)
    var I1  = this.inventories[(y-1)-1]
    var rProd  = this.ProdGrowth(prev,y)
    var rGrowth  = kernel.max_float(0,((rProd <= this.capacityGrowth) ? 
      rProd :
      this.capacityGrowth))
    Result = this.InventoryToMaxCapacity((prev*(1+rGrowth)),I1)
    return Result
    } 
  
  // ----- class method reserve @ FiniteSupplier ------------- 
  //  reserve is the inventory minus what is already sold 
  //  the price used to get the inventory is a combination of proposed price and the previous price  Reserve (p,y) { 
    return  (this.inventory.Get(p)-this.gone)
    } 
  
  // ----- class method inventoryToMaxCapacity @ FiniteSupplier ------------- 
  //  new in CCEM v6: the adaptation to low inventory is piecewise linear (to avoid oscillation)
  //  CCEMv8: inventoryToMaxCapacity is now continuous (so capacityMax is ajusted)  InventoryToMaxCapacity (capacity,inventory) { 
    var Result 
    var ratio  = (inventory/this.threshold)
    var cMax  = this.capacityMax
    Result = ((ratio > 1) ? 
      capacity :
      ((ratio < 0.5) ? 
        ((capacity <= ((ratio*cMax)*1.75)) ? 
          capacity :
          ((ratio*cMax)*1.75)) :
        kernel.min_float(capacity,(cMax*(1-(((1-ratio)*(1-ratio))*0.5))))))
    return Result
    } 
  
  // ----- class method maxTransferRate @ FiniteSupplier ------------- 
  //  computes the max capacity growth as a percentage of the complete max flow (all other s2 to s, all blocks)
  //  w1 is the current rate, w2 is the expected rate, we apply the same proportional reduction factor so that the actual transfer flow meets the constraint  MaxTransferRate (y) { 
    var Result 
    var f  = this.MaxTransferFlow(y)
    Result = ((f > 0) ? 
      kernel.min_float(1,((this.capacityGrowth*this.ForwardMaxCapacity(C_pb.year))/f)) :
      0)
    return Result
    } 
  
  // ----- class method showMaxCapacity @ FiniteSupplier ------------- 
  //  debug: explain the reasonning for max capacity (finite case)  ShowMaxCapacity (y,cMax) { 
    var prev  = this.capacities[(y-1)-1]
    var I1  = this.inventories[(y-1)-1]
    var rProd  = this.ProdGrowth(prev,y)
    var rGrowth  = kernel.max_float(0,((rProd <= this.capacityGrowth) ? 
      rProd :
      this.capacityGrowth))
    var c  = this.InventoryToMaxCapacity((prev*(1+rGrowth)),I1)
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] >>> inventory(")
    kernel.print_any(this)
    kernel.PRINC(") = ")
    kernel.printFDigit_float(I1,2)
    kernel.PRINC("; ")
    kernel.printFDigit_float(this.gone,2)
    kernel.PRINC(" (gone)\n")
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] >>> max capacity(")
    kernel.print_any(this)
    kernel.PRINC(")=")
    kernel.printFDigit_float(prev,2)
    kernel.PRINC(" -> ")
    kernel.printFDigit_float(cMax,2)
    kernel.PRINC(" (formula) ->(inventory ratio: ")
    kernel.printFDigit_float(((I1/this.threshold)*100),1)
    kernel.PRINC("%")
    kernel.PRINC(" & rProd = ")
    kernel.printFDigit_float((rProd*100),1)
    kernel.PRINC("%")
    kernel.PRINC(" => rGrowth=")
    kernel.printFDigit_float((rGrowth*100),1)
    kernel.PRINC("%")
    kernel.PRINC(") Gtep {additions:")
    kernel.printFDigit_float(this.additions[(y-1)-1],2)
    kernel.PRINC("}\n")
    } 
  
  // ----- class method see @ FiniteSupplier ------------- 
  See (y) { 
    kernel.print_any(this)
    kernel.PRINC(": price = ")
    kernel.printFDigit_float(this.sellPrices[y-1],2)
    kernel.PRINC("(")
    kernel.printFDigit_float(((this.sellPrices[y-1]/this.sellPrices[0])*100),1)
    kernel.PRINC("%")
    kernel.PRINC("), inventory = ")
    kernel.printFDigit_float((this.inventory.Get(this.sellPrices[y-1])-this.gone),2)
    kernel.PRINC(", prod = ")
    kernel.printFDigit_float(this.outputs[y-1],2)
     kernel.PRINC("\n")
    } 
  
  } 


// class file for InfiniteSupplier in module sgw9 // 
//  a useful trace for debug: level of known inventory
//  new in GW3: infinite energy model where the potential of new capacity depends on the priceclass InfiniteSupplier extends Supplier{ 
   
  constructor(name) { 
    super(name)
    this.index = 1
    this.production = 0
    this.capacityOrigin = 0
    this.investPrice = 0
    this.co2Factor = 0
    this.co2Kwh = 0
    this.from = []
    this.steelFactor = 0
    this.heat_Z = 0
    this.capacityFactor = 1.1
    this.techFactor = 0
    this.capacityMax = 0
    this.outputs = []
    this.sellPrices = []
    this.gone = 0
    this.addedCapacity = 0
    this.addedCapacities = []
    this.additions = []
    this.rawNeeds = []
    this.capacities = []
    } 
  
  // ----- class method getOutput @ InfiniteSupplier ------------- 
  //  version of getOutput for clean energy using getSupply (CCEM v6 is Diet => no overloading)  GetOutput (p,y) { 
    return  this.GetSupply(p,this.capacities[y-1],y)
    } 
  
  // ----- class method getMaxCapacity @ InfiniteSupplier ------------- 
  //    CCEM v7 fsh(expectedCapacity(s,y) + s.capacities[y - 1]) / 2 ]
  //  simpler for Clean energy  GetMaxCapacity (y) { 
    return  this.ExpectedCapacity(y)
    } 
  
  // ----- class method expectedCapacity @ InfiniteSupplier ------------- 
  //  [4] new version for clean energies -> growthPotential tells how much we could add
  //  capacity tries to match 110% of net demand (this should become a parameter, hard coded in test1.cl)   ExpectedCapacity (y) { 
    var Result 
    var prev  = this.ForwardMaxCapacity(y)
    var maxDelta  = this.MaxYearlyAdditions(y)
    var expected  = this.ProdGrowth(prev,y)
    var growth  = kernel.max_float(0,(((expected*prev) <= maxDelta) ? 
      (expected*prev) :
      maxDelta))
    Result = (prev+growth)
    return Result
    } 
  
  // ----- class method maxYearlyAdditions @ InfiniteSupplier ------------- 
  //  how how huch capacity can be added this year, taking the transfer additions into account (CCEM v6)
  //  this code assumes that the additions (computed in the year before) meet the growthPotential constraint  MaxYearlyAdditions (y) { 
    return  kernel.max_float(0,(this.growthPotential.Get(yearF(y))-this.additions[(y-1)-1]))
    } 
  
  // ----- class method maxTransferRate @ InfiniteSupplier ------------- 
  //  for Clean, s.growthPotential is the max PWh that we can add in a year  MaxTransferRate (y) { 
    var Result 
    var f  = this.MaxTransferFlow(y)
    Result = ((f > 0) ? 
      kernel.min_float(1,(this.growthPotential.Get(yearF(C_pb.year))/f)) :
      0)
    return Result
    } 
  
  // ----- class method showMaxCapacity @ InfiniteSupplier ------------- 
  //  same for InfiniteSupplier  ShowMaxCapacity (y,cMax) { 
    var prev  = this.capacities[(y-1)-1]
    var maxDelta  = this.MaxYearlyAdditions(y)
    var rProd  = this.ProdGrowth(prev,y)
    var growth  = kernel.max_float(0,(((rProd*prev) <= maxDelta) ? 
      (rProd*prev) :
      maxDelta))
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] >>> max capacity(")
    kernel.print_any(this)
    kernel.PRINC(")=")
    kernel.printFDigit_float(prev,2)
    kernel.PRINC("->")
    kernel.printFDigit_float(cMax,2)
    kernel.PRINC(" (rProd=")
    kernel.printFDigit_float((rProd*100),1)
    kernel.PRINC("%")
    kernel.PRINC(",maxD=")
    kernel.printFDigit_float(maxDelta,2)
    kernel.PRINC(" => growth=")
    kernel.printFDigit_float(growth,2)
    kernel.PRINC(") PWh {additions:")
    kernel.printFDigit_float(this.additions[(y-1)-1],2)
    kernel.PRINC("}\n")
    
    } 
  
  // ----- class method see @ InfiniteSupplier ------------- 
  See (y) { 
    kernel.print_any(this)
    kernel.PRINC(": price = ")
    kernel.printFDigit_float(this.sellPrices[y-1],2)
    kernel.PRINC("(")
    kernel.printFDigit_float(((this.sellPrices[y-1]/this.sellPrices[0])*100),1)
    kernel.PRINC("%")
    kernel.PRINC("), capacity growth potential = ")
    kernel.printFDigit_float(this.growthPotential.Get(yearF(y)),2)
    kernel.PRINC(", prod = ")
    kernel.printFDigit_float(this.outputs[y-1],2)
     kernel.PRINC("\n")
    } 
  
  } 


// class file for Sector in module sgw9 // 
//  new in CCEM v8: introduce energy sectorsclass Sector extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.index = 1
    this.energy_Z = []
    this.subMatrix = []
    } 
  
  } 


// class file for Economy in module sgw9 // 
//  ********************************************************************
//  *    Part 3: Economy and Strategies                                *
//  ********************************************************************
//  in v0.1 we keep one global economy
//  i.e. the consumers are all aggregated into oneclass Economy extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.gdp = 0
    this.startGrowth = 0
    this.investG = 0
    this.investE = 0
    this.iRevenue = 0
    this.totalConsos = []
    this.cancels = []
    this.sobriety = []
    this.inputs = []
    this.maxout = []
    this.results = []
    this.investGrowth = []
    this.investEnergy = []
    this.investTransition = []
    this.investCapacity = []
    this.disasterRatios = []
    this.lossRatios = []
    this.ironConsos = []
    this.reducedImports = []
    this.marginImpacts = []
    } 
  
  // ----- class method gdp$ @ Economy ------------- 
  Gdp_dollar (y) { 
    return  (this.results[y-1]*C_pb.world.inflation.CAGR(1,y))
    } 
  
  // ----- class method see @ Economy ------------- 
  See (y) { 
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] ")
    var arg_1 
    if (this.isa.IsIn(C_Block) == true) { 
      var g0165  = this
      arg_1 = g0165.describes
      } else {
      arg_1 = C_pb.world
      } 
    kernel.print_any(arg_1)
    kernel.PRINC(" GDP=")
    kernel.printFDigit_float(this.results[y-1],2)
    kernel.PRINC("T$(+")
    kernel.printFDigit_float(CAGR_float(this.results[0],this.results[y-1],(y-1)),1)
    kernel.PRINC(" %), invest=")
    kernel.printFDigit_float(this.investGrowth[y-1],1)
    kernel.PRINC("T$, conso=")
    kernel.printFDigit_float(this.totalConsos[y-1],2)
    kernel.PRINC(", steel:")
    kernel.printFDigit_float(this.ironConsos[y-1],1)
    kernel.PRINC("Gt\n")
    if (this == C_pb.world.all) { 
      kernel.PRINC("[")
      kernel.princ_integer(year_I(y))
      kernel.PRINC("] steel consos: ")
      kernel.printFDigit_float(this.ironConsos[y-1],2)
      kernel.PRINC("Gt at price ")
      kernel.printFDigit_float(C_pb.world.steelPrices[y-1],1)
      kernel.PRINC("$/t\n")
      kernel.PRINC("[")
      kernel.princ_integer(year_I(y))
      kernel.PRINC("] agro production: ")
      kernel.printFDigit_float(C_pb.world.wheatOutputs[y-1],2)
      kernel.PRINC("Gt from surface ")
      kernel.printFDigit_float(C_pb.world.agroSurfaces[y-1],1)
       kernel.PRINC("\n")
      } 
    } 
  
  // ----- class method init @ Economy ------------- 
  //  init the variables associated to a block (represents a consumer economy)      Init () { 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0167  = C_NIT
      while (i <= g0167) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.totalConsos = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0168  = C_NIT
      while (i <= g0168) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.inputs = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0169  = C_NIT
      while (i <= g0169) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.cancels = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0170  = C_NIT
      while (i <= g0170) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.sobriety = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0171  = C_NIT
      while (i <= g0171) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.results = va_arg2
      } 
    this.results[0]=this.gdp
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0172  = C_NIT
      while (i <= g0172) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.maxout = va_arg2
      } 
    this.maxout[0]=this.gdp
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0173  = C_NIT
      while (i <= g0173) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.investGrowth = va_arg2
      } 
    this.investGrowth[0]=this.investG
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0174  = C_NIT
      while (i <= g0174) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.investEnergy = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0175  = C_NIT
      while (i <= g0175) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.investTransition = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0176  = C_NIT
      while (i <= g0176) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.investCapacity = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0177  = C_NIT
      while (i <= g0177) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.lossRatios = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0178  = C_NIT
      while (i <= g0178) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.disasterRatios = va_arg2
      } 
    this.investEnergy[0]=this.investE
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0179  = C_NIT
      while (i <= g0179) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.ironConsos = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0180  = C_NIT
      while (i <= g0180) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.reducedImports = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0181  = C_NIT
      while (i <= g0181) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.marginImpacts = va_arg2
      } 
    } 
  
  // ----- class method consolidate @ Economy ------------- 
  //  consolidation for a given year  Consolidate (y) { 
    var arg_1 
    var g0182  = 0
    for (const g0185 of C_Block.descendants){ 
      for (const g0184 of g0185.instances){ 
        var g0183  = g0184.totalConsos[y-1]
        g0182 = (g0182+g0183)
        } 
      } 
    arg_1 = g0182
    this.totalConsos[y-1]=arg_1
    var arg_2 
    var g0186  = 0
    for (const g0189 of C_Block.descendants){ 
      for (const g0188 of g0189.instances){ 
        var g0187  = g0188.inputs[y-1]
        g0186 = (g0186+g0187)
        } 
      } 
    arg_2 = g0186
    this.inputs[y-1]=arg_2
    var arg_3 
    var g0190  = 0
    for (const g0193 of C_Block.descendants){ 
      for (const g0192 of g0193.instances){ 
        var g0191  = g0192.cancels[y-1]
        g0190 = (g0190+g0191)
        } 
      } 
    arg_3 = g0190
    this.cancels[y-1]=arg_3
    var arg_4 
    var g0194  = 0
    for (const g0197 of C_Block.descendants){ 
      for (const g0196 of g0197.instances){ 
        var g0195  = g0196.sobriety[y-1]
        g0194 = (g0194+g0195)
        } 
      } 
    arg_4 = g0194
    this.sobriety[y-1]=arg_4
    var arg_5 
    var g0198  = 0
    for (const g0201 of C_Block.descendants){ 
      for (const g0200 of g0201.instances){ 
        var g0199  = g0200.results[y-1]
        g0198 = (g0198+g0199)
        } 
      } 
    arg_5 = g0198
    this.results[y-1]=arg_5
    var arg_6 
    var g0202  = 0
    for (const g0205 of C_Block.descendants){ 
      for (const g0204 of g0205.instances){ 
        var g0203  = g0204.maxout[y-1]
        g0202 = (g0202+g0203)
        } 
      } 
    arg_6 = g0202
    this.maxout[y-1]=arg_6
    var arg_7 
    var g0206  = 0
    for (const g0209 of C_Block.descendants){ 
      for (const g0208 of g0209.instances){ 
        var g0207  = g0208.investGrowth[y-1]
        g0206 = (g0206+g0207)
        } 
      } 
    arg_7 = g0206
    this.investGrowth[y-1]=arg_7
    var arg_8 
    var g0210  = 0
    for (const g0213 of C_Block.descendants){ 
      for (const g0212 of g0213.instances){ 
        var g0211  = g0212.investEnergy[y-1]
        g0210 = (g0210+g0211)
        } 
      } 
    arg_8 = g0210
    this.investEnergy[y-1]=arg_8
    var loss  = 0
    var disaster  = 0
    var result  = 0
    for (const g0214 of C_Block.descendants){ 
      for (const w of g0214.instances){ 
        result = (result+w.results[y-1])
        disaster = (disaster+(w.results[y-1]*(w.disasterRatios[y-1]/(1-w.disasterRatios[y-1]))))
        loss = (loss+(w.results[y-1]*w.lossRatios[y-1]))
        } 
      } 
    this.disasterRatios[y-1]=(disaster/result)
    this.lossRatios[y-1]=(loss/result)
    } 
  
  } 


// class file for Block in module sgw9 // 
//  code is cleaner if we call the economy of a Consumer a Blockclass Block extends Economy{ 
   
  constructor(name) { 
    super(name)
    this.gdp = 0
    this.startGrowth = 0
    this.investG = 0
    this.investE = 0
    this.iRevenue = 0
    this.totalConsos = []
    this.cancels = []
    this.sobriety = []
    this.inputs = []
    this.maxout = []
    this.results = []
    this.investGrowth = []
    this.investEnergy = []
    this.investTransition = []
    this.investCapacity = []
    this.disasterRatios = []
    this.lossRatios = []
    this.ironConsos = []
    this.reducedImports = []
    this.marginImpacts = []
    this.needs = []
    this.carbonTaxAmounts = []
    this.socialExpenseValues = []
    this.openTrade = []
    this.tradeFactors = []
    this.giniStart = 0
    this.giniLevels = []
    } 
  
  // ----- class method index @ Block ------------- 
  //  same index for a block and its economy                        Index () { 
    return  this.describes.index
    } 
  
  // ----- class method economyRatio @ Block ------------- 
  //  GW4 : the economy dependency (gdp -> Gtoe) is made of local and export influence
  //  this is a multiplicative factor (applied to inital state)  EconomyRatio (y) { 
    if (y == 2) { 
      return  (1+this.startGrowth)
      } else {
      return  (this.NewMaxout(y)/this.gdp)
      } 
    } 
  
  // ----- class method globalEconomyRatio @ Block ------------- 
  //  [3] export influence from other block to which w is exporting (assuming w does not protect its frontiers)  
  //  v5: changed economyRatio to w (the health of the importing economy)
  //  cf comments in log.cl this is a differential equation, what is returned is (1 + dx/x) 
  //           dE/E = dLocal/Local x (Local/E = innerTrade) + dExport/Export x (Export/E) + dImport/Import x (Import / E)
  //  CCEMv6: simplification => we separate the MaxOut factor from trade impact  GlobalEconomyRatio (y) { 
    return  (this.EconomyRatio(y)*this.TradeRatio(y))
    } 
  
  // ----- class method tradeRatio @ Block ------------- 
  //  trade Ratio = 1 when no trade barriers are in place - used for needs (M2) and results (M4)  TradeRatio (y) { 
    return  ((this.InnerTrade()+this.OuterCommerceRatio(y))+importReductionRatio_Block1(this,y))
    } 
  
  // ----- class method outerCommerceRatio @ Block ------------- 
  //  returns the new outTrade ration (fraction of GDP) because of trade barrier
  //  no trade barriers => returns (1 - innerTrade(w)) by construction
  //  CCEM v6 note: still expressed as a fraction of w.GDP  OuterCommerceRatio (y) { 
    var Result 
    var g0257  = 0
    for (const g0260 of C_Block.descendants){ 
      for (const g0259 of g0260.instances){ 
        if (g0259 != this) { 
          var g0258  = (C_pb.trade[this.Index()-1][g0259.Index()-1]*(1+this.ExportReductionRatio(g0259,y)))
          g0257 = (g0257+g0258)
          } 
        } 
      } 
    Result = g0257
    return Result
    } 
  
  // ----- class method exportReductionRatio @ Block ------------- 
  //  reduction of exportation factor (w -> w2) because of w2 CBAM - always negative  ExportReductionRatio (w2,y) { 
    return  kernel.min_float(0,((w2.openTrade[this.Index()-1]-1)*C_pb.world.protectionismOutFactor))
    } 
  
  // ----- class method importTradeRatio @ Block ------------- 
  //  trade from w2 -> w expressed as a fraction of w gdp (hence the 2nd term)  ImportTradeRatio (w2,y) { 
    return  (C_pb.trade[w2.Index()-1][this.Index()-1]*(w2.gdp/this.gdp))
    } 
  
  // ----- class method newMaxout @ Block ------------- 
  //  [1] this computes the maxout expected at year y based on previous year, poopulation growth and growth invest
  //  we use the heuristic (expected damage on GDP) that we differentiate between two years and multiply by 3 to 
  //  compensate the integration factor (GDP growing and disaster ratio growing, so final compound effect needs to be multiplied by 3)
  //  v8 change : removed the population factor (in the age of AI)  NewMaxout (y) { 
    return  (((this.maxout[(y-1)-1]*(1-this.Decay(y)))*this.ProductionDecline(y))+(this.investGrowth[(y-1)-1]*this.RoI(y)))
    } 
  
  // ----- class method showMaxout @ Block ------------- 
  //  new value-assets
  //  show the maxout growth (without the effects of energy loss)  ShowMaxout (y) { 
    kernel.PRINC("=== MaxOut for block ")
    kernel.print_any(this)
    kernel.PRINC(" in year ")
    kernel.princ_integer(year_I(y))
    kernel.PRINC(" is ")
    kernel.printFDigit_float(this.NewMaxout(y),2)
    kernel.PRINC("T$ [+")
    kernel.printFDigit_float((((this.NewMaxout(y)-this.maxout[(y-1)-1])/this.maxout[(y-1)-1])*100),1)
    kernel.PRINC("%")
    kernel.PRINC("] (decay: ")
    kernel.printFDigit_float((this.Decay(y)*100),2)
    kernel.PRINC("%")
    kernel.PRINC(" invest: ")
    kernel.printFDigit_float(this.investGrowth[(y-1)-1],2)
    kernel.PRINC("T$ roi: ")
    kernel.printFDigit_float((this.RoI(y)*100),2)
    kernel.PRINC("%")
     kernel.PRINC(")\n")
    } 
  
  // ----- class method roI @ Block ------------- 
  //  new in CCEM v8, roI(b) is a function, and so is decay
  //  in CCEM v9, socialExpenses (values) is dynamic (adjusted by M5 heuristics)
  //  we also drop the square, because the burden for EU vs US is too much  RoI (y) { 
    return  (((this.DefaultRoI(y)*this.roiEfficiency.Get(yearF(y)))*this.GetCompetitiveness(y))*(1-this.socialExpenseValues[(y-1)-1]))
    } 
  
  // ----- class method defaultRoI @ Block ------------- 
  //      ((1 - b.socialExpenseValues[y - 1]) ^ 2.0)]  - CCEM v8
  //  new in CCEM v9, the default RoI (pb.world.returnOnInvestment) can be adjusted by x.roiAdjustment in a linear way  DefaultRoI (y) { 
    return  (C_pb.world.returnOnInvestment*(1+(this.describes.tactic.roiAdjustment*(((y <= 100) ? 
      y :
      100)/100))))
    } 
  
  // ----- class method showRoi @ Block ------------- 
  //  debug : showROI  ShowRoi (y) { 
    kernel.PRINC("=== ROI for block ")
    kernel.print_any(this)
    kernel.PRINC(" in year ")
    kernel.princ_integer(year_I(y))
    kernel.PRINC(" is ")
    kernel.printFDigit_float((this.RoI(y)*100),2)
    kernel.PRINC("%")
    kernel.PRINC("=")
    kernel.printFDigit_float((this.DefaultRoI(y)*100),1)
    kernel.PRINC("%")
    kernel.PRINC(" * ")
    kernel.printFDigit_float((this.roiEfficiency.Get(yearF(y))*100),2)
    kernel.PRINC("%")
    kernel.PRINC(" * ")
    kernel.printFDigit_float((kernel._exp_float((1-this.socialExpenseValues[(y-1)-1]),2)*100),2)
    kernel.PRINC("%")
    kernel.PRINC(" * [")
    kernel.printFDigit_float((this.GetCompetitiveness(y)*100),2)
    kernel.PRINC("%")
    kernel.PRINC(":")
    kernel.printFDigit_float((this.LaborCostFactor(y)*100),2)
    kernel.PRINC("%")
     kernel.PRINC("]\n")
    } 
  
  // ----- class method laborCostFactor @ Block ------------- 
  //  competitiveness is a KNU (affine) that takes labor cost (proxy : gdp/h) as input  LaborCostFactor (y) { 
    return  ((this.results[(y-1)-1]/populationEstimate_Consumer2(this.describes,y))/(C_pb.world.all.results[(y-1)-1]/worldPopulation(y)))
    } 
  
  // ----- class method getCompetitiveness @ Block ------------- 
  //  computes the competitiveness of b based on labor cost  GetCompetitiveness (y) { 
    return  C_pb.world.competitivenessFactor.Get(this.LaborCostFactor(y))
    } 
  
  // ----- class method decay @ Block ------------- 
  //  decay is the rate at which productive assets dissolve, depends on economy maturity  Decay (y) { 
    return  this.decayTable.Get(yearF(y))
    } 
  
  // ----- class method productionDecline @ Block ------------- 
  //  [4] HF = Human Factor;  differential : one year versus the previous one as multiplier
  //  in CCEM v8, we take both populationGrowth modulo AI and productivityLoss effect
  //  this factor reduces production due to lack of engagement due to pain  ProductionDecline (y) { 
    var Result 
    var c  = this.describes
    Result = ((y == 2) ? 
      1 :
      this.LaborProductionFactor(y,(c.ProductivityLoss((y-1))/c.ProductivityLoss((y-2)))))
    return Result
    } 
  
  // ----- class method laborProductionFactor @ Block ------------- 
  //  hook for v10 => requires precise data mining of active population ratio   LaborProductionFactor (y,decline) { 
    var Result 
    var pf  = (populationEstimate_Consumer2(this.describes,y)/populationEstimate_Consumer2(this.describes,(y-1)))
    var arf  = ((C_APFv10 == true) ? 
      (this.describes.ActivePop_Z(y)/this.describes.ActivePop_Z((y-1))) :
      1)
    var aif  = this.describes.tactic.aiReplaceFactor
    Result = (((((1-aif)*pf)*arf)*decline)+aif)
    return Result
    } 
  
  // ----- class method consumes @ Block ------------- 
  //  efficiency computed in M5
  //  [2] [3] very simple economical equation of a regional economy (Block)
  //  note : in GW3 we have one world economy, in GW4 we may separate
  //  (a) we take the inverst into account to comput w.maxout
  //  (b) we take the energy consumption cancellation into account
  //  (c) we take the GW distasters into account  Consumes (y) { 
    var e  = C_pb.earth
    var iv  = this.investGrowth[(y-1)-1]
    var t  = e.temperatures[(y-1)-1]
    var disasterFactor  = this.describes.DisasterRatio(t,y)
    this.disasterRatios[y-1]=disasterFactor
    this.maxout[y-1]=this.NewMaxout(y)
    C_pb.totalInvest = (C_pb.totalInvest+this.investGrowth[(y-1)-1])
    C_pb.totalGrowth = (C_pb.totalGrowth+(this.investGrowth[(y-1)-1]*this.RoI(y)))
    this.tradeFactors[y-1]=this.TradeImportFactors(y)
    e.gdpLosses[y-1]=(e.gdpLosses[y-1]+(this.maxout[y-1]*disasterFactor))
    var c  = this.describes
    var f  = c.adapt.levels[(y-1)-1]
    var avoidLosses  = (((this.maxout[y-1]*disasterFactor)*f)/(1-f))
    e.adaptGains[y-1]=(e.adaptGains[y-1]+avoidLosses)
    c.adapt.losses[y-1]=(this.maxout[y-1]*disasterFactor)
    c.adapt.gains[y-1]=avoidLosses
    
    
    this.lossRatios[y-1]=this.ImpactFromCancel(y)
    this.results[y-1]=(((this.maxout[y-1]*(1-disasterFactor))*(1-this.lossRatios[y-1]))*this.TradeRatio(y))
    
    
    this.ComputeInvest(y)
    } 
  
  // ----- class method computeInvest @ Block ------------- 
  //  [6] computes the invest for a block
  //  CCEM v7: adaptation reduces partially the investment  ComputeInvest (y) { 
    var iv  = this.investGrowth[(y-1)-1]
    var invE  = this.investEnergy[y-1]
    var r1  = this.results[(y-1)-1]
    var r2  = this.results[y-1]
    var ix  = 0
    var invAdapt  = this.describes.adapt.spends[(y-1)-1]
    
    ix = (((r2*this.iRevenue)*(1-this.lossRatios[y-1]))*(1-this.describes.MarginReduction(y)))
    C_pb.totalEInvest = (C_pb.totalEInvest+invE)
    this.investGrowth[y-1]=((ix-invAdapt)+this.carbonTaxAmounts[y-1])
    if (false == true) { 
      this.ShowGrowth(y)
      } 
    } 
  
  // ----- class method showGrowth @ Block ------------- 
  //  show the growth = invest x RoI  ShowGrowth (y) { 
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] ")
    kernel.print_any(this)
    kernel.PRINC(" growth = ")
    kernel.printFDigit_float((((this.results[y-1]-this.results[(y-1)-1])/this.results[(y-1)-1])*100),1)
    kernel.PRINC("%")
    kernel.PRINC(", from invest=")
    kernel.printFDigit_float(this.investGrowth[y-1],2)
    kernel.PRINC("T$[")
    kernel.printFDigit_float(((this.investGrowth[y-1]/this.results[y-1])*100),1)
    kernel.PRINC("%")
    kernel.PRINC("] (energy: -")
    kernel.printFDigit_float((this.describes.MarginReduction(y)*100),1)
    kernel.PRINC("%")
    kernel.PRINC(")x RoI ")
    kernel.printFDigit_float((this.RoI(y)*100),1)
    kernel.PRINC("%")
     kernel.PRINC("\n")
    } 
  
  // ----- class method tradeImportFactors @ Block ------------- 
  //  book keeping (store in M4 for easier debugging)  TradeImportFactors (y) { 
    var Result 
    var w2_bag  = []
    for (const g0277 of C_Block.descendants){ 
      for (const w2 of g0277.instances){ 
        kernel.add_list(w2_bag,this.openTrade[w2.Index()-1])
        } 
      } 
    Result = w2_bag
    return Result
    } 
  
  // ----- class method impactFromCancel @ Block ------------- 
  //  [5] GW4: fraction of the maxoutput that is used for a block (vs cancelled)
  //  1.0 if no impact, 0 if 100% cancelled
  //  cancel rate is transformed into impact for each zone, modulo redistribution policy  ImpactFromCancel (y) { 
    var Result 
    var s_energy  = 0
    var s_cancel  = 0
    var s_control  = 0
    var c  = this.describes
    var conso 
    var g0278  = 0
    for (const g0279 of c.consos[y-1]){ 
      g0278 = (g0278+g0279)
      } 
    conso = g0278
    var cancel  = c.SumCancelBySupplier(y)
    var ratio  = (cancel/(conso+cancel))
    var ratio_with_r  = (((1-c.redistribution)*c.cancelImpact.Get(ratio))+(c.redistribution*ratio))
    
    Result = ratio_with_r
    return Result
    } 
  
  // ----- class method showTrade @ Block ------------- 
  //  debug  ShowTrade (y) { 
    kernel.PRINC("[")
    kernel.print_any(year_I(y))
    kernel.PRINC("] ")
    kernel.print_any(this)
    kernel.PRINC(" maxout = ")
    kernel.printFDigit_float(this.maxout[y-1],2)
    kernel.PRINC(" (ImportRatio ")
    kernel.printFDigit_float((importReductionRatio_Block1(this,y)*100),1)
    kernel.PRINC("%")
    kernel.PRINC(", ExportRatio ")
    kernel.printFDigit_float((this.OuterCommerceRatio(y)*100),1)
    kernel.PRINC("%")
     kernel.PRINC(")\n")
    } 
  
  // ----- class method steelConsumption @ Block ------------- 
  SteelConsumption (y) { 
    this.ironConsos[y-1]=(this.results[y-1]/this.ironDriver.Get(yearF(y)))
     false
    } 
  
  // ----- class method importTradeFraction @ Block ------------- 
  //  adjusted imports from w2 to w, as a fraction of w2 gdp
  //  first term is import (w2 -> w) , second term is protectionism reduction factor  ImportTradeFraction (w2,y) { 
    return  (C_pb.trade[w2.Index()-1][this.Index()-1]*(1+importReductionRatio_Block2(this,w2,y)))
    } 
  
  // ----- class method innerTrade @ Block ------------- 
  //  fraction of gdp that is not linked to external trade  InnerTrade () { 
    var Result 
    var p  = 1
    for (const g0280 of C_Block.descendants){ 
      for (const w2 of g0280.instances){ 
        if (w2 != this) { 
          p = (p-C_pb.trade[this.Index()-1][w2.Index()-1])
          } 
        } 
      } 
    Result = p
    return Result
    } 
  
  } 


// class file for Strategy in module sgw9 // 
//  a strategy is a GTES (game theory) description of the player
//  formula : sat(c) = sigma{y | (1 - discountRate) ^ (y - 1) * sat(c,y)}
//            sat(c,y) = weightCO2 * absR(co2(y) - targetCO2(y)) +                 // expects linear degrowth to netZero
//                       weightGPD * (1 - relR(CAGR(y) - targetGDP(y)) +
//                      + weightPeople * (1 - Pain(y))) }class Strategy extends kernel.ClaireObject{ 
   
  constructor() { 
    super()
    this.discountRate = 0
    this.targetCO2 = 0
    this.targetGDP = 0
    this.weightCO2 = 0
    this.weightEconomy = 0
    this.weightPeople = 0
    } 
  
  // ----- class method self_print @ Strategy ------------- 
  //  prints a strategy  SelfPrint () { 
    kernel.PRINC("strategy(CO2:")
    kernel.printFDigit_float((this.targetCO2*100),1)
    kernel.PRINC("%")
    kernel.PRINC("x")
    kernel.printFDigit_float((this.weightCO2*100),1)
    kernel.PRINC("%")
    kernel.PRINC(",Economy:")
    kernel.printFDigit_float((this.targetGDP*100),1)
    kernel.PRINC("%")
    kernel.PRINC("x")
    kernel.printFDigit_float((this.weightEconomy*100),1)
    kernel.PRINC("%")
    kernel.PRINC(",Climate:")
    kernel.printFDigit_float((this.weightPeople*100),1)
    kernel.PRINC("%")
     kernel.PRINC(")")
    } 
  
  } 


// class file for Tactics in module sgw9 // 
//  note: c.substitution can only increase in a monotonic manner
//  Tactics is a bloc of slots that represent redirection parametersclass Tactics extends kernel.ClaireObject{ 
   
  constructor() { 
    super()
    this.taxFromPain = 0
    this.cancelFromPain = 0
    this.savingStart = 0
    this.savingFromPain = 0
    this.transitionStart = 0
    this.transitionFromPain = 1
    this.protectionismStart = 0
    this.protectionismFromPain = 0
    this.adaptMax = 0.2
    this.adaptStart = 0
    this.adaptFromPain = 0
    this.aiReplaceFactor = 0
    this.roiAdjustment = 0
    } 
  
  // ----- class method self_print @ Tactics ------------- 
  //  prints a tactics  SelfPrint () { 
    kernel.PRINC("Tactics(")
    kernel.print_any(this.tacticFrom)
     kernel.PRINC(")")
    } 
  
  } 


// class file for Adaptation in module sgw9 // 
//  CCEM v7 toto: we add an adaptation policy to each Consumerclass Adaptation extends kernel.ClaireObject{ 
   
  constructor() { 
    super()
    this.investFactor = 0
    this.spends = []
    this.sums = []
    this.levels = []
    this.losses = []
    this.gains = []
    } 
  
  } 


// class file for Consumer in module sgw9 // 
//  each bloc is a group of countries (BRIC, USEurope, ...)
//  Consumer is exported to Claire to facilitate UI developmentclass Consumer extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.index = 1
    this.consumes = []
    this.eSources = []
    this.maxSaving = 0
    this.yearlySaving = 0.01
    this.subMatrix = []
    this.population = []
    this.populationDistribution = []
    this.adultPopulation = []
    this.youngs = []
    this.seniors = []
    this.productivityFactor = 0
    this.populationFactor = 0
    this.redistribution = 0
    this.taxAcceleration = 0
    this.cancelAcceleration = 0
    this.protectionismFactor = 0
    this.consos = []
    this.ePWhs = []
    this.eDeltas = []
    this.co2Emissions = []
    this.cancel_Z = []
    this.substitutions = []
    this.savingRates = []
    this.savings = []
    this.eSavings = []
    this.transferRates = []
    this.transferFlows = []
    this.painLevels = []
    this.painEnergy = []
    this.painWarming = []
    this.painResults = []
    this.savingFactors = []
    this.transitionFactors = []
    this.satisfactions = []
    this.cursat = 0
    } 
  
  // ----- class method satScore @ Consumer ------------- 
  //  returns the satisfaction score once the satisfaction vector is computed  SatScore () { 
    var Result 
    var s  = 0
    var s2  = 0
    var n  = C_pb.year
    var y  = 2
    var g0281  = n
    while (y <= g0281) { 
      var discount  = kernel._exp_float((1-this.objective.discountRate),(y-1))
      s = (s+(discount*this.satisfactions[y-1]))
      s2 = (s2+discount)
      y = (y+1)
      } 
    Result = (s/s2)
    return Result
    } 
  
  // ----- class method tactical @ Consumer ------------- 
  //  sets the tactic for a consumer  Tactical (tStart,tFromPain,tCancel,pStart,tProtect,tTax) { 
    kernel.write(C_transitionStart,this,tStart)
    kernel.write(C_transitionFromPain,this,tFromPain)
    kernel.write(C_cancelFromPain,this,tCancel)
    kernel.write(C_protectionismStart,this,pStart)
    kernel.write(C_protectionismFromPain,this,tProtect)
     kernel.write(C_taxFromPain,this,tTax)
    } 
  
  // ----- class method gdp$ @ Consumer ------------- 
  Gdp_dollar (y) { 
    return  this.economy.Gdp_dollar(y)
    } 
  
  // ----- class method getNeed @ Consumer ------------- 
  //  verbosity for model M2
  //  [1] computes the need - Step 1
  //  two ways: (a) direct application of economy/status
  //            (b) memory: "dampening factor"
  //  Note: pop  growth comes from Emerging countries => mostly linear (KISS)
  //  GW4: the need are now localized (c.gdp)  GetNeed (y) { 
    var b  = this.economy
    var c0 
    var g0282  = 0
    for (const g0283 of this.consumes){ 
      g0282 = (g0282+g0283)
      } 
    c0 = g0282
    var dmr  = this.DematerializationRate(y)
    var c2  = (((c0*dmr)*b.GlobalEconomyRatio(y))*(1-b.disasterRatios[(y-1)-1]))
    
    
    
    var arg_1 
    var s_bag  = []
    for (const g0284 of C_Supplier.descendants){ 
      for (const s of g0284.instances){ 
        kernel.add_list(s_bag,(c2*this.Ratio(s)))
        } 
      } 
    arg_1 = s_bag
    b.needs[y-1]=arg_1
    if (y > 1) { 
      for (const tr of C_pb.transitions){ 
        this.TransferNeed(y,tr,(this.TransferRate(tr,(y-1))*b.needs[y-1][tr.from.index-1]))
        } 
      } 
    this.GetPopulation(y)
    } 
  
  // ----- class method dematerializationRate @ Consumer ------------- 
  //  [2] dematerialization rate is the product of
  //   (a) structural demat due to economy change (dematerialization & learning)
  //   (b) active efficiency gains (at a cost : invest)  DematerializationRate (y) { 
    return  ((1-this.economy.dematerialize.Get(yearF(y)))*(1-this.savingRates[(y-1)-1]))
    } 
  
  // ----- class method ratio @ Consumer ------------- 
  //  tricky: assign energy needs proportionally ... then add substitution flows   Ratio (s) { 
    var Result 
    var i  = s.index
    var arg_1 
    var g0285  = 0
    for (const g0286 of this.consumes){ 
      g0285 = (g0285+g0286)
      } 
    arg_1 = g0285
    Result = (this.consumes[i-1]/arg_1)
    return Result
    } 
  
  // ----- class method transferNeed @ Consumer ------------- 
  //  transfer some energy need from one supplier to the next
  //  new in CCEM v7: efficiency gain may occur  TransferNeed (y,tr,q) { 
    var g0049  = tr.from.index
    this.economy.needs[y-1][g0049-1]=(this.economy.needs[y-1][g0049-1]-q)
    var g0050  = tr.to.index
    this.economy.needs[y-1][g0050-1]=(this.economy.needs[y-1][g0050-1]+(q*tr.efficiency_Z))
    var g0051  = tr.from.index
    this.eSavings[y-1][g0051-1]=(this.eSavings[y-1][g0051-1]+(q*(1-tr.efficiency_Z)))
    } 
  
  // ----- class method tax @ Consumer ------------- 
  //  carbon tax is based on co2 level reached the previous year
  //  in GW3, we add the acceleration pushed by societal reaction
  //  this returns a price in $ for 1 PWh (co2Factor adjusted)
  //  tax is CO2 equivalent ! 200$/t means per equivalent of CO2 ton  Tax (s,y) { 
    if (y <= 2) { 
      return  0
      } else {
      return  ((this.carbonTax.Get(C_pb.earth.co2Levels[(y-1)-1])+this.taxAcceleration)*s.co2Factor)
      } 
    } 
  
  // ----- class method truePrice @ Consumer ------------- 
  //  this is what the consumer will pay   TruePrice (s,y) { 
    return  (s.sellPrices[y-1]+this.Tax(s,y))
    } 
  
  // ----- class method howMuch @ Consumer ------------- 
  HowMuch (s,p) { 
    var Result 
    var cneed  = this.economy.needs[C_pb.year-1][s.index-1]
    var x1  = this.GetCancel(s,p)
    var x  = ((0 <= (1-x1)) ? 
      (1-x1) :
      0)
    
    Result = (cneed*x)
    return Result
    } 
  
  // ----- class method getCancel @ Consumer ------------- 
  //  we got rid the "CancelThreat" in version 0.2 to KISS
  //  on the other hand, we had a supplier-sensitive factor to model (for coal !) => mimick price stability which we observe
  //  GW3: added the cancelAcceleration produced by M5 - the multiplicative factor mimics the effect of 
  //  sobriety forced through additional taxes from some usage  GetCancel (s,p) { 
    return  (this.cancel.Get(p)*(1+((s.isa.IsIn(C_FiniteSupplier) == true) ? 
      this.cancelAcceleration :
      0)))
    } 
  
  // ----- class method transferRate @ Consumer ------------- 
  //  reads the current transferRate  TransferRate (tr,y) { 
    if (y == 0) { 
      return  0
      } else {
      return  this.transferRates[y-1][tr.index-1]
      } 
    } 
  
  // ----- class method getPopulation @ Consumer ------------- 
  //  new in CCEM v9: computes the population distribution based on the estimate 
  //  TODO later : work with the dynamic value (that reflects warming) that would require to update DeathRate
  //  this is used to compute the evolution of the active population ratio (drives social costs)  GetPopulation (y) { 
    var pop  = this.populationEstimate.Get(yearF(y))
    var popPrev  = this.populationEstimate.Get(yearF((y-1)))
    var deathRate  = (this.deathRates.Get(yearF(y))/1000)
    var births  = ((pop-popPrev)+(popPrev*deathRate))
    var activePrev  = ((popPrev-this.youngs[(y-1)-1])-this.seniors[(y-1)-1])
    
    this.youngs[y-1]=(((19/20)*this.youngs[(y-1)-1])+births)
    this.seniors[y-1]=((((1/40)*activePrev)*(1-deathRate))+((this.seniors[(y-1)-1]*(1-deathRate))*C_pb.seniorExcessMortality))
    
    } 
  
  // ----- class method activePop% @ Consumer ------------- 
  //  active population ratio is used to compute social costs (M5)  ActivePop_Z (y) { 
    var Result 
    var pop  = this.populationEstimate.Get(yearF(y))
    var active  = ((pop-this.youngs[y-1])-this.seniors[y-1])
    Result = (active/pop)
    return Result
    } 
  
  // ----- class method showPop @ Consumer ------------- 
  //  debug: show the population distribution  ShowPop (y) { 
    var pop  = this.populationEstimate.Get(yearF(y))
    var active  = ((pop-this.youngs[y-1])-this.seniors[y-1])
    kernel.tformat("[~A] ~S population = ~F2 (youngs:~F2 seniors:~F2 active:~F2)\n",1,[year_I(y),
      this,
      pop,
      this.youngs[y-1],
      this.seniors[y-1],
      active])
    } 
  
  // ----- class method averageAge @ Consumer ------------- 
  //  average age heuristics (see Excel Model)  AverageAge (y) { 
    var Result 
    var pop  = this.populationEstimate.Get(yearF(y))
    var active  = ((pop-this.youngs[y-1])-this.seniors[y-1])
    Result = ((((this.youngs[y-1]*10)+(this.seniors[y-1]*75))+(active*40))/pop)
    return Result
    } 
  
  // ----- class method record @ Consumer ------------- 
  //  verbosity for model M3
  //  [1] record the actual substitution - use substitution matrix
  //  each operation may update the Percent because of monotonicity
  //  cancel is deduced from the actual conso to ensure need = conson + cancel  Record (s,y) { 
    var i  = s.index
    var cneed  = this.economy.needs[y-1][i-1]
    var p  = this.TruePrice(s,y)
    var oep  = s.OilEquivalent(p)
    var missed  = (cneed-this.consos[y-1][s.index-1])
    var x  = (missed/cneed)
    if (s == C_TESTO) { 
      
      } 
    
    this.Saves(s,y)
    this.Cancels(s,y,missed)
    if (this.Tax(s,y) >= (C_PMAX*0.8)) { 
      kernel.MakeError("Carbon Tax got too high ~S",[this.Tax(s,y)]).Close()
      } 
    for (const tr of s.from){ 
      this.UpdateRate(s,
        tr,
        y,
        (cneed*(1-x)))
      } 
    
    s.rawNeeds[y-1]=(s.rawNeeds[y-1]+cneed)
    consumes_Consumer2(this,s,y,this.consos[y-1][s.index-1])
    } 
  
  // ----- class method cancels @ Consumer ------------- 
  //  registers the energy consumption of c for s
  //  [2] cancellation : registers an energy consumption cancellation  Cancels (s,y,x) { 
    this.economy.cancels[y-1]=(this.economy.cancels[y-1]+x)
     this.cancel_Z[y-1][s.index-1]=(x/this.economy.needs[y-1][s.index-1])
    } 
  
  // ----- class method eCheck @ Consumer ------------- 
  //  store production  ECheck (y) { 
    var Result 
    var g0293  = 0
    for (const g0296 of C_Supplier.descendants){ 
      for (const g0295 of g0296.instances){ 
        var g0294  = (this.consos[y-1][g0295.index-1]*this.ERatio(g0295))
        g0293 = (g0293+g0294)
        } 
      } 
    Result = g0293
    return Result
    } 
  
  // ----- class method saves @ Consumer ------------- 
  //  Voluntary (efficiency) saavings, that are driven by investment
  //  s.savingFactors[y - 1] is the current policy level (set by M5)  Saves (s,y) { 
    var i  = s.index
    var cneed  = this.economy.needs[y-1][i-1]
    var ftech  = kernel._exp_float((1-s.techFactor),y)
    var w1  = this.savingRates[(y-1)-1]
    var w2  = kernel.max_float(w1,(((w1+this.yearlySaving) <= this.savingFactors[(y-1)-1]) ? 
      (w1+this.yearlySaving) :
      this.savingFactors[(y-1)-1]))
    
    this.savings[y-1][i-1]=(w1*cneed)
    this.savingRates[y-1]=w2
    
    this.economy.investEnergy[y-1]=(this.economy.investEnergy[y-1]+(((((w2-w1)*cneed)*s.investPrice)*ftech)*steelFactor_Supplier2(s,y)))
    } 
  
  // ----- class method sumSavings @ Consumer ------------- 
  //  all enery saved by efficiency gains triggered by policies      SumSavings (y) { 
    var Result 
    var g0297  = 0
    for (const g0300 of C_Supplier.descendants){ 
      for (const g0299 of g0300.instances){ 
        var g0298  = this.savings[y-1][g0299.index-1]
        g0297 = (g0297+g0298)
        } 
      } 
    Result = g0297
    return Result
    } 
  
  // ----- class method sumESavings @ Consumer ------------- 
  SumESavings (y) { 
    var Result 
    var g0301  = 0
    for (const g0304 of C_Supplier.descendants){ 
      for (const g0303 of g0304.instances){ 
        var g0302  = this.eSavings[y-1][g0303.index-1]
        g0301 = (g0301+g0302)
        } 
      } 
    Result = g0301
    return Result
    } 
  
  // ----- class method getTransferRate @ Consumer ------------- 
  GetTransferRate (tr,y) { 
    var Result 
    var tr1  = this.subMatrix[tr.index-1].Get(yearF(y))
    if (year_I(y) <= C_TransitionPivot) { 
      Result = tr1
      } else {
      var tr2  = this.subMatrix[tr.index-1].Get(2020)
      Result = (tr2+((tr1-tr2)*this.transitionFactors[(y-1)-1]))
      } 
    return Result
    } 
  
  // ----- class method updateRate @ Consumer ------------- 
  //  [3] [6] monotonic update of the transferRate substitute a fraction from one energy source to another
  //  note the monotonic behavior, we return the actual Percentage !
  //  in v0.3 we  UpdateRate (s1,tr,y,consumed) { 
    var i  = tr.index
    var s2  = tr.to
    var ftech  = kernel._exp_float((1-s2.techFactor),y)
    var adapt  = (1+tr.adaptationFactor)
    var w1  = this.TransferRate(tr,(y-1))
    var w2  = kernel.max_float(w1,this.GetTransferRate(tr,y))
    var w3  = applyMaxGrowthRate(w1,
      w2,
      s1,
      s2,
      y)
    this.substitutions[y-1][i-1]=(w1*consumed)
    this.transferRates[y-1][i-1]=((1 <= w3) ? 
      1 :
      w3)
    s2.addedCapacity = (s2.addedCapacity+((w3-w1)*consumed))
    s2.additions[y-1]=(s2.additions[y-1]+((w3-w1)*consumed))
    
    
    
    this.transferFlows[y-1][i-1]=(this.transferFlows[y-1][i-1]+((w3-w1)*consumed))
    this.ePWhs[y-1]=(this.ePWhs[y-1]+((w1*consumed)*this.ETransferRatio(tr)))
    this.eDeltas[y-1]=(this.eDeltas[y-1]+((w1*consumed)*this.ETransferRatio(tr)))
    
    this.economy.investTransition[y-1]=(this.economy.investTransition[y-1]+((((((w3-w1)*consumed)*s2.investPrice)*ftech)*steelFactor_Supplier2(s1,y))*adapt))
    this.economy.investEnergy[y-1]=(this.economy.investEnergy[y-1]+((((((w3-w1)*consumed)*s2.investPrice)*ftech)*steelFactor_Supplier2(s1,y))*adapt))
    } 
  
  // ----- class method showUpdate @ Consumer ------------- 
  //  show the update of the transfer rate  ShowUpdate (s1,s2,tr,y,consumed,w1,w3) { 
    if (C_TALK <= kernel.ClEnv.verbose) { 
      kernel.tformat("[~A] ~S transfer ~F2 PWh(~F%) [~F% now on -> add ~F3] of ~S to ~S [matrix ->~F%]\n",C_TALK,[year_I(y),
        this,
        (w1*consumed),
        w1,
        w3,
        ((w3-w1)*consumed),
        s1,
        tr.to,
        this.GetTransferRate(tr,y)])
      } 
     false
    } 
  
  // ----- class method eTransferRatio @ Consumer ------------- 
  //  [6] gwdg : when using the static eRatio of 2010, we make an error that we must fix (using an approximate formula)
  //  r1: elecRate of s1, e2: elecRate of s2, h: heatRate of tr
  //  CCEM v7: take the efficiency into account (less energy required in electric mode : cf part 2)  ETransferRatio (tr) { 
    var Result 
    var s1  = tr.from
    var s2  = tr.to
    var h  = tr.heat_Z
    var r1  = (1-s1.heat_Z)
    var r2  = (1-s2.heat_Z)
    var alpha  = (1-h)
    if (this == C_TESTC) { 
      
      } 
    Result = ((tr.efficiency_Z*(1-r1))*(1-alpha))
    return Result
    } 
  
  // ----- class method productivityLoss @ Consumer ------------- 
  //  the loss of productivity is a linear function of the pain level
  //  in CCEM v7+, we average the pain over the last 3 years to reduce oscillations  ProductivityLoss (y) { 
    var Result 
    if (y == 1) { 
      Result = 1
      } else {
      var ymin  = (((y-3) <= 1) ? 
        1 :
        (y-3))
      var ymax  = (y-1)
      var avg 
      var arg_1 
      var g0305  = 0
      var g0307  = ymin
      var g0308  = ymax
      while (g0307 <= g0308) { 
        var g0306  = this.painLevels[g0307-1]
        g0305 = (g0305+g0306)
        g0307 = (g0307+1)
        } 
      arg_1 = g0305
      avg = (arg_1/((ymax-ymin)+1))
      Result = (1-(avg*this.productivityFactor))
      } 
    return Result
    } 
  
  // ----- class method disasterRatio @ Consumer ------------- 
  //  read the loss factor from the KNU and apply a correction factor (0.7) because of investment propagation
  //  in v7 we reduce the damages through adaptation  DisasterRatio (t,y) { 
    return  ((0.7*this.disasterLoss.Get((t-C_pb.earth.avgCentury)))*(1-this.adapt.levels[(y-1)-1]))
    } 
  
  // ----- class method marginReduction @ Consumer ------------- 
  //  computes the margin impact of energy price increase, weighted avertage over energy sources
  //  KISS principle for CCEM v6: use the same cancel curves (cancel and cancelImpact) for forced 
  //  sobriety (activity stops) and margin reduction  MarginReduction (y) { 
    var Result 
    var s_energy  = 0
    var margin_impact  = 0
    var s_price  = 0
    for (const g0309 of C_Supplier.descendants){ 
      for (const s of g0309.instances){ 
        var p  = this.TruePrice(s,y)
        var oep  = s.OilEquivalent(p)
        var conso  = this.consos[y-1][s.index-1]
        s_energy = (s_energy+conso)
        s_price = (s_price+(conso*oep))
        margin_impact = (margin_impact+(conso*this.cancelImpact.Get(this.cancel.Get(oep))))
        } 
      } 
    var mi  = (margin_impact/s_energy)
    
    this.economy.marginImpacts[y-1]=mi
    Result = mi
    return Result
    } 
  
  // ----- class method cancelRatio @ Consumer ------------- 
  //  note: the techfactor is only applied to energy, because the model does not account for other resources
  //  (water, metals, ...). The assumption is that adding more control loops (with duality of finite resources 
  //   and recycling / savings with tech) would simply add complexity.      
  //  computes the cancel ratio for one zone  CancelRatio (y) { 
    var Result 
    var conso  = this.economy.totalConsos[y-1]
    var cancel  = this.economy.cancels[y-1]
    Result = (cancel/(conso+cancel))
    return Result
    } 
  
  // ----- class method redirection @ Consumer ------------- 
  //  max cancel acceleration compared to best plan (ratio)  Redirection (y,pain) { 
    this.satisfactions[y-1]=this.ComputeSatisfaction(y)
    if (year_I(y) > C_THISYEAR) { 
      this.taxAcceleration = ((1000*this.tactic.taxFromPain)*pain)
      this.cancelAcceleration = ((3*this.tactic.cancelFromPain)*pain)
      this.transitionFactors[y-1]=((150 <= (this.tactic.transitionStart+(this.tactic.transitionFromPain*pain))) ? 
        150 :
        (this.tactic.transitionStart+(this.tactic.transitionFromPain*pain)))
      this.savingFactors[y-1]=((this.maxSaving <= (this.tactic.savingStart+(this.tactic.savingFromPain*pain))) ? 
        this.maxSaving :
        (this.tactic.savingStart+(this.tactic.savingFromPain*pain)))
      
      this.protectionismFactor = (this.tactic.protectionismStart+(this.tactic.protectionismFromPain*pain))
      this.adapt.investFactor = ((this.tactic.adaptMax <= (this.tactic.adaptStart+(this.tactic.adaptFromPain*pain))) ? 
        this.tactic.adaptMax :
        (this.tactic.adaptStart+(this.tactic.adaptFromPain*pain)))
      } 
    } 
  
  // ----- class method cDensity @ Consumer ------------- 
  //  cDensity = density in CO2 of energy consumption  CDensity (y) { 
    var Result 
    var arg_1 
    var g0314  = 0
    for (const g0315 of this.consos[y-1]){ 
      g0314 = (g0314+g0315)
      } 
    arg_1 = g0314
    Result = (this.co2Emissions[y-1]/arg_1)
    return Result
    } 
  
  // ----- class method taxRate @ Consumer ------------- 
  //  carbon tax rate for a consumer : divide the money by the fossil fuel consumption
  //  return $ / Gtep  TaxRate (y) { 
    var Result 
    var t  = this.economy.carbonTaxAmounts[y-1]
    if (t > 0) { 
      var arg_1 
      var arg_2 
      var arg_3 
      var g0316  = 0
      for (const g0319 of C_FiniteSupplier.descendants){ 
        for (const g0318 of g0319.instances){ 
          var g0317  = this.consos[y-1][g0318.index-1]
          g0316 = (g0316+g0317)
          } 
        } 
      arg_3 = g0316
      arg_2 = perMWh(arg_3)
      arg_1 = (t/arg_2)
      Result = (1000*arg_1)
      } else {
      Result = 0
      } 
    return Result
    } 
  
  // ----- class method painFromCancel @ Consumer ------------- 
  //  [3] level of pain derived from cancelRate  PainFromCancel (y) { 
    var Result 
    var cr  = this.CancelRatio(y)
    var pain  = C_pb.earth.painCancel.Get(cr)
    
    Result = (pain*(1-this.redistribution))
    return Result
    } 
  
  // ----- class method economyScale @ Consumer ------------- 
  //  [3] level of pain derived from Economy resuts
  //  we measure the gowth of a product (GDP/p * material) and compare it to the expected growth using the
  //  "painGrowth" table (a meta parameter that is set by the user)  EconomyScale (y) { 
    var Result 
    var w  = C_pb.world
    var pn  = this.populationEstimate.Get(yearF(y))
    var b  = this.economy
    Result = ((b.results[y-1]/pn)*((w.wheatOutputs[y-1]/w.wheatOutputs[0])+(b.ironConsos[y-1]/b.ironConsos[0])))
    return Result
    } 
  
  // ----- class method painFromResults @ Consumer ------------- 
  PainFromResults (y) { 
    var Result 
    var w  = C_pb.world.all
    var r1  = this.EconomyScale((y-1))
    var r2  = this.EconomyScale(y)
    var growth  = ((r2-r1)/r1)
    Result = (C_pb.earth.painGrowth.Get(growth)+this.PainFromAIReplacement(y))
    return Result
    } 
  
  // ----- class method computeSatisfaction @ Consumer ------------- 
  //  computes the 3P satisfaction level of a consumer versus its objective
  //  (1)  Planet: versus C02 with a linear interpolation
  //  (2)  Profit: versus expected GPD growth (CAGR)
  //  (3)  People : using pain levels for economy, energy and climate  ComputeSatisfaction (y) { 
    var Result 
    var strat  = this.objective
    var co2Target  = (C_pb.earth.co2Levels[0]+((strat.targetCO2-C_pb.earth.co2Levels[0])*(y/90)))
    var cagrCO2  = (kernel._exp_float((this.AdjustForTrade(y,false)/this.AdjustForTrade(1,false)),(1/(y-1)))-1)
    var cagrEco  = (kernel._exp_float((this.economy.results[y-1]/this.economy.results[0]),(1/(y-1)))-1)
    var sat1  = (1-kernel.max_float(0,((1 <= ((strat.targetCO2-cagrCO2)*(-10))) ? 
      1 :
      ((strat.targetCO2-cagrCO2)*(-10)))))
    var sat2  = (1-kernel.max_float(0,((1 <= ((strat.targetGDP-cagrEco)*10)) ? 
      1 :
      ((strat.targetGDP-cagrEco)*10))))
    var sat3  = ((0 <= (1-this.painLevels[y-1])) ? 
      (1-this.painLevels[y-1]) :
      0)
    var sat  = (((strat.weightCO2*sat1)+(strat.weightEconomy*sat2))+(strat.weightPeople*sat3))
    
    kernel.tformat("[~A] ~S:~S ~F1T*, ~F1Gt -> = ~F1T*, ~F1Gt\n",2,[year_I(y),
      this,
      this.objective,
      this.economy.results[0],
      this.AdjustForTrade(1,false),
      this.economy.results[y-1],
      this.AdjustForTrade(y,false)])
    kernel.tformat("satisfaction(~S) = ~F% from (~F%:~F3 %CADR,~F%:~F3 %CAGR,~F%:~F%pain)\n",2,[this,
      sat,
      sat1,
      (100*cagrCO2),
      sat2,
      (100*cagrEco),
      sat3,
      this.painLevels[y-1]])
    Result = sat
    return Result
    } 
  
  // ----- class method adjustForTrade @ Consumer ------------- 
  //  CCEMv7: Adjusted For Trade emissions  AdjustForTrade (y,talk_ask) { 
    var Result 
    var x  = this.co2Emissions[y-1]
    for (const g0320 of C_Consumer.descendants){ 
      for (const z of g0320.instances){ 
        if (z != this) { 
          if (talk_ask == true) { 
            kernel.tformat("~S -> ~S: add ~F3 (~F3 kg/kWh) \n",0,[z,
              this,
              (z.co2Emissions[y-1]*this.economy.ImportTradeFraction(z.economy,y)),
              (z.co2Emissions[y-1]/z.economy.results[y-1])])
            } 
          x = (x+(z.co2Emissions[y-1]*this.economy.ImportTradeFraction(z.economy,y)))
          } 
        } 
      } 
    for (const g0321 of C_Consumer.descendants){ 
      for (const z of g0321.instances){ 
        if (z != this) { 
          x = (x-(this.co2Emissions[y-1]*z.economy.ImportTradeFraction(this.economy,y)))
          } 
        } 
      } 
    if (talk_ask == true) { 
      kernel.tformat("[~A] ~S adjusted for trade emissions: ~F3 -> ~F3 \n",0,[year_I(y),
        this,
        this.co2Emissions[y-1],
        x])
      } 
    Result = x
    return Result
    } 
  
  // ----- class method co2Density @ Consumer ------------- 
  //  simple estimate : CO2 density of GDP  Co2Density (y) { 
    var Result 
    var e  = this.economy
    var co2  = this.co2Emissions[y-1]
    var gdp  = e.results[y-1]
    Result = ((gdp > 0) ? 
      ((1000*co2)/gdp) :
      0)
    return Result
    } 
  
  // ----- class method computeGini @ Consumer ------------- 
  //  CCEM v9: computes a simple evaluation of inequality using the Gini coefficient (0=perfect equality, 1=perfect inequality)  ComputeGini (y) { 
    this.economy.socialExpenseValues[y-1]=(this.economy.socialExpenseRatio.Get(yearF(y))*((1-C_pb.activeToSocial)+(C_pb.activeToSocial*kernel._exp_float((this.ActivePop_Z(1)/this.ActivePop_Z(y)),2))))
    
    
     this.economy.giniLevels[y-1]=((this.economy.giniStart*((1-C_pb.socialToGini)+(C_pb.socialToGini*(this.economy.socialExpenseValues[0]/this.economy.socialExpenseValues[y-1]))))*((1-C_pb.aiToGini)+(C_pb.aiToGini*this.GetAIReplaceFactor(y))))
    } 
  
  // ----- class method painFromAIReplacement @ Consumer ------------- 
  //  pain from AI replacement is added to painFromResults in CCEM v9  PainFromAIReplacement (y) { 
    return  C_pb.earth.painReplacement.Get(this.GetAIReplaceFactor(y))
    } 
  
  // ----- class method getAIReplaceFactor @ Consumer ------------- 
  //  actual AI replace factor depends on policy (c.tactic.aiReplaceFactor) and the AI transition duration (pb.aiTransitionDuration)  GetAIReplaceFactor (y) { 
    if (y > 1) { 
      return  (this.tactic.aiReplaceFactor*kernel.min_float(1,(y/C_pb.aiTransitionDuration)))
      } else {
      return  0
      } 
    } 
  
  // ----- class method sumNeeds @ Consumer ------------- 
  //  three utilities  SumNeeds (y) { 
    var Result 
    var g0322  = 0
    for (const g0323 of this.economy.needs[y-1]){ 
      g0322 = (g0322+g0323)
      } 
    Result = g0322
    return Result
    } 
  
  // ----- class method sumConsos @ Consumer ------------- 
  SumConsos (y) { 
    var Result 
    var g0324  = 0
    for (const g0325 of this.consos[y-1]){ 
      g0324 = (g0324+g0325)
      } 
    Result = g0324
    return Result
    } 
  
  // ----- class method sumCancelBySupplier @ Consumer ------------- 
  //  v8 : more detailed evaluation of cancel (than c.cancels)    SumCancelBySupplier (y) { 
    var Result 
    var g0326  = 0
    for (const g0329 of C_Supplier.descendants){ 
      for (const g0328 of g0329.instances){ 
        var g0327  = (this.economy.needs[y-1][g0328.index-1]*this.cancel_Z[y-1][g0328.index-1])
        g0326 = (g0326+g0327)
        } 
      } 
    Result = g0326
    return Result
    } 
  
  // ----- class method getCo2KWh @ Consumer ------------- 
  //  localized version in CCEM v9. a different name to keep the code "diet"    GetCo2KWh (y) { 
    var Result 
    var arg_1 
    var g0330  = 0
    for (const g0333 of C_Supplier.descendants){ 
      for (const g0332 of g0333.instances){ 
        var g0331  = (g0332.co2Kwh*this.consos[y-1][g0332.index-1])
        g0330 = (g0330+g0331)
        } 
      } 
    arg_1 = g0330
    var arg_2 
    var g0334  = 0
    for (const g0337 of C_Supplier.descendants){ 
      for (const g0336 of g0337.instances){ 
        var g0335  = this.consos[y-1][g0336.index-1]
        g0334 = (g0334+g0335)
        } 
      } 
    arg_2 = g0334
    Result = (arg_1/arg_2)
    return Result
    } 
  
  // ----- class method energyIntensity @ Consumer ------------- 
  //  same for a zone  EnergyIntensity (y) { 
    return  (TWh(this.SumConsos(y))/(1000*this.economy.results[y-1]))
    } 
  
  // ----- class method updateChartsConsumer @ Consumer ------------- 
  //  update the Charts for a consumer  UpdateChartsConsumer (y) { 
    for (const g0342 of C_Supplier.descendants){ 
      for (const s of g0342.instances){ 
        var arg_1 
        var i_bag  = []
        var i  = 1
        var g0343  = y
        while (i <= g0343) { 
          kernel.add_list(i_bag,this.consos[i-1][s.index-1])
          i = (i+1)
          } 
        arg_1 = i_bag
        udapdateChart(this.charts.consos[s.index-1],y,arg_1)
        } 
      } 
    var arg_2 
    var i_bag  = []
    var i  = 1
    var g0344  = y
    while (i <= g0344) { 
      kernel.add_list(i_bag,this.SumNeeds(i))
      i = (i+1)
      } 
    arg_2 = i_bag
    udapdateChart(this.charts.needs,y,arg_2)
    udapdateChart(this.charts.gdp,y,this.economy.results)
    var arg_3 
    var i_bag  = []
    var i  = 1
    var g0345  = y
    while (i <= g0345) { 
      kernel.add_list(i_bag,this.CancelRatio(i))
      i = (i+1)
      } 
    arg_3 = i_bag
    udapdateChart(this.charts.cancel_Z,y,arg_3)
    var arg_4 
    var i_bag  = []
    var i  = 1
    var g0346  = y
    while (i <= g0346) { 
      kernel.add_list(i_bag,this.SumSavings(i))
      i = (i+1)
      } 
    arg_4 = i_bag
    udapdateChart(this.charts.savings,y,arg_4)
    udapdateChart(this.charts.carbonTaxAmounts,y,this.economy.carbonTaxAmounts)
     udapdateChart(this.charts.painLevels,y,this.painLevels)
    } 
  
  // ----- class method see @ Consumer ------------- 
  See (y) { 
    kernel.print_any(this)
    kernel.PRINC(": conso:")
    var arg_1 
    var g0359  = 0
    for (const g0360 of this.consos[y-1]){ 
      g0359 = (g0359+g0360)
      } 
    arg_1 = g0359
    kernel.printFDigit_float(arg_1,2)
    kernel.PRINC("PWh ")
    pl2(this.consos[y-1])
    kernel.PRINC("vs need:")
    var arg_2 
    var g0361  = 0
    for (const g0362 of this.economy.needs[y-1]){ 
      g0361 = (g0361+g0362)
      } 
    arg_2 = g0361
    kernel.printFDigit_float(arg_2,2)
    kernel.PRINC(" ")
    pl2(this.economy.needs[y-1])
    kernel.PRINC(", elec:")
    kernel.printFDigit_float(this.ePWhs[y-1],2)
     kernel.PRINC("\n")
    } 
  
  // ----- class method init @ Consumer ------------- 
  //  consumer initialization (and reinit)
  //  CCEMv6 : assumes that cancel is 0 at start (the code in game.cl is based on this)  Init () { 
    for (const g0363 of C_Supplier.descendants){ 
      for (const s of g0363.instances){ 
        if (this.cancel.Get(s.OilEquivalent(s.sellPrices[0])) > 0.01) { 
          kernel.MakeError("CCEM models assumes that cancel(~S,~S) is 0 at start",[this,s]).Close()
          } 
        } 
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0364  = C_NIT
      while (i <= g0364) { 
        var arg_1 
        var s_bag  = []
        for (const g0365 of C_Supplier.descendants){ 
          for (const s of g0365.instances){ 
            kernel.add_list(s_bag,0)
            } 
          } 
        arg_1 = s_bag
        kernel.add_list(i_bag,arg_1)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.consos = va_arg2
      } 
    this.consos[0]=this.consumes
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0366  = C_NIT
      while (i <= g0366) { 
        var arg_2 
        var s_bag  = []
        for (const g0367 of C_Supplier.descendants){ 
          for (const s of g0367.instances){ 
            kernel.add_list(s_bag,0)
            } 
          } 
        arg_2 = s_bag
        kernel.add_list(i_bag,arg_2)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.cancel_Z = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0368  = C_NIT
      while (i <= g0368) { 
        var arg_3 
        var v_list4 
        var tr 
        v_list4 = C_pb.transitions
        arg_3 = new Array(v_list4.length)
        for (let CLcount = 0; CLcount < v_list4.length; CLcount++){ 
          tr = v_list4[CLcount]
          arg_3[CLcount] = 0
          } 
        kernel.add_list(i_bag,arg_3)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.substitutions = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0369  = C_NIT
      while (i <= g0369) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.savingRates = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0370  = C_NIT
      while (i <= g0370) { 
        var arg_4 
        var s_bag  = []
        for (const g0371 of C_Supplier.descendants){ 
          for (const s of g0371.instances){ 
            kernel.add_list(s_bag,0)
            } 
          } 
        arg_4 = s_bag
        kernel.add_list(i_bag,arg_4)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.savings = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0372  = C_NIT
      while (i <= g0372) { 
        var arg_5 
        var s_bag  = []
        for (const g0373 of C_Supplier.descendants){ 
          for (const s of g0373.instances){ 
            kernel.add_list(s_bag,0)
            } 
          } 
        arg_5 = s_bag
        kernel.add_list(i_bag,arg_5)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.eSavings = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0374  = C_NIT
      while (i <= g0374) { 
        var arg_6 
        var v_list4 
        var tr 
        v_list4 = C_pb.transitions
        arg_6 = new Array(v_list4.length)
        for (let CLcount = 0; CLcount < v_list4.length; CLcount++){ 
          tr = v_list4[CLcount]
          arg_6[CLcount] = 0
          } 
        kernel.add_list(i_bag,arg_6)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.transferRates = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0375  = C_NIT
      while (i <= g0375) { 
        var arg_7 
        var v_list4 
        var tr 
        v_list4 = C_pb.transitions
        arg_7 = new Array(v_list4.length)
        for (let CLcount = 0; CLcount < v_list4.length; CLcount++){ 
          tr = v_list4[CLcount]
          arg_7[CLcount] = 0
          } 
        kernel.add_list(i_bag,arg_7)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.transferFlows = va_arg2
      } 
    this.taxAcceleration = 0
    this.cancelAcceleration = 0
    this.yearlySaving = (this.maxSaving/90)
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0376  = C_NIT
      while (i <= g0376) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.painLevels = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0377  = C_NIT
      while (i <= g0377) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.painWarming = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0378  = C_NIT
      while (i <= g0378) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.painResults = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0379  = C_NIT
      while (i <= g0379) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.painEnergy = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0380  = C_NIT
      while (i <= g0380) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.co2Emissions = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0381  = C_NIT
      while (i <= g0381) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.satisfactions = va_arg2
      } 
    this.satisfactions[0]=1
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0382  = C_NIT
      while (i <= g0382) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.savingFactors = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0383  = C_NIT
      while (i <= g0383) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.transitionFactors = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0384  = C_NIT
      while (i <= g0384) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.ePWhs = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0385  = C_NIT
      while (i <= g0385) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.eDeltas = va_arg2
      } 
    var arg_8 
    var g0386  = 0
    for (const g0389 of C_Supplier.descendants){ 
      for (const g0388 of g0389.instances){ 
        var g0387  = (this.consumes[g0388.index-1]*this.ERatio(g0388))
        g0386 = (g0386+g0387)
        } 
      } 
    arg_8 = g0386
    this.ePWhs[0]=arg_8
    var arg_9 
    var g0390  = 0
    for (const g0393 of C_Supplier.descendants){ 
      for (const g0392 of g0393.instances){ 
        var g0391  = (this.consumes[g0392.index-1]*g0392.co2Factor)
        g0390 = (g0390+g0391)
        } 
      } 
    arg_9 = g0390
    this.co2Emissions[0]=arg_9
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0394  = C_NIT
      while (i <= g0394) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.population = va_arg2
      } 
    this.population[0]=this.populationEstimate.Get(yearF(1))
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0395  = C_NIT
      while (i <= g0395) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.youngs = va_arg2
      } 
    this.youngs[0]=(this.populationEstimate.Get(yearF(1))*this.populationDistribution[0])
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0396  = C_NIT
      while (i <= g0396) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.seniors = va_arg2
      } 
    this.seniors[0]=(this.populationEstimate.Get(yearF(1))*this.populationDistribution[2])
    this.InitAdapt()
     this.InitBlock()
    } 
  
  // ----- class method eRatio @ Consumer ------------- 
  //  reads form the initial data the ratio of primary energy used for electricity (vs "heat")  ERatio (s) { 
    return  (this.eSources[s.index-1]/this.consumes[s.index-1])
    } 
  
  // ----- class method initAdapt @ Consumer ------------- 
  InitAdapt () { 
    var a  = this.adapt
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0397  = C_NIT
      while (i <= g0397) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      a.levels = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0398  = C_NIT
      while (i <= g0398) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      a.spends = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0399  = C_NIT
      while (i <= g0399) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      a.losses = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0400  = C_NIT
      while (i <= g0400) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      a.gains = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0401  = C_NIT
      while (i <= g0401) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      a.sums = va_arg2
      } 
    } 
  
  // ----- class method initBlock @ Consumer ------------- 
  InitBlock () { 
    var w  = this.economy
    w.Init()
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0402  = C_NIT
      while (i <= g0402) { 
        kernel.add_list(i_bag,[])
        i = (i+1)
        } 
      va_arg2 = i_bag
      w.needs = va_arg2
      } 
    w.needs[0]=this.consumes
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0403  = C_NIT
      while (i <= g0403) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      w.carbonTaxAmounts = va_arg2
      } 
    w.ironConsos[0]=(w.gdp/w.ironDriver.Get(yearF(1)))
    var arg_1 
    var g0404  = 0
    for (const g0405 of this.consumes){ 
      g0404 = (g0404+g0405)
      } 
    arg_1 = g0404
    w.totalConsos[0]=arg_1
    w.describes = this
    this.economy = w
    { 
      var va_arg2 
      var w2_bag  = []
      for (const g0406 of C_Block.descendants){ 
        for (const w2 of g0406.instances){ 
          kernel.add_list(w2_bag,1)
          } 
        } 
      va_arg2 = w2_bag
      w.openTrade = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0407  = C_NIT
      while (i <= g0407) { 
        var arg_2 
        var w2_bag  = []
        for (const g0408 of C_Block.descendants){ 
          for (const w2 of g0408.instances){ 
            kernel.add_list(w2_bag,1)
            } 
          } 
        arg_2 = w2_bag
        kernel.add_list(i_bag,arg_2)
        i = (i+1)
        } 
      va_arg2 = i_bag
      w.tradeFactors = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0409  = C_NIT
      while (i <= g0409) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      w.giniLevels = va_arg2
      } 
    w.giniLevels[0]=w.giniStart
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0410  = C_NIT
      while (i <= g0410) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      w.socialExpenseValues = va_arg2
      } 
    w.socialExpenseValues[0]=w.socialExpenseRatio.Get(yearF(1))
    } 
  
  } 


// class file for WorldClass in module sgw9 // 
//  book-keeping the loss of margin -> impact Invest
//  we create World as the global economy (sum of block)class WorldClass extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.steelPrice = 0
    this.returnOnInvestment = 0
    this.adaptGrowthLoss = 0
    this.wheatProduction = 0
    this.agroLand = 0
    this.protectionismInFactor = 0.5
    this.protectionismOutFactor = 1
    this.protectionismFactor = 0.5
    this.steelPrices = []
    this.agroSurfaces = []
    this.energySurfaces = []
    this.wheatOutputs = []
    } 
  
  // ----- class method registerConstant @ WorldClass ------------- 
  //  ********************************************************************
  //  *    Part 3: Experiments                                           *
  //  ********************************************************************
  //  initialize all the simulation objects
  //  we want the time series *s[y]  RegisterConstant (e,c) { 
    C_pb.world = this
    C_pb.earth = C_Earth.instances[0]
    C_pb.oil = e
    C_pb.clean = c
    } 
  
  // ----- class method init @ WorldClass ------------- 
  //  init for the world economy  Init () { 
    { 
      var va_arg2 
      var _CL_obj  = (new Economy()).Is(C_Economy)
      va_arg2 = _CL_obj
      this.all = va_arg2
      } 
    this.all.Init()
    var arg_1 
    var g0441  = 0
    for (const g0444 of C_Consumer.descendants){ 
      for (const g0443 of g0444.instances){ 
        var g0442 
        var g0445  = 0
        for (const g0446 of g0443.consumes){ 
          g0445 = (g0445+g0446)
          } 
        g0442 = g0445
        g0441 = (g0441+g0442)
        } 
      } 
    arg_1 = g0441
    this.all.totalConsos[0]=arg_1
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0447  = C_NIT
      while (i <= g0447) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.steelPrices = va_arg2
      } 
    this.steelPrices[0]=this.steelPrice
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0448  = C_NIT
      while (i <= g0448) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.agroSurfaces = va_arg2
      } 
    this.agroSurfaces[0]=this.agroLand
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0449  = C_NIT
      while (i <= g0449) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.energySurfaces = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0450  = C_NIT
      while (i <= g0450) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.wheatOutputs = va_arg2
      } 
     this.wheatOutputs[0]=this.wheatProduction
    } 
  
  } 


// class file for Earth in module sgw9 // 
//  ********************************************************************
//  *    Part 4: Gaia                                                  *
//  ********************************************************************
//  there is only one earth :)class Earth extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.co2PPM = 0
    this.co2Add = 0
    this.co2Cumul = 0
    this.avgTemp = 0
    this.avgCentury = 0
    this.co2Ratio = 0
    this.painProfile = []
    this.painDelay = 0
    this.co2Emissions = []
    this.co2Levels = []
    this.co2Cumuls = []
    this.temperatures = []
    this.gdpLosses = []
    this.adaptGains = []
    } 
  
  // ----- class method painFromWarming @ Earth ------------- 
  //  verbosity for model M5
  //  In CCEMv7 the pain is reduced through the adaptation level  PainFromWarming (c,y) { 
    return  (this.painClimate.Get(this.warming.Get(this.co2Levels[y-1]))*(1-c.adapt.levels[(y-1)-1]))
    } 
  
  // ----- class method react @ Earth ------------- 
  //  [1] [2] [3] even simpler : computes the CO2 and the temperature,
  //  then (M5) apply the pain to re-evaluate the reactions  React (y) { 
    var x  = this.co2Levels[(y-1)-1]
    this.co2Levels[y-1]=(x+(this.co2Emissions[y-1]*this.co2Ratio))
    this.co2Cumuls[y-1]=(this.co2Cumuls[(y-1)-1]+this.co2Emissions[y-1])
    
    this.temperatures[y-1]=((this.avgTemp-this.warming.Get(this.co2PPM))+this.warming.Get(this.co2Levels[y-1]))
    for (const g0451 of C_Consumer.descendants){ 
      for (const c of g0451.instances){ 
        c.ComputeGini(y)
        } 
      } 
    for (const g0452 of C_Consumer.descendants){ 
      for (const c of g0452.instances){ 
        var pain_energy  = c.PainFromCancel(y)
        var pain_results  = c.PainFromResults(y)
        var pain_warming  = this.PainFromWarming(c,y)
        var pain  = ((pain_warming+pain_energy)+pain_results)
        
        c.painLevels[y-1]=pain
        c.painEnergy[y-1]=pain_energy
        c.painResults[y-1]=(((2*c.painResults[(y-1)-1])+pain_results)/3)
        c.painWarming[y-1]=pain_warming
        c.Redirection(y,((y > this.painDelay) ? 
          c.painLevels[(y-this.painDelay)-1] :
          0))
        } 
      } 
    computeProtectionism(y)
    computeAdaptation(y)
    } 
  
  // ----- class method updateChartsEarth @ Earth ------------- 
  //  update the Charts for the earth  UpdateChartsEarth (y) { 
    udapdateChart(this.charts.co2Levels,y,this.co2Levels)
    udapdateChart(this.charts.co2Emissions,y,this.co2Emissions)
    udapdateChart(this.charts.temperatures,y,this.temperatures)
     udapdateChart(this.charts.gdpLosses,y,this.gdpLosses)
    } 
  
  // ----- class method see @ Earth ------------- 
  See (y) { 
    kernel.PRINC("--- CO2 at ")
    kernel.printFDigit_float(this.co2Levels[y-1],2)
    kernel.PRINC("ppm, temperature = ")
    kernel.printFDigit_float(this.temperatures[y-1],1)
    kernel.PRINC("C (+")
    kernel.printFDigit_float(warming_integer(y),1)
    kernel.PRINC("), tax = ")
    var arg_1 
    var c_bag  = []
    for (const g0471 of C_Consumer.descendants){ 
      for (const c of g0471.instances){ 
        kernel.add_list(c_bag,c.carbonTax.Get(this.co2Levels[y-1]))
        } 
      } 
    arg_1 = c_bag
    kernel.princ_list(arg_1)
     kernel.PRINC("\n")
    } 
  
  // ----- class method init @ Earth ------------- 
  Init () { 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0472  = C_NIT
      while (i <= g0472) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.temperatures = va_arg2
      } 
    this.temperatures[0]=this.avgTemp
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0473  = C_NIT
      while (i <= g0473) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.co2Levels = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0474  = C_NIT
      while (i <= g0474) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.gdpLosses = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0475  = C_NIT
      while (i <= g0475) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.adaptGains = va_arg2
      } 
    this.co2Levels[0]=this.co2PPM
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0476  = C_NIT
      while (i <= g0476) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.co2Emissions = va_arg2
      } 
    this.co2Emissions[0]=this.co2Add
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0477  = C_NIT
      while (i <= g0477) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.co2Cumuls = va_arg2
      } 
     this.co2Cumuls[0]=this.co2Cumul
    } 
  
  } 


// class file for KNUstorage in module sgw9 // 
//  losses avoided thanks to adaptation 
//  ********************************************************************
//  *    Part 5: KNU (Key Known Unknowns) Storage & Charts             *
//  ********************************************************************
//  here we shall store the original input values that are mofidied by the KNUsclass KNUstorage extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.dematerializes = []
    this.subMatrices = []
    this.cancels = []
    } 
  
  } 


// class file for Problem in module sgw9 // 
//  pain levels
//  ********************************************************************
//  *    Part 6: Experiments                                           *
//  ********************************************************************
//  our problem solver objectclass Problem extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.comment = "default scenario"
    this.transitions = []
    this.trade = []
    this.year = 1
    this.priceRange = []
    this.prodCurve = []
    this.needCurve = []
    this.seniorExcessMortality = 0.985
    this.transferPriceSensitivity = 0
    this.activeToSocial = 0.25
    this.socialToGini = 0
    this.aiToGini = 0
    this.aiTransitionDuration = 30
    this.totalInvest = 0
    this.totalGrowth = 0
    this.totalEInvest = 0
    } 
  
  // ----- class method disolve @ Problem ------------- 
  //  [6] dichotomic search for the price that matches supply and demand the best  Disolve (s) { 
    var Result 
    var v1  = this.TryPrice(s,this.priceRange[0])
    var v2  = this.TryPrice(s,this.priceRange[C_NIS-1])
    Result = this.Dichotomy(s,
      1,
      v1,
      C_NIS,
      v2)
    return Result
    } 
  
  // ----- class method dichotomy @ Problem ------------- 
  //  while i1 and i2 are not close enough, we split in the middle and see which one we keep (i1:overdemand, i2: oversupply)  Dichotomy (s,i1,v1,i2,v2) { 
    var Result 
    
    if (i2 <= (i1+1)) { 
      
      Result = ((kernel.abs_float(v1) < kernel.abs_float(v2)) ? 
        this.priceRange[i1-1] :
        this.priceRange[i2-1])
      } else {
      var i3  = kernel._7_integer1((i1+i2),2)
      var v3  = this.TryPrice(s,this.priceRange[i3-1])
      
      Result = ((v3 >= 0) ? 
        this.Dichotomy(s,
          i3,
          v3,
          i2,
          v2) :
        this.Dichotomy(s,
          i1,
          v1,
          i3,
          v3))
      } 
    return Result
    } 
  
  // ----- class method tryPrice @ Problem ------------- 
  //  try a price and return Demand - supply (hence very low price gives a positive value and high price a negative one)  TryPrice (s,p) { 
    var Result 
    var y  = this.year
    var demand  = totalDemand(y,s,p)
    var supply  = s.GetOutput(p,y)
    Result = (demand-supply)
    return Result
    } 
  
  // ----- class method run @ Problem ------------- 
  //  one simulation stepsavingF  Run (talk_ask) { 
    var y  = (this.year+1)
    C_pb.year = y
    kernel.tformat("==================================  [~A] =================================== \n",2,[year_I(y)])
    if ((y == C_YTALK) || 
        (y == C_YSTOP)) { 
      C_DEBUG = 1
      C_SHOW2 = 1
      } 
    for (const g0486 of C_Consumer.descendants){ 
      for (const c of g0486.instances){ 
        c.GetNeed(y)
        } 
      } 
    for (const g0487 of C_Supplier.descendants){ 
      for (const s of g0487.instances){ 
        
        s.ComputeCapacity(this.year)
        s.sellPrices[y-1]=this.Disolve(s)
        s.BalanceEnergy(y)
        for (const g0488 of C_Consumer.descendants){ 
          for (const c of g0488.instances){ 
            c.Record(s,y)
            } 
          } 
        s.RecordCapacity(y)
        } 
      } 
    
    getEconomy(y)
    if ((talk_ask == true) && 
        (kernel.ClEnv.verbose > 0)) { 
      kernel.PRINC("[")
      kernel.princ_integer(year_I(y))
      kernel.PRINC("] gdp = ")
      kernel.printFDigit_float(C_pb.world.all.results[y-1],2)
      kernel.PRINC("T$ from ")
      kernel.printFDigit_float(C_pb.world.all.inputs[y-1],2)
      kernel.PRINC("PWh input at ")
      printEnergyPrices(y)
      kernel.PRINC("\n")
      } 
    this.earth.React(y)
    if (y == C_YSTOP) { 
      kernel.MakeError("stop at YSTOP",[]).Close()
      } 
    } 
  
  // ----- class method resetNeed @ Problem ------------- 
  ResetNeed () { 
    var i  = 1
    var g0495  = C_NIS
    while (i <= g0495) { 
      this.needCurve[i-1]=0
      i = (i+1)
      } 
    } 
  
  } 


// class file for Experiment in module sgw9 // 
//  an experiment is defined by a specific parametric setup
//  experiments are defined in the scenario.cl file
//  the outcome of an experiment is a scenario (set of charts)class Experiment extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    } 
  
  } 

var C_TALK
var C_DEBUG
var C_Version
var C_ORIGIN
var C_THISYEAR
var C_NIT
var C_NIS
var C_Year
var C_Percent
var C_Price
var C_Energy
var C_PMIN
var C_PMAX
var C_CARNOT
var C_Tmeasure
var C_Charts
var C_ChartsEarth
var C_ChartsSupplier
var C_ChartsConsumer
var C_ListFunction
var C_StepFunction
var C_Affine
var C_Transition
var C_Supplier
var C_FiniteSupplier
var C_InfiniteSupplier
var C_Sector
var C_Economy
var C_Block
var C_Strategy
var C_Tactics
var C_Adaptation
var C_Consumer
var C_WorldClass
var C_Earth
var C_KNUstorage
var C_Problem
var C_pb
var C_Experiment
var C_TESTE
var C_TESTC
var C_TESTO
var C_CCEMv9
var C_SHOW1
var C_SHOW2
var C_HOW
var C_DIBUG
var C_BALANCE
var C_SHOW3
var C_TransitionPivot
var C_SHOW4
var C_APFv10
var C_STEEL
var C_SHOW5
var C_MAXTAX
var C_MAXTR
var C_MAXCANCEL
var C_Gt2km2
var C_YSTOP
var C_YTALK
var C_ELASMAX
var C_KNUstore
var C_EUenergy2010
var C_USenergy2010
var C_CNenergy2010
var C_INenergy2010
var C_RWenergy2010
var C_Oil2010
var C_Coal2010
var C_Gas2010
var C_Clean2010
var C_OilMaxGrowth
var C_CoalMaxGrowth
var C_GasMaxGrowth
var C_CleanMaxGrowth
var C_USeSources2010
var C_EUeSources2010
var C_CNeSources2010
var C_INeSources2010
var C_RWeSources2010
var C_EfromOil2010
var C_EfromCoal2010
var C_EfromGas2010
var C_EfromClean2010
var C_Oil
var C_Coal
var C_Gas
var C_Clean
var C_AdaptFossil
var C_Transport
var C_Industry
var C_Residential
var C_Others
var C_USDemat
var C_EUDemat
var C_CNDemat
var C_INDemat
var C_RWDemat
var C_USCancel
var C_EUCancel
var C_CNCancel
var C_INCancel
var C_RestCancel
var C_CancelImpactAdvanced
var C_CancelImpactDeveloping
var C_AdaptCurve
var C_US
var C_EU
var C_CN
var C_IN
var C_Rest
var C_World
var C_USgdp
var C_USir
var C_USeco
var C_EUgdp
var C_EUir
var C_EUeco
var C_CNgdp
var C_CNir
var C_CNeco
var C_INgdp
var C_INir
var C_INeco
var C_Wgdp
var C_Wir
var C_RWeco
var C_Gaia

// ----- function from method year! @ integer ------------- 
//  ratio heat to electricity
//  we use a relative index that sarts at 1 for 2010 or 1980, based on ORIGINfunction year_I (i) { 
  return  ((C_ORIGIN-1)+i)
  } 

// ----- function from method yIndex @ integer ------------- 
function yIndex (i) { 
  return  ((i+1)-C_ORIGIN)
  } 

// ----- function from method yearF @ integer ------------- 
function yearF (i) { 
  return  ((C_ORIGIN-1)+i)
  } 

// ----- function from method PWh @ float ------------- 
//  transforms a Gt of oil equivalent into PWhfunction PWh (x) { 
  return  (x*11.6)
  } 

// ----- function from method perMWh @ float ------------- 
//  transforms a price per Tep into a price per MWhfunction perMWh (x) { 
  return  (x/11.6)
  } 

// ----- function from method makeTmeasure @ integer ------------- 
//  creates a Teasure of size yfunction makeTmeasure (x) { 
  var Result 
  var n_bag  = []
  var n  = 1
  var g0496  = x
  while (n <= g0496) { 
    var arg_1 
    var _CL_obj  = (new kernel.ClaireMeasure()).Is(kernel.C_measure)
    arg_1 = _CL_obj.Close()
    kernel.add_list(n_bag,arg_1)
    n = (n+1)
    } 
  Result = n_bag
  return Result
  } 

// ----- function from method affine @ listargs ------------- 
//  assumes l is a list of pairs (x-i,y-i) and x-i is a strictly increasing sequencefunction affine (l) { 
  var Result 
  var arg_1 
  var v_list1 
  var x 
  var v_local1 
  v_list1 = l
  arg_1 = new Array(v_list1.length)
  for (let CLcount = 0; CLcount < v_list1.length; CLcount++){ 
    x = v_list1[CLcount]
    v_local1 = x[1-1]
    arg_1[CLcount] = v_local1
    } 
  var arg_2 
  var v_list1 
  var x 
  var v_local1 
  v_list1 = l
  arg_2 = new Array(v_list1.length)
  for (let CLcount = 0; CLcount < v_list1.length; CLcount++){ 
    x = v_list1[CLcount]
    v_local1 = x[2-1]
    arg_2[CLcount] = v_local1
    } 
  Result = make_affine(arg_1,arg_2)
  return Result
  } 

// ----- function from method make_affine @ list ------------- 
function make_affine (l1,l2) { 
  var Result 
  var m1  = 1e+09
  var M1  = -1e+09
  var i  = 2
  var g0497  = l1.length
  while (i <= g0497) { 
    if (l1[(i-1)-1] >= l1[i-1]) { 
      kernel.MakeError("affine params decrease: ~S",[l1]).Close()
      } 
    i = (i+1)
    } 
  for (const v of l2){ 
    m1 = ((m1 <= v) ? 
      m1 :
      v)
    M1 = ((M1 <= v) ? 
      v :
      M1)
    } 
  var _CL_obj  = (new Affine()).Is(C_Affine)
  _CL_obj.n = l1.length
  _CL_obj.minValue = m1
  _CL_obj.maxValue = M1
  _CL_obj.xValues = l1
  _CL_obj.yValues = l2
  Result = _CL_obj
  return Result
  } 

// ----- function from method step @ listargs ------------- 
//  same code for StepFunctionfunction step (l) { 
  var Result 
  var m1  = 1e+09
  var M1  = -1e+09
  var l1 
  var v_list1 
  var x 
  var v_local1 
  v_list1 = l
  l1 = new Array(v_list1.length)
  for (let CLcount = 0; CLcount < v_list1.length; CLcount++){ 
    x = v_list1[CLcount]
    v_local1 = x[1-1]
    l1[CLcount] = v_local1
    } 
  var l2 
  var v_list1 
  var x 
  var v_local1 
  v_list1 = l
  l2 = new Array(v_list1.length)
  for (let CLcount = 0; CLcount < v_list1.length; CLcount++){ 
    x = v_list1[CLcount]
    v_local1 = x[2-1]
    l2[CLcount] = v_local1
    } 
  var i  = 2
  var g0498  = l.length
  while (i <= g0498) { 
    if (l1[(i-1)-1] >= l1[i-1]) { 
      kernel.MakeError("step function params decrease: ~S",[l1]).Close()
      } 
    i = (i+1)
    } 
  for (const v of l2){ 
    m1 = ((m1 <= v) ? 
      m1 :
      v)
    M1 = ((M1 <= v) ? 
      v :
      M1)
    } 
  var _CL_obj  = (new StepFunction()).Is(C_StepFunction)
  _CL_obj.n = l.length
  _CL_obj.minValue = m1
  _CL_obj.maxValue = M1
  _CL_obj.xValues = l1
  _CL_obj.yValues = l2
  Result = _CL_obj
  return Result
  } 

// ----- function from method boundedMultiply @ float ------------- 
//  bounded multiplication  x is multiplied by y (unchanged for y = 1) but bounded by minValue and maxValuefunction boundedMultiply (x,y,minVal,maxVal) { 
  if (y <= 1) { 
    return  (minVal+((x-minVal)*y))
    } else {
    return  (x+((maxVal-x)*((y-1)/y)))
    } 
  } 

// ----- function from method supplier! @ integer ------------- 
//  max(delta(capacity) in PWh) is a yearly roadmap (does not only depend on price but volume effects)
//  access to a supplier from its index - ugly but faster than "exists(s in Supplier ...)"function supplier_I (i) { 
  var Result 
  var n  = kernel.size_class(C_FiniteSupplier)
  Result = ((i <= n) ? 
    C_FiniteSupplier.instances[i-1] :
    C_InfiniteSupplier.instances[(i-n)-1])
  return Result
  } 

// ----- function from method makeTransition @ string ------------- 
//  WARNING: this would be convenient but is not diet : (instanced(Transition))
//  create a transition (used in test.cl)
//  makeTransition(name,i->j,heat%, efficiency%, adaptationFactor%)function makeTransition (name,fromIndex,toIndex,h_Z,e_Z,a_Z) { 
  var tr 
  var _CL_obj  = (new Transition()).Is(C_Transition)
  _CL_obj.index = (1+C_pb.transitions.length)
  _CL_obj.from = supplier_I(fromIndex)
  _CL_obj.to = supplier_I(toIndex)
  _CL_obj.tag = name
  tr = _CL_obj
  C_pb.transitions = kernel.add_list(C_pb.transitions,tr)
  tr.heat_Z = h_Z
  tr.efficiency_Z = e_Z
  tr.adaptationFactor = a_Z
  var g0047  = supplier_I(fromIndex)
  g0047.from = kernel.add_list(g0047.from,tr)
  } 

// ----- function from method tr! @ integer ------------- 
//  debug short cut : find a transition through its indexfunction tr_I (i) { 
  return  C_pb.transitions[i-1]
  } 

// ----- function from method EJ @ float ------------- 
//  tranforms a Gt of oil equivalent into EJ (Exa Joule)function EJ (x) { 
  return  ((x/11.6)*41.86)
  } 

// ----- function from method TWh @ float ------------- 
//  transforms a Gt of oil equivalent into TWh (Tera Watt Hour)function TWh (x) { 
  return  (x*11630)
  } 

// ----- function from method C @ integer ------------- 
//  current satisfaction (score) -> classical for GTES
//  find a consumer by its indexfunction C (i) { 
  var Result 
  var c_some  = null
  for (const g0499 of C_Consumer.descendants){ 
    var g0500 
    g0500= false
    for (const c of g0499.instances){ 
      if (c.index == i) { 
        c_some = c
        g0500 = c_some
        break // loop = tuple("g0500", any)
        } 
      } 
    if (g0500 == true) { 
      
      break // loop = tuple("niet", any)
      } 
    } 
  Result = c_some
  return Result
  } 

// ----- function from method strategy @ float ------------- 
//  tactic is what gets optimized to achieve goals
//   how to set CO2 tax, how to set barriers (with CO2 emmiting), 
//  how to regulate energy transition, how to accelerate Cancel
//  constructor for Strategyfunction strategy (tCO2,tGDP,wCO2,wEconomy) { 
  var Result 
  var _CL_obj  = (new Strategy()).Is(C_Strategy)
  _CL_obj.targetCO2 = tCO2
  _CL_obj.targetGDP = tGDP
  _CL_obj.weightCO2 = wCO2
  _CL_obj.weightEconomy = wEconomy
  _CL_obj.weightPeople = (1-(wEconomy+wCO2))
  Result = _CL_obj
  return Result
  } 

// ----- function from method gdp$ @ integer ------------- 
//  the initialization function
//  utilities ------------------------------------------------------------------
//  inflation is a convention for printing a result in CCEM - by default, we use constant 2010 dollarsfunction gdp_dollar_integer (y) { 
  return  C_pb.world.all.Gdp_dollar(y)
  } 

// ----- function from method fP @ float ------------- 
//  easier for step-wise functions :)
//  print a float in fixed number of characters -------------------------------function fP (x,i) { 
  if (x < 0) { 
    kernel.PRINC("-")
    fP((-x),(i-1))
    }  else if (x >= 10) { 
    var n  = kernel.integer_I_float((kernel.log(x)/kernel.log(10)))
    kernel.princ_float9(x,(i-(n+2)))
    if (i == (n+2)) { 
      kernel.PRINC(" ")
      } 
    } else {
    kernel.princ_float9(x,(i-2))
    } 
  } 

// ----- function from method random @ float ------------- 
//  random number generator -------------------------------------------------function random_float (a,b) { 
  var Result 
  if (a > b) { 
    kernel.MakeError("random(a,b): a must be <= b",[]).Close()
    } 
  var r  = kernel.random_integer1(1000000)
  Result = (a+((r*(b-a))/1e+06))
  return Result
  } 

// ----- function from method sum @ list ------------- 
//  our sum macro  function sum (l) { 
  var Result 
  var x  = 0
  for (const y of l){ 
    x = (x+y)
    } 
  Result = x
  return Result
  } 

// ----- function from method average @ list ------------- 
//  averagefunction average (l) { 
  var Result 
  var arg_1 
  var g0501  = 0
  for (const g0502 of l){ 
    g0501 = (g0501+g0502)
    } 
  arg_1 = g0501
  Result = (arg_1/l.length)
  return Result
  } 

// ----- function from method CAGR @ float ------------- 
//  Composed Anual Growth Ratefunction CAGR_float (x1,x2,n) { 
  return  ((kernel._exp_float((x2/x1),(1/n))-1)*100)
  } 

// ----- function from method float! @ float ------------- 
//  makes float! a coercion (works both for integer and float)function float_I_float (x) { 
  return  x
  } 

// ----- function from method showNeeds @ list<type_expression>(Consumer, float, Block, integer) ------------- 
//  debug: show the needsfunction showNeeds_Consumer1 (c,c2,b,y) { 
  kernel.tformat("--- globalEconomyRatio(b,y) = ~F3 * ~F3\n",1,[b.EconomyRatio(y),b.TradeRatio(y)])
  kernel.tformat("--- economyRatio(b,y) = ~F3 / ~F3\n",1,[b.NewMaxout(y),b.gdp])
  b.ShowMaxout(y)
  b.ShowRoi(y)
  kernel.PRINC("[")
  kernel.print_any(year_I(y))
  kernel.PRINC("] ")
  kernel.print_any(c)
  kernel.PRINC(" needs = ")
  kernel.printFDigit_float(c2,2)
  kernel.PRINC(" (economy ")
  kernel.printFDigit_float((b.GlobalEconomyRatio(y)*100),1)
  kernel.PRINC("%")
  kernel.PRINC(", export ")
  kernel.printFDigit_float((b.OuterCommerceRatio(y)*100),1)
  kernel.PRINC("%")
  kernel.PRINC(", import ")
  kernel.printFDigit_float((importReductionRatio_Block1(b,y)*100),1)
  kernel.PRINC("%")
  kernel.PRINC(") x dmr=")
  kernel.printFDigit_float((c.DematerializationRate(y)*100),1)
  kernel.PRINC("%")
   kernel.PRINC("\n")
  } 

// ----- function from method showNeeds @ list<type_expression>(Consumer, integer) ------------- 
//  version that may be called from the consolefunction showNeeds_Consumer2 (c,y) { 
  var b  = c.economy
  var c0 
  var g0503  = 0
  for (const g0504 of c.consumes){ 
    g0503 = (g0503+g0504)
    } 
  c0 = g0503
  var dmr  = c.DematerializationRate(y)
  var c2  = (((c0*dmr)*b.GlobalEconomyRatio(y))*(1-b.disasterRatios[(y-1)-1]))
  showNeeds_Consumer1(c,c2,b,y)
  } 

// ----- function from method importReductionRatio @ list<type_expression>(Block, integer) ------------- 
//  opposite situation : w is impacted by imports from w2, because of its own barrier or 
//  because w2 is doing poorlyfunction importReductionRatio_Block1 (w,y) { 
  var Result 
  var g0505  = 0
  for (const g0508 of C_Block.descendants){ 
    for (const g0507 of g0508.instances){ 
      if (g0507 != w) { 
        var g0506  = (w.ImportTradeRatio(g0507,y)*importReductionRatio_Block2(w,g0507,y))
        g0505 = (g0505+g0506)
        } 
      } 
    } 
  Result = g0505
  return Result
  } 

// ----- function from method importReductionRatio @ list<type_expression>(Block, Block, integer) ------------- 
//  reduction of importation factor (w2 -> w:import): this is a negative correction when openTrade is less than 1.0function importReductionRatio_Block2 (w,w2,y) { 
  return  kernel.min_float(0,((w.openTrade[w2.Index()-1]-1)*C_pb.world.protectionismInFactor))
  } 

// ----- function from method populationEstimate @ list<type_expression>(Consumer, integer) ------------- 
//  new in CCEM v6: we model the impact of warming on the population
//  decline is both birth reductions (illnesses) and increased mortalityfunction populationEstimate_Consumer2 (c,y) { 
  var Result 
  var pn  = c.populationEstimate.Get(yearF(y))
  var birthrate  = (1/80)
  var decline 
  var g0509  = 0
  var g0511  = ((1 <= (y-80)) ? 
    (y-80) :
    1)
  var g0512  = (y-1)
  while (g0511 <= g0512) { 
    var g0510  = (((c.populationEstimate.Get(yearF(g0511))*birthrate)*c.painLevels[g0511-1])*c.populationFactor)
    g0509 = (g0509+g0510)
    g0511 = (g0511+1)
    } 
  decline = g0509
  Result = (pn-decline)
  return Result
  } 

// ----- function from method totalDemand @ integer ------------- 
//  [5] computes the need - Step 2 - for one precise supplier
//  compute total demand for all consumers for a suplier s and price pfunction totalDemand (y,s,p) { 
  var Result 
  var g0513  = 0
  for (const g0516 of C_Consumer.descendants){ 
    for (const g0515 of g0516.instances){ 
      var g0514  = g0515.HowMuch(s,s.OilEquivalent((p+g0515.Tax(s,y))))
      g0513 = (g0513+g0514)
      } 
    } 
  Result = g0513
  return Result
  } 

// ----- function from method consumes @ list<type_expression>(Consumer, Supplier, integer, float) ------------- 
//  record all cancel rates
//  [4] [6]  consumes : register the CO2 and register the energyfunction consumes_Consumer2 (c,s,y,x) { 
  if (s == C_TESTE) { 
    kernel.tformat("[~A] ~S consumes ~F2 of ~S [need = ~F2 reduced-> ~F2] \n",1,[year_I(y),
      c,
      x,
      s,
      c.economy.needs[y-1][s.index-1],
      c.HowMuch(s,c.TruePrice(s,y))])
    } 
  C_pb.earth.co2Emissions[y-1]=(C_pb.earth.co2Emissions[y-1]+(x*s.co2Factor))
  c.co2Emissions[y-1]=(c.co2Emissions[y-1]+(x*s.co2Factor))
  c.ePWhs[y-1]=(c.ePWhs[y-1]+(x*c.ERatio(s)))
  
  c.economy.carbonTaxAmounts[y-1]=(c.economy.carbonTaxAmounts[y-1]+((c.Tax(s,y)*x)/1000))
  c.economy.totalConsos[y-1]=(c.economy.totalConsos[y-1]+x)
  c.economy.inputs[y-1]=(c.economy.inputs[y-1]+x)
  s.gone = (s.gone+x)
   s.outputs[y-1]=(s.outputs[y-1]+x)
  } 

// ----- function from method steelFactor @ list<type_expression>(Supplier, integer) ------------- 
//  part of the cost of new energy is linked to the cost of steelfunction steelFactor_Supplier2 (s,y) { 
  var Result 
  var pf  = s.steelFactor
  Result = ((1-pf)+(pf*(C_pb.world.steelPrices[(y-1)-1]/C_pb.world.steelPrices[0])))
  return Result
  } 

// ----- function from method applyMaxGrowthRate @ float ------------- 
//  GW5 : to take the capacity growth into account, we need to compute the max growth rate expressed for the transfer flow,
//  computes the max capacity growth as a percentage of the complete max flow (all other s2 to s, all blocks)
//  w1 is the current rate, w2 is the expected rate, we apply the same proportional reduction factor so that the actual transfer flow meets the constraintfunction applyMaxGrowthRate (w1,w2,s1,s2,y) { 
  return  (w1+(((w2-w1)*s2.MaxTransferRate(y))*s1.PriceDeltaRate(s2,y)))
  } 

// ----- function from method getEconomy @ integer ------------- 
//  verbosity for model M4
//  computes the economy for a given year -> 4 blocs then consolidatefunction getEconomy (y) { 
  for (const g0517 of C_Block.descendants){ 
    for (const b of g0517.instances){ 
      checkBalance_Consumer1(b.describes,y)
      } 
    } 
  for (const g0518 of C_Supplier.descendants){ 
    for (const s of g0518.instances){ 
      s.CheckTransfers(y)
      } 
    } 
  for (const g0519 of C_Block.descendants){ 
    for (const b of g0519.instances){ 
      b.Consumes(y)
      } 
    } 
  for (const g0520 of C_Consumer.descendants){ 
    for (const c of g0520.instances){ 
      c.economy.sobriety[y-1]=(c.economy.cancels[y-1]*(c.cancelAcceleration/(1+c.cancelAcceleration)))
      } 
    } 
  var e  = C_pb.world.all
  e.Consolidate(y)
  steelPrice_integer(y)
  for (const g0521 of C_Block.descendants){ 
    for (const b of g0521.instances){ 
      b.SteelConsumption(y)
      } 
    } 
  var arg_1 
  var g0522  = 0
  for (const g0525 of C_Block.descendants){ 
    for (const g0524 of g0525.instances){ 
      var g0523  = g0524.ironConsos[y-1]
      g0522 = (g0522+g0523)
      } 
    } 
  arg_1 = g0522
  C_pb.world.all.ironConsos[y-1]=arg_1
  
  agroOutput(y)
  
  
  
  } 

// ----- function from method steelPrice @ integer ------------- 
//  [7] computes the steel price function steelPrice_integer (y) { 
  var w  = C_pb.world
  w.steelPrices[y-1]=((w.steelPrice*(avgOilEquivalent(y)/avgOilEquivalent(1)))*(w.energy4steel.Get(yearF(y))/w.energy4steel.Get(yearF(1))))
  } 

// ----- function from method computeProtectionism @ integer ------------- 
//  [6] once the "alpha" factors have been set, we compute the protectionism level ()
//  note that we protect based on the difference between co2/Energy and the existance of a similar level of CO2 taxfunction computeProtectionism (y) { 
  var w  = C_pb.world
  for (const g0530 of C_Consumer.descendants){ 
    for (const c1 of g0530.instances){ 
      var w1  = c1.economy
      var alpha  = c1.protectionismFactor
      for (const g0531 of C_Consumer.descendants){ 
        for (const c2 of g0531.instances){ 
          if (c2 != c1) { 
            var co2perE1  = c1.CDensity(y)
            var co2perE2  = c2.CDensity(y)
            var w2  = c2.economy
            var ctax1  = c1.TaxRate(y)
            var ctax2  = c2.TaxRate(y)
            w1.reducedImports[y-1]=(w1.reducedImports[y-1]-((w2.results[y-1]*C_pb.trade[w2.Index()-1][w1.Index()-1])*importReductionRatio_Block2(w1,w2,y)))
            
            w1.openTrade[c2.index-1]=(1-kernel.min_float(1,((alpha*((0 <= ((co2perE2-co2perE1)/(0.001+co2perE1))) ? 
              ((co2perE2-co2perE1)/(0.001+co2perE1)) :
              0))*((0 <= ((ctax1-ctax2)/(0.001+ctax1))) ? 
              ((ctax1-ctax2)/(0.001+ctax1)) :
              0))))
            
            if (alpha > 0) { 
              kernel.tformat("protectionism for ~S(tax:~F2) -> ~S(tax:~F2) = ~F% from co2/GDP ~F% and ~F% [~F%]\n",2,[c1,
                ctax1,
                c2,
                ctax2,
                w1.openTrade[c2.index-1],
                co2perE1,
                co2perE2,
                alpha])
              } 
            } 
          } 
        } 
      } 
    } 
  } 

// ----- function from method agroOutput @ integer ------------- 
//  transform m2/MWh into millionskm2/PWhfunction agroOutput (y) { 
  var w  = C_pb.world
  var e  = C_pb.earth
  var newClean  = ((0 <= (C_pb.clean.capacities[y-1]-C_pb.clean.capacities[(y-1)-1])) ? 
    (C_pb.clean.capacities[y-1]-C_pb.clean.capacities[(y-1)-1]) :
    0)
  var prevSurface  = w.agroSurfaces[(y-1)-1]
  var efficiencyRatio  = ((w.agroEfficiency.Get(avgOilEquivalent(y))*w.bioHealth.Get(warming_integer((y-1))))*w.cropYield.Get(yearF(y)))
  
  w.energySurfaces[y-1]=(w.energySurfaces[(y-1)-1]+((newClean*w.landImpact.Get(yearF(y)))*C_Gt2km2))
  w.agroSurfaces[y-1]=((w.agroLand-w.energySurfaces[y-1])*w.lossLandWarming.Get(warming_integer(y)))
  w.wheatOutputs[y-1]=((w.wheatProduction*(w.agroSurfaces[y-1]/w.agroLand))*efficiencyRatio)
  
  } 

// ----- function from method warming @ integer ------------- 
//  handyfunction warming_integer (y) { 
  return  (C_pb.earth.temperatures[y-1]-C_pb.earth.avgCentury)
  } 

// ----- function from method avgOilEquivalent @ integer ------------- 
//  avgOilEquivalent(y) is the equivalent oil price for each energy source weighted by productionfunction avgOilEquivalent (y) { 
  var Result 
  var p  = 0
  var o  = 0
  for (const g0532 of C_Supplier.descendants){ 
    for (const s of g0532.instances){ 
      p = (p+(s.OilEquivalent(s.sellPrices[y-1])*s.outputs[y-1]))
      o = (o+s.outputs[y-1])
      } 
    } 
  Result = (p/o)
  return Result
  } 

// ----- function from method computeAdaptation @ integer ------------- 
//  CCEM v7: Adaptation
//  adaptationLevel is read from the investment levels that defines the "insurance" protection
//  the driver is the ratio (adaptation spending / dommage+3)function computeAdaptation (y) { 
  for (const g0533 of C_Consumer.descendants){ 
    for (const c of g0533.instances){ 
      if (c.adapt.levels[(y-1)-1] < c.adapt.efficiency.maxValue) { 
        c.adapt.spends[y-1]=(c.economy.investGrowth[y-1]*c.adapt.investFactor)
        } 
      c.adapt.sums[y-1]=(c.adapt.sums[(y-1)-1]+c.adapt.spends[y-1])
      var dommage  = (c.economy.results[y-1]*c.disasterLoss.Get(3))
      var investRatio  = (c.adapt.sums[y-1]/dommage)
      
      c.adapt.levels[y-1]=c.adapt.efficiency.Get(investRatio)
      } 
    } 
  } 

// ----- function from method dmatch @ thing ------------- 
//  ********************************************************************
//  *    Part 6: Run-time model checking                               *
//  ********************************************************************
//  match a string in the object name (consumer or supplier) to debug the modelfunction dmatch (x,y) { 
  if (x.name == y) {return true
  } else {return false}} 

// ----- function from method checkBalance @ list<type_expression>(Consumer, integer) ------------- 
//  transfer decisions from past year are applied
//  Dynamic Balance checks for M4 
//  debug function: show the energy balance of a consumer (need -> conso + cancel)
//  we keep it for the time being to avoid new bugs ...
//  V7 note: savings are not checked since they are removed from needs (eSavings and savings)function checkBalance_Consumer1 (c,y) { 
  var c1  = c.SumNeeds(y)
  var c2  = c.SumConsos(y)
  var c3  = c.SumCancelBySupplier(y)
  var csum  = (c2+c3)
  
  if (kernel.abs_float(((c1-csum)/csum)) > 0.01) { 
    kernel.tformat("[~S] BALANCE(~S): need ~F2 vs ~F2 {~F%} (consos:~F%, cancels:~F%)\n",0,[year_I(y),
      c,
      c1,
      csum,
      kernel.abs_float(((c1-csum)/csum)),
      (c2/csum),
      (c3/csum)])
    for (const g0534 of C_Supplier.descendants){ 
      for (const s of g0534.instances){ 
        checkBalance_Consumer2(c,s,y)
        } 
      } 
    } 
  } 

// ----- function from method checkBalance @ list<type_expression>(Consumer, Supplier, integer) ------------- 
//  more precise debug function: balance for a consumer and a supplierfunction checkBalance_Consumer2 (c,s,y) { 
  var c1  = c.Needs()[y-1][s.index-1]
  var c2  = c.consos[y-1][s.index-1]
  var c3  = (c.Needs()[y-1][s.index-1]*c.cancel_Z[y-1][s.index-1])
  var csum  = (c2+c3)
  
  } 

// ----- function from method printEnergyPrices @ integer ------------- 
//  show the pricesfunction printEnergyPrices (y) { 
  for (const g0535 of C_Supplier.descendants){ 
    for (const s of g0535.instances){ 
      kernel.print_any(s)
      kernel.PRINC(":")
      kernel.printFDigit_float(s.sellPrices[y-1],1)
      kernel.PRINC("$,")
      } 
    } 
  } 

// ----- function from method priceSample @ list ------------- 
//  sample makes an affine object from the prod/need curves - x axis is price incrementfunction priceSample (l) { 
  var Result 
  var m1  = 1e+09
  var M1  = -1e+09
  var l1 
  var x_bag  = []
  var x  = 1
  var g0536  = C_NIS
  while (x <= g0536) { 
    kernel.add_list(x_bag,C_pb.priceRange[x-1])
    x = (x+1)
    } 
  l1 = x_bag
  for (const v of l){ 
    m1 = ((m1 <= v) ? 
      m1 :
      v)
    M1 = ((M1 <= v) ? 
      v :
      M1)
    } 
  var _CL_obj  = (new Affine()).Is(C_Affine)
  _CL_obj.n = l.length
  _CL_obj.minValue = m1
  _CL_obj.maxValue = M1
  _CL_obj.xValues = l1
  _CL_obj.yValues = l
  Result = _CL_obj
  return Result
  } 

// ----- function from method timeSample @ list ------------- 
//  same with a time serie - x axis is yearsfunction timeSample (l) { 
  var Result 
  var m1  = 1e+09
  var M1  = -1e+09
  var nL  = l.length
  var l1 
  var i_bag  = []
  var i  = 1
  var g0537  = nL
  while (i <= g0537) { 
    kernel.add_list(i_bag,yearF(i))
    i = (i+1)
    } 
  l1 = i_bag
  for (const v of l){ 
    m1 = ((m1 <= v) ? 
      m1 :
      v)
    M1 = ((M1 <= v) ? 
      v :
      M1)
    } 
  var _CL_obj  = (new Affine()).Is(C_Affine)
  _CL_obj.n = l.length
  _CL_obj.minValue = m1
  _CL_obj.maxValue = M1
  _CL_obj.xValues = l1
  _CL_obj.yValues = l
  Result = _CL_obj
  return Result
  } 

// ----- function from method iterate_run @ list<type_expression>(integer) ------------- 
//  run n years of simulation, then show the resultsfunction iterate_run_integer1 (n) { 
   iterate_run_integer2(n,true)
  } 

// ----- function from method iterate_run @ list<type_expression>(integer, boolean) ------------- 
function iterate_run_integer2 (n,talk_ask) { 
  if (talk_ask == true) { 
    kernel.time_set()
    } 
  var i  = 1
  var g0546  = n
  while (i <= g0546) { 
    C_pb.Run(talk_ask)
    i = (i+1)
    } 
  if (talk_ask == true) { 
    kernel.time_show()
     see_void()
    } 
  } 

// ----- function from method allSaving @ integer ------------- 
// 
//  needed in web.cl (world sum of savings)   function allSaving (y) { 
  var Result 
  var g0547  = 0
  for (const g0550 of C_Consumer.descendants){ 
    for (const g0549 of g0550.instances){ 
      var g0548  = g0549.SumSavings(y)
      g0547 = (g0547+g0548)
      } 
    } 
  Result = g0547
  return Result
  } 

// ----- function from method steelConso @ integer ------------- 
function steelConso (y) { 
  var Result 
  var g0551  = 0
  for (const g0554 of C_Block.descendants){ 
    for (const g0553 of g0554.instances){ 
      var g0552  = g0553.ironConsos[y-1]
      g0551 = (g0551+g0552)
      } 
    } 
  Result = g0551
  return Result
  } 

// ----- function from method carbonTax @ integer ------------- 
function carbonTax_integer (y) { 
  var Result 
  var g0555  = 0
  for (const g0558 of C_Consumer.descendants){ 
    for (const g0557 of g0558.instances){ 
      var g0556  = g0557.economy.carbonTaxAmounts[y-1]
      g0555 = (g0555+g0556)
      } 
    } 
  Result = g0555
  return Result
  } 

// ----- function from method co2KWh @ integer ------------- 
//  computes the co2KWh ratio for each yearfunction co2KWh (y) { 
  var Result 
  var arg_1 
  var g0559  = 0
  for (const g0562 of C_Supplier.descendants){ 
    for (const g0561 of g0562.instances){ 
      var g0560  = (g0561.co2Kwh*g0561.outputs[y-1])
      g0559 = (g0559+g0560)
      } 
    } 
  arg_1 = g0559
  var arg_2 
  var g0563  = 0
  for (const g0566 of C_Supplier.descendants){ 
    for (const g0565 of g0566.instances){ 
      var g0564  = g0565.outputs[y-1]
      g0563 = (g0563+g0564)
      } 
    } 
  arg_2 = g0563
  Result = (arg_1/arg_2)
  return Result
  } 

// ----- function from method energyIntensity @ integer ------------- 
//  computes the energy intensity (kW.h/$) for each yearfunction energyIntensity_integer (y) { 
  return  (TWh(C_pb.world.all.totalConsos[y-1])/(1000*C_pb.world.all.results[y-1]))
  } 

// ----- function from method gdpp @ integer ------------- 
//  compute the GDP/personfunction gdpp (y) { 
  return  (C_pb.world.all.results[y-1]/worldPopulation(y))
  } 

// ----- function from method averagePain @ integer ------------- 
//  averagePainfunction averagePain (y) { 
  var Result 
  var arg_1 
  var g0567  = 0
  for (const g0570 of C_Consumer.descendants){ 
    for (const g0569 of g0570.instances){ 
      var g0568  = g0569.painLevels[y-1]
      g0567 = (g0567+g0568)
      } 
    } 
  arg_1 = g0567
  Result = (arg_1/4)
  return Result
  } 

// ----- function from method averageEnergyPain @ integer ------------- 
//  averagePain from (lack of) energyfunction averageEnergyPain (y) { 
  var Result 
  var arg_1 
  var g0571  = 0
  for (const g0574 of C_Consumer.descendants){ 
    for (const g0573 of g0574.instances){ 
      var g0572  = g0573.painEnergy[y-1]
      g0571 = (g0571+g0572)
      } 
    } 
  arg_1 = g0571
  Result = (arg_1/4)
  return Result
  } 

// ----- function from method averageEconomyPain @ integer ------------- 
//  averagePain from Economy (loss of PNB)function averageEconomyPain (y) { 
  var Result 
  var arg_1 
  var g0575  = 0
  for (const g0578 of C_Consumer.descendants){ 
    for (const g0577 of g0578.instances){ 
      var g0576  = g0577.painResults[y-1]
      g0575 = (g0575+g0576)
      } 
    } 
  arg_1 = g0575
  Result = (arg_1/4)
  return Result
  } 

// ----- function from method averageWarmingPain @ integer ------------- 
//  averagePain from warmingfunction averageWarmingPain (y) { 
  var Result 
  var arg_1 
  var g0579  = 0
  for (const g0582 of C_Consumer.descendants){ 
    for (const g0581 of g0582.instances){ 
      var g0580  = g0581.painWarming[y-1]
      g0579 = (g0579+g0580)
      } 
    } 
  arg_1 = g0579
  Result = (arg_1/4)
  return Result
  } 

// ----- function from method see @ void ------------- 
//  ********************************************************************
//  *    Part 2: Simulation & Results                                  *
//  ********************************************************************
//  see() shows the situation for a given yearfunction see_void () { 
  kernel.PRINC("************************************************************************************\n")
  kernel.PRINC("*          Simulation results in Year ")
  kernel.princ_integer(year_I(C_pb.year))
  kernel.PRINC("                                         *\n")
  kernel.PRINC("*          ")
  kernel.princ_string8(C_pb.comment,68)
  kernel.PRINC("    *\n")
  kernel.PRINC("************************************************************************************\n")
  C_pb.world.all.See(C_pb.year)
  C_pb.earth.See(C_pb.year)
  for (const g0583 of C_Supplier.descendants){ 
    for (const s of g0583.instances){ 
      s.See(C_pb.year)
      } 
    } 
  for (const g0584 of C_Consumer.descendants){ 
    for (const c of g0584.instances){ 
      c.See(C_pb.year)
      } 
    } 
  for (const g0585 of C_Consumer.descendants){ 
    for (const c of g0585.instances){ 
      c.economy.See(C_pb.year)
      } 
    } 
  seeGDP(C_pb.year)
  updateCharts(C_pb.year)
   sls()
  } 

// ----- function from method updateCharts @ integer ------------- 
//  update all the Charts (at the end of the simulation)function updateCharts (y) { 
  C_pb.earth.UpdateChartsEarth(y)
  for (const g0590 of C_Consumer.descendants){ 
    for (const c of g0590.instances){ 
      c.UpdateChartsConsumer(y)
      } 
    } 
  for (const g0591 of C_Supplier.descendants){ 
    for (const s of g0591.instances){ 
      s.UpdateChartsSupplier(y)
      } 
    } 
  } 

// ----- function from method udapdateChart @ list ------------- 
//  updates all the measures in a Tmeasure from a Chartsfunction udapdateChart (lm,y,lv) { 
  var i  = 1
  var g0604  = y
  while (i <= g0604) { 
    lm[i-1].Add(lv[i-1])
    i = (i+1)
    } 
  } 

// ----- function from method seeGDP @ integer ------------- 
//  show the GDP with inflationfunction seeGDP (y) { 
  kernel.PRINC("[")
  kernel.princ_integer(year_I(y))
  kernel.PRINC("] current GDP = ")
  kernel.printFDigit_float(gdp_dollar_integer(y),2)
  kernel.PRINC("T$, ")
  for (const g0605 of C_Consumer.descendants){ 
    for (const c of g0605.instances){ 
      kernel.print_any(c)
      kernel.PRINC(": ")
      kernel.printFDigit_float(c.Gdp_dollar(y),2)
      kernel.PRINC("T$, ")
      } 
    } 
   kernel.PRINC("\n")
  } 

// ----- function from method sls @ void ------------- 
//  single line summaryfunction sls () { 
  var w  = C_pb.world.all
  var y  = C_pb.year
  kernel.PRINC("// ")
  kernel.princ_string8(C_pb.comment,5)
  kernel.PRINC("(")
  kernel.princ_integer(year_I(y))
  kernel.PRINC(") PNB: ")
  kernel.printFDigit_float(w.results[y-1],1)
  kernel.PRINC("T$, ")
  kernel.printFDigit_float(w.totalConsos[y-1],1)
  kernel.PRINC("PWh -> ")
  kernel.printFDigit_float(C_pb.earth.co2Levels[y-1],1)
  kernel.PRINC("ppm CO2, ")
  kernel.printFDigit_float(C_pb.earth.temperatures[y-1],1)
  kernel.PRINC("C, ")
  kernel.printFDigit_float(C_pb.clean.outputs[y-1],1)
  kernel.PRINC("PWh clean, ")
  kernel.printFDigit_float((electrification_Z(y)*100),1)
  kernel.PRINC("%")
  kernel.PRINC(" electricity\n")
  } 

// ----- function from method electrification% @ integer ------------- 
//  electrification ratiofunction electrification_Z (y) { 
  var Result 
  var arg_1 
  var g0606  = 0
  for (const g0609 of C_Consumer.descendants){ 
    for (const g0608 of g0609.instances){ 
      var g0607  = g0608.ePWhs[y-1]
      g0606 = (g0606+g0607)
      } 
    } 
  arg_1 = g0606
  Result = (arg_1/C_pb.world.all.totalConsos[y-1])
  return Result
  } 

// ----- function from method transferToClean% @ integer ------------- 
//  transfert to clean ratio at a given year (weighted average by consos)function transferToClean_Z (y) { 
  var Result 
  var sum_w  = 0
  var sum_p  = 0
  for (const g0610 of C_Consumer.descendants){ 
    for (const c of g0610.instances){ 
      var w 
      var g0611  = 0
      for (const g0612 of c.consos[y-1]){ 
        g0611 = (g0611+g0612)
        } 
      w = g0611
      for (const g0613 of C_FiniteSupplier.descendants){ 
        for (const s of g0613.instances){ 
          var tr  = s.GetTransition(C_pb.clean)
          sum_w = (sum_w+w)
          sum_p = (sum_p+(w*c.transferRates[y-1][tr.index-1]))
          } 
        } 
      } 
    } 
  Result = (sum_p/sum_w)
  return Result
  } 

// ----- function from method pl2 @ list ------------- 
//  prints a list of float with F2function pl2 (l) { 
  for (const x of l){ 
    kernel.printFDigit_float(x,2)
    kernel.PRINC(" ")
    } 
  } 

// ----- function from method worldPopulation @ integer ------------- 
//  worldwide populationfunction worldPopulation (y) { 
  var Result 
  var g0618  = 0
  for (const g0621 of C_Consumer.descendants){ 
    for (const g0620 of g0621.instances){ 
      var g0619  = populationEstimate_Consumer2(g0620,y)
      g0618 = (g0618+g0619)
      } 
    } 
  Result = g0618
  return Result
  } 

// ----- function from method init @ void ------------- 
//  initialize all the simulation objects
//  we want the time series *s[y]function init_void () { 
  { 
    var va_arg2 
    var i_bag  = []
    var i  = 2
    var g0622  = (C_NIS+1)
    while (i <= g0622) { 
      kernel.add_list(i_bag,(C_PMIN+((C_PMAX*(i*i))/((C_NIS+1)*(C_NIS+1)))))
      i = (i+1)
      } 
    va_arg2 = i_bag
    C_pb.priceRange = va_arg2
    } 
  { 
    var va_arg2 
    var x_bag  = []
    var x  = 1
    var g0623  = C_NIS
    while (x <= g0623) { 
      kernel.add_list(x_bag,0)
      x = (x+1)
      } 
    va_arg2 = x_bag
    C_pb.needCurve = va_arg2
    } 
  { 
    var va_arg2 
    var x_bag  = []
    var x  = 1
    var g0624  = C_NIS
    while (x <= g0624) { 
      kernel.add_list(x_bag,0)
      x = (x+1)
      } 
    va_arg2 = x_bag
    C_pb.prodCurve = va_arg2
    } 
  makeCharts(C_NIT)
   initialization()
  } 

// ----- function from method makeCharts @ integer ------------- 
//     initKNU()]
//  update all the Chartsfunction makeCharts (y) { 
  C_pb.earth.charts = makeChartsEarth(y)
  for (const g0785 of C_Consumer.descendants){ 
    for (const c of g0785.instances){ 
      c.charts = makeChartsConsumer(y)
      } 
    } 
  for (const g0786 of C_Supplier.descendants){ 
    for (const s of g0786.instances){ 
      s.charts = makeChartsSupplier(y)
      } 
    } 
  } 

// ----- function from method makeChartsEarth @ integer ------------- 
//  create an empty chart for the earthfunction makeChartsEarth (y) { 
  var Result 
  var _CL_obj  = (new ChartsEarth()).Is(C_ChartsEarth)
  _CL_obj.co2Levels = makeTmeasure(y)
  _CL_obj.temperatures = makeTmeasure(y)
  _CL_obj.co2Emissions = makeTmeasure(y)
  _CL_obj.gdpLosses = makeTmeasure(y)
  Result = _CL_obj
  return Result
  } 

// ----- function from method makeChartsConsumer @ integer ------------- 
//  create an empty chart for a consumerfunction makeChartsConsumer (y) { 
  var Result 
  var _CL_obj  = (new ChartsConsumer()).Is(C_ChartsConsumer)
  { 
    var va_arg2 
    var s_bag  = []
    for (const g0787 of C_Supplier.descendants){ 
      for (const s of g0787.instances){ 
        kernel.add_list(s_bag,makeTmeasure(y))
        } 
      } 
    va_arg2 = s_bag
    _CL_obj.consos = va_arg2
    } 
  _CL_obj.gdp = makeTmeasure(y)
  _CL_obj.needs = makeTmeasure(y)
  _CL_obj.cancel_Z = makeTmeasure(y)
  _CL_obj.savings = makeTmeasure(y)
  _CL_obj.carbonTaxAmounts = makeTmeasure(y)
  _CL_obj.painLevels = makeTmeasure(y)
  Result = _CL_obj
  return Result
  } 

// ----- function from method makeChartsSupplier @ integer ------------- 
//  create an empty chart for a supplierfunction makeChartsSupplier (y) { 
  var Result 
  var _CL_obj  = (new ChartsSupplier()).Is(C_ChartsSupplier)
  _CL_obj.outputs = makeTmeasure(y)
  _CL_obj.sellPrices = makeTmeasure(y)
  _CL_obj.inventories = makeTmeasure(y)
  _CL_obj.capacities = makeTmeasure(y)
  _CL_obj.rawNeeds = makeTmeasure(y)
  Result = _CL_obj
  return Result
  } 

// ----- function from method initialization @ void ------------- 
//  reusable part (for init and reinit)function initialization () { 
  C_pb.year = 1
  C_pb.world.Init()
  C_pb.earth.Init()
  consolidate_void()
  for (const g0788 of C_Supplier.descendants){ 
    for (const s of g0788.instances){ 
      s.Init()
      } 
    } 
  for (const g0789 of C_Consumer.descendants){ 
    for (const c of g0789.instances){ 
      c.Init()
      } 
    } 
   C_pb.world.all.Consolidate(1)
  } 

// ----- function from method reinit @ void ------------- 
//  reinit version (refresh data)   function reinit () { 
  if (C_pb.earth != null) { 
     initialization()
    } else {
     init_void()
    } 
  } 

// ----- function from method consolidate @ void ------------- 
//  consolidation of the world economy : init versionfunction consolidate_void () { 
  var e  = C_pb.world.all
  { 
    var va_arg2 
    var g0790  = 0
    for (const g0793 of C_Block.descendants){ 
      for (const g0792 of g0793.instances){ 
        var g0791  = g0792.gdp
        g0790 = (g0790+g0791)
        } 
      } 
    va_arg2 = g0790
    e.gdp = va_arg2
    } 
  { 
    var va_arg2 
    var g0794  = 0
    for (const g0797 of C_Block.descendants){ 
      for (const g0796 of g0797.instances){ 
        var g0795  = g0796.investG
        g0794 = (g0794+g0795)
        } 
      } 
    va_arg2 = g0794
    e.investG = va_arg2
    } 
  { 
    var va_arg2 
    var g0798  = 0
    for (const g0801 of C_Block.descendants){ 
      for (const g0800 of g0801.instances){ 
        var g0799  = g0800.investE
        g0798 = (g0798+g0799)
        } 
      } 
    va_arg2 = g0798
    e.investE = va_arg2
    } 
  } 

// ----- function from method SETM @ list ------------- 
//  ********************************************************************
//  *    Part 4: KNU scripting, reset & Randomization                  *
//  ********************************************************************
//  create a transition matrix for a sector
//  assumes 0% at ORIGIN
//  eg : SETM(list(2050,2100),
//                    list(list(Coal,list(Oil,0%,0%),list(Gas,100%,100%),list(Clean,0%,0%)),
//                         list(Oil,list(Gas,10%,20%),list(Clean,10%,30%)),
//                          list(Gas,list(Clean,20%,40%))))function SETM (ldates,ldesc) { 
  var Result 
  var n  = ldates.length
  var larg 
  var v_list1 
  var tr 
  v_list1 = C_pb.transitions
  larg = new Array(v_list1.length)
  for (let CLcount = 0; CLcount < v_list1.length; CLcount++){ 
    tr = v_list1[CLcount]
    larg[CLcount] = null
    } 
  for (const l of ldesc){ 
    var s1  = l[1-1]
    var k  = l.length
    var w  = 2
    var g0802  = k
    while (w <= g0802) { 
      var l2  = l[w-1]
      var s2  = l2[1-1]
      var tr  = s1.GetTransition(s2)
      
      var arg_1 
      var arg_2 
      var arg_4 
      var j_bag  = []
      var j  = 1
      var g0803  = n
      while (j <= g0803) { 
        kernel.add_list(j_bag,ldates[j-1])
        j = (j+1)
        } 
      arg_4 = j_bag
      arg_2 = kernel._7_plus_list([C_ORIGIN],arg_4)
      var arg_3 
      var arg_5 
      var j_bag  = []
      var j  = 1
      var g0804  = n
      while (j <= g0804) { 
        kernel.add_list(j_bag,l2[(j+1)-1])
        j = (j+1)
        } 
      arg_5 = j_bag
      arg_3 = kernel._7_plus_list([0],arg_5)
      arg_1 = make_affine(arg_2,arg_3)
      larg[tr.index-1]=arg_1
      w = (w+1)
      } 
    } 
  Result = larg
  return Result
  } 

// ----- function from method ETM @ list ------------- 
//  How to define the energy transition matrix from the sector KNUs
//  ETM (Energy Transition Matrix) would be produced from the sector transition matrices and
//  zone-specific transition speeds 
//  example : => ETM(list(60%,80%,100%),list(Transport,20%),list(Industry,30%),list(Residential,20%))
//  assertion: length(seed) = length(ldates)function ETM (seed,sectors) { 
  var Result 
  var ldates  = []
  var lweight 
  var s_bag  = []
  for (const g0805 of C_Sector.descendants){ 
    for (const s of g0805.instances){ 
      kernel.add_list(s_bag,0)
      } 
    } 
  lweight = s_bag
  for (const l of sectors){ 
    var s  = l[0]
    lweight[s.index-1]=l[1]
    } 
  var arg_1 
  var arg_2 
  var g0806  = 0
  for (const g0807 of lweight){ 
    g0806 = (g0806+g0807)
    } 
  arg_2 = g0806
  arg_1 = (1-arg_2)
  lweight[kernel.size_class(C_Sector)-1]=arg_1
  for (const g0808 of C_Sector.descendants){ 
    for (const s of g0808.instances){ 
      if (ldates.length == 0) { 
        ldates = s.subMatrix[0].xValues
        } 
      } 
    } 
  
  var v_list1 
  var tr 
  var v_local1 
  v_list1 = C_pb.transitions
  Result = new Array(v_list1.length)
  for (let CLcount = 0; CLcount < v_list1.length; CLcount++){ 
    tr = v_list1[CLcount]
    var i  = tr.index
    var n  = ldates.length
    var arg_3 
    var j_bag  = []
    var j  = 1
    var g0809  = n
    while (j <= g0809) { 
      var arg_4 
      var arg_5 
      var g0810  = 0
      for (const g0813 of C_Sector.descendants){ 
        for (const g0812 of g0813.instances){ 
          var g0811  = (g0812.subMatrix[tr.index-1].yValues[j-1]*tr.from.EnergyWeight(g0812,lweight))
          g0810 = (g0810+g0811)
          } 
        } 
      arg_5 = g0810
      arg_4 = (seed[j-1]*arg_5)
      kernel.add_list(j_bag,arg_4)
      j = (j+1)
      } 
    arg_3 = j_bag
    v_local1 = make_affine(ldates,arg_3)
    Result[CLcount] = v_local1
    } 
  return Result
  } 

// ----- function from method densityCurve @ integer ------------- 
//  creates an Affine function that increases according to CAGR given for some decades (cummulated decrease of energy)
//  ex: USDemat :: densityCurve(1980,list(2020,1.7%),list(2050,1.5%),list(2100,1.2%))function densityCurve (start,l) { 
  var Result 
  var date  = start
  var ldate  = [date]
  var value  = 0
  var lvalue  = [value]
  for (const item of l){ 
    var end  = item[1-1]
    var cagr  = item[2-1]
    var n  = ((end-date)/10)
    var i  = 1
    var g0822  = n
    while (i <= g0822) { 
      date = (date+10)
      ldate = kernel.add_list(ldate,date)
      value = (1-((1-value)/kernel._exp_float((1+cagr),10)))
      lvalue = kernel.add_list(lvalue,value)
      i = (i+1)
      } 
    } 
  Result = make_affine(ldate,lvalue)
  return Result
  } 

// ----- function from method elasticityCurve @ float ------------- 
function elasticityCurve (start,shortTerm,longTerm) { 
  var Result 
  var price  = start
  var lprices  = [price]
  var value  = 0
  var lvalues  = [value]
  price = (price*2)
  lprices = kernel.add_list(lprices,price)
  value = (1-((1-value)/(1+shortTerm)))
  lvalues = kernel.add_list(lvalues,value)
  var i  = 1
  var g0823  = C_ELASMAX
  while (i <= g0823) { 
    price = (price*2)
    lprices = kernel.add_list(lprices,price)
    
    value = (1-((1-value)/(1+longTerm)))
    if (i == C_ELASMAX) { 
      value = 0.99
      } 
    lvalues = kernel.add_list(lvalues,value)
    i = (i+1)
    } 
  Result = make_affine(lprices,lvalues)
  return Result
  } 

// ----- function from method initKNU @ void ------------- 
//  init the store for values that will be mofidied by the KNU slidersfunction initKNU () { 
  { 
    var va_arg2 
    var b_bag  = []
    for (const g0826 of C_Block.descendants){ 
      for (const b of g0826.instances){ 
        kernel.add_list(b_bag,b.dematerialize)
        } 
      } 
    va_arg2 = b_bag
    C_KNUstore.dematerializes = va_arg2
    } 
  { 
    var va_arg2 
    var c_bag  = []
    for (const g0827 of C_Consumer.descendants){ 
      for (const c of g0827.instances){ 
        kernel.add_list(c_bag,c.subMatrix)
        } 
      } 
    va_arg2 = c_bag
    C_KNUstore.subMatrices = va_arg2
    } 
  { 
    var va_arg2 
    var c_bag  = []
    for (const g0828 of C_Consumer.descendants){ 
      for (const c of g0828.instances){ 
        kernel.add_list(c_bag,c.cancel)
        } 
      } 
    va_arg2 = c_bag
    C_KNUstore.cancels = va_arg2
    } 
  var arg_1 
  var b_bag  = []
  for (const g0829 of C_Block.descendants){ 
    for (const b of g0829.instances){ 
      kernel.add_list(b_bag,b.RoI())
      } 
    } 
  arg_1 = b_bag
  kernel.write(C_roIs,C_KNUstore,arg_1)
  } 

// ----- function from method accelerate @ list ------------- 
//     
//  ********************************************************************
//  *    Part 5: Utility functions for input                           *
//  ********************************************************************
//  accelerate : change the date to accelerate a policy (pivot is 2000)function accelerate_list (policy,factor) { 
  var Result 
  var v_list1 
  var p 
  var v_local1 
  v_list1 = policy
  Result = new Array(v_list1.length)
  for (let CLcount = 0; CLcount < v_list1.length; CLcount++){ 
    p = v_list1[CLcount]
    v_local1 = p.Accelerate(factor)
    Result[CLcount] = v_local1
    } 
  return Result
  } 

// ----- function from method improve% @ float ------------- 
//  improve% : modify the factors without changing the dates - additive version
//  special form so that % stays a percentfunction improve_Z_float (x,factor) { 
  
  if (factor > 0) { 
    return  (x+(factor*(1-x)))
    } else {
    return  (x+(factor*x))
    } 
  } 

// ----- function from method multiply% @ float ------------- 
//  multiplicative version  x -> x * (1 + factor)  (factor = 0% => idempotent)function multiply_Z_float (x,factor) { 
  
  return  kernel.min_float(1,(x*(1+factor)))
  } 

// ----- function from method tune @ list ------------- 
//  tune a policy by changing one substitutionfunction tune (policy,from,to,line) { 
  var Result 
  var tr  = from.GetTransition(to)
  var n  = policy.length
  var i_bag  = []
  var i  = 1
  var g0832  = n
  while (i <= g0832) { 
    kernel.add_list(i_bag,((i == tr.index) ? 
      line :
      policy[i-1]))
    i = (i+1)
    } 
  Result = i_bag
  return Result
  } 

// ----- function from method balanceOfTrade @ list ------------- 
//  create a trade matrix
//  inputs are export flows in billions of dollars, gdp in in trillons of dollarsfunction balanceOfTrade (lt,lgdp) { 
  var Result 
  var c_bag  = []
  for (const g0833 of C_Consumer.descendants){ 
    for (const c of g0833.instances){ 
      var arg_1 
      var ec  = c.economy
      var c2_bag  = []
      for (const g0834 of C_Consumer.descendants){ 
        for (const c2 of g0834.instances){ 
          kernel.add_list(c2_bag,(lt[c.index-1][c2.index-1]/(lgdp[c.index-1]*1000)))
          } 
        } 
      arg_1 = c2_bag
      kernel.add_list(c_bag,arg_1)
      } 
    } 
  Result = c_bag
  return Result
  } 

// ----- function from method traceOil @ void ------------- 
//  typical for 1MW wind: 3.2Me cost, 460T steel, 1.7Me cost of steel
//  debug utilities for tracing one specific Energy sourcefunction traceOil () { 
  C_TESTO = C_Oil
  } 

// ----- function from method traceGas @ void ------------- 
function traceGas () { 
  C_TESTO = C_Gas
  } 

// ----- function from method traceCoal @ void ------------- 
function traceCoal () { 
  C_TESTO = C_Coal
  } 

// ----- function from method traceClean @ void ------------- 
function traceClean () { 
  C_TESTO = C_Clean
  } 

// ----- function from method defaultTactic @ float ------------- 
//  we have a default tactic that is used for all zone before we start to optimize, that is used for 
//  sensitivity analysisfunction defaultTactic (ai_Z) { 
  var Result 
  var _CL_obj  = (new Tactics()).Is(C_Tactics)
  _CL_obj.transitionStart = 0
  _CL_obj.transitionFromPain = 1
  _CL_obj.cancelFromPain = 0
  _CL_obj.taxFromPain = 0
  _CL_obj.aiReplaceFactor = ai_Z
  Result = _CL_obj
  return Result
  } 

// ----- function from method noTransfers @ void ------------- 
//  debug: cancel all transfers to see how the system reacts (each energy source grows independently)function noTransfers () { 
  kernel.tformat("====== NO TRANSFERS: cancels all substitution matrices   =============== \n",0,[])
  for (const g0835 of C_Consumer.descendants){ 
    for (const c of g0835.instances){ 
      { 
        var va_arg2 
        var i_bag  = []
        var i  = 1
        var g0836  = 6
        while (i <= g0836) { 
          kernel.add_list(i_bag,affine([[1980,0],[2100,0]]))
          i = (i+1)
          } 
        va_arg2 = i_bag
        c.subMatrix = va_arg2
        } 
      } 
    } 
  } 

// ----- function from method fullTransfers @ void ------------- 
//  (noTransfers())   // only use during step 2 of tuning protocol
//  opposite : appply the full transfer strategyfunction fullTransfers () { 
  kernel.tformat("====== FULL TRANSFERS: applies the full substitution matrices   =============== \n",0,[])
  for (const g0837 of C_Consumer.descendants){ 
    for (const c of g0837.instances){ 
      c.tactic.transitionStart = 1
      } 
    } 
  } 

// ----- function from method ev7 @ void ------------- 
//  specific energy calibration that is used to reproduce CCEM v7 calibrationfunction ev7 () { 
  kernel.tformat("Fossil Energy reserves - CCEM v7 Hypotheses ==================== \n",0,[])
  C_Oil.inventory = affine([[30,2300],[60,4000],[120,5600]])
  C_Gas.inventory = affine([[7,1900],[15,3000],[30,4600]])
  C_Coal.inventory = affine([[7,7000],[15,15000],[30,30000]])
  C_Clean.growthPotential = affine([[2010,0.4],
    [2020,0.4],
    [2030,1.5],
    [2040,2],
    [2100,4]])
  } 

// ----- function from method go @ integer ------------- 
//  do n years of simulationfunction go (n) { 
  init_void()
   iterate_run_integer2(n,true)
  } 

// ----- function from method jsmain @ void ------------- 
//  what we launch by default with js
//  two things : the first simulation and a reinit/go(90)function jsmain () { 
  kernel.ClEnv.verbose = 0
  go(90)
  kernel.tformat("============================ RELAUNCH ============================ \n",0,[])
  reinit()
   go(90)
  } 


//--------------- meta description + top-level instructions ----
function MetaLoad() { 
  
  // instructions from module sources
  C_TALK = 1 
  C_DEBUG = 5 
  C_Version = 0.9 
  C_ORIGIN = 2010 
  C_THISYEAR = 2026 
  C_NIT = 221 
  C_NIS = 5000 
  C_Year = kernel.C_integer 
  C_Percent = kernel.C_float 
  C_Price = kernel.C_float 
  C_Energy = kernel.C_float 
  C_PMIN = 1 
  C_PMAX = 2500 
  C_CARNOT = 3 
  C_Tmeasure = kernel.C_list 
  C_Charts = new kernel.ClaireClass("Charts",kernel.C_object,false)
  C_ChartsEarth = new kernel.ClaireClass("ChartsEarth",C_Charts,false)
  C_ChartsSupplier = new kernel.ClaireClass("ChartsSupplier",C_Charts,false)
  C_ChartsConsumer = new kernel.ClaireClass("ChartsConsumer",C_Charts,false)
  C_ListFunction = new kernel.ClaireClass("ListFunction",kernel.C_object,false)
  C_StepFunction = new kernel.ClaireClass("StepFunction",C_ListFunction,false)
  C_Affine = new kernel.ClaireClass("Affine",C_ListFunction,false)
  C_Transition = new kernel.ClaireClass("Transition",kernel.C_object,false)
  C_Supplier = new kernel.ClaireClass("Supplier",kernel.C_thing,true)
  C_FiniteSupplier = new kernel.ClaireClass("FiniteSupplier",C_Supplier,true)
  C_InfiniteSupplier = new kernel.ClaireClass("InfiniteSupplier",C_Supplier,true)
  C_Transition = new kernel.ClaireClass("Transition",kernel.C_object,false)
  C_Sector = new kernel.ClaireClass("Sector",kernel.C_thing,true)
  C_Economy = new kernel.ClaireClass("Economy",kernel.C_thing,true)
  C_Block = new kernel.ClaireClass("Block",C_Economy,true)
  C_Strategy = new kernel.ClaireClass("Strategy",kernel.C_object,false)
  C_Tactics = new kernel.ClaireClass("Tactics",kernel.C_object,false)
  C_Adaptation = new kernel.ClaireClass("Adaptation",kernel.C_object,false)
  C_Consumer = new kernel.ClaireClass("Consumer",kernel.C_thing,true)
  C_Tactics = new kernel.ClaireClass("Tactics",kernel.C_object,false)
  C_Economy = new kernel.ClaireClass("Economy",kernel.C_thing,true)
  C_WorldClass = new kernel.ClaireClass("WorldClass",kernel.C_thing,true)
  C_Block = new kernel.ClaireClass("Block",C_Economy,true)
  C_Strategy = new kernel.ClaireClass("Strategy",kernel.C_object,false)
  C_Earth = new kernel.ClaireClass("Earth",kernel.C_thing,true)
  C_KNUstorage = new kernel.ClaireClass("KNUstorage",kernel.C_thing,true)
  C_ChartsEarth = new kernel.ClaireClass("ChartsEarth",C_Charts,false)
  C_ChartsSupplier = new kernel.ClaireClass("ChartsSupplier",C_Charts,false)
  C_ChartsConsumer = new kernel.ClaireClass("ChartsConsumer",C_Charts,false)
  C_Problem = new kernel.ClaireClass("Problem",kernel.C_thing,true)
  C_pb = (new Problem("pb")).Is(C_Problem)
  
  C_Experiment = new kernel.ClaireClass("Experiment",kernel.C_thing,true)
  
  C_TESTE = null 
  C_TESTC = null 
  C_TESTO = null 
  C_CCEMv9 = 5 
  C_SHOW1 = 1 
  C_SHOW2 = 5 
  C_HOW = 5 
  C_DIBUG = 5 
  C_BALANCE = 5 
  C_SHOW3 = 5 
  C_TransitionPivot = 2020 
  C_SHOW4 = 5 
  C_APFv10 = false 
  C_STEEL = 5 
  C_SHOW5 = 5 
  C_MAXTAX = 1000 
  C_MAXTR = 150 
  C_MAXCANCEL = 3 
  C_Gt2km2 = 0.001 
  C_YSTOP = 1000 
  C_YTALK = 1000 
  C_ELASMAX = 5 
  C_KNUstore = (new KNUstorage("KNUstore")).Is(C_KNUstorage)
  
  kernel.PRINC("--- load Global Warming Dynamic Games input2010.cl -- \n")
  C_ORIGIN = 2010
  C_EUenergy2010 = [6.87,
    3.34,
    4.23,
    1.51] 
  C_USenergy2010 = [9.8,
    6.51,
    6.4,
    1.32] 
  C_CNenergy2010 = [5.2,
    20.459999999999997,
    1.08,
    0.8600000000000001] 
  C_INenergy2010 = [1.84,
    3.4499999999999997,
    0.545,
    0.17] 
  C_RWenergy2010 = [24.29,
    10.350000000000001,
    19.25,
    3.03] 
  C_Oil2010 = ((((C_USenergy2010[0]+C_EUenergy2010[0])+C_CNenergy2010[0])+C_INenergy2010[0])+C_RWenergy2010[0]) 
  C_Coal2010 = ((((C_USenergy2010[1]+C_EUenergy2010[1])+C_CNenergy2010[1])+C_INenergy2010[1])+C_RWenergy2010[1]) 
  C_Gas2010 = ((((C_USenergy2010[2]+C_EUenergy2010[2])+C_CNenergy2010[2])+C_INenergy2010[2])+C_RWenergy2010[2]) 
  C_Clean2010 = ((((C_USenergy2010[3]+C_EUenergy2010[3])+C_CNenergy2010[3])+C_INenergy2010[3])+C_RWenergy2010[3]) 
  C_OilMaxGrowth = 0.06 
  C_CoalMaxGrowth = 0.04 
  C_GasMaxGrowth = 0.05 
  C_CleanMaxGrowth = 0.08 
  C_USeSources2010 = [0.047,
    1.847,
    0.987,
    1.322] 
  C_EUeSources2010 = [0.15200000000000002,
    0.701,
    0.587,
    1.507] 
  C_CNeSources2010 = [0.034,
    3.233,
    0.07700000000000001,
    0.8630000000000001] 
  C_INeSources2010 = [0.011,
    0.642,
    0.118,
    0.166] 
  C_RWeSources2010 = [0.8300000000000001,
    1.982,
    2.9349999999999996,
    3.028] 
  C_EfromOil2010 = ((((C_USeSources2010[0]+C_EUeSources2010[0])+C_CNeSources2010[0])+C_INeSources2010[0])+C_RWeSources2010[0]) 
  C_EfromCoal2010 = ((((C_USeSources2010[1]+C_EUeSources2010[1])+C_CNeSources2010[1])+C_INeSources2010[1])+C_RWeSources2010[1]) 
  C_EfromGas2010 = ((((C_USeSources2010[2]+C_EUeSources2010[2])+C_CNeSources2010[2])+C_INeSources2010[2])+C_RWeSources2010[2]) 
  C_EfromClean2010 = ((((C_USeSources2010[3]+C_EUeSources2010[3])+C_CNeSources2010[3])+C_INeSources2010[3])+C_RWeSources2010[3]) 
  C_Oil = (new FiniteSupplier("Oil")).Is(C_FiniteSupplier)
  C_Oil.index = 1
  C_Oil.inventory = affine([[30,1745],[60,3745],[120,5085]])
  C_Oil.threshold = (0.8*2900)
  C_Oil.techFactor = 0.01
  C_Oil.production = C_Oil2010
  C_Oil.equilibriumPrice = affine([[2010,35],
    [2020,30],
    [2050,50],
    [2100,100],
    [2200,150]])
  C_Oil.capacityOrigin = (48*1.1)
  C_Oil.capacityGrowth = 0.06
  C_Oil.capacityFactor = 1.1
  C_Oil.co2Factor = 0.272
  C_Oil.co2Kwh = 270
  C_Oil.investPrice = 0.13
  C_Oil.steelFactor = 0.1
  
  C_Coal = (new FiniteSupplier("Coal")).Is(C_FiniteSupplier)
  C_Coal.index = 2
  C_Coal.inventory = affine([[7,7240],[15,11400],[30,15540]])
  C_Coal.techFactor = 0.01
  C_Coal.production = C_Coal2010
  C_Coal.threshold = (0.5*10000)
  C_Coal.equilibriumPrice = affine([[2010,7.7],
    [2020,6],
    [2050,10],
    [2100,15],
    [2200,20]])
  C_Coal.capacityOrigin = (44.11*1.1)
  C_Coal.capacityGrowth = C_CoalMaxGrowth
  C_Coal.capacityFactor = 1.1
  C_Coal.co2Factor = 0.28300000000000003
  C_Coal.co2Kwh = 280
  C_Coal.investPrice = 0.43000000000000005
  C_Coal.steelFactor = 0.15
  
  C_Gas = (new FiniteSupplier("Gas")).Is(C_FiniteSupplier)
  C_Gas.index = 3
  C_Gas.inventory = affine([[7,1875],[15,4415],[30,5600]])
  C_Gas.threshold = (0.8*3200)
  C_Gas.techFactor = 0.01
  C_Gas.production = C_Gas2010
  C_Gas.equilibriumPrice = affine([[2010,14],
    [2020,7],
    [2050,15],
    [2100,30],
    [2200,40]])
  C_Gas.capacityOrigin = (31.505000000000003*(1+C_GasMaxGrowth))
  C_Gas.capacityGrowth = C_GasMaxGrowth
  C_Gas.capacityFactor = 1.1
  C_Gas.co2Factor = 0.184
  C_Gas.co2Kwh = 180
  C_Gas.investPrice = 0.13
  C_Gas.steelFactor = 0.1
  
  C_Clean = (new InfiniteSupplier("Clean")).Is(C_InfiniteSupplier)
  C_Clean.index = 4
  C_Clean.techFactor = 0.01
  C_Clean.growthPotential = affine([[2010,0.3],
    [2020,0.6],
    [2030,1],
    [2040,1.3],
    [2100,2],
    [2200,3]])
  C_Clean.capacityFactor = 1.1
  C_Clean.production = C_Clean2010
  C_Clean.capacityOrigin = (6.890000000000001*(1+C_CleanMaxGrowth))
  C_Clean.equilibriumPrice = affine([[2010,68],
    [2020,50],
    [2050,40],
    [2100,30],
    [2200,20]])
  C_Clean.investPrice = 0.9500000000000001
  C_Clean.co2Factor = 0
  C_Clean.co2Kwh = 0
  C_Clean.steelFactor = 0.4
  
  C_AdaptFossil = 0.6 
  makeTransition("Oil to Coal",
    1,
    2,
    0.3,
    1,
    0)
  makeTransition("Oil to Gas",
    1,
    3,
    0.85,
    1,
    0.2)
  makeTransition("Oil to clean electricity",
    1,
    4,
    0,
    0.4,
    C_AdaptFossil)
  makeTransition("Coal to Gas",
    2,
    3,
    0.85,
    0.8,
    0.2)
  makeTransition("Coal to clean",
    2,
    4,
    0,
    0.4,
    C_AdaptFossil)
  makeTransition("Gas to clean",
    3,
    4,
    0,
    0.4,
    C_AdaptFossil)
  C_Transport = (new Sector("Transport")).Is(C_Sector)
  C_Transport.index = 1
  C_Transport.energy_Z = [0.44,
    0.03,
    0.024,
    0.019]
  C_Transport.subMatrix = SETM([2020,
    2050,
    2100,
    2200],[[C_Oil,
    [C_Coal,
      0,
      0,
      0,
      0],
    [C_Gas,
      0.03,
      0.1,
      0.2,
      0.3],
    [C_Clean,
      0.005,
      0.1,
      0.3,
      0.5]],[C_Coal,[C_Gas,
    1,
    1,
    1,
    1],[C_Clean,
    0,
    0,
    0,
    0]],[C_Gas,[C_Clean,
    0,
    0.1,
    0.4,
    0.5]]])
  
  C_Industry = (new Sector("Industry")).Is(C_Sector)
  C_Industry.index = 2
  C_Industry.energy_Z = [0.33,
    0.51,
    0.51,
    0.47]
  C_Industry.subMatrix = SETM([2020,
    2050,
    2100,
    2200],[[C_Oil,
    [C_Coal,
      0.01,
      0.02,
      0,
      0],
    [C_Gas,
      0.03,
      0.2,
      0.4,
      0.5],
    [C_Clean,
      0.01,
      0.2,
      0.5,
      0.6]],[C_Coal,[C_Gas,
    0.13,
    0.2,
    0.3,
    0.4],[C_Clean,
    0.1,
    0.5,
    0.55,
    0.55]],[C_Gas,[C_Clean,
    0.05,
    0.3,
    0.5,
    0.6]]])
  
  C_Residential = (new Sector("Residential")).Is(C_Sector)
  C_Residential.index = 3
  C_Residential.energy_Z = [0.11,
    0.28,
    0.335,
    0.47]
  C_Residential.subMatrix = SETM([2020,
    2050,
    2100,
    2200],[[C_Oil,
    [C_Coal,
      0,
      0,
      0,
      0],
    [C_Gas,
      0.03,
      0.1,
      0.5,
      0.6],
    [C_Clean,
      0.01,
      0.3,
      0.5,
      0.6]],[C_Coal,[C_Gas,
    0.13,
    0.2,
    0.3,
    0.4],[C_Clean,
    0.06,
    0.4,
    0.5,
    0.5]],[C_Gas,[C_Clean,
    0.05,
    0.35,
    0.5,
    0.6]]])
  
  C_Others = (new Sector("Others")).Is(C_Sector)
  C_Others.index = 4
  C_Others.energy_Z = [0.12,
    0.18,
    0.13,
    0.034]
  C_Others.subMatrix = SETM([2020,
    2050,
    2100,
    2200],[[C_Oil,
    [C_Coal,
      0,
      0,
      0,
      0],
    [C_Gas,
      0.03,
      0.1,
      0.3,
      0.4],
    [C_Clean,
      0.01,
      0.2,
      0.5,
      0.6]],[C_Coal,[C_Gas,
    0.13,
    0.2,
    0.3,
    0.4],[C_Clean,
    0.06,
    0.4,
    0.5,
    0.6]],[C_Gas,[C_Clean,
    0.1,
    0.25,
    0.5,
    0.6]]])
  
  C_USDemat = densityCurve(2010,[[2020,0.0175],
    [2050,0.012],
    [2100,0.01],
    [2200,0.005]]) 
  C_EUDemat = densityCurve(2010,[[2020,0.0015000000000000002],
    [2050,0.005],
    [2100,0.005],
    [2200,0.005]]) 
  C_CNDemat = densityCurve(2010,[[2020,0.040999999999999995],
    [2050,0.02],
    [2100,0.012],
    [2200,0.005]]) 
  C_INDemat = densityCurve(2010,[[2020,-0.015],
    [2050,0],
    [2100,0.005],
    [2200,0.005]]) 
  C_RWDemat = densityCurve(2010,[[2020,-0.0191],
    [2050,0],
    [2100,0.005],
    [2200,0.005]]) 
  C_USCancel = elasticityCurve(35,0.05,0.3) 
  C_EUCancel = C_USCancel 
  C_CNCancel = elasticityCurve(35,0.1,0.5) 
  C_INCancel = elasticityCurve(35,0.1,0.4) 
  C_RestCancel = elasticityCurve(35,0.07,0.3) 
  C_CancelImpactAdvanced = affine([[0,0],
    [0.1,0.04],
    [0.2,0.08],
    [0.3,0.12],
    [0.4,0.2],
    [0.5,0.3],
    [0.7,0.5],
    [1,1]]) 
  C_CancelImpactDeveloping = affine([[0,0],
    [0.1,0.1],
    [0.2,0.2],
    [0.3,0.32],
    [0.4,0.44],
    [0.5,0.6],
    [0.7,1],
    [1,1]]) 
  C_AdaptCurve = affine([[0,0],[5,0.6]]) 
  C_US = (new Consumer("US")).Is(C_Consumer)
  C_US.index = 1
  var var_inverse_y 
  var_inverse_y = strategy(0,0.02,0.1,0.5)
  C_US.objective = var_inverse_y
  var_inverse_y.stratFrom = C_US
  C_US.consumes = C_USenergy2010
  C_US.eSources = C_USeSources2010
  C_US.cancel = C_USCancel
  C_US.cancelImpact = C_CancelImpactAdvanced
  C_US.maxSaving = 0.15
  C_US.populationEstimate = affine([[1980,0.226],
    [2010,0.311],
    [2040,0.365],
    [2100,0.394],
    [2200,0.4]])
  C_US.populationDistribution = [0.28,0.54,0.19]
  C_US.deathRates = affine([[2010,8.2],
    [2030,8.9],
    [2050,10.1],
    [2070,11],
    [2100,11]])
  C_US.subMatrix = ETM([1.3,
    1.3,
    1,
    1,
    1],[[C_Transport,0.3],[C_Industry,0.2],[C_Residential,0.2]])
  C_US.disasterLoss = affine([[1,0],
    [1.5,0.015],
    [2,0.04],
    [3,0.08],
    [4,0.15],
    [5,0.25]])
  C_US.carbonTax = affine([[380,0],[6000,0]])
  { 
    var va_arg2 
    var _CL_obj  = (new Adaptation()).Is(C_Adaptation)
    _CL_obj.efficiency = C_AdaptCurve
    va_arg2 = _CL_obj
    C_US.adapt = va_arg2
    } 
  var var_inverse_y 
  var_inverse_y = defaultTactic(0.3)
  C_US.tactic = var_inverse_y
  var_inverse_y.tacticFrom = C_US
  
  C_EU = (new Consumer("EU")).Is(C_Consumer)
  C_EU.index = 2
  var var_inverse_y 
  var_inverse_y = strategy(-0.035,0,0.4,0.2)
  C_EU.objective = var_inverse_y
  var_inverse_y.stratFrom = C_EU
  C_EU.consumes = C_EUenergy2010
  C_EU.eSources = C_EUeSources2010
  C_EU.cancel = C_EUCancel
  C_EU.cancelImpact = C_CancelImpactAdvanced
  C_EU.maxSaving = 0.1
  C_EU.populationEstimate = affine([[1980,0.406],
    [2000,0.43000000000000005],
    [2040,0.45],
    [2080,0.42000000000000004],
    [2100,0.41000000000000003],
    [2200,0.32999999999999996]])
  C_EU.populationDistribution = [0.22,0.54,0.25]
  C_EU.deathRates = affine([[2010,10.6],
    [2030,11.5],
    [2050,13.1],
    [2070,14.1],
    [2100,12.8]])
  C_EU.subMatrix = ETM([1.1,
    1.1,
    1,
    1,
    1],[[C_Transport,0.32],[C_Industry,0.25],[C_Residential,0.26]])
  C_EU.disasterLoss = affine([[1,0],
    [1.5,0.015],
    [2,0.04],
    [3,0.08],
    [4,0.15],
    [5,0.25]])
  C_EU.carbonTax = affine([[380,0],[6000,0]])
  { 
    var va_arg2 
    var _CL_obj  = (new Adaptation()).Is(C_Adaptation)
    _CL_obj.efficiency = C_AdaptCurve
    va_arg2 = _CL_obj
    C_EU.adapt = va_arg2
    } 
  var var_inverse_y 
  var_inverse_y = defaultTactic(0.3)
  C_EU.tactic = var_inverse_y
  var_inverse_y.tacticFrom = C_EU
  
  C_CN = (new Consumer("CN")).Is(C_Consumer)
  C_CN.index = 3
  var var_inverse_y 
  var_inverse_y = strategy(-0.02,0.03,0.2,0.6)
  C_CN.objective = var_inverse_y
  var_inverse_y.stratFrom = C_CN
  C_CN.consumes = C_CNenergy2010
  C_CN.eSources = C_CNeSources2010
  C_CN.cancel = C_CNCancel
  C_CN.cancelImpact = C_CancelImpactDeveloping
  C_CN.maxSaving = 0.2
  C_CN.populationEstimate = affine([[1980,0.981],
    [2010,1.35],
    [2040,1.3800000000000001],
    [2050,1.31],
    [2080,0.97],
    [2100,0.75],
    [2200,0.5]])
  C_CN.populationDistribution = [0.27,0.6,0.13]
  C_CN.deathRates = affine([[2010,7.3],
    [2030,9.7],
    [2050,13.4],
    [2070,16.1],
    [2100,15.5]])
  C_CN.subMatrix = ETM([0.8,
    0.8,
    1,
    1,
    1],[[C_Transport,0.16],[C_Industry,0.48],[C_Residential,0.18]])
  C_CN.disasterLoss = affine([[1,0],
    [1.5,0.015],
    [2,0.04],
    [3,0.08],
    [4,0.15],
    [5,0.25]])
  C_CN.carbonTax = affine([[380,0],[6000,0]])
  { 
    var va_arg2 
    var _CL_obj  = (new Adaptation()).Is(C_Adaptation)
    _CL_obj.efficiency = C_AdaptCurve
    va_arg2 = _CL_obj
    C_CN.adapt = va_arg2
    } 
  var var_inverse_y 
  var_inverse_y = defaultTactic(1)
  C_CN.tactic = var_inverse_y
  var_inverse_y.tacticFrom = C_CN
  
  C_IN = (new Consumer("IN")).Is(C_Consumer)
  C_IN.index = 4
  var var_inverse_y 
  var_inverse_y = strategy(0.01,0.02,0.1,0.4)
  C_IN.objective = var_inverse_y
  var_inverse_y.stratFrom = C_IN
  C_IN.consumes = C_INenergy2010
  C_IN.eSources = C_INeSources2010
  C_IN.cancel = C_INCancel
  C_IN.maxSaving = 0.25
  C_IN.cancelImpact = C_CancelImpactDeveloping
  C_IN.populationEstimate = affine([[1980,0.6819999999999999],
    [2010,1.24],
    [2040,1.6],
    [2080,1.5],
    [2100,1.2],
    [2200,0.9]])
  C_IN.populationDistribution = [0.41,0.51,0.08]
  C_IN.deathRates = affine([[2010,8.2],
    [2030,9.4],
    [2050,9.5],
    [2070,10.8],
    [2100,12.3]])
  C_IN.subMatrix = ETM([0.8,
    0.8,
    0.6,
    0.8,
    0.8],[[C_Transport,0.12],[C_Industry,0.49],[C_Residential,0.12]])
  C_IN.disasterLoss = affine([[1,0],
    [1.5,0.015],
    [2,0.04],
    [3,0.08],
    [4,0.15],
    [5,0.25]])
  C_IN.carbonTax = affine([[380,0],[6000,0]])
  { 
    var va_arg2 
    var _CL_obj  = (new Adaptation()).Is(C_Adaptation)
    _CL_obj.efficiency = C_AdaptCurve
    va_arg2 = _CL_obj
    C_IN.adapt = va_arg2
    } 
  var var_inverse_y 
  var_inverse_y = defaultTactic(0.1)
  C_IN.tactic = var_inverse_y
  var_inverse_y.tacticFrom = C_IN
  
  C_Rest = (new Consumer("Rest")).Is(C_Consumer)
  C_Rest.index = 5
  var var_inverse_y 
  var_inverse_y = strategy(-0.01,0.01,0.2,0.3)
  C_Rest.objective = var_inverse_y
  var_inverse_y.stratFrom = C_Rest
  C_Rest.consumes = C_RWenergy2010
  C_Rest.eSources = C_RWeSources2010
  C_Rest.cancel = C_RestCancel
  C_Rest.cancelImpact = C_CancelImpactDeveloping
  C_Rest.maxSaving = 0.2
  C_Rest.populationEstimate = affine([[1980,(4.4-(((0.226+0.406)+0.981)+0.6819999999999999))],
    [2010,(7.3-(((0.43000000000000005+0.31)+1.35)+1.35))],
    [2040,(9-(((0.45+0.365)+1.3800000000000001)+1.6))],
    [2080,(9.4-(((0.42000000000000004+0.38)+0.97)+1.6500000000000001))],
    [2100,(9.2-(((0.41000000000000003+0.394)+0.75)+1.53))],
    [2200,(7-(((0.4+0.32999999999999996)+0.5)+0.9))]])
  C_Rest.populationDistribution = [0.44,0.43,0.13]
  C_Rest.deathRates = affine([[2010,0.07200000000000001],
    [2030,0.053],
    [2050,0.073],
    [2070,0.084],
    [2100,0.07400000000000001]])
  C_Rest.subMatrix = ETM([0.7,
    0.7,
    0.6,
    0.7,
    0.8],[[C_Transport,0.39],[C_Industry,0.18],[C_Residential,0.2]])
  C_Rest.disasterLoss = affine([[1,0],
    [1.5,0.015],
    [2,0.04],
    [3,0.08],
    [4,0.15],
    [5,0.25]])
  C_Rest.carbonTax = affine([[380,0],[6000,0]])
  { 
    var va_arg2 
    var _CL_obj  = (new Adaptation()).Is(C_Adaptation)
    _CL_obj.efficiency = C_AdaptCurve
    va_arg2 = _CL_obj
    C_Rest.adapt = va_arg2
    } 
  var var_inverse_y 
  var_inverse_y = defaultTactic(0.1)
  C_Rest.tactic = var_inverse_y
  var_inverse_y.tacticFrom = C_Rest
  
  C_World = (new WorldClass("World")).Is(C_WorldClass)
  C_World.steelPrice = 190
  C_World.inflation = step([[2020,0.017],
    [2030,0.025],
    [2100,0.02],
    [2200,0.01]])
  C_World.energy4steel = affine([[1980,40],
    [2000,20],
    [2020,21],
    [2050,30],
    [2100,60],
    [2200,80]])
  C_World.wheatProduction = 0.64
  C_World.agroLand = 47
  C_World.returnOnInvestment = 0.23
  C_World.competitivenessFactor = affine([[0,0.7],
    [0.25,1.4],
    [1,1],
    [1.2,0.9],
    [2,0.8]])
  C_World.landImpact = affine([[2000,8],
    [2020,10],
    [2050,20],
    [2100,15],
    [2200,10]])
  C_World.lossLandWarming = affine([[0,1],[2,0.96],[4,0.9]])
  C_World.agroEfficiency = affine([[30,1],
    [60,0.96],
    [100,0.92],
    [200,0.85],
    [500,0.75]])
  C_World.bioHealth = affine([[0,1],
    [1,0.99],
    [2,0.96],
    [4,0.9]])
  C_World.cropYield = affine([[2000,1],
    [2020,1.2],
    [2050,1.5],
    [2100,1.8],
    [2200,2]])
  
  C_USgdp = 15 
  
  
  C_USir = 0.22 
  C_USeco = (new Block("USeco")).Is(C_Block)
  C_USeco.describes = C_US
  C_US.economy = C_USeco
  C_USeco.gdp = C_USgdp
  C_USeco.decayTable = affine([[1980,0.015],[2100,0.02]])
  C_USeco.startGrowth = 0.02
  C_USeco.dematerialize = C_USDemat
  C_USeco.socialExpenseRatio = affine([[2010,0.21],[2100,0.27]])
  C_USeco.roiEfficiency = affine([[2010,1],
    [2020,1.2],
    [2025,1.4],
    [2050,1.4],
    [2100,1.4],
    [2200,1]])
  C_USeco.investG = (15*C_USir)
  C_USeco.investE = 0.05
  C_USeco.iRevenue = C_USir
  C_USeco.ironDriver = affine([[2010,158],
    [2020,182],
    [2050,200],
    [2100,250]])
  C_USeco.giniStart = 0.4
  
  C_EUgdp = 14.5 
  
  
  C_EUir = 0.22 
  C_EUeco = (new Block("EUeco")).Is(C_Block)
  C_EUeco.describes = C_EU
  C_EU.economy = C_EUeco
  C_EUeco.gdp = C_EUgdp
  C_EUeco.decayTable = affine([[1980,0.02],[2100,0.02]])
  C_EUeco.startGrowth = 0
  C_EUeco.dematerialize = C_EUDemat
  C_EUeco.socialExpenseRatio = affine([[2010,0.27],[2100,0.28]])
  C_EUeco.roiEfficiency = affine([[2010,0.5],
    [2020,0.6],
    [2025,1.2],
    [2030,1.3],
    [2050,1.2],
    [2100,1.2],
    [2200,0.8]])
  C_EUeco.investG = (14.5*C_EUir)
  C_EUeco.investE = 0.15000000000000002
  C_EUeco.iRevenue = C_EUir
  C_EUeco.ironDriver = affine([[2010,83],
    [2020,104],
    [2050,120],
    [2100,150]])
  C_EUeco.giniStart = 0.3
  
  C_CNgdp = 6 
  C_CNir = 0.4 
  C_CNeco = (new Block("CNeco")).Is(C_Block)
  C_CNeco.describes = C_CN
  C_CN.economy = C_CNeco
  C_CNeco.gdp = C_CNgdp
  C_CNeco.decayTable = affine([[1980,0],
    [2020,0],
    [2050,0.015],
    [2100,0.02]])
  C_CNeco.startGrowth = 0.06
  C_CNeco.dematerialize = C_CNDemat
  C_CNeco.socialExpenseRatio = affine([[2010,0.08],[2100,0.22]])
  C_CNeco.roiEfficiency = affine([[2010,0.8],
    [2020,0.75],
    [2022,0.4],
    [2030,0.4],
    [2050,0.5],
    [2100,0.7],
    [2200,0.8]])
  C_CNeco.investG = (6*C_CNir)
  C_CNeco.investE = 0.07
  C_CNeco.iRevenue = C_CNir
  C_CNeco.ironDriver = affine([[2010,9.8],
    [2020,11.8],
    [2050,25],
    [2100,60]])
  C_CNeco.giniStart = 0.44
  
  C_INgdp = 1.7 
  C_INir = 0.28 
  C_INeco = (new Block("INeco")).Is(C_Block)
  C_INeco.describes = C_IN
  C_IN.economy = C_INeco
  C_INeco.gdp = C_INgdp
  C_INeco.decayTable = affine([[1980,0],[2040,0.005],[2100,0.02]])
  C_INeco.startGrowth = 0.06
  C_INeco.dematerialize = C_INDemat
  C_INeco.socialExpenseRatio = affine([[2010,0.07],[2100,0.18]])
  C_INeco.roiEfficiency = affine([[1980,0.4],
    [2020,0.42],
    [2025,0.55],
    [2050,0.6],
    [2100,0.65],
    [2200,0.6]])
  C_INeco.investG = (1.7*C_INir)
  C_INeco.investE = 0.05
  C_INeco.iRevenue = C_INir
  C_INeco.ironDriver = affine([[2010,24],
    [2020,22],
    [2050,15],
    [2100,30]])
  C_INeco.giniStart = 0.35
  
  C_Wgdp = (66-(((14.5+C_USgdp)+C_CNgdp)+C_INgdp)) 
  C_Wir = 0.2 
  C_RWeco = (new Block("RWeco")).Is(C_Block)
  C_RWeco.describes = C_Rest
  C_Rest.economy = C_RWeco
  C_RWeco.gdp = C_Wgdp
  C_RWeco.decayTable = affine([[2010,0.03],[2020,0.025],[2100,0.02]])
  C_RWeco.startGrowth = 0
  C_RWeco.dematerialize = C_RWDemat
  C_RWeco.socialExpenseRatio = affine([[2010,0.11],[2100,0.2]])
  C_RWeco.roiEfficiency = affine([[2010,0.3],
    [2020,0.3],
    [2025,0.6],
    [2030,0.6],
    [2050,0.65],
    [2100,0.7],
    [2200,0.7]])
  C_RWeco.investG = (28.799999999999997*C_Wir)
  C_RWeco.investE = 0.5
  C_RWeco.iRevenue = C_Wir
  C_RWeco.ironDriver = affine([[2010,63],
    [2020,56],
    [2050,45],
    [2100,60]])
  C_RWeco.giniStart = 0.7
  
  C_pb.trade = balanceOfTrade([[0,
      167,
      90,
      46,
      1204],
    [248,
      0,
      132,
      25,
      1175],
    [360,
      250,
      0,
      10,
      1035],
    [75,
      25,
      10,
      0,
      139],
    [1204,
      1275,
      1200,
      890,
      205,
      0]],[15,
    14.5,
    6,
    1.7,
    29.4])
  C_Gaia = (new Earth("Gaia")).Is(C_Earth)
  C_Gaia.co2PPM = 388
  C_Gaia.co2Add = 34
  C_Gaia.co2Ratio = 0.0692
  C_Gaia.co2Cumul = 1340
  C_Gaia.warming = affine([[388,0.63],
    [414,1],
    [560,2.7],
    [660,3.2],
    [1200,4.7]])
  C_Gaia.TCRE = affine([[0,0],[4000,2],[8000,3.8]])
  C_Gaia.avgTemp = 14.53
  C_Gaia.avgCentury = 13.9
  C_Gaia.painProfile = [0.4,0.3,0.3]
  C_Gaia.painClimate = step([[0.7,0],
    [1,0.05],
    [1.5,0.1],
    [2,0.15],
    [3,0.3],
    [4,0.5]])
  C_Gaia.painGrowth = step([[-0.2,0.2],
    [-0.05,0.1],
    [0,0.05],
    [0.01,0.01],
    [0.02,0.001],
    [0.03,0]])
  C_Gaia.painCancel = step([[0,0],
    [0.05,0.02],
    [0.1,0.05],
    [0.2,0.1],
    [0.3,0.2],
    [0.5,0.3]])
  C_Gaia.painReplacement = affine([[0,0],[0.2,0.1],[1,0.5]])
  
  C_World.RegisterConstant(C_Oil,C_Clean)
  console.log("------------- end of sgw9 meta_load --------------")
  } 
MetaLoad()
jsmain()

