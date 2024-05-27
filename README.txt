// +-------------------------------------------------------------------------+
// |     Global Warming Dynamic Games (GWDG)                                 |
// |     readme                                                              |
// |     Copyright (C) Yves Caseau, 2008-2024                                |
// +-------------------------------------------------------------------------+

VERSION : V0.5

1. Project Description 
======================

GWDG  is a long term project based on
- CCEM : a global earth model about the energy/economy/climate/redirection model
- GTES : evolutionary game-theoretical simulation
- Claire Server : a toolkit to produce a Go Web server for CLAIRE applications

This repository is the official repo for CCEM (Coupling Coarse Earth Models)
- each major relase has its own subdirectory 
- the current version is v0.5

CCEM Web site : http://modelccem.eu

2. Version Description:  (V0.5)
======================

Version 0.3:  2022

Version 0.4 : 2023
This version implements an updated CCEM model with four zones EU, US, CN and RoW
with their own economies
This is the reference version for the "IAM & Global Warming" talks

Version 0.5 : 2024
this version has a complete implementation of redirection, including trade protectionism (e.g.CBAM)


3. Installation:
===============

The files are provided as CLAIRE files (executable specifications) and Javascript files.
Installation notes will come later, this is still a prototype

How to use the CLAIRE files:
-----------------------------

(1) define a module in init.cl (if you have CLAIRE4 installed on your computer)
m5 :: module(part_of = claire,
              source = *where* / "gwdgv0.5",
              uses = list(Reader),
              made_of = list("model","game","simul","input"))

(2) claire4 -m m5 will run CCEM under the REPL interpreter.

How to use the Javascrip files:
-------------------------------

node gw1.js
will run one 90 years iteration of the simulation 

	
4. Claire files
===============

log.cl:            as usual, the log file => where to look firt to read about the current state
model.cl           data model
game.cl            The CCEM model (heart of GWDG)
simul.cl           simulation loop + utilities
input.cl           configuration file (always interpreted)
	
5. Related doc
==============

the updated documentation may be found on:  https://sites.google.com/view/modelccem
discussions about CCEM and its results may be found at http://organisationarchitecture.blogspot.com/

6. Data
=======

This project uses scenario files (look at oai to use a similar approach)

7.Test and run
==============

the test file is input.cl 
The test file contains the configuration
  - description of the suppliers, zones, economies
  - definition of the scenario experiments h*()
  - go* methods which simply run go(E)


To generate an excel file:
--------------------------

(1) run the desired scenario, e.g. h0()
(2) kaya("excel/filename.csv")  -> creates a csv file in the excel dir
(3) excel("excel/filename")  -> same (with 4 main KPI)

then, in Excel, use in the data section the "Get Data" with the down arrow that 
must select "From text (legacy)"
- OK for first screen
- select comma on second screen
- advanced -> select "." as decimal separator

