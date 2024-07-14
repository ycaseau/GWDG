/***** CLAIRE Compilation of module gw1 into Javascript 
       [version 4.1.1 / safety 3] Sunday 07-14-2024 16:46:17 *****/

const kernel = require('./ClaireKernel')


// class file for ListFunction in module gw1 // 
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
    var g0070  = this.n
    while (i <= g0070) { 
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
  
  // ----- class method adjust @ ListFunction ------------- 
//  adjust a policy represented by an affine function: keep the dates, change the value by a factor
//  destructive operation -> changes the affine / list functionAdjust (factor) { 
    var i  = 1
    var g0071  = this.n
    while (i <= g0071) { 
      this.yValues[i-1]=(this.yValues[i-1]*factor)
      i = (i+1)
      } 
    } 
  
  } 


// class file for StepFunction in module gw1 // 
//  StepFunction is the simplestclass StepFunction extends ListFunction{ 
   
  constructor() { 
    super()
    this.xValues = []
    this.yValues = []
    this.minValue = 0
    this.maxValue = 0
    this.n = 0
    } 
  
  // ----- class method get @ StepFunction ------------- 
//  this would make gw0 non diet
//  [get(a:Affine,x:integer) : float 
//    -> get(a,float!(x)) ]
//  returns the value of the step function for a given point between m and M : easier !Get (x) { 
    var Result 
    var i  = 0
    var j  = 1
    var g0072  = this.n
    while (j <= g0072) { 
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


// class file for Affine in module gw1 // 
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
//  utilities ------------------------------------------------------------------
//  returns the value of the affine function for a given point between m and MGet (x) { 
    var Result 
    var i  = 0
    var j  = 1
    var g0073  = this.n
    while (j <= g0073) { 
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
      var g0074  = this.n
      while (i <= g0074) { 
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
//  improve : modify the factors without changing the datesImprove (factor) { 
    var Result 
    var _CL_obj  = (new Affine()).Is(C_Affine)
    _CL_obj.n = this.n
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0075  = this.n
      while (i <= g0075) { 
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
      var g0076  = this.n
      while (i <= g0076) { 
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
  
  } 


// class file for Transition in module gw1 // 
//  in GW3 we create transition objects (s1 -> s2) to make the code easier to read !class Transition extends kernel.ClaireObject{ 
   
  constructor() { 
    super()
    this.index = 1
    this.heat_Z = 0
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
//  additional transfer amounts for a transitionTransferAmount (c,y) { 
    return  c.transferFlows[y-1][this.index-1]
    } 
  
  // ----- class method actualEnergy @ Transition ------------- 
//  actual transfer in PWh (world wide)ActualEnergy (y) { 
    var Result 
    var g0077  = 0
    for (const g0080 of C_Consumer.descendants){ 
      for (const g0079 of g0080.instances){ 
        var g0078  = g0079.substitutions[y-1][this.index-1]
        g0077 = (g0077+g0078)
        } 
      } 
    Result = g0077
    return Result
    } 
  
  } 


// class file for Supplier in module gw1 // 
//  an energy supplier is defined by its inventory and the way it can be brought
//  to market (price-wise = strategy & production-wise = constraints)class Supplier extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.index = 1
    this.production = 0
    this.capacityMax = 0
    this.price = 0
    this.sensitivity = 0
    this.investPrice = 0
    this.co2Factor = 0
    this.co2Kwh = 0
    this.from = []
    this.steelFactor = 0
    this.heat_Z = 0
    this.horizonFactor = 1.1
    this.techFactor = 0
    this.outputs = []
    this.sellPrices = []
    this.gone = 0
    this.addedCapacity = 0
    this.addedCapacities = []
    this.additions = []
    this.netNeeds = []
    this.capacities = []
    } 
  
  // ----- class method getTransition @ Supplier ------------- 
//  finds a transitionGetTransition (s2) { 
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
      var g0081  = x
      Result = g0081
      } else {
      Result = kernel.MakeError("no transition exists from ~S to ~S",[C_from,C_to]).Close()
      } 
    return Result
    } 
  
  // ----- class method prevPrice @ Supplier ------------- 
//  previous pricePrevPrice (y) { 
    return  this.sellPrices[(y-1)-1]
    } 
  
  // ----- class method prev3Price @ Supplier ------------- 
//  [5] previous price, average over 3 yearsPrev3Price (y) { 
    if (y == 2) { 
      return  this.price
      }  else if (y == 3) { 
      return  ((this.sellPrices[(y-1)-1]+(2*this.price))/3)
      } else {
      return  ((((4*this.sellPrices[(y-1)-1])+this.sellPrices[(y-2)-1])-(2*this.sellPrices[(y-3)-1]))/3)
      } 
    } 
  
  // ----- class method prevMaxCapacity @ Supplier ------------- 
//  previous max capacity (includes additions from transfers)PrevMaxCapacity (y) { 
    return  (this.capacities[(y-1)-1]+this.addedCapacities[(y-1)-1])
    } 
  
  // ----- class method prodGrowth @ Supplier ------------- 
//  this is a heuristic that needs to get adjusted, it says that the maxcapacity should be X% (110)
//  of the net demand that was seen (net = needs - savings & cancel) averaged over past 3 yearsProdGrowth (prev,y) { 
    var Result 
    if (y <= 3) { 
      Result = 0.05
      } else {
      var s  = ((((4*this.netNeeds[(y-1)-1])+this.netNeeds[(y-2)-1])-(2*this.netNeeds[(y-2)-1]))/3)
      if (this == C_TESTE) { 
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
        var g0083  = (y-1)
        while (i <= g0083) { 
          kernel.add_list(i_bag,this.netNeeds[i-1])
          i = (i+1)
          } 
        arg_1 = i_bag
        kernel.princ_list(arg_1)
        kernel.PRINC("\n")
        } 
      Result = (((s/prev)*this.horizonFactor)-1)
      } 
    return Result
    } 
  
  // ----- class method getProd @ Supplier ------------- 
//  The second step is to maximize the utility function over a price range from 0 to X, (that is
//  with a capacity that does not increase more than 15%GetProd (y) { 
    var cMax  = this.Capacity(y,this.Prev3Price(y))
    this.capacities[y-1]=(cMax-this.addedCapacities[(y-1)-1])
    if (this == C_TESTE) { 
      kernel.PRINC("[")
      kernel.princ_integer(year_I(y))
      kernel.PRINC("] compute prod(")
      kernel.print_any(this)
      kernel.PRINC(") cmax=")
      kernel.printFDigit_float(cMax,2)
      kernel.PRINC(" @price:")
      kernel.printFDigit_float(this.Prev3Price(y),2)
      kernel.PRINC(")\n")
      this.ShowMaxCapacity(y,this.Prev3Price(y))
      this.ShowOutput(y,this.Prev3Price(y))
      } 
    var p  = 1
    var g0084  = C_NIS
    while (p <= g0084) { 
      C_pb.prodCurve[p-1]=this.GetOutput(C_pb.priceRange[p-1],cMax,y)
      p = (p+1)
      } 
    } 
  
  // ----- class method oilEquivalent @ Supplier ------------- 
//  when we compute cancellation or savings, all threshold are defined with oilPrice
//  this is a normalized (equivalent of oil, adjusted for price increase)OilEquivalent (p) { 
    return  ((p*C_pb.oil.price)/this.price)
    } 
  
  // ----- class method recordCapacity @ Supplier ------------- 
//  each production has a price (Invest = capacity increase / 20)
//  we distribute the energy investment across the blocs using energy consumption as a ratio
//  note: we call this once consomations are knownRecordCapacity (y) { 
    var p1  = this.sellPrices[y-1]
    var p2  = this.Prev3Price(y)
    var addCapacity  = kernel.max_float(0,(this.capacities[y-1]-this.PrevMaxCapacity(y)))
    if (this == C_TESTE) { 
      kernel.PRINC(">>>>> ")
      this.ShowOutput(y,p1)
      } 
    if (this.isa.IsIn(C_FiniteSupplier) == true) { 
      var g0089  = this
      g0089.inventories[y-1]=(g0089.inventory.Get(p2)-g0089.gone)
      } 
    
    var addInvest  = (addCapacity*this.investPrice)
    for (const g0090 of C_Block.descendants){ 
      for (const b of g0090.instances){ 
        b.investEnergy[y-1]=(b.investEnergy[y-1]+(addInvest*this.ShareOfConsumption(b,y)))
        } 
      } 
    } 
  
  // ----- class method shareOfConsumption @ Supplier ------------- 
//  share of energy consumption for a block
//  we use the previous year to get the ratio (consumption is not known yet)ShareOfConsumption (b,y) { 
    var Result 
    var arg_1 
    var g0091  = 0
    for (const g0094 of C_Block.descendants){ 
      for (const g0093 of g0094.instances){ 
        var g0092  = g0093.describes.consos[(y-1)-1][this.index-1]
        g0091 = (g0091+g0092)
        } 
      } 
    arg_1 = g0091
    Result = (b.describes.consos[(y-1)-1][this.index-1]/arg_1)
    return Result
    } 
  
  // ----- class method balanceEnergy @ Supplier ------------- 
  BalanceEnergy (y) { 
    var production  = this.GetOutput(this.sellPrices[y-1],this.Capacity(y,this.Prev3Price(y)),y)
    var listConsos 
    var c_bag  = []
    for (const g0095 of C_Consumer.descendants){ 
      for (const c of g0095.instances){ 
        kernel.add_list(c_bag,c.HowMuch(this,c.TruePrice(this,y)))
        } 
      } 
    listConsos = c_bag
    var total 
    var g0096  = 0
    for (const g0097 of listConsos){ 
      g0096 = (g0096+g0097)
      } 
    total = g0096
    
    
    for (const g0098 of C_Consumer.descendants){ 
      for (const c of g0098.instances){ 
        c.consos[y-1][this.index-1]=(listConsos[c.index-1]*(production/total))
        } 
      } 
    } 
  
  // ----- class method maxTransferFlow @ Supplier ------------- 
//  maxTransferFlow is the sum of all transfer rates (from all s2 to s) at the max possible level from the existing one (y  -1)
//  note the look-ahead pattern: the code is similar to updateRate (without the capacity constraint)
//  approximate : since c.consos is not known yet, we use the previous year's consosMaxTransferFlow (y) { 
    var Result 
    var e  = 0
    for (const tr of C_pb.transitions){ 
      if (tr.to == this) { 
        for (const g0099 of C_Consumer.descendants){ 
          for (const c of g0099.instances){ 
            var w1  = c.TransferRate(tr,(y-1))
            var w2  = kernel.max_float(w1,(c.transitionFactors[(y-1)-1]*c.GetTransferRate(tr,y)))
            e = (e+((w2-w1)*c.consos[(y-1)-1][tr.from.index-1]))
            } 
          } 
        } 
      } 
    Result = e
    return Result
    } 
  
  // ----- class method showOutput @ Supplier ------------- 
//  ********************************************************************
//  *    Part 6: Run-time model checking                               *
//  ********************************************************************
//  debug: explain the reasonningShowOutput (y,p) { 
    var cMax  = this.Capacity(y,this.Prev3Price(y))
    var cProd  = (this.production*((1 <= (cMax/this.capacityMax)) ? 
      1 :
      (cMax/this.capacityMax)))
    var pRatio  = (p/this.price)
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] output(")
    kernel.print_any(this)
    kernel.PRINC(")@")
    kernel.printFDigit_float(p,2)
    kernel.PRINC("=")
    kernel.printFDigit_float(this.GetOutput(p,cMax,y),2)
    kernel.PRINC(" {max:")
    kernel.printFDigit_float(cMax,2)
    kernel.PRINC(", projected:")
    kernel.printFDigit_float(cProd,2)
    kernel.PRINC("} (pratio: ")
    kernel.printFDigit_float((pRatio*100),1)
    kernel.PRINC(")\n")
    } 
  
  // ----- class method checkTransfers @ Supplier ------------- 
//  checks that transfers are consistent (delta capacities versus current levels of transfers)CheckTransfers (y) { 
    this.addedCapacities[y-1]=this.addedCapacity
    var delta1  = (this.addedCapacity-this.addedCapacities[(y-1)-1])
    var delta2  = 0
    for (const tr of C_pb.transitions){ 
      if (tr.to == this) { 
        for (const g0100 of C_Consumer.descendants){ 
          for (const c of g0100.instances){ 
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
  
  // ----- class method avgTax @ Supplier ------------- 
//  average tax AvgTax (y) { 
    var Result 
    var w1  = 0
    var w2  = 0
    for (const g0101 of C_Consumer.descendants){ 
      for (const c of g0101.instances){ 
        w1 = (w1+(c.Tax(this,y)*c.needs[y-1][this.index-1]))
        w2 = (w2+c.needs[y-1][this.index-1])
        } 
      } 
    Result = (w1/w2)
    return Result
    } 
  
  // ----- class method init @ Supplier ------------- 
//  supplier initialization (and reinit)Init () { 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0102  = C_NIT
      while (i <= g0102) { 
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
      var g0103  = 0
      for (const g0106 of C_Consumer.descendants){ 
        for (const g0105 of g0106.instances){ 
          var g0104  = g0105.eSources[this.index-1]
          g0103 = (g0103+g0104)
          } 
        } 
      arg_2 = g0103
      arg_1 = (this.production-arg_2)
      va_arg2 = (arg_1/this.production)
      this.heat_Z = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0107  = C_NIT
      while (i <= g0107) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.sellPrices = va_arg2
      } 
    this.sellPrices[0]=this.price
    this.gone = 0
    this.addedCapacity = 0
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0108  = C_NIT
      while (i <= g0108) { 
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
      var g0109  = C_NIT
      while (i <= g0109) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.addedCapacities = va_arg2
      } 
    if (this.isa.IsIn(C_FiniteSupplier) == true) { 
      var g0110  = this
      { 
        var va_arg2 
        var i_bag  = []
        var i  = 1
        var g0111  = C_NIT
        while (i <= g0111) { 
          kernel.add_list(i_bag,0)
          i = (i+1)
          } 
        va_arg2 = i_bag
        g0110.inventories = va_arg2
        } 
      g0110.inventories[0]=g0110.inventory.Get(g0110.price)
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0112  = C_NIT
      while (i <= g0112) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.netNeeds = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0113  = C_NIT
      while (i <= g0113) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.capacities = va_arg2
      } 
     this.capacities[0]=this.capacityMax
    } 
  
  } 


// class file for FiniteSupplier in module gw1 // 
//  keep track of max capacity
//  two subclasses with two capacity model
//  This is the regular one for fossile fuels : finite inventory = f(price)class FiniteSupplier extends Supplier{ 
   
  constructor(name) { 
    super(name)
    this.index = 1
    this.production = 0
    this.capacityMax = 0
    this.price = 0
    this.sensitivity = 0
    this.investPrice = 0
    this.co2Factor = 0
    this.co2Kwh = 0
    this.from = []
    this.steelFactor = 0
    this.heat_Z = 0
    this.horizonFactor = 1.1
    this.techFactor = 0
    this.outputs = []
    this.sellPrices = []
    this.gone = 0
    this.addedCapacity = 0
    this.addedCapacities = []
    this.additions = []
    this.netNeeds = []
    this.capacities = []
    this.capacityGrowth = 0
    this.threshold = 0
    this.inventories = []
    } 
  
  // ----- class method getOutput @ FiniteSupplier ------------- 
//  verbosity for model M1
//  [1] compute what the output for x:Supplier would be at price p
//  OCCAM version -> we do not model the price strategy (lower to increase revenue), nor do model 
//  really simple version : linear bounded by Cmax
//     linear -> p = x.price (origin) ->  p.production (origin)   &   x.sensitivity
//     capped by cMax (see below, given as a parameter)GetOutput (p,cMax,y) { 
    var Result 
    var cProd  = (this.production*((1 <= (cMax/this.capacityMax)) ? 
      1 :
      (cMax/this.capacityMax)))
    var pRatio  = (p/this.price)
    var f1  = kernel.min_float(cMax,kernel.max_float(0,((cProd*(1+((pRatio-1)*this.sensitivity)))*kernel.max_float(0,kernel.min_float(1,((2*pRatio)-1))))))
    Result = f1
    return Result
    } 
  
  // ----- class method capacity @ FiniteSupplier ------------- 
//  current max capacity should be proportional to inventory modulo the growth constraints
//  we also take into account the quantity that was added through substitutions (cf. PrevMax uses additions)
//  p is the average price of the last 3 years -> sets available inventory
//  [3] regular version for fossile energies : tries to match the evolution of demand
//  capacity is adjusted when the inventory is below the threshold levelCapacity (y,p) { 
    var Result 
    var prev  = this.PrevMaxCapacity(y)
    var I1  = (this.inventory.Get(p)-this.gone)
    var I0  = this.threshold
    var rProd  = this.ProdGrowth(prev,y)
    var rGrowth  = kernel.max_float(0,((rProd <= this.capacityGrowth) ? 
      rProd :
      this.capacityGrowth))
    Result = (((prev*(1+rGrowth)) <= (this.capacityMax*(I1/I0))) ? 
      (prev*(1+rGrowth)) :
      (this.capacityMax*(I1/I0)))
    return Result
    } 
  
  // ----- class method maxTransferRate @ FiniteSupplier ------------- 
//  computes the max capacity growth as a percentage of the complete max flow (all other s2 to s, all blocks)
//  w1 is the current rate, w2 is the expected rate, we apply the same proportional reduction factor so that the actual transfer flow meets the constraintMaxTransferRate (y) { 
    var Result 
    var f  = this.MaxTransferFlow(y)
    Result = ((f > 0) ? 
      ((this.capacityGrowth*this.PrevMaxCapacity(C_pb.year))/f) :
      0)
    return Result
    } 
  
  // ----- class method showMaxCapacity @ FiniteSupplier ------------- 
//  debug: explain the reasonning for max capacity (finite case)ShowMaxCapacity (y,p) { 
    var prev  = this.PrevMaxCapacity(y)
    var I1  = (this.inventory.Get(p)-this.gone)
    var I0  = this.inventory.Get(0)
    var rProd  = this.ProdGrowth(prev,y)
    var rGrowth  = kernel.max_float(0,((rProd <= this.capacityGrowth) ? 
      rProd :
      this.capacityGrowth))
    var c  = (((prev*(1+rGrowth)) <= (this.capacityMax*(I1/I0))) ? 
      (prev*(1+rGrowth)) :
      (this.capacityMax*(I1/I0)))
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] >>> max capacity(")
    kernel.print_any(this)
    kernel.PRINC("@")
    kernel.printFDigit_float(p,2)
    kernel.PRINC(")=")
    kernel.printFDigit_float(c,2)
    kernel.PRINC(" (inventory ratio: ")
    kernel.printFDigit_float(((I1/I0)*100),1)
    kernel.PRINC(" & rProd = ")
    kernel.printFDigit_float((rProd*100),1)
    kernel.PRINC(" => rGrowth=")
    kernel.printFDigit_float((rGrowth*100),1)
    kernel.PRINC(") Gtep {was:")
    kernel.printFDigit_float(prev,2)
    kernel.PRINC("}\n")
    } 
  
  // ----- class method see @ FiniteSupplier ------------- 
  See (y) { 
    kernel.print_any(this)
    kernel.PRINC(": price = ")
    kernel.printFDigit_float(this.sellPrices[y-1],2)
    kernel.PRINC("(")
    kernel.printFDigit_float(((this.sellPrices[y-1]/this.sellPrices[0])*100),1)
    kernel.PRINC("), inventory = ")
    kernel.printFDigit_float((this.inventory.Get(this.sellPrices[y-1])-this.gone),2)
    kernel.PRINC(", prod = ")
    kernel.printFDigit_float(this.outputs[y-1],2)
     kernel.PRINC("\n")
    } 
  
  } 


// class file for InfiniteSupplier in module gw1 // 
//  a useful trace for debug: level of known inventory
//  new in GW3: infinite energy model where the potential of new capacity depends on the priceclass InfiniteSupplier extends Supplier{ 
   
  constructor(name) { 
    super(name)
    this.index = 1
    this.production = 0
    this.capacityMax = 0
    this.price = 0
    this.sensitivity = 0
    this.investPrice = 0
    this.co2Factor = 0
    this.co2Kwh = 0
    this.from = []
    this.steelFactor = 0
    this.heat_Z = 0
    this.horizonFactor = 1.1
    this.techFactor = 0
    this.outputs = []
    this.sellPrices = []
    this.gone = 0
    this.addedCapacity = 0
    this.addedCapacities = []
    this.additions = []
    this.netNeeds = []
    this.capacities = []
    } 
  
  // ----- class method getOutput @ InfiniteSupplier ------------- 
//  [2] CCEM 4 : formula is different for clean energy : supplier needs to sell all it can produce
//  but expects a price that is proportional to the GDP (in a world of energy abundance) - modulo sensitivity
//  note : in a world of restriction, price is driven by cancellationGetOutput (p,cMax,y) { 
    var Result 
    var cProd  = this.production
    var p0  = this.price
    var w  = C_pb.world.all
    var p1  = (p0*(1+(((w.results[(y-1)-1]/w.results[0])-1)*this.sensitivity)))
    var pRatio  = (p/p1)
    var f1  = ((cMax <= (pRatio*(cMax/this.horizonFactor))) ? 
      cMax :
      (pRatio*(cMax/this.horizonFactor)))
    Result = f1
    return Result
    } 
  
  // ----- class method capacity @ InfiniteSupplier ------------- 
//  [4] new version for clean energies -> growthPotential tells how much we could add
//  capacity tries to match 110% of net demand (this should become a parameter, hard coded in test1.cl) Capacity (y,p) { 
    var Result 
    var prev  = this.PrevMaxCapacity(y)
    var maxDelta  = this.growthPotential.Get(yearF(y))
    var expected  = this.ProdGrowth(prev,y)
    var growth  = kernel.max_float(0,(((expected*prev) <= maxDelta) ? 
      (expected*prev) :
      maxDelta))
    Result = (prev+growth)
    return Result
    } 
  
  // ----- class method maxTransferRate @ InfiniteSupplier ------------- 
//  for Clean, s.growthPotential is the max PWh that we can add in a yearMaxTransferRate (y) { 
    var Result 
    var f  = this.MaxTransferFlow(y)
    Result = ((f > 0) ? 
      (this.growthPotential.Get(yearF(C_pb.year))/f) :
      0)
    return Result
    } 
  
  // ----- class method showMaxCapacity @ InfiniteSupplier ------------- 
  ShowMaxCapacity (y,p) { 
    var prev  = this.PrevMaxCapacity(y)
    var maxDelta  = this.growthPotential.Get(yearF(y))
    var rProd  = this.ProdGrowth(prev,y)
    var growth  = kernel.max_float(0,(((rProd*prev) <= maxDelta) ? 
      (rProd*prev) :
      maxDelta))
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] >>> max capacity(")
    kernel.print_any(this)
    kernel.PRINC("@")
    kernel.printFDigit_float(p,2)
    kernel.PRINC(")=")
    kernel.printFDigit_float((prev+growth),2)
    kernel.PRINC("  (rProd=")
    kernel.printFDigit_float((rProd*100),1)
    kernel.PRINC(",maxD=")
    kernel.printFDigit_float(maxDelta,2)
    kernel.PRINC(" => growth=")
    kernel.printFDigit_float(growth,2)
    kernel.PRINC(") Gtep {was:")
    kernel.printFDigit_float(prev,2)
    kernel.PRINC("}\n")
    } 
  
  // ----- class method see @ InfiniteSupplier ------------- 
  See (y) { 
    kernel.print_any(this)
    kernel.PRINC(": price = ")
    kernel.printFDigit_float(this.sellPrices[y-1],2)
    kernel.PRINC("(")
    kernel.printFDigit_float(((this.sellPrices[y-1]/this.sellPrices[0])*100),1)
    kernel.PRINC("), capacity growth potential = ")
    kernel.printFDigit_float(this.growthPotential.Get(yearF(y)),2)
    kernel.PRINC(", prod = ")
    kernel.printFDigit_float(this.outputs[y-1],2)
     kernel.PRINC("\n")
    } 
  
  } 


// class file for Economy in module gw1 // 
//  note: c.savings and c.substitution can only increase in a monotonic manner
//  ********************************************************************
//  *    Part 3: Economy and Strategies                                *
//  ********************************************************************
//  in v0.1 we keep one global economy
//  i.e. the consumers are all aggregated into oneclass Economy extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.gdp = 0
    this.investG = 0
    this.investE = 0
    this.iRevenue = 0
    this.totalConsos = []
    this.cancels = []
    this.inputs = []
    this.maxout = []
    this.results = []
    this.investGrowth = []
    this.investEnergy = []
    this.disasterRatios = []
    this.lossRatios = []
    this.ironConsos = []
    this.marginImpacts = []
    } 
  
  // ----- class method see @ Economy ------------- 
  See (y) { 
    kernel.PRINC("[")
    kernel.princ_integer(year_I(y))
    kernel.PRINC("] ")
    var arg_1 
    if (this.isa.IsIn(C_Block) == true) { 
      var g0116  = this
      arg_1 = g0116.describes
      } else {
      arg_1 = C_pb.world
      } 
    kernel.print_any(arg_1)
    kernel.PRINC(" PNB=")
    kernel.printFDigit_float(this.results[y-1],2)
    kernel.PRINC("T$, invest=")
    kernel.printFDigit_float(this.investGrowth[y-1],1)
    kernel.PRINC("T$, conso=")
    kernel.printFDigit_float(this.totalConsos[y-1],2)
    kernel.PRINC(", steel:")
    kernel.printFDigit_float(this.ironConsos[y-1],1)
    kernel.PRINC("Gt\n")
    if (this == C_pb.world) { 
      kernel.PRINC("[")
      kernel.princ_integer(year_I(y))
      kernel.PRINC("] steel consos: ")
      kernel.printFDigit_float(this.ironConsos[y-1],1)
      kernel.PRINC("Gt at price ")
      this.SteelPrices()[y-1].PrintFDigit(1)
      kernel.PRINC("$/t\n")
      kernel.PRINC("[")
      kernel.princ_integer(year_I(y))
      kernel.PRINC("] agro production: ")
      this.WheatOutputs()[y-1].PrintFDigit(1)
      kernel.PRINC("Gt from surface ")
      this.AgroSurfaces()[y-1].PrintFDigit(1)
       kernel.PRINC("\n")
      } 
    } 
  
  // ----- class method init @ Economy ------------- 
//  init the variables associated to a block (represents a consumer economy)    Init () { 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0118  = C_NIT
      while (i <= g0118) { 
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
      var g0119  = C_NIT
      while (i <= g0119) { 
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
      var g0120  = C_NIT
      while (i <= g0120) { 
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
      var g0121  = C_NIT
      while (i <= g0121) { 
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
      var g0122  = C_NIT
      while (i <= g0122) { 
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
      var g0123  = C_NIT
      while (i <= g0123) { 
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
      var g0124  = C_NIT
      while (i <= g0124) { 
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
      var g0125  = C_NIT
      while (i <= g0125) { 
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
      var g0126  = C_NIT
      while (i <= g0126) { 
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
      var g0127  = C_NIT
      while (i <= g0127) { 
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
      var g0128  = C_NIT
      while (i <= g0128) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.marginImpacts = va_arg2
      } 
    } 
  
  // ----- class method consolidate @ Economy ------------- 
//  consolidation for a given yearConsolidate (y) { 
    var arg_1 
    var g0129  = 0
    for (const g0132 of C_Block.descendants){ 
      for (const g0131 of g0132.instances){ 
        var g0130  = g0131.totalConsos[y-1]
        g0129 = (g0129+g0130)
        } 
      } 
    arg_1 = g0129
    this.totalConsos[y-1]=arg_1
    var arg_2 
    var g0133  = 0
    for (const g0136 of C_Block.descendants){ 
      for (const g0135 of g0136.instances){ 
        var g0134  = g0135.inputs[y-1]
        g0133 = (g0133+g0134)
        } 
      } 
    arg_2 = g0133
    this.inputs[y-1]=arg_2
    var arg_3 
    var g0137  = 0
    for (const g0140 of C_Block.descendants){ 
      for (const g0139 of g0140.instances){ 
        var g0138  = g0139.cancels[y-1]
        g0137 = (g0137+g0138)
        } 
      } 
    arg_3 = g0137
    this.cancels[y-1]=arg_3
    var arg_4 
    var g0141  = 0
    for (const g0144 of C_Block.descendants){ 
      for (const g0143 of g0144.instances){ 
        var g0142  = g0143.results[y-1]
        g0141 = (g0141+g0142)
        } 
      } 
    arg_4 = g0141
    this.results[y-1]=arg_4
    var arg_5 
    var g0145  = 0
    for (const g0148 of C_Block.descendants){ 
      for (const g0147 of g0148.instances){ 
        var g0146  = g0147.maxout[y-1]
        g0145 = (g0145+g0146)
        } 
      } 
    arg_5 = g0145
    this.maxout[y-1]=arg_5
    var arg_6 
    var g0149  = 0
    for (const g0152 of C_Block.descendants){ 
      for (const g0151 of g0152.instances){ 
        var g0150  = g0151.investGrowth[y-1]
        g0149 = (g0149+g0150)
        } 
      } 
    arg_6 = g0149
    this.investGrowth[y-1]=arg_6
    var arg_7 
    var g0153  = 0
    for (const g0156 of C_Block.descendants){ 
      for (const g0155 of g0156.instances){ 
        var g0154  = g0155.investEnergy[y-1]
        g0153 = (g0153+g0154)
        } 
      } 
    arg_7 = g0153
    this.investEnergy[y-1]=arg_7
    var loss  = 0
    var disaster  = 0
    var result  = 0
    for (const g0157 of C_Block.descendants){ 
      for (const w of g0157.instances){ 
        result = (result+w.results[y-1])
        disaster = (disaster+(w.results[y-1]*(w.disasterRatios[y-1]/(1-w.disasterRatios[y-1]))))
        loss = (loss+(w.results[y-1]*w.lossRatios[y-1]))
        } 
      } 
    this.disasterRatios[y-1]=(disaster/result)
    this.lossRatios[y-1]=(loss/result)
    } 
  
  } 


// class file for Block in module gw1 // 
//  code is cleaner if we call the economy of a Consumer a Blockclass Block extends Economy{ 
   
  constructor(name) { 
    super(name)
    this.gdp = 0
    this.investG = 0
    this.investE = 0
    this.iRevenue = 0
    this.totalConsos = []
    this.cancels = []
    this.inputs = []
    this.maxout = []
    this.results = []
    this.investGrowth = []
    this.investEnergy = []
    this.disasterRatios = []
    this.lossRatios = []
    this.ironConsos = []
    this.marginImpacts = []
    this.openTrade = []
    this.tradeFactors = []
    } 
  
  // ----- class method economyRatio @ Block ------------- 
//  GW4 : the economy dependency (gdp -> Gtoe) is made of local and export influence
//  this is a multiplicative factor (applied to inital state)EconomyRatio (y) { 
    if (y == 2) { 
      return  1.02
      } else {
      return  (this.NewMaxout(y)/this.gdp)
      } 
    } 
  
  // ----- class method localEconomyRatio @ Block ------------- 
//  local influence is GDP weighted by inner zone tradeLocalEconomyRatio (y) { 
    return  (this.EconomyRatio(y)*this.InnerTrade())
    } 
  
  // ----- class method globalEconomyRatio @ Block ------------- 
//  [3] export influence from other block to which w is exporting (assuming w does not protect its frontiers)  
//  v5: changed economyRatio to w (the health of the importing economy)
//  cf comments in log.cl this is a differential equation, what is returned is (1 + dx/x) 
//           dE/E = dLocal/Local x (Local/E = innerTrade) + dExport/Export x (Export/E) + dImport/Import x (Import / E)GlobalEconomyRatio (y) { 
    return  ((this.LocalEconomyRatio(y)+this.OuterCommerceRatio(y))+importReductionRatio_Block1(this,y))
    } 
  
  // ----- class method outerCommerceRatio @ Block ------------- 
//  returns the weighted sum of growth that is associated to exports (from x to other w2 that are growing, modulo trade barriers )OuterCommerceRatio (y) { 
    var Result 
    var g0176  = 0
    for (const g0179 of C_Block.descendants){ 
      for (const g0178 of g0179.instances){ 
        if (g0178 != this) { 
          var g0177  = ((g0178.EconomyRatio(y)*C_pb.trade[this.Index()-1][g0178.Index()-1])*(1+exportReductionRatio_Block2(this,g0178,y)))
          g0176 = (g0176+g0177)
          } 
        } 
      } 
    Result = g0176
    return Result
    } 
  
  // ----- class method importTradeRatio @ Block ------------- 
//  trade from w2 -> w expressed as a fraction of w gdp (hence the 3rd term)ImportTradeRatio (w2,y) { 
    return  ((this.EconomyRatio(y)*C_pb.trade[w2.Index()-1][this.Index()-1])*(w2.gdp/this.gdp))
    } 
  
  // ----- class method tradeImportFactors @ Block ------------- 
//  book keepingTradeImportFactors (y) { 
    var Result 
    var w2_bag  = []
    for (const g0180 of C_Block.descendants){ 
      for (const w2 of g0180.instances){ 
        if (w2 != this) { 
          kernel.add_list(w2_bag,this.openTrade[w2.Index()-1])
          } 
        } 
      } 
    Result = w2_bag
    return Result
    } 
  
  // ----- class method index @ Block ------------- 
  Index () { 
    return  this.describes.index
    } 
  
  // ----- class method populationRatio @ Block ------------- 
//  [2]  the second term is, as before, based on  growthPopulationRatio (y) { 
    var Result 
    var c  = this.describes
    var p0  = c.population.Get(yearF(1))
    var pn  = c.population.Get(yearF(y))
    Result = (1+((c.popEnergy*(pn-p0))/p0))
    return Result
    } 
  
  // ----- class method populationGrowth @ Block ------------- 
//  differential : one year versus the previous one
//  in CCEM v5, we take into account the effect of painPopulationGrowth (y) { 
    var Result 
    var arg_1 
    if (y == 2) { 
      arg_1 = 1
      } else {
      var c  = this.describes
      arg_1 = (c.ProductivityLoss((y-1))/c.ProductivityLoss((y-2)))
      } 
    Result = ((this.PopulationRatio(y)/this.PopulationRatio((y-1)))*arg_1)
    return Result
    } 
  
  // ----- class method newMaxout @ Block ------------- 
//  [1] [4] this computes the maxout expected at year y based on previous year, poopulation growth and growth invest
//  we use the heuristic (expected damage on GDP) that we differentiate between two years and multiply by 3 to 
//  compensate the integration factor (GDP growing and disaster ratio growing, so final compound effect needs to be multiplied by 3)NewMaxout (y) { 
    return  (((this.maxout[(y-1)-1]*this.PopulationGrowth(y))+(this.investGrowth[(y-1)-1]*this.roI.Get(yearF(y))))*(1-this.DisasterYearly(y)))
    } 
  
  // ----- class method disasterYearly @ Block ------------- 
  DisasterYearly (y) { 
    if (0 <= (5*(this.disasterRatios[y-1]-this.disasterRatios[(y-1)-1]))) { 
      return  (5*(this.disasterRatios[y-1]-this.disasterRatios[(y-1)-1]))
      } else {
      return  0
      } 
    } 
  
  // ----- class method consumes @ Block ------------- 
//  [2] [3] [4] [6] very simple economical equation of a regional economy (Block)
//  note : in GW3 we have one world economy, in GW4 we may separate
//  (a) we take the inverst into account to comput w.maxout
//  (b) we take the energy consumption cancellation into account
//  (c) we take the GW distasters into accountConsumes (y) { 
    var e  = C_pb.earth
    var t  = e.temperatures[(y-1)-1]
    var iv  = this.investGrowth[(y-1)-1]
    var invE  = this.investEnergy[y-1]
    this.disasterRatios[y-1]=kernel.max_float(this.disasterRatios[(y-1)-1],this.describes.disasterLoss.Get((t-e.avgCentury)))
    this.maxout[y-1]=this.NewMaxout(y)
    this.tradeFactors[y-1]=this.TradeImportFactors(y)
    e.gdpLosses[y-1]=(e.gdpLosses[y-1]+(this.maxout[y-1]*this.DisasterYearly(y)))
    
    
    
    this.lossRatios[y-1]=this.ImpactFromCancel(y)
    this.results[y-1]=((this.maxout[y-1]*(1-this.lossRatios[y-1]))*((1+importReductionRatio_Block1(this,y))+exportReductionRatio_Block1(this,y)))
    
    
    if (C_TESTC == this.describes) { 
      kernel.PRINC("[")
      kernel.print_any(year_I(y))
      kernel.PRINC("] ")
      kernel.print_any(this)
      kernel.PRINC(" mxout = ")
      kernel.printFDigit_float(this.maxout[y-1],2)
      kernel.PRINC(" (ImportRatio ")
      kernel.printFDigit_float((importReductionRatio_Block1(this,y)*100),1)
      kernel.PRINC(", ExportRatio ")
      kernel.printFDigit_float((exportReductionRatio_Block1(this,y)*100),1)
      kernel.PRINC(")\n")
      } 
    var r1  = this.results[(y-1)-1]
    var r2  = this.results[y-1]
    var ix  = 0
    
    ix = ((((r2*this.iRevenue)*(1-this.lossRatios[y-1]))*(1-this.describes.MarginReduction(y)))*(1-this.DisasterYearly(y)))
    var arg_1 
    var arg_2 
    var g0185  = 0
    for (const g0188 of C_Consumer.descendants){ 
      for (const g0187 of g0188.instances){ 
        var g0186  = g0187.carbonTaxes[y-1]
        g0185 = (g0185+g0186)
        } 
      } 
    arg_2 = g0185
    arg_1 = (invE-arg_2)
    invE = kernel.max_float(0,arg_1)
    this.investGrowth[y-1]=(ix-invE)
    } 
  
  // ----- class method impactFromCancel @ Block ------------- 
//  [5] GW4: fraction of the maxoutput that is used for a block (vs cancelled)
//  1.0 if no impact, 0 if 100% cancelled
//  cancel rate is transformed into impact for each zone, modulo redistribution policyImpactFromCancel (y) { 
    var Result 
    var s_energy  = 0
    var s_cancel  = 0
    var s_control  = 0
    var c  = this.describes
    var conso 
    var g0219  = 0
    for (const g0220 of c.consos[y-1]){ 
      g0219 = (g0219+g0220)
      } 
    conso = g0219
    var cancel  = c.SumCancels(y)
    var saving  = c.SumSavings(y)
    var ratio  = (cancel/((conso+cancel)+saving))
    var ratio_with_r  = (((1-c.redistribution)*c.cancelImpact.Get(ratio))+(c.redistribution*ratio))
    
    Result = ratio_with_r
    return Result
    } 
  
  // ----- class method steelConsumption @ Block ------------- 
//  [7] computes the steel consumption from gdpSteelConsumption (y) { 
    this.ironConsos[y-1]=(this.results[y-1]/this.ironDriver.Get(yearF(y)))
     false
    } 
  
  // ----- class method innerTrade @ Block ------------- 
//  fraction of gdp that is not linked to external tradeInnerTrade () { 
    var Result 
    var p  = 1
    for (const g0221 of C_Block.descendants){ 
      for (const w2 of g0221.instances){ 
        if (w2 != this) { 
          p = (p-C_pb.trade[this.Index()-1][w2.Index()-1])
          } 
        } 
      } 
    Result = p
    return Result
    } 
  
  } 


// class file for Strategy in module gw1 // 
//  a strategy is a GTES (game theory) description of the playerclass Strategy extends kernel.ClaireObject{ 
   
  constructor() { 
    super()
    this.targetGdp = 0
    this.targetCO2 = 0
    this.targetPain = 0
    this.weightGDP = 0
    this.weightCO2 = 0
    this.weightPain = 0
    } 
  
  // ----- class method self_print @ Strategy ------------- 
//  prints a strategySelfPrint () { 
    kernel.PRINC("strategy(Gdp:")
    kernel.printFDigit_float((this.targetGdp*100),1)
    kernel.PRINC("x")
    kernel.printFDigit_float((this.weightGDP*100),1)
    kernel.PRINC(",CO2:")
    kernel.printFDigit_float(this.targetCO2,1)
    kernel.PRINC("x")
    kernel.printFDigit_float((this.weightCO2*100),1)
    kernel.PRINC(",Pain:")
    kernel.printFDigit_float((this.targetPain*100),1)
    kernel.PRINC("x")
    kernel.printFDigit_float((((1-this.weightGDP)-this.weightCO2)*100),1)
     kernel.PRINC(")")
    } 
  
  } 


// class file for Consumer in module gw1 // 
//  each bloc is a group of countries (BRIC, USEurope, ...)class Consumer extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.index = 1
    this.consumes = []
    this.eSources = []
    this.subMatrix = []
    this.popEnergy = 0
    this.taxFromPain = 0
    this.cancelFromPain = 0
    this.protectionismStart = 0
    this.protectionismFromPain = 0
    this.transitionFromPain = 0
    this.productivityFactor = 0
    this.redistribution = 0
    this.taxAcceleration = 0
    this.cancelAcceleration = 0
    this.transitionStart = 1
    this.protectionismFactor = 0
    this.startNeeds = []
    this.needs = []
    this.needs1 = []
    this.consos = []
    this.sellPrices = []
    this.ePWhs = []
    this.eDeltas = []
    this.co2Emissions = []
    this.cancel_Z = []
    this.savings = []
    this.substitutions = []
    this.transferRates = []
    this.transferFlows = []
    this.carbonTaxes = []
    this.painLevels = []
    this.painEnergy = []
    this.painWarming = []
    this.painResults = []
    this.transitionFactors = []
    this.satisfactions = []
    } 
  
  // ----- class method tactical @ Consumer ------------- 
//  sets the tactic for a consumerTactical (tStart,tFromPain,tCancel,pStart,tProtect,tTax) { 
    this.transitionStart = tStart
    this.transitionFromPain = tFromPain
    this.cancelFromPain = tCancel
    this.protectionismStart = pStart
    this.protectionismFromPain = tProtect
    this.taxFromPain = tTax
    } 
  
  // ----- class method productivityLoss @ Consumer ------------- 
//  the loss of productivity is a linear function of the pain levelProductivityLoss (y) { 
    var Result 
    var p  = this.painLevels[y-1]
    Result = (1-(p*this.productivityFactor))
    return Result
    } 
  
  // ----- class method ratio @ Consumer ------------- 
//  tricky: assign energy needs proportionally ... then add substitution flows Ratio (s) { 
    var Result 
    var i  = s.index
    var arg_1 
    var g0222  = 0
    for (const g0223 of this.consumes){ 
      g0222 = (g0222+g0223)
      } 
    arg_1 = g0222
    Result = (this.consumes[i-1]/arg_1)
    return Result
    } 
  
  // ----- class method transferNeed @ Consumer ------------- 
//  transfer some energy need from one supplier to the nextTransferNeed (y,tr,q) { 
    if (tr.from == C_TESTE) { 
      kernel.tformat(">>>> Need transfer of ~F2Gtoe for ~S from ~S to ~S\n",0,[q,
        this,
        tr.from,
        tr.to])
      } 
    var g0046  = tr.from.index
    this.needs[y-1][g0046-1]=(this.needs[y-1][g0046-1]-q)
    var g0047  = tr.to.index
    this.needs[y-1][g0047-1]=(this.needs[y-1][g0047-1]+q)
    } 
  
  // ----- class method tax @ Consumer ------------- 
//  carbon tax is based on co2 level reached the previous year
//  in GW3, we add the acceleration pushed by societal reaction
//  this returns a price in $ for 1 PWh (co2Factor adjusted)
//  CinCO2 :: (12.0 / 44.0)  // one C for 2 O => no longer in use
//  tax is CO2 equivalent ! 200$/t means per equivalent of CO2 tonTax (s,y) { 
    if (y <= 2) { 
      return  0
      } else {
      return  ((this.carbonTax.Get(C_pb.earth.co2Levels[(y-1)-1])+this.taxAcceleration)*s.co2Factor)
      } 
    } 
  
  // ----- class method truePrice @ Consumer ------------- 
//  this is what the consumer will pay TruePrice (s,y) { 
    return  (s.sellPrices[y-1]+this.Tax(s,y))
    } 
  
  // ----- class method howMuch @ Consumer ------------- 
  HowMuch (s,p) { 
    var Result 
    var cneed  = this.needs[C_pb.year-1][s.index-1]
    var x1  = this.GetCancel(s,p)
    var x2  = this.PrevSaving(s)
    var x  = kernel.max_float(0,((1-x1)*(1-x2)))
    
    Result = (cneed*x)
    return Result
    } 
  
  // ----- class method getCancel @ Consumer ------------- 
//  we got rid the "CancelThreat" in version 0.2 to KISS
//  on the other hand, we had a supplier-sensitive factor to model (for coal !) => mimick price stability which we observe
//  GW3: added the cancelAcceleration produced by M5 buGetCancel (s,p) { 
    return  (this.cancel.Get(p)*(1+((s.isa.IsIn(C_FiniteSupplier) == true) ? 
      this.cancelAcceleration :
      0)))
    } 
  
  // ----- class method prevSaving @ Consumer ------------- 
//  savings level at the moment for s  (based on savings level of past year)
//  note that actual saving is monotonic because we invest and keep saving at the level from the pastPrevSaving (s) { 
    var Result 
    var y  = C_pb.year
    Result = this.savings[(y-1)-1][s.index-1]
    return Result
    } 
  
  // ----- class method transferRate @ Consumer ------------- 
//  reads the current transferRateTransferRate (tr,y) { 
    if (y == 0) { 
      return  0
      } else {
      return  this.transferRates[y-1][tr.index-1]
      } 
    } 
  
  // ----- class method record @ Consumer ------------- 
//  verbosity for model M3
//  [1] record the actual savings and substitution - use substitution matrix
//  each operation may update the Percent because of monotonicity
//  cancel is deduced from the actual conso to ensure need = conson + savings + cancelRecord (s,y) { 
    var i  = s.index
    var cneed  = this.needs[y-1][i-1]
    var p  = this.TruePrice(s,y)
    var oep  = s.OilEquivalent(p)
    var w1  = this.PrevSaving(s)
    var w2  = this.saving.Get(yearF(y))
    var missed  = ((cneed*(1-w1))-this.consos[y-1][s.index-1])
    var x  = (missed/cneed)
    
    this.sellPrices[y-1][s.index-1]=p
    this.Cancels(s,y,missed)
    this.Saves(s,y,w2)
    if (this.Tax(s,y) >= (C_PMAX*0.8)) { 
      kernel.MakeError("Carbon Tax got too high ~S",[this.Tax(s,y)]).Close()
      } 
    for (const tr of s.from){ 
      this.UpdateRate(s,
        tr,
        y,
        (cneed*(1-(x+w1))))
      } 
    
    s.netNeeds[y-1]=(s.netNeeds[y-1]+(cneed*(1-w1)))
    consumes_Consumer2(this,s,y,this.consos[y-1][s.index-1])
    } 
  
  // ----- class method cancels @ Consumer ------------- 
//  registers the energy consumption of c for s
//  cancellation : registers an energy consumption cancellationCancels (s,y,x) { 
    this.economy.cancels[y-1]=(this.economy.cancels[y-1]+x)
     this.cancel_Z[y-1][s.index-1]=(x/this.needs[y-1][s.index-1])
    } 
  
  // ----- class method saves @ Consumer ------------- 
//  store production
//  [2] [5]  saves a given amount of energy (always increasing) - hence we return the actual percent
//  note that it would be nice to add a delay (more than a year)
//  GW3: c.saving is a policy table that is assumed to be increasingSaves (s,y,w) { 
    var i  = s.index
    var cneed  = this.needs[y-1][i-1]
    var ftech  = kernel._exp_float((1-s.techFactor),y)
    var w1  = this.savings[(y-1)-1][i-1]
    var w2  = ((w1 <= w) ? 
      w :
      w1)
    
    this.economy.inputs[y-1]=(this.economy.inputs[y-1]+(w*cneed))
    this.savings[y-1][i-1]=w2
    
    this.economy.investEnergy[y-1]=(this.economy.investEnergy[y-1]+(((((w2-w1)*cneed)*s.investPrice)*ftech)*steelFactor_Supplier2(s,y)))
    } 
  
  // ----- class method getTransferRate @ Consumer ------------- 
//  getTransferRate: reads the substitution matrix and multiply by c.transtionFactors[y - 1]GetTransferRate (tr,y) { 
    return  (this.transitionFactors[(y-1)-1]*this.subMatrix[tr.index-1].Get(yearF(y)))
    } 
  
  // ----- class method updateRate @ Consumer ------------- 
//  [3] [6] monotonic update of the transferRate substitute a fraction from one energy source to another
//  note the monotonic behavior, we return the actual Percentage !
//  in v0.3 weUpdateRate (s1,tr,y,consumed) { 
    var i  = tr.index
    var s2  = tr.to
    var ftech  = kernel._exp_float((1-s2.techFactor),y)
    var w1  = this.TransferRate(tr,(y-1))
    var w2  = kernel.max_float(w1,(this.transitionFactors[(y-1)-1]*this.GetTransferRate(tr,y)))
    var w3  = applyMaxGrowthRate(w1,w2,s2,y)
    this.substitutions[y-1][i-1]=(w1*consumed)
    this.transferRates[y-1][i-1]=((1 <= w3) ? 
      1 :
      w3)
    s2.addedCapacity = (s2.addedCapacity+((w3-w1)*consumed))
    s2.additions[y-1]=(s2.additions[y-1]+((w3-w1)*consumed))
    
    
    this.transferFlows[y-1][i-1]=(this.transferFlows[y-1][i-1]+((w3-w1)*consumed))
    this.ePWhs[y-1]=(this.ePWhs[y-1]-((w1*consumed)*this.ETransferRatio(s1,s2,tr.heat_Z)))
    this.eDeltas[y-1]=(this.eDeltas[y-1]+((w1*consumed)*this.ETransferRatio(s1,s2,tr.heat_Z)))
    if ((s2 == C_TESTE) || 
        (this == C_TESTC)) { 
      if (C_TALK <= kernel.ClEnv.verbose) { 
        kernel.tformat("[~A:~F2] ~S transfer ~F2 PWh(~F%) [~F% now on -> add ~F3] of ~S to ~S [matrix ->~F%]\n",C_TALK,[year_I(y),
          s2.addedCapacity,
          this,
          (w1*consumed),
          w1,
          w3,
          ((w3-w1)*consumed),
          s1,
          tr.to,
          this.GetTransferRate(tr,y)])
        } 
      
      } 
    
    this.economy.investEnergy[y-1]=(this.economy.investEnergy[y-1]+(((((w3-w1)*consumed)*s1.investPrice)*ftech)*steelFactor_Supplier2(s1,y)))
    } 
  
  // ----- class method eTransferRatio @ Consumer ------------- 
//  [6] gwdg : when using the static eRatio of 2010, we make an error that we must fix
//  r1: elecRate of s1, e2: elecRate of s2, h: heatRate of trETransferRatio (s1,s2,h) { 
    var Result 
    var r1  = (1-s1.heat_Z)
    var r2  = (1-s2.heat_Z)
    var alpha  = (1-h)
    if (this == C_TESTC) { 
      
      } 
    Result = (r1-(r2*alpha))
    return Result
    } 
  
  // ----- class method marginReduction @ Consumer ------------- 
//  computes the margin impact of energy price increase, weighted avertage over energy sourcesMarginReduction (y) { 
    var Result 
    var s_energy  = 0
    var margin_impact  = 0
    var s_price  = 0
    for (const g0230 of C_Supplier.descendants){ 
      for (const s of g0230.instances){ 
        var p  = this.TruePrice(s,y)
        var oep  = s.OilEquivalent(p)
        var conso  = this.consos[y-1][s.index-1]
        s_energy = (s_energy+conso)
        s_price = (s_price+(conso*oep))
        margin_impact = (margin_impact+(conso*this.marginImpact.Get(oep)))
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
//  computes the cancel ratio for one zoneCancelRatio (y) { 
    var Result 
    var conso  = this.economy.totalConsos[y-1]
    var cancel  = this.economy.cancels[y-1]
    Result = (cancel/(conso+cancel))
    return Result
    } 
  
  // ----- class method redirection @ Consumer ------------- 
//  max transition acceleration compared to best planRedirection (y,pain) { 
    this.satisfactions[y-1]=this.ComputeSatisfaction(y)
    this.taxAcceleration = ((5000*this.taxFromPain)*pain)
    this.cancelAcceleration = (this.cancelFromPain*pain)
    this.transitionFactors[y-1]=((150 <= (this.transitionStart+(this.transitionFromPain*pain))) ? 
      150 :
      (this.transitionStart+(this.transitionFromPain*pain)))
    
    this.protectionismFactor = (this.protectionismStart+(this.protectionismFromPain*pain))
    } 
  
  // ----- class method taxRate @ Consumer ------------- 
//  carbon tax rate for a consumer : divide the money by the fossil fuel consumption
//  return $ / GtepTaxRate (y) { 
    var Result 
    var t  = this.carbonTaxes[y-1]
    if (t > 0) { 
      var arg_1 
      var arg_2 
      var arg_3 
      var g0231  = 0
      for (const g0234 of C_FiniteSupplier.descendants){ 
        for (const g0233 of g0234.instances){ 
          var g0232  = this.consos[y-1][g0233.index-1]
          g0231 = (g0231+g0232)
          } 
        } 
      arg_3 = g0231
      arg_2 = perMWh(arg_3)
      arg_1 = (t/arg_2)
      Result = (1000*arg_1)
      } else {
      Result = 0
      } 
    return Result
    } 
  
  // ----- class method painFromCancel @ Consumer ------------- 
//  [3] level of pain derived from cancelRatePainFromCancel (y) { 
    var Result 
    var cr  = this.CancelRatio(y)
    var pain  = C_pb.earth.painCancel.Get(cr)
    
    Result = (pain*(1-this.redistribution))
    return Result
    } 
  
  // ----- class method painFromResults @ Consumer ------------- 
//  [3] level of pain derived from Economy resuts
//  notes: 
//    - redistriction policy only applies to energy - because of the "one world economy" assumption
//    - we should factor in the PainFromResults (y) { 
    var Result 
    var w  = C_pb.world.all
    var r1  = w.results[(y-1)-1]
    var r2  = w.results[y-1]
    var growth  = ((r2-r1)/r1)
    
    Result = C_pb.earth.painGrowth.Get(growth)
    return Result
    } 
  
  // ----- class method computeSatisfaction @ Consumer ------------- 
//  computes the satisfaction level of a consumer versus its objective
//  we estimate the 2100 value for GDP, CO2 and pain with a linear interpolationComputeSatisfaction (y) { 
    var Result 
    var strat  = this.objective
    var gdpTarget  = (this.economy.results[0]*kernel._exp_float((1+strat.targetGdp),(y-1)))
    var co2Target  = (C_pb.earth.co2Levels[0]+((strat.targetCO2-C_pb.earth.co2Levels[0])*(y/90)))
    var painTarget  = (this.painLevels[0]+((strat.targetPain-this.painLevels[0])*(y/90)))
    var sat1  = (1-(kernel.abs_float((this.economy.results[y-1]-gdpTarget))/gdpTarget))
    var sat2  = (1-(kernel.abs_float((C_pb.earth.co2Levels[y-1]-co2Target))/co2Target))
    var sat3  = (1-(this.painLevels[y-1]-painTarget))
    var sat  = (((strat.weightGDP*sat1)+(strat.weightCO2*sat2))+(strat.weightPain*sat3))
    
    
    Result = sat
    return Result
    } 
  
  // ----- class method sumNeeds @ Consumer ------------- 
//  four utilitiesSumNeeds (y) { 
    var Result 
    var g0237  = 0
    for (const g0238 of this.needs[y-1]){ 
      g0237 = (g0237+g0238)
      } 
    Result = g0237
    return Result
    } 
  
  // ----- class method sumConsos @ Consumer ------------- 
  SumConsos (y) { 
    var Result 
    var g0239  = 0
    for (const g0240 of this.consos[y-1]){ 
      g0239 = (g0239+g0240)
      } 
    Result = g0239
    return Result
    } 
  
  // ----- class method sumCancels @ Consumer ------------- 
  SumCancels (y) { 
    var Result 
    var g0241  = 0
    for (const g0244 of C_Supplier.descendants){ 
      for (const g0243 of g0244.instances){ 
        var g0242  = (this.needs[y-1][g0243.index-1]*this.cancel_Z[y-1][g0243.index-1])
        g0241 = (g0241+g0242)
        } 
      } 
    Result = g0241
    return Result
    } 
  
  // ----- class method sumSavings @ Consumer ------------- 
  SumSavings (y) { 
    var Result 
    var g0245  = 0
    for (const g0248 of C_Supplier.descendants){ 
      for (const g0247 of g0248.instances){ 
        var g0246  = (this.needs[y-1][g0247.index-1]*this.savings[y-1][g0247.index-1])
        g0245 = (g0245+g0246)
        } 
      } 
    Result = g0245
    return Result
    } 
  
  // ----- class method allNeed @ Consumer ------------- 
//  combine for all suppliers  (used in hist(c:Consumer))AllNeed (y) { 
    var Result 
    var g0249  = 0
    for (const g0250 of this.needs[y-1]){ 
      g0249 = (g0249+g0250)
      } 
    Result = g0249
    return Result
    } 
  
  // ----- class method allCancel @ Consumer ------------- 
  AllCancel (y) { 
    return  this.economy.cancels[y-1]
    } 
  
  // ----- class method allSaving @ Consumer ------------- 
  AllSaving (y) { 
    var Result 
    var g0251  = 0
    for (const g0252 of this.savings[y-1]){ 
      g0251 = (g0251+g0252)
      } 
    Result = g0251
    return Result
    } 
  
  // ----- class method allConso @ Consumer ------------- 
  AllConso (y) { 
    var Result 
    var g0253  = 0
    for (const g0254 of this.consos[y-1]){ 
      g0253 = (g0253+g0254)
      } 
    Result = g0253
    return Result
    } 
  
  // ----- class method savingRatio @ Consumer ------------- 
//  saving ratiosSavingRatio (y) { 
    return  (this.SumSavings(y)/this.SumNeeds(y))
    } 
  
  // ----- class method energyIntensity @ Consumer ------------- 
//  same for a zoneEnergyIntensity (y) { 
    return  (TWh(this.SumConsos(y))/(1000*this.economy.results[y-1]))
    } 
  
  // ----- class method see @ Consumer ------------- 
  See (y) { 
    kernel.print_any(this)
    kernel.PRINC(": conso(PWh) ")
    pl2(this.consos[y-1])
    kernel.PRINC(" vs need ")
    pl2(this.needs[y-1])
    kernel.PRINC(", elec:")
    kernel.printFDigit_float(this.ePWhs[y-1],2)
     kernel.PRINC("\n")
    } 
  
  // ----- class method init @ Consumer ------------- 
//  consumer initialization (and reinit)Init () { 
    { 
      var va_arg2 
      var s_bag  = []
      for (const g0263 of C_Supplier.descendants){ 
        for (const s of g0263.instances){ 
          kernel.add_list(s_bag,(this.consumes[s.index-1]/(1-this.cancel.Get(s.price))))
          } 
        } 
      va_arg2 = s_bag
      this.startNeeds = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0264  = C_NIT
      while (i <= g0264) { 
        kernel.add_list(i_bag,[])
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.needs = va_arg2
      } 
    this.needs[0]=this.consumes
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0265  = C_NIT
      while (i <= g0265) { 
        kernel.add_list(i_bag,[])
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.needs1 = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0266  = C_NIT
      while (i <= g0266) { 
        var arg_1 
        var s_bag  = []
        for (const g0267 of C_Supplier.descendants){ 
          for (const s of g0267.instances){ 
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
      var g0268  = C_NIT
      while (i <= g0268) { 
        var arg_2 
        var s_bag  = []
        for (const g0269 of C_Supplier.descendants){ 
          for (const s of g0269.instances){ 
            kernel.add_list(s_bag,0)
            } 
          } 
        arg_2 = s_bag
        kernel.add_list(i_bag,arg_2)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.sellPrices = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0270  = C_NIT
      while (i <= g0270) { 
        var arg_3 
        var s_bag  = []
        for (const g0271 of C_Supplier.descendants){ 
          for (const s of g0271.instances){ 
            kernel.add_list(s_bag,0)
            } 
          } 
        arg_3 = s_bag
        kernel.add_list(i_bag,arg_3)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.cancel_Z = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0272  = C_NIT
      while (i <= g0272) { 
        var arg_4 
        var s_bag  = []
        for (const g0273 of C_Supplier.descendants){ 
          for (const s of g0273.instances){ 
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
      var g0274  = C_NIT
      while (i <= g0274) { 
        var arg_5 
        var v_list4 
        var tr 
        var v_local4 
        v_list4 = C_pb.transitions
        arg_5 = new Array(v_list4.length)
        for (let CLcount = 0; CLcount < v_list4.length; CLcount++){ 
          tr = v_list4[CLcount]
          v_local4 = 0
          arg_5[CLcount] = v_local4
          } 
        kernel.add_list(i_bag,arg_5)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.substitutions = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0275  = C_NIT
      while (i <= g0275) { 
        var arg_6 
        var v_list4 
        var tr 
        var v_local4 
        v_list4 = C_pb.transitions
        arg_6 = new Array(v_list4.length)
        for (let CLcount = 0; CLcount < v_list4.length; CLcount++){ 
          tr = v_list4[CLcount]
          v_local4 = 0
          arg_6[CLcount] = v_local4
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
      var g0276  = C_NIT
      while (i <= g0276) { 
        var arg_7 
        var v_list4 
        var tr 
        var v_local4 
        v_list4 = C_pb.transitions
        arg_7 = new Array(v_list4.length)
        for (let CLcount = 0; CLcount < v_list4.length; CLcount++){ 
          tr = v_list4[CLcount]
          v_local4 = 0
          arg_7[CLcount] = v_local4
          } 
        kernel.add_list(i_bag,arg_7)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.transferFlows = va_arg2
      } 
    this.taxAcceleration = 0
    this.cancelAcceleration = 0
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0277  = C_NIT
      while (i <= g0277) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.carbonTaxes = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0278  = C_NIT
      while (i <= g0278) { 
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
      var g0279  = C_NIT
      while (i <= g0279) { 
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
      var g0280  = C_NIT
      while (i <= g0280) { 
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
      var g0281  = C_NIT
      while (i <= g0281) { 
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
      var g0282  = C_NIT
      while (i <= g0282) { 
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
      var g0283  = C_NIT
      while (i <= g0283) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.satisfactions = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0284  = C_NIT
      while (i <= g0284) { 
        kernel.add_list(i_bag,1)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.transitionFactors = va_arg2
      } 
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0285  = C_NIT
      while (i <= g0285) { 
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
      var g0286  = C_NIT
      while (i <= g0286) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.eDeltas = va_arg2
      } 
    var arg_8 
    var g0287  = 0
    for (const g0290 of C_Supplier.descendants){ 
      for (const g0289 of g0290.instances){ 
        var g0288  = (this.consumes[g0289.index-1]*this.ERatio(g0289))
        g0287 = (g0287+g0288)
        } 
      } 
    arg_8 = g0287
    this.ePWhs[0]=arg_8
     this.InitBlock()
    } 
  
  // ----- class method eRatio @ Consumer ------------- 
//  reads form the initial data the ratio of primary energy used for electricity (vs "heat")ERatio (s) { 
    return  (this.eSources[s.index-1]/this.consumes[s.index-1])
    } 
  
  // ----- class method initBlock @ Consumer ------------- 
  InitBlock () { 
    var w  = this.economy
    w.Init()
    w.ironConsos[0]=(w.gdp/w.ironDriver.Get(yearF(1)))
    var arg_1 
    var g0323  = 0
    for (const g0324 of this.consumes){ 
      g0323 = (g0323+g0324)
      } 
    arg_1 = g0323
    w.totalConsos[0]=arg_1
    w.describes = this
    this.economy = w
    { 
      var va_arg2 
      var w2_bag  = []
      for (const g0325 of C_Block.descendants){ 
        for (const w2 of g0325.instances){ 
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
      var g0326  = C_NIT
      while (i <= g0326) { 
        var arg_2 
        var w2_bag  = []
        for (const g0327 of C_Block.descendants){ 
          for (const w2 of g0327.instances){ 
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
    } 
  
  } 


// class file for WorldClass in module gw1 // 
//  book-keeping the loss of margin -> impact Invest
//  we create World as the global economy (sum of block)class WorldClass extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.crisisFromPain = 0
    this.steelPrice = 0
    this.wheatProduction = 0
    this.agroLand = 0
    this.protectionismInFactor = 0.5
    this.protectionismOutFactor = 1
    this.steelPrices = []
    this.agroSurfaces = []
    this.energySurfaces = []
    this.wheatOutputs = []
    } 
  
  // ----- class method reinit @ WorldClass ------------- 
//  reinit version (refresh data)   Reinit (e,c) { 
    if (C_pb.earth != null) { 
       reinit_void()
      } else {
       init_WorldClass1(this,e,c)
      } 
    } 
  
  } 


// class file for Earth in module gw1 // 
//  ********************************************************************
//  *    Part 4: Gaia                                                  *
//  ********************************************************************
//  there is only one earth :)class Earth extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.co2PPM = 0
    this.co2Add = 0
    this.avgTemp = 0
    this.avgCentury = 0
    this.co2Ratio = 0
    this.painProfile = []
    this.co2Emissions = []
    this.co2Levels = []
    this.temperatures = []
    this.gdpLosses = []
    } 
  
  // ----- class method react @ Earth ------------- 
//  verbosity for model M5
//  [1] [2] even simpler : computes the CO2 and the temperature,
//  then (M5) apply the pain to re-evaluate the reactionsReact (y) { 
    var x  = this.co2Levels[(y-1)-1]
    this.co2Levels[y-1]=(x+(this.co2Emissions[y-1]*this.co2Ratio))
    
    this.temperatures[y-1]=((this.avgTemp-this.warming.Get(this.co2PPM))+this.warming.Get(this.co2Levels[y-1]))
    for (const g0464 of C_Consumer.descendants){ 
      for (const c of g0464.instances){ 
        var pain_energy  = c.PainFromCancel(y)
        var pain_results  = c.PainFromResults(y)
        var pain_warming  = this.painClimate.Get(this.warming.Get(this.co2Levels[y-1]))
        var pain  = ((pain_warming+pain_energy)+pain_results)
        
        c.painLevels[y-1]=pain
        c.painEnergy[y-1]=pain_energy
        c.painResults[y-1]=pain_results
        c.painWarming[y-1]=pain_warming
        c.Redirection(y,pain)
        } 
      } 
    computeProtectionism(y)
    } 
  
  // ----- class method see @ Earth ------------- 
  See (y) { 
    kernel.PRINC("--- CO2 at ")
    kernel.printFDigit_float(this.co2Levels[y-1],2)
    kernel.PRINC(", temperature = ")
    kernel.printFDigit_float(this.temperatures[y-1],1)
    kernel.PRINC(", impact = ")
    kernel.printFDigit_float((C_pb.world.all.disasterRatios[y-1]*100),1)
    kernel.PRINC(", tax = ")
    var arg_1 
    var c_bag  = []
    for (const g0485 of C_Consumer.descendants){ 
      for (const c of g0485.instances){ 
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
      var g0486  = C_NIT
      while (i <= g0486) { 
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
      var g0487  = C_NIT
      while (i <= g0487) { 
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
      var g0488  = C_NIT
      while (i <= g0488) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.gdpLosses = va_arg2
      } 
    this.co2Levels[0]=this.co2PPM
    { 
      var va_arg2 
      var i_bag  = []
      var i  = 1
      var g0489  = C_NIT
      while (i <= g0489) { 
        kernel.add_list(i_bag,0)
        i = (i+1)
        } 
      va_arg2 = i_bag
      this.co2Emissions = va_arg2
      } 
     this.co2Emissions[0]=this.co2Add
    } 
  
  } 


// class file for Problem in module gw1 // 
//  ********************************************************************
//  *    Part 5: Experiments                                           *
//  ********************************************************************
//  our problem solver objectclass Problem extends kernel.ClaireThing{ 
   
  constructor(name) { 
    super(name)
    this.comment = "default scenario"
    this.transitions = []
    this.trade = []
    this.year = 1
    this.priceRange = []
    this.debugCurve = []
    this.prodCurve = []
    this.needCurve = []
    } 
  
  // ----- class method solve @ Problem ------------- 
//  [6] our cute "solve" - find the intersection of the two curves
//  find the price that:
//   (1) minimize the distance between the two curves
//   (2) if there are ties : pick the highest price ! ( maximize the profits of the seller)
//  three cases:
//   (a) there is an intersection -> find the price
//   (b) production is much higher -> satisfy the demand at lowest price
//   (c) production is too small -> prices should go higher
//  currently: raise an error in case (c)Solve (s) { 
    var Result 
    var v0  = 1e+10
    var p0  = 0
    var i0  = 1
    var i  = 1
    var g0490  = C_NIS
    while (i <= g0490) { 
      var x  = C_pb.priceRange[i-1]
      var v  = (this.prodCurve[i-1]-this.needCurve[i-1])
      this.debugCurve[i-1]=v
      
      
      if ((v > 0) && 
          (v < v0)) { 
        v0 = v
        p0 = x
        i0 = i
        } 
      i = (i+1)
      } 
    
    if (s == C_TESTE) { 
      kernel.PRINC("*** total demand for ")
      kernel.print_any(s)
      kernel.PRINC(" is ")
      var arg_1 
      var g0491  = 0
      for (const g0494 of C_Consumer.descendants){ 
        for (const g0493 of g0494.instances){ 
          var g0492  = g0493.needs[C_pb.year-1][s.index-1]
          g0491 = (g0491+g0492)
          } 
        } 
      arg_1 = g0491
      kernel.printFDigit_float(arg_1,2)
      kernel.PRINC("  => ")
      var arg_2 
      var c_bag  = []
      for (const g0495 of C_Consumer.descendants){ 
        for (const c of g0495.instances){ 
          kernel.add_list(c_bag,[c,c.HowMuch(s,p0)])
          } 
        } 
      arg_2 = c_bag
      kernel.print_any(arg_2)
      kernel.PRINC("\n")
      kernel.PRINC("solve(")
      kernel.print_any(s)
      kernel.PRINC(") -> price=")
      kernel.princ_float5(p0)
      kernel.PRINC(" : delta=")
      kernel.printFDigit_float(v0,2)
      kernel.PRINC(", qty=")
      kernel.printFDigit_float(this.prodCurve[i0-1],2)
      kernel.PRINC(", need= ")
      kernel.printFDigit_float(this.needCurve[i0-1],2)
      kernel.PRINC(", tax=")
      kernel.printFDigit_float(s.AvgTax(C_pb.year),2)
      kernel.PRINC("\n")
      for (const g0496 of C_Consumer.descendants){ 
        for (const c of g0496.instances){ 
          kernel.PRINC("Cancel/save(")
          kernel.print_any(c)
          kernel.PRINC(") = ")
          kernel.printFDigit_float((c.GetCancel(s,(s.OilEquivalent(p0)+s.AvgTax(C_pb.year)))*100),1)
          kernel.PRINC("/")
          kernel.printFDigit_float((c.PrevSaving(s)*100),1)
          kernel.PRINC("; ")
          } 
        } 
      kernel.PRINC("@ oil=")
      kernel.printFDigit_float((s.OilEquivalent(p0)+s.AvgTax(C_pb.year)),2)
      kernel.PRINC("\n")
      } 
    if (p0 == 0) { 
      kernel.tformat("********************** IMPOSSIBLE TO SOLVE MARKET EQUATION [~S] ********************** \n",0,[s])
      kernel.PRINC("prod Curve is ")
      kernel.print_any(this.prodCurve)
      kernel.PRINC("\n")
      kernel.PRINC("need Curve is ")
      kernel.print_any(this.needCurve)
      kernel.PRINC("\n")
      kernel.MakeError("stop error with solve(~S)",[s]).Close()
      } 
    Result = p0
    return Result
    } 
  
  // ----- class method run @ Problem ------------- 
//  one simulation stepRun () { 
    var y  = (this.year+1)
    C_pb.year = y
    kernel.tformat("==================================  [~A] =================================== \n",2,[year_I(y)])
    if ((y == C_YTALK) || 
        (y == C_YSTOP)) { 
      C_gw1_DEBUG = 1
      C_gw1_SHOW2 = 1
      } 
    for (const g0497 of C_Consumer.descendants){ 
      for (const c of g0497.instances){ 
        getNeed_Consumer1(c,y)
        } 
      } 
    for (const g0498 of C_Supplier.descendants){ 
      for (const s of g0498.instances){ 
        
        s.GetProd(this.year)
        this.ResetNeed()
        for (const g0499 of C_Consumer.descendants){ 
          for (const c of g0499.instances){ 
            getNeed_Consumer2(c,s,y)
            } 
          } 
        s.sellPrices[y-1]=this.Solve(s)
        s.BalanceEnergy(y)
        for (const g0500 of C_Consumer.descendants){ 
          for (const c of g0500.instances){ 
            c.Record(s,y)
            } 
          } 
        s.RecordCapacity(y)
        } 
      } 
    
    getEconomy(y)
    if (kernel.ClEnv.verbose > 0) { 
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
    var g0509  = C_NIS
    while (i <= g0509) { 
      this.needCurve[i-1]=0
      i = (i+1)
      } 
    } 
  
  } 

var C_gw1_TALK
var C_gw1_DEBUG
var C_gw1_Version
var C_gw1_NIT
var C_gw1_NIS
var C_gw1_PMIN
var C_gw1_PMAX
var C_gw1_Year
var C_gw1_Percent
var C_gw1_Price
var C_gw1_Energy
var C_gw1_ListFunction
var C_gw1_StepFunction
var C_gw1_Affine
var C_gw1_Transition
var C_gw1_Supplier
var C_gw1_FiniteSupplier
var C_gw1_InfiniteSupplier
var C_gw1_Economy
var C_gw1_Block
var C_gw1_Strategy
var C_gw1_Consumer
var C_gw1_WorldClass
var C_gw1_Earth
var C_gw1_Problem
var C_gw1_pb
var C_gw1_TESTE
var C_gw1_TESTC
var C_gw1_SHOW1
var C_gw1_SHOW2
var C_gw1_HOW
var C_gw1_BALANCE
var C_gw1_SHOW3
var C_gw1_SHOW4
var C_gw1_SHOW5
var C_gw1_MAXTAX
var C_gw1_MAXTR
var C_gw1_Gt2km2
var C_gw1_YSTOP
var C_gw1_YTALK
var C_gw1_Oil2010
var C_gw1_Gas2010
var C_gw1_Coal2010
var C_gw1_Clean2010
var C_gw1_EfromOil2010
var C_gw1_EfromCoal2010
var C_gw1_EfromGas2010
var C_gw1_EfromClean2010
var C_gw1_Oil
var C_gw1_Coal
var C_gw1_Gas
var C_gw1_Clean
var C_gw1_EnergyTransition
var C_gw1_USSaving
var C_gw1_EUSaving
var C_gw1_CNSaving
var C_gw1_RWSaving
var C_gw1_USDemat
var C_gw1_EUDemat
var C_gw1_CNDemat
var C_gw1_RWDemat
var C_gw1_UScancel
var C_gw1_EUcancel
var C_gw1_CNcancel
var C_gw1_RestCancel
var C_gw1_CancelImpact
var C_gw1_USeSources2010
var C_gw1_EUeSources2010
var C_gw1_CNeSources2010
var C_gw1_RWeSources2010
var C_gw1_USenergy2010
var C_gw1_EUenergy2010
var C_gw1_CNenergy2010
var C_gw1_RWenergy2010
var C_gw1_US
var C_gw1_EU
var C_gw1_CN
var C_gw1_Rest
var C_gw1_World
var C_gw1_USgdp
var C_gw1_USir
var C_gw1_USeco
var C_gw1_EUgdp
var C_gw1_EUir
var C_gw1_EUeco
var C_gw1_CNgdp
var C_gw1_CNir
var C_gw1_CNeco
var C_gw1_Wgdp
var C_gw1_Wir
var C_gw1_RWeco
var C_gw1_Gaia

// ----- function from method year! @ integer ------------- 
//  energy is in PWh
//  we use a relative index that sarts at 1 for 2010function year_I (i) { 
  return  (2009+i)
  } 

// ----- function from method yearF @ integer ------------- 
function yearF (i) { 
  return  (2009+i)
  } 

// ----- function from method PWh @ float ------------- 
//  transforms a Gt of oil equivalent into PWhfunction PWh (x) { 
  return  (x*11.6)
  } 

// ----- function from method perMWh @ float ------------- 
//  transforms a price per Tep into a price per MWhfunction perMWh (x) { 
  return  (x/11.6)
  } 

// ----- function from method affine @ listargs ------------- 
//  assumes l is a list of pairs (x-i,y-i) and x-i is a strictly increasing sequencefunction affine (l) { 
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
  var g0510  = l.length
  while (i <= g0510) { 
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
  _CL_obj.n = l.length
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
  var g0511  = l.length
  while (i <= g0511) { 
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
//  create a transition (used in test.cl)function makeTransition (name,fromIndex,toIndex,h_Z) { 
  var tr 
  var _CL_obj  = (new Transition()).Is(C_Transition)
  _CL_obj.index = (1+C_pb.transitions.length)
  _CL_obj.from = supplier_I(fromIndex)
  _CL_obj.to = supplier_I(toIndex)
  _CL_obj.tag = name
  tr = _CL_obj
  C_pb.transitions = kernel.add_list(C_pb.transitions,tr)
  tr.heat_Z = h_Z
  var g0045  = supplier_I(fromIndex)
  g0045.from = kernel.add_list(g0045.from,tr)
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
//  record level of satisfaction for each year
//  find a consumer by its indexfunction C (i) { 
  var Result 
  var c_some  = null
  for (const g0512 of C_Consumer.descendants){ 
    var g0513 
    g0513= false
    for (const c of g0512.instances){ 
      if (c.index == i) { 
        c_some = c
        g0513 = c_some
        break // loop = tuple("g0513", any)
        } 
      } 
    if (g0513 == true) { 
      
      break // loop = tuple("niet", any)
      } 
    } 
  Result = c_some
  return Result
  } 

// ----- function from method strategy @ float ------------- 
//  constructor for Strategyfunction strategy (tGdp,tCO2,tHappy,wGDP,wCO2) { 
  var Result 
  var _CL_obj  = (new Strategy()).Is(C_Strategy)
  _CL_obj.targetGdp = tGdp
  _CL_obj.targetCO2 = tCO2
  _CL_obj.targetPain = (1-tHappy)
  _CL_obj.weightGDP = wGDP
  _CL_obj.weightCO2 = wCO2
  _CL_obj.weightPain = (1-(wGDP+wCO2))
  Result = _CL_obj
  return Result
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
  var g0514  = 0
  for (const g0515 of l){ 
    g0514 = (g0514+g0515)
    } 
  arg_1 = g0514
  Result = (arg_1/l.length)
  return Result
  } 

// ----- function from method float! @ float ------------- 
//  makes float! a coercion (works both for integer and float)function float_I_float (x) { 
  return  x
  } 

// ----- function from method getNeed @ list<type_expression>(Consumer, integer) ------------- 
//  verbosity for model M2
//  [1] computes the need - Step 1
//  two ways: (a) direct application of economy/status
//            (b) memory: "dampening factor"
//  note the "need" does not take savings into account since they'll be added
//  Note: pop  growth comes from Emerging countries => mostly linear (KISS)
//  GW4: the need are now localized (c.population & c.gdp)function getNeed_Consumer1 (c,y) { 
  var b  = c.economy
  var c0 
  var g0516  = 0
  for (const g0517 of c.startNeeds){ 
    g0516 = (g0516+g0517)
    } 
  c0 = g0516
  var dmr  = (1-b.dematerialize.Get(yearF(y)))
  var c2  = ((((c0*dmr)*b.GlobalEconomyRatio(y))*b.PopulationRatio(y))*(1-b.disasterRatios[(y-1)-1]))
  
  
  
  if (C_TESTC == c) { 
    kernel.PRINC("[")
    kernel.print_any(year_I(y))
    kernel.PRINC("] ")
    kernel.print_any(c)
    kernel.PRINC(" needs = ")
    kernel.printFDigit_float(c2,2)
    kernel.PRINC(" (economy ")
    kernel.printFDigit_float((b.GlobalEconomyRatio(y)*100),1)
    kernel.PRINC(", export ")
    kernel.printFDigit_float((exportReductionRatio_Block1(b,y)*100),1)
    kernel.PRINC(", import ")
    kernel.printFDigit_float((importReductionRatio_Block1(b,y)*100),1)
    kernel.PRINC(")\n")
    } 
  if (C_TESTE != null) { 
    kernel.PRINC("--- ")
    kernel.print_any(c)
    kernel.PRINC(" needs(")
    C_TESTE.Print()
    kernel.PRINC(") = ")
    kernel.printFDigit_float((c2*c.Ratio(C_TESTE)),2)
    kernel.PRINC("\n")
    } 
  var arg_1 
  var s_bag  = []
  for (const g0518 of C_Supplier.descendants){ 
    for (const s of g0518.instances){ 
      kernel.add_list(s_bag,(c2*c.Ratio(s)))
      } 
    } 
  arg_1 = s_bag
  c.needs[y-1]=arg_1
  var arg_2 
  var s_bag  = []
  for (const g0519 of C_Supplier.descendants){ 
    for (const s of g0519.instances){ 
      kernel.add_list(s_bag,(c2*c.Ratio(s)))
      } 
    } 
  arg_2 = s_bag
  c.needs1[y-1]=arg_2
  if (y > 1) { 
    for (const tr of C_pb.transitions){ 
      c.TransferNeed(y,tr,(c.TransferRate(tr,(y-1))*c.needs[y-1][tr.from.index-1]))
      } 
    } 
  } 

// ----- function from method exportReductionRatio @ list<type_expression>(Block, integer) ------------- 
//  previous methods the total outerCommerce = growth (1 - exportReductionRatio)
//  this methods returns only the export reductionfunction exportReductionRatio_Block1 (w,y) { 
  var Result 
  var g0520  = 0
  for (const g0523 of C_Block.descendants){ 
    for (const g0522 of g0523.instances){ 
      if (g0522 != w) { 
        var g0521  = ((g0522.EconomyRatio(y)*C_pb.trade[w.Index()-1][g0522.Index()-1])*exportReductionRatio_Block2(w,g0522,y))
        g0520 = (g0520+g0521)
        } 
      } 
    } 
  Result = g0520
  return Result
  } 

// ----- function from method exportReductionRatio @ list<type_expression>(Block, Block, integer) ------------- 
//  reduction of exportation factor (w -> w2) because of w2 CBAM - always negativefunction exportReductionRatio_Block2 (w,w2,y) { 
  return  kernel.min_float(0,((w2.openTrade[w.Index()-1]-1)*C_pb.world.protectionismOutFactor))
  } 

// ----- function from method importReductionRatio @ list<type_expression>(Block, integer) ------------- 
//  opposite situation : w is impacted by imports from w2, because of its own barrier or because w2 is doing poorlyfunction importReductionRatio_Block1 (w,y) { 
  var Result 
  var g0524  = 0
  for (const g0527 of C_Block.descendants){ 
    for (const g0526 of g0527.instances){ 
      if (g0526 != w) { 
        var g0525  = (w.ImportTradeRatio(g0526,y)*importReductionRatio_Block2(w,g0526,y))
        g0524 = (g0524+g0525)
        } 
      } 
    } 
  Result = g0524
  return Result
  } 

// ----- function from method importReductionRatio @ list<type_expression>(Block, Block, integer) ------------- 
//  reduction of importation factor (w2 -> w:import): this is a negative correction when openTrade is less than 1.0function importReductionRatio_Block2 (w,w2,y) { 
  return  kernel.min_float(0,((w.openTrade[w2.Index()-1]-1)*C_pb.world.protectionismInFactor))
  } 

// ----- function from method getNeed @ list<type_expression>(Consumer, Supplier, integer) ------------- 
//  [5] computes the need - Step 2 - for one precise supplier
//  (a) relative needs for + current Carbon tax (the carbon shifts the demand curve)
//  (b) record the qty that would be bought for a list of pricefunction getNeed_Consumer2 (c,s,y) { 
  var t  = c.Tax(s,y)
  
  var p  = 1
  var g0528  = C_NIS
  while (p <= g0528) { 
    if (c.HowMuch(s,s.OilEquivalent((C_pb.priceRange[p-1]+t))) < 0) { 
      kernel.MakeError("bug with ~S, ~S @ price ~S",[c,s,s.OilEquivalent((C_pb.priceRange[p-1]+t))]).Close()
      } 
    C_pb.needCurve[p-1]=(C_pb.needCurve[p-1]+c.HowMuch(s,s.OilEquivalent((C_pb.priceRange[p-1]+t))))
    p = (p+1)
    } 
  } 

// ----- function from method consumes @ list<type_expression>(Consumer, Supplier, integer, float) ------------- 
//  record all savings
//  [4] [6]  consumes : register the CO2 and register the energyfunction consumes_Consumer2 (c,s,y,x) { 
  if (s == C_TESTE) { 
    kernel.tformat("[~A] ~S consumes ~F2 of ~S [need = ~F2 reduced-> ~F2] \n",1,[year_I(y),
      c,
      x,
      s,
      c.needs[y-1][s.index-1],
      c.HowMuch(s,c.TruePrice(s,y))])
    } 
  C_pb.earth.co2Emissions[y-1]=(C_pb.earth.co2Emissions[y-1]+(x*s.co2Factor))
  c.co2Emissions[y-1]=(c.co2Emissions[y-1]+(x*s.co2Factor))
  if (c == C_TESTC) { 
    kernel.tformat("electricity(~S) = ~F2 PWhs from ~S (at ~F%) \n",1,[c,
      (x*c.ERatio(s)),
      s,
      c.ERatio(s)])
    } 
  c.ePWhs[y-1]=(c.ePWhs[y-1]+(x*c.ERatio(s)))
  
  c.carbonTaxes[y-1]=(c.carbonTaxes[y-1]+((c.Tax(s,y)*x)/1000))
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
//  w1 is the current rate, w2 is the expected rate, we apply the same proportional reduction factor so that the actual transfer flow meets the constraintfunction applyMaxGrowthRate (w1,w2,s,y) { 
  return  (w1+((w2-w1)*kernel.min_float(1,s.MaxTransferRate(y))))
  } 

// ----- function from method getEconomy @ integer ------------- 
//  verbosity for model M4
//  computes the economy for a given year -> 4 blocs then consolidatefunction getEconomy (y) { 
  for (const g0529 of C_Block.descendants){ 
    for (const b of g0529.instances){ 
      checkBalance_Consumer1(b.describes,y)
      } 
    } 
  for (const g0530 of C_Supplier.descendants){ 
    for (const s of g0530.instances){ 
      s.CheckTransfers(y)
      } 
    } 
  for (const g0531 of C_Block.descendants){ 
    for (const b of g0531.instances){ 
      b.Consumes(y)
      } 
    } 
  var e  = C_pb.world.all
  e.Consolidate(y)
  steelPrice_integer(y)
  for (const g0532 of C_Block.descendants){ 
    for (const b of g0532.instances){ 
      b.SteelConsumption(y)
      } 
    } 
  var arg_1 
  var g0533  = 0
  for (const g0536 of C_Block.descendants){ 
    for (const g0535 of g0536.instances){ 
      var g0534  = g0535.ironConsos[y-1]
      g0533 = (g0533+g0534)
      } 
    } 
  arg_1 = g0533
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
//  note that we protect based on the difference between co2/GDP and the existance of a similar level of CO2 taxfunction computeProtectionism (y) { 
  var w  = C_pb.world
  for (const g0559 of C_Consumer.descendants){ 
    for (const c1 of g0559.instances){ 
      var w1  = c1.economy
      var alpha  = c1.protectionismFactor
      for (const g0560 of C_Consumer.descendants){ 
        for (const c2 of g0560.instances){ 
          if (c2 != c1) { 
            var co2perE1 
            var arg_1 
            var g0561  = 0
            for (const g0562 of c1.consos[y-1]){ 
              g0561 = (g0561+g0562)
              } 
            arg_1 = g0561
            co2perE1 = (c1.co2Emissions[y-1]/arg_1)
            var co2perE2 
            var arg_2 
            var g0563  = 0
            for (const g0564 of c2.consos[y-1]){ 
              g0563 = (g0563+g0564)
              } 
            arg_2 = g0563
            co2perE2 = (c2.co2Emissions[y-1]/arg_2)
            var ctax1  = c1.TaxRate(y)
            var ctax2  = c2.TaxRate(y)
            
            w1.openTrade[c2.index-1]=(1-kernel.min_float(1,((alpha*((0 <= ((co2perE2-co2perE1)/(0.001+co2perE1))) ? 
              ((co2perE2-co2perE1)/(0.001+co2perE1)) :
              0))*((0 <= ((ctax1-ctax2)/(0.001+ctax1))) ? 
              ((ctax1-ctax2)/(0.001+ctax1)) :
              0))))
            
            if (alpha > 0) { 
              kernel.tformat("protectionism for ~S(tax:~F2) -> ~S(tax:~F2) = ~F% from co2/GDP ~F% and ~F%\n",1,[c1,
                ctax1,
                c2,
                ctax2,
                w1.openTrade[c2.index-1],
                co2perE1,
                co2perE2])
              } 
            } 
          } 
        } 
      } 
    } 
  } 

// ----- function from method agroOutput @ integer ------------- 
//  trabnsform m2/MWh into millionskm2/Gtepfunction agroOutput (y) { 
  var w  = C_pb.world
  var e  = C_pb.earth
  var newClean  = ((0 <= (C_pb.clean.capacities[y-1]-C_pb.clean.capacities[(y-1)-1])) ? 
    (C_pb.clean.capacities[y-1]-C_pb.clean.capacities[(y-1)-1]) :
    0)
  var prevSurface  = w.agroSurfaces[(y-1)-1]
  var efficiencyRatio  = ((w.agroEfficiency.Get(avgOilEquivalent(y))*w.bioHealth.Get(e.temperatures[(y-1)-1]))*w.cropYield.Get(yearF(y)))
  w.energySurfaces[y-1]=(w.energySurfaces[(y-1)-1]+((newClean*w.landImpact.Get(yearF(y)))*C_Gt2km2))
  w.agroSurfaces[y-1]=((w.agroLand-w.energySurfaces[y-1])*w.lossLandWarming.Get(C_pb.earth.co2Levels[y-1]))
  w.wheatOutputs[y-1]=((w.wheatProduction*(w.agroSurfaces[y-1]/w.agroLand))*efficiencyRatio)
  
  } 

// ----- function from method avgOilEquivalent @ integer ------------- 
//  avgOilEquivalent(y) is the equivalent oil price for each energy source weighted by productionfunction avgOilEquivalent (y) { 
  var Result 
  var p  = 0
  var o  = 0
  for (const g0565 of C_Supplier.descendants){ 
    for (const s of g0565.instances){ 
      p = (p+(s.OilEquivalent(s.sellPrices[y-1])*s.outputs[y-1]))
      o = (o+s.outputs[y-1])
      } 
    } 
  Result = (p/o)
  return Result
  } 

// ----- function from method checkBalance @ list<type_expression>(Consumer, integer) ------------- 
//  Dynamic Balance checks for M4 
//  debug function: show the energy balance of a consumer (need -> conso + savings + cancel)
//  we keep it for the time being to avoid new bugs ...function checkBalance_Consumer1 (c,y) { 
  var c1  = c.SumNeeds(y)
  var c2  = c.SumConsos(y)
  var c3  = c.SumCancels(y)
  var c4  = c.SumSavings(y)
  var csum  = ((c2+c3)+c4)
  if (kernel.abs_float(((c1-csum)/csum)) > 0.01) { 
    kernel.tformat("[~S] BALANCE(~S): need ~F2 vs ~F2 {~F%} (consos:~F%, cancels:~F%, savings:~F%)\n",0,[year_I(y),
      c,
      c1,
      csum,
      kernel.abs_float(((c1-csum)/csum)),
      (c2/csum),
      (c3/csum),
      (c4/csum)])
    for (const g0566 of C_Supplier.descendants){ 
      for (const s of g0566.instances){ 
        checkBalance_Consumer2(c,s,y)
        } 
      } 
    } 
  } 

// ----- function from method checkBalance @ list<type_expression>(Consumer, Supplier, integer) ------------- 
//  more precise debug function: balance for a consumer and a supplierfunction checkBalance_Consumer2 (c,s,y) { 
  var c1  = c.needs[y-1][s.index-1]
  var c2  = c.consos[y-1][s.index-1]
  var c3  = (c.needs[y-1][s.index-1]*c.cancel_Z[y-1][s.index-1])
  var c4  = (c.needs[y-1][s.index-1]*c.savings[y-1][s.index-1])
  var csum  = ((c2+c3)+c4)
  
  } 

// ----- function from method printEnergyPrices @ integer ------------- 
//  show the pricesfunction printEnergyPrices (y) { 
  for (const g0567 of C_Supplier.descendants){ 
    for (const s of g0567.instances){ 
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
  var g0568  = C_NIS
  while (x <= g0568) { 
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
  var g0569  = nL
  while (i <= g0569) { 
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

// ----- function from method add_years @ integer ------------- 
//  CRAZY CLAIRE BUG: if this method is called add, the code cannot be printed
//  add n years of simulationsfunction add_years (n) { 
  kernel.time_set()
  var i  = 1
  var g0570  = n
  while (i <= g0570) { 
    C_pb.Run()
    i = (i+1)
    } 
  kernel.time_show()
   see_void()
  } 

// ----- function from method allSaving @ integer ------------- 
function allSaving_integer (y) { 
  var Result 
  var g0579  = 0
  for (const g0582 of C_Consumer.descendants){ 
    for (const g0581 of g0582.instances){ 
      var g0580  = g0581.SumSavings(y)
      g0579 = (g0579+g0580)
      } 
    } 
  Result = g0579
  return Result
  } 

// ----- function from method steelConso @ integer ------------- 
function steelConso (y) { 
  var Result 
  var g0583  = 0
  for (const g0586 of C_Block.descendants){ 
    for (const g0585 of g0586.instances){ 
      var g0584  = g0585.ironConsos[y-1]
      g0583 = (g0583+g0584)
      } 
    } 
  Result = g0583
  return Result
  } 

// ----- function from method carbonTax @ integer ------------- 
function carbonTax_integer (y) { 
  var Result 
  var g0587  = 0
  for (const g0590 of C_Consumer.descendants){ 
    for (const g0589 of g0590.instances){ 
      var g0588  = g0589.carbonTaxes[y-1]
      g0587 = (g0587+g0588)
      } 
    } 
  Result = g0587
  return Result
  } 

// ----- function from method co2KWh @ integer ------------- 
//  computes the co2KWh ratio for each yearfunction co2KWh (y) { 
  var Result 
  var arg_1 
  var g0591  = 0
  for (const g0594 of C_Supplier.descendants){ 
    for (const g0593 of g0594.instances){ 
      var g0592  = (g0593.co2Kwh*g0593.outputs[y-1])
      g0591 = (g0591+g0592)
      } 
    } 
  arg_1 = g0591
  var arg_2 
  var g0595  = 0
  for (const g0598 of C_Supplier.descendants){ 
    for (const g0597 of g0598.instances){ 
      var g0596  = g0597.outputs[y-1]
      g0595 = (g0595+g0596)
      } 
    } 
  arg_2 = g0595
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
  var g0607  = 0
  for (const g0610 of C_Consumer.descendants){ 
    for (const g0609 of g0610.instances){ 
      var g0608  = g0609.painLevels[y-1]
      g0607 = (g0607+g0608)
      } 
    } 
  arg_1 = g0607
  Result = (arg_1/4)
  return Result
  } 

// ----- function from method averageEnergyPain @ integer ------------- 
//  averagePain from (lack of) energyfunction averageEnergyPain (y) { 
  var Result 
  var arg_1 
  var g0611  = 0
  for (const g0614 of C_Consumer.descendants){ 
    for (const g0613 of g0614.instances){ 
      var g0612  = g0613.painEnergy[y-1]
      g0611 = (g0611+g0612)
      } 
    } 
  arg_1 = g0611
  Result = (arg_1/4)
  return Result
  } 

// ----- function from method averageEconomyPain @ integer ------------- 
//  averagePain from Economy (loss of PNB)function averageEconomyPain (y) { 
  var Result 
  var arg_1 
  var g0615  = 0
  for (const g0618 of C_Consumer.descendants){ 
    for (const g0617 of g0618.instances){ 
      var g0616  = g0617.painResults[y-1]
      g0615 = (g0615+g0616)
      } 
    } 
  arg_1 = g0615
  Result = (arg_1/4)
  return Result
  } 

// ----- function from method averageWarmingPain @ integer ------------- 
//  averagePain from warmingfunction averageWarmingPain (y) { 
  var Result 
  var arg_1 
  var g0619  = 0
  for (const g0622 of C_Consumer.descendants){ 
    for (const g0621 of g0622.instances){ 
      var g0620  = g0621.painWarming[y-1]
      g0619 = (g0619+g0620)
      } 
    } 
  arg_1 = g0619
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
  for (const g0623 of C_Supplier.descendants){ 
    for (const s of g0623.instances){ 
      s.See(C_pb.year)
      } 
    } 
  for (const g0624 of C_Consumer.descendants){ 
    for (const c of g0624.instances){ 
      c.See(C_pb.year)
      } 
    } 
  for (const g0625 of C_Consumer.descendants){ 
    for (const c of g0625.instances){ 
      c.economy.See(C_pb.year)
      } 
    } 
   sls()
  } 

// ----- function from method sls @ void ------------- 
//  single line summaryfunction sls () { 
  var w  = C_pb.world.all
  var y  = C_pb.year
  kernel.PRINC("// ")
  kernel.princ_string8(C_pb.comment,5)
  kernel.PRINC(" PNB: ")
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
  var arg_1 
  var arg_2 
  var arg_3 
  var g0630  = 0
  for (const g0633 of C_Consumer.descendants){ 
    for (const g0632 of g0633.instances){ 
      var g0631  = g0632.ePWhs[y-1]
      g0630 = (g0630+g0631)
      } 
    } 
  arg_3 = g0630
  arg_2 = (arg_3/w.totalConsos[y-1])
  arg_1 = (arg_2*100)
  kernel.printFDigit_float(arg_1,1)
  kernel.PRINC(" electricity\n")
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
  var g0634  = 0
  for (const g0637 of C_Consumer.descendants){ 
    for (const g0636 of g0637.instances){ 
      var g0635  = g0636.population.Get(yearF(y))
      g0634 = (g0634+g0635)
      } 
    } 
  Result = g0634
  return Result
  } 

// ----- function from method init @ list<type_expression>(WorldClass, Supplier, Supplier) ------------- 
//  ********************************************************************
//  *    Part 3: Experiments                                           *
//  ********************************************************************
//  initialize all the simulation objects
//  we want the time series *s[y]function init_WorldClass1 (w,e,c) { 
  C_pb.world = w
  C_pb.earth = C_Earth.instances[0]
  C_pb.oil = e
  C_pb.clean = c
  { 
    var va_arg2 
    var i_bag  = []
    var i  = 2
    var g0638  = (C_NIS+1)
    while (i <= g0638) { 
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
    var g0639  = C_NIS
    while (x <= g0639) { 
      kernel.add_list(x_bag,0)
      x = (x+1)
      } 
    va_arg2 = x_bag
    C_pb.debugCurve = va_arg2
    } 
  { 
    var va_arg2 
    var x_bag  = []
    var x  = 1
    var g0640  = C_NIS
    while (x <= g0640) { 
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
    var g0641  = C_NIS
    while (x <= g0641) { 
      kernel.add_list(x_bag,0)
      x = (x+1)
      } 
    va_arg2 = x_bag
    C_pb.prodCurve = va_arg2
    } 
   reinit_void()
  } 

// ----- function from method reinit @ void ------------- 
//  reusable part (reinit)function reinit_void () { 
  C_pb.year = 1
  init_WorldClass4(C_pb.world)
  C_pb.earth.Init()
  consolidate_void()
  for (const g0642 of C_Supplier.descendants){ 
    for (const s of g0642.instances){ 
      s.Init()
      } 
    } 
  for (const g0643 of C_Consumer.descendants){ 
    for (const c of g0643.instances){ 
      c.Init()
      } 
    } 
   C_pb.world.all.Consolidate(1)
  } 

// ----- function from method init @ list<type_expression>(WorldClass) ------------- 
//  init for the world economyfunction init_WorldClass4 (w) { 
  { 
    var va_arg2 
    var _CL_obj  = (new Economy()).Is(C_Economy)
    va_arg2 = _CL_obj
    w.all = va_arg2
    } 
  w.all.Init()
  var arg_1 
  var g0644  = 0
  for (const g0647 of C_Consumer.descendants){ 
    for (const g0646 of g0647.instances){ 
      var g0645 
      var g0648  = 0
      for (const g0649 of g0646.consumes){ 
        g0648 = (g0648+g0649)
        } 
      g0645 = g0648
      g0644 = (g0644+g0645)
      } 
    } 
  arg_1 = g0644
  w.all.totalConsos[0]=arg_1
  { 
    var va_arg2 
    var i_bag  = []
    var i  = 1
    var g0650  = C_NIT
    while (i <= g0650) { 
      kernel.add_list(i_bag,0)
      i = (i+1)
      } 
    va_arg2 = i_bag
    w.steelPrices = va_arg2
    } 
  w.steelPrices[0]=w.steelPrice
  { 
    var va_arg2 
    var i_bag  = []
    var i  = 1
    var g0651  = C_NIT
    while (i <= g0651) { 
      kernel.add_list(i_bag,0)
      i = (i+1)
      } 
    va_arg2 = i_bag
    w.agroSurfaces = va_arg2
    } 
  w.agroSurfaces[0]=w.agroLand
  { 
    var va_arg2 
    var i_bag  = []
    var i  = 1
    var g0652  = C_NIT
    while (i <= g0652) { 
      kernel.add_list(i_bag,0)
      i = (i+1)
      } 
    va_arg2 = i_bag
    w.energySurfaces = va_arg2
    } 
  { 
    var va_arg2 
    var i_bag  = []
    var i  = 1
    var g0653  = C_NIT
    while (i <= g0653) { 
      kernel.add_list(i_bag,0)
      i = (i+1)
      } 
    va_arg2 = i_bag
    w.wheatOutputs = va_arg2
    } 
   w.wheatOutputs[0]=w.wheatProduction
  } 

// ----- function from method consolidate @ void ------------- 
//  consolidation of the world economy : init versionfunction consolidate_void () { 
  var e  = C_pb.world.all
  { 
    var va_arg2 
    var g0654  = 0
    for (const g0657 of C_Block.descendants){ 
      for (const g0656 of g0657.instances){ 
        var g0655  = g0656.gdp
        g0654 = (g0654+g0655)
        } 
      } 
    va_arg2 = g0654
    e.gdp = va_arg2
    } 
  { 
    var va_arg2 
    var g0658  = 0
    for (const g0661 of C_Block.descendants){ 
      for (const g0660 of g0661.instances){ 
        var g0659  = g0660.investG
        g0658 = (g0658+g0659)
        } 
      } 
    va_arg2 = g0658
    e.investG = va_arg2
    } 
  { 
    var va_arg2 
    var g0662  = 0
    for (const g0665 of C_Block.descendants){ 
      for (const g0664 of g0665.instances){ 
        var g0663  = g0664.investE
        g0662 = (g0662+g0663)
        } 
      } 
    va_arg2 = g0662
    e.investE = va_arg2
    } 
  } 

// ----- function from method accelerate @ list ------------- 
//  ********************************************************************
//  *    Part 4: Utility functions for input                           *
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
//  improve% : modify the factors without changing the dates
//  special form so that % stays a percentfunction improve_Z_float (x,factor) { 
  
  if (factor > 0) { 
    return  (x+(factor*(1-x)))
    } else {
    return  (x+(factor*x))
    } 
  } 

// ----- function from method tune @ list ------------- 
//  tune a policy by changing one substitutionfunction tune (policy,from,to,line) { 
  var Result 
  var tr  = from.GetTransition(to)
  var n  = policy.length
  var i_bag  = []
  var i  = 1
  var g0668  = n
  while (i <= g0668) { 
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
//  inputs are export flows in billions of dollars, gdp in in trillons of dollarsfunction balanceOfTrade (l) { 
  var Result 
  var c_bag  = []
  for (const g0673 of C_Consumer.descendants){ 
    for (const c of g0673.instances){ 
      var arg_1 
      var ec  = c.economy
      var c2_bag  = []
      for (const g0674 of C_Consumer.descendants){ 
        for (const c2 of g0674.instances){ 
          kernel.add_list(c2_bag,(l[c.index-1][c2.index-1]/(ec.gdp*1000)))
          } 
        } 
      arg_1 = c2_bag
      kernel.add_list(c_bag,arg_1)
      } 
    } 
  Result = c_bag
  return Result
  } 

// ----- function from method go @ integer ------------- 
//  ********************************************************************
//  *    Part 4: Launch (go(n))                                        *
//  ********************************************************************
//  do n years of simulationfunction go (n) { 
  init_WorldClass1(C_World,C_Oil,C_Clean)
   add_years(n)
  } 

// ----- function from method jsmain @ void ------------- 
//  what we launch by default with jsfunction jsmain () { 
  kernel.ClEnv.verbose = 0
   go(90)
  } 


//--------------- meta description + top-level instructions ----
function MetaLoad() { 
  
  // instructions from module sources
  C_TALK = 1 
  C_DEBUG = 5 
  C_Version = 0.5 
  C_NIT = 200 
  C_NIS = 1000 
  C_PMIN = 4 
  C_PMAX = 860 
  C_Year = kernel.C_integer 
  C_Percent = kernel.C_float 
  C_Price = kernel.C_float 
  C_Energy = kernel.C_float 
  C_ListFunction = new kernel.ClaireClass("ListFunction",kernel.C_object,false)
  C_StepFunction = new kernel.ClaireClass("StepFunction",C_ListFunction,false)
  C_Affine = new kernel.ClaireClass("Affine",C_ListFunction,false)
  C_Transition = new kernel.ClaireClass("Transition",kernel.C_object,false)
  C_Supplier = new kernel.ClaireClass("Supplier",kernel.C_thing,true)
  C_FiniteSupplier = new kernel.ClaireClass("FiniteSupplier",C_Supplier,true)
  C_InfiniteSupplier = new kernel.ClaireClass("InfiniteSupplier",C_Supplier,true)
  C_Transition = new kernel.ClaireClass("Transition",kernel.C_object,false)
  C_Economy = new kernel.ClaireClass("Economy",kernel.C_thing,true)
  C_Block = new kernel.ClaireClass("Block",C_Economy,true)
  C_Strategy = new kernel.ClaireClass("Strategy",kernel.C_object,false)
  C_Consumer = new kernel.ClaireClass("Consumer",kernel.C_thing,true)
  C_Economy = new kernel.ClaireClass("Economy",kernel.C_thing,true)
  C_WorldClass = new kernel.ClaireClass("WorldClass",kernel.C_thing,true)
  C_Block = new kernel.ClaireClass("Block",C_Economy,true)
  C_Strategy = new kernel.ClaireClass("Strategy",kernel.C_object,false)
  C_Earth = new kernel.ClaireClass("Earth",kernel.C_thing,true)
  C_Problem = new kernel.ClaireClass("Problem",kernel.C_thing,true)
  C_pb = (new Problem("pb")).Is(C_Problem)
  
  
  C_TESTE = null 
  C_TESTC = null 
  C_SHOW1 = 5 
  C_SHOW2 = 5 
  C_HOW = 5 
  C_BALANCE = 5 
  C_SHOW3 = 5 
  C_SHOW4 = 5 
  C_SHOW5 = 5 
  C_MAXTAX = 5000 
  C_MAXTR = 150 
  C_Gt2km2 = 0.0116 
  C_YSTOP = 1000 
  C_YTALK = 1000 
  C_Oil2010 = 46.4 
  C_Gas2010 = 34.8 
  C_Coal2010 = 56.8 
  C_Clean2010 = 7.5 
  C_EfromOil2010 = 1.074 
  C_EfromCoal2010 = 8.405000000000001 
  C_EfromGas2010 = 4.704 
  C_EfromClean2010 = 6.886 
  C_Oil = (new FiniteSupplier("Oil")).Is(C_FiniteSupplier)
  C_Oil.index = 1
  C_Oil.inventory = affine([[perMWh(400),PWh(193)],
    [perMWh(600),PWh(290)],
    [perMWh(1600),PWh(350)],
    [perMWh(5000),PWh(450)]])
  C_Oil.threshold = (PWh(193)*0.9)
  C_Oil.techFactor = 0.01
  C_Oil.production = C_Oil2010
  C_Oil.price = 35.3
  C_Oil.capacityMax = (46.4*1.1)
  C_Oil.capacityGrowth = 0.06
  C_Oil.horizonFactor = 1.2
  C_Oil.sensitivity = 0.4
  C_Oil.co2Factor = 0.272
  C_Oil.co2Kwh = 270
  C_Oil.investPrice = 0.13
  C_Oil.steelFactor = 0.1
  
  C_Coal = (new FiniteSupplier("Coal")).Is(C_FiniteSupplier)
  C_Coal.index = 2
  C_Coal.inventory = affine([[perMWh(80),PWh(600)],[perMWh(150),PWh(800)],[perMWh(200),PWh(1000)]])
  C_Coal.threshold = PWh(400)
  C_Coal.techFactor = 0.01
  C_Coal.production = C_Coal2010
  C_Coal.price = 8.62
  C_Coal.capacityMax = (56.8*1.1)
  C_Coal.horizonFactor = 1.1
  C_Coal.capacityGrowth = 0.006999999999999999
  C_Coal.sensitivity = 0.2
  C_Coal.co2Factor = 0.28300000000000003
  C_Coal.co2Kwh = 280
  C_Coal.investPrice = 0.43000000000000005
  C_Coal.steelFactor = 0.15
  
  C_Gas = (new FiniteSupplier("Gas")).Is(C_FiniteSupplier)
  C_Gas.index = 3
  C_Gas.inventory = affine([[perMWh(163),PWh(160)],[perMWh(320),PWh(220)],[perMWh(5500),PWh(270)]])
  C_Gas.threshold = PWh(100)
  C_Gas.techFactor = 0.01
  C_Gas.production = C_Gas2010
  C_Gas.price = 14.1
  C_Gas.capacityMax = (34.8*1.1)
  C_Gas.capacityGrowth = 0.08
  C_Gas.horizonFactor = 1.1
  C_Gas.sensitivity = 0.8
  C_Gas.co2Factor = 0.184
  C_Gas.co2Kwh = 180
  C_Gas.investPrice = 0.13
  C_Gas.steelFactor = 0.1
  
  C_Clean = (new InfiniteSupplier("Clean")).Is(C_InfiniteSupplier)
  C_Clean.index = 4
  C_Clean.techFactor = 0.01
  C_Clean.growthPotential = affine([[2000,0.2],
    [2020,0.2],
    [2030,1.5],
    [2040,2],
    [2100,4]])
  C_Clean.horizonFactor = 1.1
  C_Clean.production = C_Clean2010
  C_Clean.capacityMax = (7.5*1.1)
  C_Clean.price = 50
  C_Clean.sensitivity = 0.5
  C_Clean.investPrice = 0.9500000000000001
  C_Clean.co2Factor = 0
  C_Clean.co2Kwh = 0
  C_Clean.steelFactor = 0.4
  
  makeTransition("Oil to Coal (CTL)",1,2,1)
  makeTransition("Oil to Gas",1,3,0.8)
  makeTransition("Oil to clean electricity",1,4,0.1)
  makeTransition("Coal to Gas",2,3,0.8)
  makeTransition("Coal to clean",2,4,0.2)
  makeTransition("Gas to clean",3,4,0.3)
  C_EnergyTransition = [affine([[2010,0],[2100,0]]),
    affine([[2010,0],
      [2020,0],
      [2040,0.05],
      [2100,0.08]]),
    affine([[2010,0],
      [2020,0],
      [2040,0.07],
      [2100,0.15000000000000002]]),
    affine([[2010,0],
      [2020,0],
      [2040,0.05],
      [2100,0.1]]),
    affine([[2010,0],
      [2020,0.02],
      [2040,0.1],
      [2100,0.2]]),
    affine([[2010,0],
      [2020,0.05],
      [2040,0.15000000000000002],
      [2100,0.3]])] 
  C_USSaving = affine([[2010,0],
    [2020,0.1],
    [2030,0.18],
    [2050,0.25],
    [2100,0.35]]) 
  C_EUSaving = affine([[2010,0],
    [2020,0.08],
    [2030,0.18],
    [2050,0.25],
    [2100,0.35]]) 
  C_CNSaving = affine([[2010,0],
    [2020,0.07],
    [2030,0.1],
    [2050,0.2],
    [2100,0.35]]) 
  C_RWSaving = affine([[2010,0],
    [2020,0.06],
    [2030,0.1],
    [2050,0.15],
    [2100,0.3]]) 
  C_USDemat = affine([[2010,0],
    [2020,0.22],
    [2030,0.35],
    [2050,0.48],
    [2100,0.6]]) 
  C_EUDemat = affine([[2010,0],
    [2020,0.1],
    [2030,0.25],
    [2050,0.4],
    [2100,0.55]]) 
  C_CNDemat = affine([[2010,0],
    [2020,0.28],
    [2030,0.35],
    [2050,0.45],
    [2100,0.6]]) 
  C_RWDemat = affine([[2010,0],
    [2020,0.07],
    [2030,0.14],
    [2050,0.3],
    [2100,0.5]]) 
  C_UScancel = affine([[35.3,0],
    [69,0.05],
    [138,0.33999999999999997],
    [276,0.54],
    [520,0.7],
    [860,0.99]]) 
  C_EUcancel = C_UScancel 
  C_CNcancel = affine([[35.3,0],
    [69,0.3],
    [138,0.5],
    [276,0.7],
    [520,0.8],
    [860,0.99]]) 
  C_RestCancel = affine([[35.3,0],
    [69,0.15000000000000002],
    [138,0.45],
    [276,0.6],
    [520,0.9],
    [860,0.99]]) 
  C_CancelImpact = affine([[0,0],
    [0.1,0.05],
    [0.2,0.14],
    [0.3,0.24],
    [0.4,0.33],
    [0.5,0.43],
    [0.7,0.6],
    [1,1]]) 
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
  C_RWeSources2010 = [(((1.074-C_USeSources2010[0])-C_EUeSources2010[0])-C_CNeSources2010[0]),
    (((8.405000000000001-C_USeSources2010[1])-C_EUeSources2010[1])-C_CNeSources2010[1]),
    (((4.704-C_USeSources2010[2])-C_EUeSources2010[2])-C_CNeSources2010[2]),
    (((6.886-C_USeSources2010[3])-C_EUeSources2010[3])-C_CNeSources2010[3])] 
  C_USenergy2010 = [10.44,
    6.03,
    7.08,
    1.59] 
  C_EUenergy2010 = [7.89,
    3.13,
    4.64,
    1.6700000000000002] 
  C_CNenergy2010 = [5.45,
    21.34,
    1.04,
    0.93] 
  C_RWenergy2010 = [22.62,
    26.330000000000002,
    22.04,
    3.24] 
  C_US = (new Consumer("US")).Is(C_Consumer)
  C_US.index = 1
  C_US.objective = strategy(0.03,
    600,
    0.9,
    0.4,
    0.3)
  strategy(0.03,
    600,
    0.9,
    0.4,
    0.3).stratFrom = C_US
  C_US.consumes = C_USenergy2010
  C_US.eSources = C_USeSources2010
  C_US.cancel = C_UScancel
  C_US.cancelImpact = C_CancelImpact
  C_US.marginImpact = C_UScancel.Improve(-0.3)
  C_US.saving = C_USSaving
  C_US.population = affine([[2010,0.311],[2040,0.365],[2100,0.394]])
  C_US.popEnergy = 0.4
  C_US.subMatrix = tune(C_EnergyTransition,C_Coal,C_Gas,affine([[2010,0.1],
    [2020,0.6],
    [2040,0.7],
    [2100,0.8]]))
  C_US.disasterLoss = affine([[1,0],
    [1.5,0.015],
    [2,0.04],
    [3,0.08],
    [4,0.15],
    [5,0.25]])
  C_US.carbonTax = affine([[380,0],[6000,0]])
  C_US.cancelFromPain = 0
  C_US.taxFromPain = 0
  
  C_EU = (new Consumer("EU")).Is(C_Consumer)
  C_EU.index = 2
  C_EU.objective = strategy(0.02,
    500,
    1,
    0.3,
    0.4)
  strategy(0.02,
    500,
    1,
    0.3,
    0.4).stratFrom = C_EU
  C_EU.consumes = C_EUenergy2010
  C_EU.eSources = C_EUeSources2010
  C_EU.cancel = C_EUcancel
  C_EU.cancelImpact = C_CancelImpact
  C_EU.marginImpact = C_EUcancel.Improve(-0.2)
  C_EU.saving = C_EUSaving
  C_EU.population = affine([[2000,0.43000000000000005],
    [2040,0.45],
    [2080,0.42000000000000004],
    [2100,0.41000000000000003]])
  C_EU.popEnergy = 0.4
  C_EU.subMatrix = tune(C_EnergyTransition,C_Coal,C_Gas,affine([[2010,0.1],
    [2020,0.3],
    [2040,0.5],
    [2100,0.8]]))
  C_EU.disasterLoss = affine([[1,0],
    [1.5,0.015],
    [2,0.04],
    [3,0.08],
    [4,0.15],
    [5,0.25]])
  C_EU.carbonTax = affine([[380,0],[6000,0]])
  C_EU.cancelFromPain = 0
  C_EU.taxFromPain = 0
  
  C_CN = (new Consumer("CN")).Is(C_Consumer)
  C_CN.index = 3
  C_CN.objective = strategy(0.04,
    600,
    0.6,
    0.4,
    0.4)
  strategy(0.04,
    600,
    0.6,
    0.4,
    0.4).stratFrom = C_CN
  C_CN.consumes = C_CNenergy2010
  C_CN.eSources = C_CNeSources2010
  C_CN.cancel = C_CNcancel
  C_CN.cancelImpact = C_CancelImpact.Improve(0.3)
  C_CN.marginImpact = C_CNcancel.Improve(0.2)
  C_CN.saving = C_CNSaving
  C_CN.population = affine([[2010,1.35],
    [2040,1.3800000000000001],
    [2050,1.31],
    [2080,0.97],
    [2100,0.75]])
  C_CN.popEnergy = 0.5
  C_CN.subMatrix = tune(tune(C_EnergyTransition,C_Coal,C_Gas,affine([[2010,0.03],
    [2020,0.08],
    [2040,0.1],
    [2100,0.12000000000000001]])),C_Coal,C_Clean,affine([[2010,0],
    [2020,0.03],
    [2040,0.07],
    [2100,0.2]]))
  C_CN.disasterLoss = affine([[1,0],
    [1.5,0.015],
    [2,0.04],
    [3,0.08],
    [4,0.15],
    [5,0.25]])
  C_CN.carbonTax = affine([[380,0],[6000,0]])
  C_CN.cancelFromPain = 0
  C_CN.taxFromPain = 0
  
  C_Rest = (new Consumer("Rest")).Is(C_Consumer)
  C_Rest.index = 4
  C_Rest.objective = strategy(0.03,
    600,
    0.8,
    0.5,
    0.4)
  strategy(0.03,
    600,
    0.8,
    0.5,
    0.4).stratFrom = C_Rest
  C_Rest.consumes = C_RWenergy2010
  C_Rest.eSources = C_RWeSources2010
  C_Rest.cancel = C_RestCancel
  C_Rest.cancelImpact = C_CancelImpact
  C_Rest.marginImpact = C_RestCancel
  C_Rest.saving = C_RWSaving
  C_Rest.population = affine([[2010,(7.3-((0.43000000000000005+0.31)+1.35))],
    [2040,(9-((0.45+0.365)+1.3800000000000001))],
    [2080,(9.4-((0.42000000000000004+0.38)+0.97))],
    [2100,(9.2-((0.41000000000000003+0.394)+0.75))]])
  C_Rest.popEnergy = 0.7
  C_Rest.subMatrix = accelerate_list(C_EnergyTransition,-0.1)
  C_Rest.disasterLoss = affine([[1,0],
    [1.5,0.015],
    [2,0.04],
    [3,0.08],
    [4,0.15],
    [5,0.25]])
  C_Rest.carbonTax = affine([[380,0],[6000,0]])
  C_Rest.cancelFromPain = 0
  C_Rest.taxFromPain = 0
  
  C_World = (new WorldClass("World")).Is(C_WorldClass)
  C_World.steelPrice = 3800
  C_World.energy4steel = affine([[2000,0.5],
    [2020,0.45],
    [2050,0.6],
    [2100,1]])
  C_World.wheatProduction = 0.6599999999999999
  C_World.agroLand = 17.6
  C_World.landImpact = affine([[2000,8],
    [2020,10],
    [2050,20],
    [2100,15]])
  C_World.lossLandWarming = affine([[0,1],[2,0.96],[4,0.9]])
  C_World.agroEfficiency = affine([[400,1],
    [600,0.96],
    [1000,0.92],
    [2000,0.85],
    [5000,0.75]])
  C_World.bioHealth = affine([[0,1],
    [1,0.98],
    [2,0.96],
    [4,0.9]])
  C_World.cropYield = affine([[2000,1],
    [2020,1.15],
    [2050,1.3],
    [2100,1.5]])
  
  C_USgdp = 15 
  C_USir = 0.2 
  C_USeco = (new Block("USeco")).Is(C_Block)
  C_USeco.describes = C_US
  C_US.economy = C_USeco
  C_USeco.gdp = C_USgdp
  C_USeco.dematerialize = C_USDemat
  C_USeco.roI = affine([[2000,0.18],
    [2020,0.18],
    [2050,0.18],
    [2100,0.15]])
  C_USeco.investG = (15*C_USir)
  C_USeco.investE = 0.05
  C_USeco.iRevenue = C_USir
  C_USeco.ironDriver = affine([[2010,122],
    [2020,156],
    [2050,200],
    [2100,300]])
  
  C_EUgdp = 14.5 
  C_EUir = 0.2 
  C_EUeco = (new Block("EUeco")).Is(C_Block)
  C_EUeco.describes = C_EU
  C_EU.economy = C_EUeco
  C_EUeco.gdp = C_EUgdp
  C_EUeco.dematerialize = C_EUDemat
  C_EUeco.roI = affine([[2000,0.045],
    [2020,0.045],
    [2050,0.08],
    [2100,0.1]])
  C_EUeco.investG = (14.5*C_EUir)
  C_EUeco.investE = 0.15000000000000002
  C_EUeco.iRevenue = C_EUir
  C_EUeco.ironDriver = affine([[2010,92],
    [2020,96],
    [2050,120],
    [2100,200]])
  
  C_CNgdp = 6 
  C_CNir = 0.42 
  C_CNeco = (new Block("CNeco")).Is(C_Block)
  C_CNeco.describes = C_CN
  C_CN.economy = C_CNeco
  C_CNeco.gdp = C_CNgdp
  C_CNeco.dematerialize = C_CNDemat
  C_CNeco.roI = affine([[2000,0.3],
    [2020,0.26],
    [2050,0.2],
    [2100,0.15]])
  C_CNeco.investG = (6*C_CNir)
  C_CNeco.investE = 0.07
  C_CNeco.iRevenue = C_CNir
  C_CNeco.ironDriver = affine([[2010,9],
    [2020,14.4],
    [2050,30],
    [2100,60]])
  
  C_Wgdp = (66.6-((14.5+C_USgdp)+C_CNgdp)) 
  C_Wir = 0.25 
  C_RWeco = (new Block("RWeco")).Is(C_Block)
  C_RWeco.describes = C_Rest
  C_Rest.economy = C_RWeco
  C_RWeco.gdp = C_Wgdp
  C_RWeco.dematerialize = C_RWDemat
  C_RWeco.roI = affine([[2000,0.03],
    [2020,0.035],
    [2050,0.06],
    [2100,0.08]])
  C_RWeco.investG = (31.099999999999994*C_Wir)
  C_RWeco.investE = 0.5
  C_RWeco.iRevenue = C_Wir
  C_RWeco.ironDriver = affine([[2010,54],
    [2020,50],
    [2050,55],
    [2100,60]])
  
  C_pb.trade = balanceOfTrade([[0,
      167,
      90,
      1250],
    [248,
      0,
      132,
      1200],
    [360,
      250,
      0,
      900],
    [1250,
      1200,
      900,
      0]])
  C_Gaia = (new Earth("Gaia")).Is(C_Earth)
  C_Gaia.co2PPM = 388
  C_Gaia.co2Add = 34
  C_Gaia.co2Ratio = 0.0692
  C_Gaia.warming = affine([[200,0],
    [400,0.7],
    [560,2.4],
    [680,2.8],
    [1200,4.3]])
  C_Gaia.avgTemp = 14.629999999999999
  C_Gaia.avgCentury = 13.9
  C_Gaia.painProfile = [0.4,0.3,0.3]
  C_Gaia.painClimate = step([[1,0],
    [1.5,0.01],
    [2,0.1],
    [3,0.2],
    [4,0.3]])
  C_Gaia.painGrowth = step([[-0.2,0.2],
    [-0.05,0.1],
    [0,0.05],
    [0.01,0.01],
    [0.02,0.01],
    [0.03,0]])
  C_Gaia.painCancel = step([[0,0],
    [0.05,0.02],
    [0.1,0.05],
    [0.2,0.1],
    [0.3,0.2],
    [0.5,0.3]])
  
  console.log("------------- end of gw1 meta_load --------------")
  } 
MetaLoad()
jsmain()

