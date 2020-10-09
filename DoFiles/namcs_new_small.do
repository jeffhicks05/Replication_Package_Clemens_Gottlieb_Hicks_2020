set scheme plotplain
set more off
pause on
clear all

***************
* Directories *
***************

global parent = "C:\Users\jeffh\Dropbox\ResearchProjects\HumanCapitalDoctors\golf"
global input = "$parent\Data\"
global crosswalks ="$parent\Data\crosswalks"
global output = "$parent\Results\NAMCS_New"
global prices = "$parent\Data\PSPS_weights"

************************
* Load and Append Data *
************************


use $input\NAMCS\namcs2003.dta, clear

	ds diag*
	foreach var in `r(varlist)' {
		cap	tostring `var', replace		
	}
	
forvalues year = 2003(1)2015 {
	preserve
		use $input\NAMCS\namcs`year'.dta, clear
		ds diag*
		foreach var in `r(varlist)' {
			cap	tostring `var', replace		
		}
		tempfile temp
		save "`temp'", replace
	restore
	
	append using "`temp'", force

}

replace vyear = 1996 if vyear == 96
replace vyear = 1995 if vyear == 95
replace vyear = 1994 if vyear == 94
replace vyear = 1993 if vyear == 93
replace vyear = year if mi(vyear)

**************
* Data Clean *
**************


keep if year > 2002

//medicaid
gen payment_group = 1 if paytype == 3 | paytyper == 3

// medicare
replace payment_group = 2 if paytype == 2 | paytyper == 2
// private
replace payment_group = 3 if  inlist(paytype, 1, 5) | inlist(paytyper,1,5)
	   
gen accepting_new_patients = aceptnew == 1
gen accepting_new_medicaid = nmedcaid ==1
gen accepting_new_medicare = nmedcare ==1
// three forms of private insurance in NACMS
gen accepting_new_private = capitate == 1 | nselfpay == 1 | nocap == 1


**********************************
* Averages Between 2003 and 2006 *
**********************************

preserve

	keep if inrange(year,2003,2006)
	
	// small fraction of other types (such as workers comp, and unindentied payment source)
	drop if mi(payment_group)
	
	reghdfe timemd [aw = patwt], absorb(diag13d payment_type_fe = payment_group) residual(time_resid)
	replace time_resid = timemd + payment_type_fe
	
	gcollapse (mean) timemd time_resid (rawsum) sum = patwt [aw=patwt], by(payment_group)
	
	gegen total = total(sum) 
	gen frac_visits = sum / total
	
	drop sum total
	
	tempfile time_mean 
	save "`time_mean'"
	
restore

preserve

	keep if inrange(year,2003,2006)
	
	drop if mi(payment_group)
	
	reghdfe timemd [aw = patwt], absorb(diag13d payment_type_fe = payment_group) residual(time_resid)
	replace time_resid = timemd + payment_type_fe
	
	gcollapse (mean) timemd time_resid [aw=patwt]
	gen payment_group = 4
	
	gen frac_visits = 1
	
	tempfile time_mean2 
	save "`time_mean2'"
	
restore

count if !mi(payment_group) & inrange(year,2003,2006)
local Nvisits = `r(N)'
gunique phycode year if !mi(payment_group) & inrange(year,2003,2006)
local Nphys_namcs = `r(unique)'


preserve
	// physician weights not present until later in the sample. 
	// use unweighted at physician level.
	
	keep if inrange(year,2003,2006)
	
	gen accepting4 = aceptnew == 1
	gen accepting1 = nmedcaid ==1
	gen accepting2 = nmedcare ==1
	// three forms of private insurance in NACMS
	gen accepting3 = capitate == 1 | nselfpay == 1 | nocap == 1	
	
	gcollapse (mean) accepting1 accepting2 accepting3 accepting4
	
	gen id =1 
	reshape long accepting , j(payment_group) i(id)
	drop id
	
	rename accepting accepting_NAMCS
	
	merge 1:1 payment_group using "`time_mean'", nogen
	merge 1:1 payment_group using "`time_mean2'", nogen update
	
	tempfile NAMCS
	save "`NAMCS'"
	
restore

cap frame drop NAMCS_results
frame create NAMCS_results
frame change NAMCS_results

use "`NAMCS'", clear 



******************************
* Load CTS Data for Averages *
******************************

cap frame change default

*** Append CTS Data Sets
use $input\CTS_PublicUse\CTS1996And1997.dta, clear
append using $input\CTS_PublicUse\CTS1998And1999.dta
append using $input\CTS_PublicUse\CTS2000And2001.dta
append using $input\CTS_PublicUse\CTS2004And2005.dta


*********************************
* Taking New Patients Variables *
*********************************

gen accepting1 = inlist(NWMCAID,2,3,4) 
gen accepting2 = inlist(NWMCARE,2,3,4) 
gen accepting3 = inlist(NWPRIV,2,3,4) 
gegen accepting4 = rowmax(accepting*)

// Physician level data - weights corresponds yo physician

count
local Nphys_cts = `r(N)'

gcollapse (mean) accepting*  [aw = PHYSIDX]

gen id =1 
reshape long accepting , j(payment_group) i(id)
drop id

rename accepting accepting_CTS
	
tempfile CTS
save "`CTS'"

frame change NAMCS_results
merge 1:1 payment_group using "`CTS'", nogen

order payment_group accepting_CTS accepting_NAMCS frac_visits timemd time_resid 

xpose, clear varname

rename v1 Medicaid
rename v2 Medicare
rename v3 Private
rename v4 All
rename _varname variable
drop if variable == "payment_group"

gen N = `Nvisits' if inlist(variable, "timemd", "time_resid", "frac_visits")
replace N = `Nphys_namcs' if variable == "accepting_NAMCS"
replace N = `Nphys_cts' if variable == "accepting_CTS"


mkmat Medicaid Medicare Private All N, rownames(variable) matrix(results)

estout matrix(results, fmt(2 2 2 2 0)) using $output/descriptives_NAMCS_CTS.tex, replace type substitute("accepting_CTS" "\hspace{4mm} Accepting New Patients" "accepting_NAMCS" "\hspace{4mm} Accepting New Patients" "frac_visits" "\hspace{4mm} Fraction of Visits" "timemd" "\hspace{4mm} Mean Visit Length" "time_resid" "\hspace{4mm} Mean Visit Length Adjusted" "count" "N (Physicians or Visits)") eqlabel(none) mlabel(none) style(tex) prehead("\begin{tabular}{lccccc} \toprule") postfoot("\bottomrule \end{tabular}") refcat(accepting_CTS "CTS (1996 to 2005)" accepting_NAMCS "NAMCS (2003 to 2006)", nolabel)


* Output Table *


/*
*****************************
* Average Time Use By NAMCS *
*****************************


binscatter medicaid medicare other_payment year [aw = patwt], discrete line(connect) xtitle(Year) ytitle(Fraction) ///
legend(pos(6) cols(1) label(1 "Medicaid") label(2 "Medicare") label(3 "Other (Private)")) xlabel(#15) 

graph export $output/payment_group_types.pdf, replace


binscatter timemd year [aw = patwt], discrete line(connect) xtitle(Year) ytitle(Average Visit Length) by(payment_group) ///
legend(pos(6) cols(1) label(1 "Medicaid") label(2 "Medicare") label(3 "Other (Private)")) xlabel(#15)
graph export $output/time_use_by_payment_group.pdf, replace

reghdfe timemd [aw = patwt], absorb(diag13d payment_type_fe = payment_group) residual(resid)
replace resid = timemd + payment_type_fe
binscatter resid year [aw = patwt], discrete line(connect) xtitle(Year) ytitle(Average Visit Length Residualized) by(payment_group) ///
legend(pos(6) cols(1) label(1 "Medicaid") label(2 "Medicare") label(3 "Other (Private)")) xlabel(#15) 
graph export $output/time_use_by_payment_group_residual.pdf, replace

binscatter resid year [aw = patwt], discrete line(connect) xtitle(Year) ytitle(Average Visit Length Residualized) by(sex) ///
legend(pos(6) cols(1) ) xlabel(#15) 
graph export $output/time_use_by_gender_residual.pdf, replace
*/




