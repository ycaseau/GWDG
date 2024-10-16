

                +--------------------------------------+
                | GWDG Project log file v0.6           |
                +--------------------------------------+




16 Octobre 2023 ---------------------- cloture pour un mois -------------------------------


SHOW2 := true is a CLAIRE BUG -> fix for CLAIRE 4.1.0 !!!!!!!!!!!!

à finir avant de passer à GW5
==============================
- imprimer les M5 outcome
- calculer un SCC associé (dOutcome/dCO2)
- a comparer avec l'effet d'une taxe CO2 au meme niveau


// December 2nd, 2023 : closure of CCEM v4 !

model.cl
   (a) move slots to Economy (from Consumer)
       dematerialize
       RoI

   (b) move to Consumer (Zone)
       population
       disasterLoss

Impact of global warming destruction is cummulative
   (a) b.disasterLoss[y] := % of productive capacity, increasing monotonously
   (b) needs (getNeed in game.cl) is reduced by disasterLoss[y - 1]
   (c) in simul.cl we keep the average value of disasterLoss (for the world)

// December 9th : re-run all simulation 
// run the sensibility analysis -> see what the two most interesting examples are

[2100] World PNB=215.3, invest=29.2, conso=13.29, steel:2.3Gt
--- CO2 at 650.45, temperature = 16.6, impact = 7.6%, tax = 0.0,0.0,0.0,0.0
Oil: price = 3361.00(819.7%), inventory = 78.70, prod = 2.09
Coal: price = 181.00(181.0%), inventory = 386.45, prod = 5.35
Gas: price = 1785.00(1095.0%), inventory = 17.62, prod = 0.59
Clean: price = 942.00(171.2%), capacity growth potential = 0.07, prod = 5.24
US: conso(GTep) 0.63 0.14 0.21 1.38  vs need 2.74 0.31 2.79 2.04  
EU: conso(GTep) 0.18 0.03 0.05 0.39  vs need 0.78 0.06 0.66 0.58  
CN: conso(GTep) 0.00 2.79 0.02 1.01  vs need 2.35 5.97 3.60 2.92  
Rest: conso(GTep) 1.28 2.38 0.30 2.45  vs need 4.65 4.73 4.65 4.02  
[2100] US PNB=73.4, invest=8.8, conso=2.37, steel:0.2Gt
[2100] EU PNB=22.3, invest=2.6, conso=0.66, steel:0.1Gt
[2100] CN PNB=66.2, invest=10.7, conso=3.83, steel:1.1Gt
[2100] Rest PNB=53.2, invest=6.9, conso=6.41, steel:0.8Gt

h0() ->  PNB = 203 (CN 51), 12.02 Gt, 626 CO2      // carbon tax
h1c() -> PNB = 238 (CN : 87), 15.5 Gt, 676 CO2      // coal growth 
h1g() -> PNB = 230 (CN: 75), 14.5 Gt, 649 CO2      // green growth

h2-() -> PNB = 194 (CN: 66), 11.9 Gt, 610 CO2      // less oil (China does not care)
h2+() -> PNB = 262 (CN: 70), 16.6 Gt, 708 CO2      // more oil (US boom, EU too)

h3+() -> PNB = 249 (CN: 87), 12.78 Gt, 649 CO2      // more savings
h3-() -> PNB = 204 (CN: 64), 13.68 Gt, 654 CO2      // less savings

h4+() -> PNB = 228 (CN: 69), 14.3 Gt, 648 CO2      // more substitution
h4-() -> PNB = 198 (CN: 50), 11.72 Gt, 652 CO2      // less substitution

h5-() -> PNB = 181 (CN: 37), 11.9 Gt, 593 CO2      // less cancel
h5+() -> PNB = 220 (CN: 63), 13.94 Gt, 659 CO2      // more cancel

h6-() -> PNB = 192 (CN: 51), 14.03 Gt, 656 CO2      // less dematerialization
h6+() -> PNB = 236 (CN: 79), 12.78 Gt, 644 CO2      // more dematerialization

h7-() -> PNB = 201 (CN: 63), 12.6 Gt, 644 CO2      // less economic growth
h7+() -> PNB = 225 (CN: 64), 13.4 Gt, 653 CO2      // more economic growth

h8() -> PNB = 206 (CN: 50), 12.38 Gt, 610 CO2      // less carbon tax
h8+() -> PNB = 175 (CN: 15.5), 9.93 Gt, 528 CO2       // more carbon tax

h9-() -> PNB = 218 (CN: 66), 13.31 Gt, 651 CO2      // less GW impact
h9+() -> PNB = 211 (CN: 67), 13.05 Gt, 649 CO2       // more GW impact

Nordo: h11(10%)  ->  PNB = 260 (CN: 68), 15.6 Gt, 747 CO2  
Janco: h12(200%)  ->  PNB = 151 (CN:24), 9.23 Gt, 500 CO2
Singulo : h13(150%) -> PNB = 224 (CN: 20), 10.6 Gt, 519 CO2    

// redo excel
- excel("excel/diamandis")


// December 23rd 2023, add the KNUs
cf. simul.cl : knu() show the six KNUs
- KNU1: 
- KNU2
- KNU3 
- KNU4 : computes the maximal energy transition from fossile to green and adds the legacy electrity ratio (10%)
- KNU5: 
- KUN6: approximate SCC (computed after the simulation) : Loss/excess CO2

WARNING: changed the getOutput(Supplier) heuristics and introduced a min(1, Cmax/max)
to separate Coal (abundant) from Oil (scarce) to get realistics price increases for coal 

// ---------- new simulations ---------------------------------

[2100] World PNB=221.7, invest=29.9, conso=13.02, steel:2.3Gt
--- CO2 at 623.42, temperature = 16.5, impact = 7.2%, tax = 0.0,0.0,0.0,0.0
Oil: price = 2198.00(536.0%), inventory = 64.91, prod = 1.65
Coal: price = 188.00(188.0%), inventory = 417.92, prod = 5.27
Gas: price = 1416.00(868.7%), inventory = 17.59, prod = 0.60
Clean: price = 960.00(174.5%), capacity growth potential = 0.14, prod = 5.50
US: conso(GTep) 0.58 0.13 0.18 1.37  vs need 2.44 0.29 2.62 2.06  
EU: conso(GTep) 0.15 0.02 0.04 0.35  vs need 0.63 0.05 0.56 0.53  
CN: conso(GTep) 0.03 2.78 0.08 1.13  vs need 2.29 6.16 3.71 3.16  
Rest: conso(GTep) 0.88 2.33 0.28 2.63  vs need 4.49 4.79 4.66 4.36  
[2100] US PNB=77.4, invest=9.5, conso=2.27, steel:0.2Gt
[2100] EU PNB=22.9, invest=2.8, conso=0.57, steel:0.1Gt
[2100] CN PNB=69.1, invest=10.9, conso=4.03, steel:1.1Gt
[2100] Rest PNB=52.1, invest=6.6, conso=6.13, steel:0.8Gt

KNU1 = max clean energy per decade = 13.2 PWh/ 10 years
KNU2 = energy intensity decrease = 1.2% (CAGR 2010-2050)
KNU3 = negative long-term elasticity energy demand to price = -33.8%
KNU4 = approx electrification of energy = 48.6% in 2050
KNU5 = average worldwide ReturnOnInvest = 9.3% (2010-2050)
KNU6 = SCC estimate based on GW impact at +2.6C: 6.7% => 269.5 $/t

h0() ->  PNB = 207 (CN 51.7), 11.62 Gt, 595 CO2      // carbon tax
h1c() -> PNB = 236 (CN : 82), 14.47 Gt, 641 CO2      // coal growth 
h1g() -> PNB = 241 (CN: 75), 14.6 Gt, 622 CO2        // green growth
// note : with the new output model, if we grow the coal capacity, we need to 
// change the price sensitivity 


h2-() -> PNB = 195 (CN: 60), 11.71 Gt, 567 CO2      // less oil (China does not care)
h2+() -> PNB = 264 (CN: 71.4), 15.97 Gt, 663 CO2      // more oil (US boom, EU too)

h3+() -> PNB = 249 (CN: 77), 12.3 Gt, 604 CO2      // more savings
h3-() -> PNB = 209 (CN: 59), 13.52 Gt, 611 CO2      // less savings

h4+() -> PNB = 236 (CN: 68), 14.35 Gt, 606 CO2      // more substitution
h4-() -> PNB = 199 (CN: 50), 11.4 Gt, 608 CO2      // less substitution

h7-() -> PNB = 204 (CN: 59), 12.2 Gt, 602 CO2      // less economic growth
h7+() -> PNB = 230 (CN: 62), 13.35 Gt, 608 CO2      // more economic growth

h8() -> PNB = 210 (CN: 49), 11.88 Gt, 580 CO2      // less carbon tax
h8+() -> PNB = 183 (CN: 23), 9.9 Gt, 531 CO2       // more carbon tax


// refaire les excel
excel("excel/h0")
kaya("excel/kaya")
h2+() / h2-()  -> low/high fossil
h8() / h8+()  -> low/high carbon tax

13.9 + 3 -> 16.9
13.9 + 1.7 -> 15.6

Nordo: h11(10%)  ->  PNB = 239 (CN: 57), 16.30 Gt, 691 CO2   16.8C
Janco: h12(200%)  ->  PNB = 203 (CN:26), 9.78 Gt, 494 CO2
Diamandis : h13(150%) -> PNB = 220 (CN: 26), 9.98 Gt, 507 CO2  


Xmas Day: close CCEM for the year !

BUT : last change on ROI  means that all figures must be redone for the paper

// January 2024 : redo simulation for CCEM24 paper

new file organisation : simul.cl and display.cl 

// March 3rd : introduce an option 
NewCO2:boolean := true means that the accumulation model is simpler
ppm = ppm + CO2addFactor * (emissions)

// February 1st : start GW5 ! ====================================================

// February 3: start model + input changes

model:
- added heat% to the Supplier ('model.cl')
- translated the energy inputs of input.cl to PWh
- added heat% to transitions ('model.cl'): share of transfer that concerns direct heart
- techFactor is Energy-based (one per source) and describes the decline in costs (for 1MW installed)
- added co2Emmisions at the zone level (easy to compute) - will check on Europe ....
- added the production of electricity per zone as a factor (electrification of energy = KPI)
    - slots: c.eSources + c.eKWh (model.cl + init in simul.cl)

// February 10th : implement electricity production 
2 steps:
- compute the electricity production (eKWh) using the ratios (at each consume(C,S) step)
- adjust for transfers (S2 -> S1) usign the formula in the notebook x . (r1 - alpha * r2)
  where alpha = 1 - t.heat%

=> tune the estimate of ePWh (electricity production) by taking the transfer into account
(cf. execel file: energyMatrix.xls)  => done (approximate but OK)
-> at the same time, tuned the growth for China and the transfer matrix to get a nice 2020 energy forecast

added a feedback loop : pain to production (ratio = productivityFactor, zone dependant: attached to Consumer)
    r = 0 -> People is not a key factor, AI will dominate
    r = 1 -> -10% people => -10% output 

// March 17th : resume (at last)  
=> change the CO2 emission to concentration model ! see the excel table that shows the linear relation
   co2Neutral gets removed and there is a absorbtion factor (0.5% per year) that is added to the ppm
   ppm (volume) translation is 28.97/44 (volume to mass) * (1 / 5.137) since the atmosphere is 5.137 * 10^18 kg
     
  in the future we could model that this factor grows (acidification of oceans reaches a maximum)
  TODO : retrofit to GW4 to see if there is a big difference


 // March 22nd: restart with the great question of protectionism -----------------------------
 // key decision is not to simulate the amount of the CBAM tax but directly the effect on reducing trade
 // this way, it can cover may kind of protectionism taxes, as well as boycotts or redirection

 (a) it starts with the tactical redirection !
      Consumer.protectionismFactor : a factor alpha that is used in M4
//    note that this factor is part of the tactical vector of the Consumer      
      openTrade is a matrix w1 x w2 -> percent of trade that is blocked
      w1.openTrade[w2] := 1 - alpha * max(0,(w2.co2perE - w1.co2perE) / w1.co2perE) *
                                      max(0,(w2.co2Tax - w1.co2tax) / w1.co2tax) 


// For a block w, the economy (CDP) is local + export
// energy demand for local grows according to (maxOut evolution)
// export is bound to the flow w -> w2 (growth of w2 is inherited to w)
// import,which is part of local, may also be impacted (if w1 reduces, or if imports get reduced) -> only a negative factor
// note : since we deal with differences through multiplicative factors, we assume small diffferences
// equation Economy = local + export + import
//          dE = dLocal + dExport + dImport
//          dE/E = dLocal/Local x (Local/E = innerTrade) + dExport/Export x (Export/E) + dImport/Import x (Import / E)

 (b) this reduces the energy consumption (getNeeds in game.cl) that will impact maxOut
     the expected flow is (economyRatio(w2,y) * pb.trade[index(w)][index(w2 as Block)]
     first factor is growth of w2, 
     we start with two constant factors of the world economy (that could be regionalized later )
     // cf World in model.cl (start with 50% and 100%, ask economists ....)    
       - w.protectionismInFactor = factor of the reduction that is kept (the rest is sourced elsewhere)
       - w.protectionismOutFactor = factor of the reduction that is applied to the loosing exporting economy.
                                    that combines selling elswhere but ripple effects on the value chain.
     // game.cl (M2) 
    [globalEconomyRatio(w:Block,y:Year) : Percent
             -> localEconomyRatio(w,y) + outerCommerceRatio(w,y) + importReductionRatio(w,y)] ]
         these two new functions take into account the two protectionism factors


 (b) stratégie player = goals (économie, pain, CO2)  
   // CO2 does not matter really but we can play

 (c) tactical  =  BR from game theory 
    (a) CO2 tax = reaction from pain (taxAcceleration, cancelAcceleration)
    (b) cancel (sobriété)
    (c) transition énergétique (inventer un framework pour customiser le vecteur de départ)
      => transition énergétique est nourrie par CO2 tax, mais nous pourrions ajouter des investissements nationaux
      => transition énergétique est également savings
     (d) CBAM : protectionism = f(delta CO2 ... or delta tax)
         we need a simple formula that links the decided (%reduction OR tarif)
 
 (d) measure CO2/habitant for all zones and see how it evolves (cf. Hannah Ritchie)

 (e) manual tactic set - model.cl 
     tactical(c:Consumer,
        transitionStart, transitionFromPain,    // default 100%, 0%
        cancelFromPain,                         // default 0%
        taxFromPain,                            // default 0%
        protectionismFromPain)                  // default 0%

// April 13th : time to debug

  - growthPotential (model.cl, game.cl, input.cl) : yearly roadmap
  - Horror: the fine tuning was lost -> redo the tuning - actually all this weekend work was lost

// May 1st : start the month of GW5 / IAMES ---

     repair !
       (1) all stupid typos ...
       (2) good formula for import Reduction
         [importReductionRatio(w:Block, w2:Block,y:Year) : Percent
          -> max(0.0, (w.openTrade[index(w2 as Block)] - 1.0) *  pb.world.protectionismInFactor) ]
       (3) growthPotential : now a yearly roadmap ....
       (4) created tTable(s,y) to check the trasnfer flows
       INCREDIBLE BUG: confusion vs s.added and s.additions[y]  

  NEXT MISSION: tune addition and transfer flows thanks to the tTable tool !!!!!!

// May 4th
    - separate S.addedCapacities[y] = cummulative added capacity (yearly log of s.addedCapacity
               S.additions[y] = yearly added capacity => used for investment
    - added checkTransfers (make sure that it is really clean < 0.1%)
    - the addedCapacity is cummulative => fix the formula for maxProd growth !!

// May 5th
   -> need to tune transers - test with and without transfers !
      seems OK ! (there was a bug in the CN:Coal->Gas transfer value)
   -> see why CN coal consumption does not seen to change ?
     This is tricky : transfer creates a capacity, but the old coal is available, hence more energy feeds more growth, and coal
     consumption is not reduced.
   -> Check the investments for Energy : do not matter much : Energy is cheap, adding 1PWh is not a big deal (1T$) 
      formulas seems OK
   THIS SHOULD BE TOLD IN BLOG AND IAMES PRESENTATION : CCEM IS A MODEL WHERE ECONOMY IS STRANGLED BY LACK OF ENERGY IN 21TH CENTURY
   WHEN WE CREATE GREEN ENERGIES, WE CREATE GROWTH BUT FOSSIL ENERGIES ARE STILL USED
  
   evening: redo all simulations for scenarios (h*) since we have changed China

// May 8th : start redirections
   - implement reinit(), so that we can do multiple runs of one scenario with different tactics
   - (1a) tEt(EU) done, crazy -> carbon tax alone = self-sacrifice for others ...
          THIS IS ALSO A KEY POINT FOR THE BLOG AND IAMES PRESENTATION
          CARBON TAX for EU ALONE DOES NOT REDUCE CO2 EMISSIONS

// May 9th: further redirections : tacx (tax), tacc (cancel), tact (transition), tacp (protectionism)
   - acceleration of cancel - NEW: cancelAcceleration only for fossil !
   - acceleration of transition
           - needs to implement a control factor for the transition (default 100%)
             trabnzitionStart, transitionFromPain  -> transitionControl

// May 10th: implement protectionism (CBAM) and display results (trade flows)
    - add tradeFlows for debug (compute in M4)
    - add carbonTaxRates(c,y) to adjust CBAM in a differential way = function (computed)

// May 11th : tune the impact on EU and CN when imports are restricted
    - EU:  missing the impact of import on MaxOut !
      CHANGE: maxout is not touched by Import BUT we add the impact when we compute gdp 
          - importReductionRatio   -> used both for need & maxout->gdp
          - exportReductionRatio
      The impact on energy has been computed already :)
    - symetrical formula : works on China exports
    NOTE: when we play with GTES, we need to add an import based on retaliation, not CO2
         => X apply the same rate for (Y -> X) than Y CBAM for (X -> Y)
    - implement a table : sample the tactic and prints the satisfaction
        tactical %,  GDP, CO2, Satisfaction, pain associated to this tactical lever
 

// May 12th
   - GW5 is officially closed
   - move to Javascript generation (project cl2js)
   
// June 9th - reopen for AXA IM presentation
-> recréer des scenarios NGFS 
    NGFS0 = Janco
    NGFS 1 = CP (2.8)
    NGFS 2 = NDG (2.1 -> 2.4 because no sequestration)

-> faire des tableaux Excel pour comparer avec NGFS
   faire tout en base 100 (2010) pour comparer les évolutions
    GDP, Oil Price (relative), Energy Consumption, Clean, temperature delta, GT emissions

Problemes à régler : commencer dans le train
(1) comprendre pourquoi h8++ n a pas plus d'impact sur les émissions de CO2
   => adapter cancel si besoin .... hypothèse 800$ de taxe carbone -> calculer le prix énegie à 300g/kWh
(2) reconstruire un Jancovici = Carbonzero avec une division par 4 des émissions en 2050
(3) on notera que CCEM ne fait pas d'hypothèse de séquestration de CO2 donc on obtient des températures plus hautes

(1) h8c : taxe uniforme a 500$/t
     -> on découvre une elasticité conservatrice = - 5% si on double, puis -30% ensuite
     -> valider que pour le petrole 500$/t -> 37$/PWh
    AHA ! la valeur n est pas la sur une tonne de carbone mais de CO2 !
    IT WORKS MUCH BETTER.
     h12: PNB: 188.1T$, 108.5PWh -> 520.9ppm CO2, 15.9C, 63.9PWh clean, 66.5% electricit
    ===>  we need to understand why h12(200%) breaks (we get a NaN, not cool)

    TRIPLE bug 
      (a) cancel augmente trop vite et passe a 1 trop tot
      (b) mais le code devrait etre safe ... corrigé dans game.cl (safe delta)
      (c) si les taxes étouffent la demande, pas clair que le prix baisse a zero.
          trouver une formule plus sympa (ou un min = prix de départ / 2)
          il suffit de multiplier par min(max(0,pRatio - 0.5) / 2,1) 

(2) ajout d'un facteur cancel dans scénario Janco
    -> fonctionne mais pas génial (terme trop faible)
    => pas vraiment utile : la taxe carbone fait le job

// conclusion de Lundi soir : il a du travail pour avoir
// (1) un bon fonctionnemenbt de la taxe carbone
// (2) des triples scénarios propres
// (2) des NGFS propres

// 15 Juin 2024 
TODO (1) creer  un NGFS0 qui marche
         - avec 70PWh de clean en 2050  -> OK
         - nécessite de faire plus de transfer  -> OK 250%
         - obtenir un run(90) qui marche  ! 

         
         - monter la demat a 2.7% par an pour NGFS (pas Janco)




      (2) refaire Janco / Nordo / Diamandis

      (3) faire les 3 NGFS

      (4) refaire les EXCEL Nordo + nouveau excel NGFS
            GDP /  Oil price
            Energy /  Clean
            Temperature / GT


 // 11 Juillet : cloture de GW5 / creation de GW6
// ================================= Start  GW6 =========================================

// August 20th
 (0) introduce KNUs (8 of them) as cones or variable coeff (for ROI)
  {model.cl} create two types of KNU : cones and factors  
    - a KNUcone generates an affine 
    - a KNUfactor generate a number or a percentage

// August 21st 
{input.cl} create the eight KNUs

{simul.cl} create a reset() function that allows to restart the simulation using values generated by the 
  KNU (cf. the tactical vector)

// August 25th: KNUs are working well + link with CLSERVE is OK !

// August 31st : resume on CCEMv6

introduce boolean DI : true -> direct use of disolve, false -> use old solve 
I should get rid of the old solve later when disolve is OK and tested
cool : it works ! temporart TESTsolve function lauches both algo and they return the exact same price :)
=> run a few of the test case

we turn DI to true and look at performance improvement => amazing - 20x faster

// September 15th
  - added decay for economies
  - added inflation (to be able to compute gdp$ in current dollars)
  - added kpi (lambdas) for the KNUs

  Main principles for growth 
  ==========================
      - work in constant dollars (smaller growth) : 2.4% in the past, more like 1% coming
      - decay is built it (1% per year, same for all zones)
      - tuning with ROI x InvestRate.
        RoI adjusted in time (factors : taxation: weight of redistribution, R&D investment, regulation)
        OCCAM principle: do not try to model RoI based on subfactors (should be explained in the paper) unless 
        enough data is available, or unless subloops identified.

// September 21st
  - goal : 0.5% energy intensity decline (demat) + additional sumSavings
     => reduce by 1/2
  - growth -> reduce world
      - introduced decay (1%) at world level
  - OCCAM : we have removed the marginImpact and use cancelImpact instead
  - add a KNU summary and run (calibrated on 9/21 !)
  - show the GDP in current dollars (inflation) 
  
// Septembre 22nd (to be continued during trips)
   - strategy: c.satisfaction = weight of the three pains (Economy, Climate, Energy)
        -> Economy Pain = Zone economy growth * health of material economy
        game.cl : code the new compurteSatisfaction function () + 
                  new economy pain function (factors material economly growth)
                  based on the growth of (Result/c.pop * (agro + steel)/wordPop)

   - tactic : (all Percentage) taxStartn,taxFromPain, transitionStart,transitionFromPain, 
                               cancelStart,cancelFromPain, 

   gtes.cl :  new file with best response (classical local opt + randomized 2opt)
   implement best response for consumer (optimize tactics to improve strategic satisfaction)
    - code satisfaction (satScore(c))
    - code bestResponse(c) => find the best tactic for a consumer

// September 28th
  - introduce India as a separate zone  
      - zones = [US, EU, CN, India, Rest], 5 x 5 trade matrix
  - we do not replace "economy" by "model" => current approach has its own merits 
    (everything related to econony/M4 is in the Block object)
  - retune using automation
      - script file
      - produces a log file "Result-date"
      - easy to compare with previous runs

// Tune energy production (M1)
  (a) new getOutput(Supplier) => use getMaxCapacity
  (b) getMaxCapacity => average over two years (to avoid oscillations)
  (c) getOutput does not go over Cmax, but at low price factor the reduction (dynMaxCapacity)
  (d) InfiniteSupplier is not changed yet

// October 5th, 61st birthday ! solved the issues with M1
  - fixed a bug in getMaxCapacity (addedCapacity, not addition)
  - 10 years average price
  - the formula that uses Inventory/threshold is a function (inventoryToMaxCapacity) and is now stepwise Affine
  - we reintroduced the quadratic behavior of getOutput (to reduce output for really low price)
          f1 := min(cMax, max(0.0, cProd * (1 + (pRatio - 1) * s.sensitivity) * pRatio))

 // TODO FOR OCTOBER
 // ===================

(1) tune BestResponse 
    - run and trace Satisfaction for a few use cases
    - debug one optimization loop
    - move to compiled code :)

(2) write the explanation of the new models 
     - on the PPT (equations)
     - in the paper (explanations)











// ====  (backlog) ======================================================================
   (a) Carbon Tax money is spent (a fraction) to subsidize green energy
   (b) we have a new pain function (game.cl) based on Sobriety (cancel), Results (gdp growth) and Warming
      TODO -> check wheat output  from 0.65 in 2010 to 0.8 in 2020
           -> introduce then the agro factor ? not clear, wheat is just a proxy, 
              https://en.wikipedia.org/wiki/List_of_countries_by_wheat_production#/media/File:World_Production_Of_Primary_Crops,_Main_Commodities.svg
          -> Delay the use of wheat in pain until GW6
    (c) introduce strategies for supplier (requires keeping economic record ... the goal is to maximize LT profits)
     would allow to simulate scarcity management







