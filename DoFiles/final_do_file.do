clear all
set more off
set scheme plotplain
pause on
set matsize 1000

**********************
* Globals and Locals *
**********************


global data = "C:\Golf\Data\" 
global output =  "C:\Golf\Results\"

gl code = "C:\Golf\DoFiles"
adopath + $code\ado
adopath + $code\ado\reghdfe


net install ftools, from($code/ado/ftools-master/ftools-master/src)
reghdfe, compile

cap log close
log using $output/full_log.scml, replace

global pooled_weight = "wtphy4" // "wtphy4 = sample weight, weight = ones (no weighting)"
global stars = "+ .1 * .05 ** .01"

************************************
* Load Data and From Panel Dataset *
************************************
include $code/load_clean.do


****************
* Descriptives *
****************
include $code/descriptives.do

************
* Scatters *	
************
include $code/scatters.do

*********************
* Lifecycle Graphs *
*********************
include $code/lifecycle_graphs.do

**************************************
*  Dynamic Difference in Difference  *
**************************************
include $code/dynamic_did.do


***************************
* Static Diff in Diff *
***************************

include $code/static_did.do
	


*************************************************
* Investment and Labor Supply Before Attrition  *
*************************************************

include $code/attrition.do


********************
* Attrition By Age *
********************

preserve

	bys id: egen maxwave= max(wave)
	gen last_period = wave == maxwave
	
	keep if wave<4
	
	collapse last_period, by(agebins)	
	
	drop if mi(agebins)
	
	twoway (scatter last_period agebins, msymbol(S) msize(large) mcolor(blue)), ///
		xtitle("Age Group", size(medium)) ytitle(Attrition Rate, size(medium)) ylabel(,labsize(medium)) legend(off) scale(1) ///
		xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-74" 75 "75-85", angle(45) labsize(medium))
		
	graph export $regressions_output\attritionbyage.pdf, replace

restore

cap log close
