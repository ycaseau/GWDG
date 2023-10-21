// +-------------------------------------------------------------------------+
// |     Global Warming Dynamic Games (GWDG)                                      |
// |     readme                                                              |
// |     Copyright (C) Yves Caseau, 2008-2023                                |
// +-------------------------------------------------------------------------+

VERSION : V0.4

1. Project Description 
======================

<this must exist somewhere>



2. Version Description:  (V0.4)
======================

This version implements an updated CCEM model with four zones EU, US, CN and RoW
with their own economies
This is the reference version for the "IAM & Global Warming" talks


3. Installation:
===============

this is a standard module, look at init.cl in wk.

	
4. Claire files
===============

log.cl:            as usual, the log file => where to look firt to read about the current state
model.cl           data model
game.cl            The CCEM model (heart of GWDG)
simul.cl           simulation loop + utilities
input.cl           configuration file (always interpreted)
	
5. Related doc
==============
overall description may be found at http://organisationarchitecture.blogspot.com/

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

