# CCEMv8 -- Coupling Coarse Earth Models (v0.8)

**GWDG: Global Warming Dynamic Games**
Copyright (C) 2009-2025 Yves Caseau
Reference: [http://modelccem.eu](http://modelccem.eu)

---

## 1. Overview

CCEMv8 is a system-dynamics simulation that couples five sub-models (M1-M5) to explore the interplay between **energy supply**, **energy demand**, **economic growth**, **CO2 / climate**, and **societal reaction (pain & redirection)**.  The code is written in [CLAIRE](https://github.com/ycaseau/CLAIRE4), a declarative/object-oriented language designed for combinatorial optimisation and simulation.

The simulation advances year by year (starting from an `ORIGIN` year, either 1980 or 2010) for up to 221 years (`NIT`). At each time step the five models are evaluated in sequence, producing equilibrium energy prices, GDP, CO2 emissions, global temperature, and a "pain" feedback signal that drives policy redirection.

### Key Design Principles

- **Coarse-grained**: the world is divided into 5 consumer zones and 4 energy sources.
- **Coupled feedback loops**: energy prices influence demand, which influences CO2, which causes warming, which causes pain, which triggers policy changes, which alter energy demand and prices.
- **Game-theoretic layer (GTES)**: each consumer zone has a strategy (objectives) and tactics (policy levers) that can be optimised via a best-response algorithm.
- **Key Known Unknowns (KNUs)**: the major uncertainties are explicitly modelled as parameterised cones, enabling systematic sensitivity analysis and scenario exploration.

---

## 2. File Structure

| File | Size | Purpose |
|------|------|---------|
| **model.cl** | 33 KB | Data model: all class definitions (Supplier, Consumer, Economy, Earth, etc.) and utility functions |
| **game.cl** | 60 KB | The five sub-models M1-M5: production, consumption, substitution, economy, and redirection |
| **simul.cl** | 31 KB | Simulation engine (`run`, `init`, `reinit`), initialisation, KNU scripting, and input utility functions (ETM, SETM, densityCurve, elasticityCurve) |
| **input2010.cl** | 32 KB | Data file for the 2010-origin scenario: energy data, consumer zones, economies, Earth parameters, transitions, sectors |
| **input1980.cl** | 31 KB | Alternate data file with a 1980 origin |
| **input.cl** | 28 KB | Legacy data file (CCEMv7 format, kept for reference) |
| **scenario.cl** | 43 KB | KNU cone definitions, sensitivity experiments (h1-h11), triangle scenarios (Nordhaus/Jancovici/Diamandis), NGFS scenarios, Excel export |
| **gtes.cl** | 19 KB | Game-Theoretic Evolutionary Simulation: KNU framework, best-response optimisation, 2-opt search for Nash equilibrium |
| **display.cl** | 41 KB | Text-based display of affine functions, tables, histograms, and model showback (not used in web/JS mode) |
| **web.cl** | 25 KB | Web server interface: dataset generation for plotters, slider values, callbacks, MVP scenarios |
| **plot.cl** | 5 KB | PlotTuple abstraction for chart generation |
| **log.cl** | 29 KB | Development log (changelog) |
| **init.cl** | 0.6 KB | Module declaration and compiler settings |

### Module Dependencies

```
init.cl          -- module declaration (gw1)
  model.cl       -- data model (loaded first)
  game.cl        -- sub-models M1..M5
  simul.cl       -- simulation engine + init + KNU utilities
  input2010.cl   -- scenario data (or input1980.cl)
  scenario.cl    -- experiments & KNU cones
  gtes.cl        -- game-theoretic optimisation
  display.cl     -- text display (optional, not diet)
  web.cl         -- web interface (optional)
  plot.cl        -- plot utilities
```

---

## 3. Data Model (model.cl)

### 3.1 Global Constants

| Constant | Type | Value | Meaning |
|----------|------|-------|---------|
| `ORIGIN` | integer | 2010 | Start year of the simulation |
| `NIT` | integer | 221 | Maximum number of simulation years |
| `NIS` | integer | 5000 | Number of price sample points for equilibrium search |
| `PMIN` | Price | 1.0 | Minimum energy price ($/MWh) |
| `PMAX` | Price | 2500.0 | Maximum energy price ($/MWh) |
| `CARNOT` | float | 3.0 | Heat-to-electricity conversion ratio |

Time is indexed by `Year` (1-based: year 1 = ORIGIN). The helper `year!(i)` converts index to calendar year; `yIndex(i)` does the reverse.

### 3.2 ListFunction: Affine and StepFunction

The model uses piecewise-linear (`Affine`) and step (`StepFunction`) functions extensively to represent relationships that vary over time or with a parameter. Both inherit from `ListFunction`:

```
ListFunction
  ├── Affine          -- piecewise-linear interpolation between (x,y) pairs
  └── StepFunction    -- step function (constant between breakpoints)
```

Key operations: `get(a, x)` evaluates the function, `scalarProduct`, `adds`, `boundedProduct`, `accelerate`, `improve`, `improve%`, `multiply%`.

### 3.3 Energy Supply: Supplier Hierarchy

```
Supplier (abstract)
  ├── FiniteSupplier    -- fossil fuels (Oil, Coal, Gas) with finite inventory
  └── InfiniteSupplier  -- clean energy (nuclear, solar, wind, hydro) with growth potential
```

**Key Supplier slots:**

| Slot | Type | Description |
|------|------|-------------|
| `production` | Energy | Current production level (PWh) |
| `capacityOrigin` | Energy | Max capacity at simulation start |
| `equilibriumPrice` | Affine | Expected price per MWh as a function of year |
| `investPrice` | Price | Cost (T$/PWh) to add one PWh/year of capacity |
| `co2Factor` | Percent | CO2 mass ratio (Gt CO2 per PWh) |
| `co2Kwh` | float | Grams of CO2 per kWh |
| `heat%` | Percent | Fraction used for direct heat (vs electricity) |
| `techFactor` | Percent | Annual technology improvement rate |
| `steelFactor` | Percent | Steel cost share in investment |
| `capacityFactor` | Percent | Target capacity vs market needs (default 110%) |

**FiniteSupplier** adds: `inventory` (Affine: reserves as f(price)), `capacityGrowth` (max annual growth), `threshold` (inventory level below which production is reduced).

**InfiniteSupplier** adds: `growthPotential` (Affine: max yearly capacity additions as f(year)).

### 3.4 Transitions

A `Transition` object represents the substitution path from one energy source to another (e.g., Coal -> Clean). There are 6 transitions for 4 energy sources:

| Index | From | To | Key Parameters |
|-------|------|----|----------------|
| 1 | Oil | Coal | heat%, efficiency%, adaptationFactor |
| 2 | Oil | Gas | |
| 3 | Oil | Clean | |
| 4 | Coal | Gas | |
| 5 | Coal | Clean | |
| 6 | Gas | Clean | |

Each transition specifies:
- **heat%**: fraction of transferred energy that stays as primary (heat) rather than electricity
- **efficiency%**: energy efficiency gain when transitioning (e.g., 40% for fossil-to-electric means 60% less primary energy needed)
- **adaptationFactor**: additional investment cost for adaptation (e.g., 60% extra for fossil-to-clean)

### 3.5 Sectors (new in CCEMv8)

Four energy sectors define how energy is used and how transitions happen at different speeds:

| Sector | Index | Description |
|--------|-------|-------------|
| Transport | 1 | Road, air, maritime |
| Industry | 2 | Manufacturing, mining |
| Residential | 3 | Heating, cooling, appliances |
| Others | 4 | Agriculture, services, etc. |

Each sector has an `energy%` list (weight of each energy source) and a `subMatrix` (sector-specific energy transition matrix, built via `SETM`). The zone-level substitution matrix (`ETM`) is a weighted linear combination of sector matrices, modulated by zone-specific transition speed factors.

### 3.6 Consumer Zones

```
Consumer <: thing
```

The world is divided into 5 consumer zones:

| Zone | Index | Description |
|------|-------|-------------|
| US | 1 | United States (+ Japan in some contexts) |
| EU | 2 | Europe |
| CN | 3 | China |
| IN | 4 | India |
| Rest | 5 | Rest of the World |

**Key Consumer slots:**

| Slot | Type | Description |
|------|------|-------------|
| `consumes` | list\<Energy\> | Initial consumption by energy source (4 values in PWh) |
| `eSources` | list\<Energy\> | Electricity production by primary source |
| `cancel` | Affine | Price-elasticity: fraction of demand cancelled as f(price) |
| `cancelImpact` | Affine | GDP impact of cancellation: loss fraction as f(cancel%) |
| `maxSaving` | Percent | Maximum achievable efficiency savings |
| `subMatrix` | list\<Affine\> | Substitution matrix (6 transitions, each an Affine of year -> transfer%) |
| `population` | Affine | Population growth model (billions, as f(year)) |
| `carbonTax` | ListFunction | Carbon tax as f(CO2 ppm): $/tonne CO2 |
| `disasterLoss` | Affine | GDP loss as f(temperature increase) |
| `objective` | Strategy | Game-theoretic strategy (goals) |
| `tactic` | Tactics | Policy levers (adjustable parameters) |
| `adapt` | Adaptation | Adaptation policy and efficiency curve |

### 3.7 Economy: Block and WorldClass

```
Economy <: thing
  ├── Block     -- regional economy (one per Consumer)
  └── WorldClass -- global aggregation + shared parameters
```

**Block** (regional economy) key slots:

| Slot | Type | Description |
|------|------|-------------|
| `gdp` | Price | Initial GDP in T$ |
| `startGrowth` | Percent | Initial growth rate |
| `decayTable` | Affine | Asset decay rate as f(year) |
| `iRevenue` | Percent | Fraction of GDP that is invested |
| `dematerialize` | Affine | Energy de-densification (less energy per GDP) |
| `roiEfficiency` | Affine | ROI efficiency factor as f(year) |
| `socialExpenseRatio` | Affine | Social spending share of GDP |
| `ironDriver` | Affine | Steel intensity (GDP/steel_consumption) |

**WorldClass** adds global parameters: `steelPrice`, `energy4steel`, `wheatProduction`, `agroLand`, `returnOnInvestment`, `competitivenessFactor`, `landImpact`, `lossLandWarming`, `agroEfficiency`, `bioHealth`, `cropYield`, `inflation`, etc.

### 3.8 Strategy and Tactics

**Strategy** defines goals (the "what"):
- `targetCO2`: desired CO2 emission trajectory
- `targetGDP`: desired CAGR
- `weightCO2`, `weightEconomy`, `weightPeople`: relative weights in satisfaction function

**Tactics** defines policy levers (the "how"), each driven by pain level:
- `taxFromPain`: carbon tax acceleration
- `cancelFromPain`: demand reduction acceleration
- `transitionStart` / `transitionFromPain`: energy transition speed
- `savingStart` / `savingFromPain`: efficiency investment
- `protectionismStart` / `protectionismFromPain`: trade barriers (CBAM)
- `adaptStart` / `adaptFromPain`: adaptation spending

### 3.9 Earth (Gaia)

A single `Earth` object tracks the climate system:

| Slot | Type | Description |
|------|------|-------------|
| `co2PPM` | float | Initial CO2 concentration (388 ppm in 2010) |
| `co2Ratio` | float | Fraction of emissions retained in atmosphere |
| `warming` | Affine | Temperature as f(CO2 concentration) |
| `avgTemp` | float | Starting temperature (14.53°C in 2010) |
| `avgCentury` | float | 20th century average (13.9°C) |
| `painClimate` | StepFunction | Climate pain as f(warming) |
| `painGrowth` | StepFunction | Economic pain as f(GDP growth rate) |
| `painCancel` | StepFunction | Energy pain as f(cancellation ratio) |
| `painDelay` | integer | Years of delay between pain signal and policy action (new in v8) |

### 3.10 Problem

`Problem` is the top-level simulation container (`pb` is the global singleton):

```
pb :: Problem(
  world: WorldClass,
  earth: Earth,
  transitions: list<Transition>,
  trade: list<list<Percent>>,      -- trade flow matrix
  year: integer,                    -- current simulation year
  oil: Supplier,                    -- reference energy
  clean: Supplier,                  -- clean energy reference
  priceRange: list<Price>,          -- discrete price grid for equilibrium search
  ...)
```

---

## 4. The Simulation Engine (simul.cl)

### 4.1 Initialization

`init()` prepares all simulation data structures:

1. Creates the price range (`priceRange`): 5000 price points from PMIN to PMAX on a quadratic scale
2. Initialises Charts for data recording
3. Calls `initialization()` which:
   - Sets `pb.year := 1`
   - Initialises World, Earth, all Suppliers, all Consumers (and their Block economies)
   - Consolidates the global economy

**Supplier init** (`init(s:Supplier)`): creates output/price/capacity time-series arrays, sets `heat%` from electricity production data, initialises capacities and inventories.

**Consumer init** (`init(c:Consumer)`): creates all tracking arrays (needs, consos, cancels, substitutions, savings, pain levels, etc.), computes initial electricity ratio and CO2 emissions, initialises adaptation and block economy.

### 4.2 The Main Loop: `run(p:Problem)`

Each call to `run()` advances the simulation by one year. The core sequence is:

```
run(pb):
  y := pb.year + 1

  (1) M2: getNeed(c, y) for each Consumer
        -- compute energy needs from GDP, dematerialization, disasters
        -- apply substitution transfers from previous year

  (2) For each Supplier s:
      (a) M1: computeCapacity(s, y)      -- compute max capacity
      (b) M2: disolve(pb, s)              -- find equilibrium price (dichotomy)
      (c) M2: balanceEnergy(s, y)         -- allocate production to consumers
      (d) M3: record(c, s, y)             -- record cancels, saves, substitutions, CO2
      (e) M2: recordCapacity(s, y)        -- compute energy investment from capacity growth

  (3) M4: getEconomy(y)                   -- compute GDP for all blocks
        -- checkBalance, consumes(b,y), consolidate
        -- steelPrice, agroOutput

  (4) M5: react(earth, y)                 -- CO2 levels, temperature, pain, redirection
        -- computeProtectionism, computeAdaptation
```

### 4.3 Results Display

After `iterate_run(n)` completes n years, `see()` prints a comprehensive summary: world GDP, CO2 levels, temperature, energy prices and production, consumer consumption, and zone-level economies. Charts are updated for later visualisation.

---

## 5. The Five Sub-Models (game.cl)

### 5.1 M1 -- Production Model

**Question**: *How much energy can each supplier produce at a given price?*

**Core equations** (referenced as [1]-[4] in the code):

- **[1][2] `getSupply(s, p, cMax, y)`**: production = min(cMax, projected_output * price_ratio), where `price_ratio = p / equilibriumPrice(year)`.

- **[3] `expectedCapacity` (FiniteSupplier)**: capacity tracks demand growth (via `prodGrowth`), bounded by `capacityGrowth`, and reduced when inventory drops below threshold (`inventoryToMaxCapacity`).

- **[4] `expectedCapacity` (InfiniteSupplier)**: capacity grows to match demand but is bounded by `growthPotential` (max yearly additions).

- **`reserve(s, p, y)`**: remaining inventory = f(price) - cumulative consumption.

### 5.2 M2 -- Consumption Model

**Question**: *How much energy does each zone need and consume?*

**Core equations** (referenced as [1]-[6]):

- **[1] `getNeed(c, y)`**: total need = initial_consumption * dematerialization * economyRatio * (1 - disasterRatio). Needs are distributed proportionally across energy sources, then substitution transfers from the previous year are applied.

- **[2] `dematerializationRate`**: combines structural dematerialization (service economy shift) with active efficiency savings.

- **[3] `globalEconomyRatio`**: combines local GDP growth with trade effects (exports, imports, protectionism).

- **[5] `howMuch(c, s, p)`**: actual consumption = need * (1 - cancel%). Cancellation depends on the oil-equivalent price.

- **[6] `disolve`**: dichotomic search (binary search over 5000 price points) to find the price where total demand equals supply. Returns the equilibrium price.

- **`balanceEnergy`**: once the price is found, actual production is computed and distributed proportionally to consumers.

### 5.3 M3 -- Substitution Model

**Question**: *How fast can we substitute one form of primary energy for another?*

**Core equations** (referenced as [1]-[6]):

- **[1] `record(c, s, y)`**: for each consumer-supplier pair, records actual consumption, cancellation, savings, and substitution transfers.

- **[3] `updateRate`**: monotonically updates the transfer rate for each transition. The new rate is read from the substitution matrix (`getTransferRate`) and bounded by capacity growth constraints (`applyMaxGrowthRate`). Investment costs for the transition are computed and recorded.

- **[6] `eTransferRatio`**: computes the electricity production correction when energy is transferred between sources (accounting for heat% and efficiency%).

**CCEMv8 innovation**: substitution matrices are built from sector-level transition matrices (`SETM`) combined via zone-specific weights (`ETM`). Policy modulation (`transitionFactors`) only applies after 2020 (`TransitionPivot`).

### 5.4 M4 -- Economy Model

**Question**: *What GDP is produced from investment, technology, energy, and workforce?*

**Core equations** (referenced as [1]-[7]):

- **[1] `newMaxout(b, y)`**: maximum potential GDP = previous_maxout * (1 - decay) * productionDecline + investment * RoI.

- **RoI**: `returnOnInvestment * roiEfficiency(year) * competitiveness * (1 - socialExpenseRatio)^2`.

- **[2][3] `consumes(b, y)`**: actual GDP = maxout * (1 - disasterFactor) * (1 - lossRatio) * tradeRatio. Where:
  - `disasterFactor`: GDP loss from global warming (reduced by adaptation)
  - `lossRatio`: GDP loss from energy cancellation (reduced by redistribution)
  - `tradeRatio`: trade impact from protectionism

- **[4] `productionDecline`**: productivity loss from pain (averaged over 3 years).

- **[6] `computeInvest`**: growth investment = GDP * investmentRate * (1 - lossRatio) * (1 - marginReduction) - adaptation spending + carbon tax revenue.

- **[7] `steelPrice`, `agroOutput`**: secondary models for steel prices (linked to energy costs) and agricultural production (affected by land use for clean energy, warming, and technology).

### 5.5 M5 -- Ecology & Redirection Model

**Question**: *What policy redirections should we expect from warming consequences?*

**Core equations** (referenced as [1]-[7]):

- **[1][2] `react(e, y)`**: updates CO2 concentration (additive model based on `co2Ratio`) and temperature (from `warming` affine).

- **[3][4] Pain computation**: pain = painClimate + painCancel + painResults
  - `painFromWarming`: climate pain from temperature increase (reduced by adaptation)
  - `painFromCancel`: energy pain from demand cancellation
  - `painFromResults`: economic pain from GDP growth shortfall

- **[5] `redirection`**: pain drives policy levers:
  - `taxAcceleration` = MAXTAX * taxFromPain * pain
  - `cancelAcceleration` = cancelFromPain * pain
  - `transitionFactors` = transitionStart + transitionFromPain * pain
  - `savingFactors` = savingStart + savingFromPain * pain
  - `protectionismFactor` = protectionismStart + protectionismFromPain * pain

- **CCEMv8 innovation**: `painDelay` parameter introduces a lag between pain signal and policy action.

- **[6] `computeProtectionism`**: trade barriers are set based on CO2 intensity differentials and carbon tax differentials between zones.

- **[7] `computeAdaptation`**: adaptation spending accumulates over time; its effectiveness (damage attenuation %) follows an affine curve of cumulative spending relative to expected damages.

- **Satisfaction** (`computeSatisfaction`): weighted combination of Planet (CO2 trajectory), Profit (GDP growth), and People (pain) satisfaction, discounted over time.

---

## 6. Data File Structure (input2010.cl)

The data file is organized in 4 parts:

### Part 1: Energy Supply Data

**Energy consumption by zone** (in PWh, 2010 data from "Our World in Data"):
```
USenergy2010 :: list<Energy>(9.8, 6.51, 6.4, 1.32)    -- Oil, Coal, Gas, Clean
EUenergy2010 :: list<Energy>(6.87, 3.34, 4.23, 1.51)
CNenergy2010 :: list<Energy>(5.2, 20.46, 1.08, 0.86)
INenergy2010 :: list<Energy>(1.84, 3.45, 0.545, 0.17)
RWenergy2010 :: list<Energy>(24.29, 10.35, 19.25, 3.03)
```

**Electricity sources** (in PWh): similarly broken down by zone and primary source.

**Supplier definitions** -- each is a fully parameterised object:

- **Oil** (FiniteSupplier): inventory curve 3400-7500 PWh depending on price, threshold at 80% of 2900 PWh, equilibrium price trajectory from $35/MWh (2010) to $150/MWh (2200), 6% max capacity growth.

- **Coal** (FiniteSupplier): largest reserves (8400-20400 PWh), cheapest equilibrium price ($7.7-$20/MWh), 4% max capacity growth.

- **Gas** (FiniteSupplier): reserves 2100-5100 PWh, equilibrium price $14-$40/MWh, 5% max growth.

- **Clean** (InfiniteSupplier): no finite inventory but bounded by growth potential (0.4 PWh/yr in 2010 to 7 PWh/yr in 2200), equilibrium price declining from $68 to $20/MWh.

**Transitions**: 6 transition objects created via `makeTransition(name, from, to, heat%, efficiency%, adaptationFactor)`.

**Sectors**: Transport, Industry, Residential, Others -- each with energy weights and sector-specific substitution matrices (`SETM`).

**Dematerialization curves**: zone-specific annual rates of energy intensity improvement, using `densityCurve()`:
```
USDemat :: densityCurve(2010, list(2020,1.3%), list(2050,1.2%), list(2100,1%), list(2200,0.5%))
```

**Cancellation curves**: price elasticity via `elasticityCurve(startPrice, shortTermElasticity, longTermElasticity)`:
```
USCancel :: elasticityCurve(35.0, 5%, 30%)
```

### Part 2: Consumers and Economies

**Consumer zones** (US, EU, CN, IN, Rest): each fully specified with:
- Energy consumption by source
- Strategy (objective): `strategy(targetCO2, targetGDP, weightCO2, weightEconomy)`
- Cancel and cancelImpact curves
- Population growth model
- Substitution matrix via `ETM(seed_list, sector_weights)`
- Disaster loss curve
- Carbon tax function (default: none)
- Adaptation curve
- Default tactics

**Block economies** (USeco, EUeco, CNeco, INeco, RWeco): each with:
- Initial GDP (in constant 2010 T$)
- Decay table, start growth rate
- Dematerialization curve
- ROI efficiency curve
- Social expense ratio curve
- Investment rate
- Iron (steel) driver curve

**Trade matrix**: export flows between zones, converted to % of GDP via `balanceOfTrade()`.

**WorldClass** (World): steel price, energy-for-steel curve, agricultural parameters, competitiveness factor, inflation rate, return on investment.

### Part 3: Earth (Gaia)

```
Gaia :: Earth(
    co2PPM = 388.0,           -- 2010 CO2 level
    co2Ratio = 0.0692,        -- retention ratio
    warming = affine(...),    -- CO2 -> temperature
    avgTemp = 14.53,          -- 2010 temperature
    painClimate = step(...),  -- warming -> pain
    painGrowth = step(...),   -- GDP growth -> pain
    painCancel = step(...))   -- energy cancellation -> pain
```

### Part 4: Launch

```
go(n) -> init(), iterate_run(n, true)     -- runs n years
jsmain() -> go(90), reinit(), go(90)      -- default JS entry point
```

---

## 7. Game-Theoretic Optimisation (gtes.cl)

### 7.1 KNU Framework

Two types of Key Known Unknowns:

- **KNUcone**: produces an Affine between lower/median/upper bounds (e.g., `KGreen` for clean growth potential)
- **KNUfactor**: a multiplicative scalar between lower/median/upper (e.g., `KOilGas` for fossil reserves)

Six core KNUs: `KOilGas`, `KGreen`, `KElec`, `KDamage`, `KHuman`, `KAdapt`.
Four model KNUs: `KIntensity`, `KRoI`, `KTrade`.

### 7.2 Best-Response Optimisation

The `Optimizer` (`BR`) tunes tactical parameters for a consumer to maximise its satisfaction score:

1. **Sampling**: coarse grid search over each parameter
2. **Dichotomic refinement**: binary-search style fine-tuning
3. **Pair optimisation**: jointly optimise correlated parameter pairs (e.g., transitionStart + transitionFromPain)
4. **2-opt**: random perturbation of two parameters simultaneously to escape local optima

Each evaluation requires a full simulation run (`runLoop` -> `reinit` + `iterate_run`).

---

## 8. Scenarios (scenario.cl)

### Sensitivity Experiments (h1-h11)

| ID | Tests | Key Parameter Change |
|----|-------|---------------------|
| h1+/h1- | Clean energy growth capacity | Growth potential up/down |
| h2-/h2+/h2++ | Fossil fuel reserves | Inventory curves |
| h3a/h3b/h3c/h3d | Efficiency/tech/productivity/population | Savings, techFactor, productivityFactor |
| h4-/h4+ | Energy transition speed | XtoClean substitution rates |
| h5-/h5+ | Price elasticity of cancellation | Cancel curves |
| h6-/h6+ | Dematerialization speed | Block dematerialize curves |
| h7-/h7+ | Economic growth outlook | ROI efficiency |
| h8-/h8/h8+ | Carbon tax levels | Carbon tax functions |
| h9d/h9-/h9+/h9++ | Climate damage severity | DisasterLoss curves |
| h10t/h10-/h10+ | Adaptation effectiveness | Adaptation efficiency curves |
| h11/h11+ | Trade barriers (CBAM) | Protectionism + carbon tax |

### Triangle Scenarios

- **h21 (Nordhaus)**: letting the planet warm to 3.5°C is economically optimal, with low damages and moderate carbon tax
- **h22 (Jancovici)**: aggressive decarbonisation to stay below +1.5°C, heavy carbon tax, no new fossil exploration
- **h23 (Diamandis)**: technology-driven abundance, high efficiency gains, fast clean transition

### NGFS Scenarios

- **NGFS0**: Net-Zero aligned (IRENA/IEA-like, strong dematerialization)
- **NGFS1 (Current Policies)**: business as usual
- **NGFS2 (NDC)**: nationally determined contributions with moderate carbon taxation

---

## 9. Web Interface (web.cl)

The web module generates datasets for interactive plotters and manages 15 sliders corresponding to KNUs and tactical parameters. It provides:

- **Datasets**: energy production, inventories, transitions, GDP, CO2, temperature, pain, electricity, etc.
- **Slider callbacks**: when a user moves a slider, the corresponding KNU or parameter is adjusted and the simulation is re-run
- **MVP scenarios**: pre-configured scenarios accessible from the web interface

---

## 10. Glossary

| Term | Definition |
|------|------------|
| **PWh** | Peta-Watt-hours (10^15 Wh) -- primary unit for energy |
| **T$** | Trillion dollars (constant 2010 dollars unless stated) |
| **Gt** | Gigatonnes |
| **ppm** | Parts per million (CO2 concentration) |
| **MWh** | Megawatt-hour (price unit for energy) |
| **CAGR** | Compound Annual Growth Rate |
| **KNU** | Key Known Unknown -- parameterised uncertainty |
| **GTES** | Game-Theoretic Evolutionary Simulation |
| **ETM** | Energy Transition Matrix (zone-level, built from sector SETM) |
| **SETM** | Sector Energy Transition Matrix |
| **CBAM** | Carbon Border Adjustment Mechanism |
| **Pain** | Composite index (0-100%) of societal distress from climate, energy, and economic factors |
| **Cancel** | Demand destruction due to high energy prices |
| **Dematerialization** | Decreasing energy intensity of GDP |
| **Diet** | CLAIRE compilation mode for JavaScript export (restricts language features) |
