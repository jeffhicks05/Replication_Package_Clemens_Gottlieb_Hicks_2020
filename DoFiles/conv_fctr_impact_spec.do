clear all
set more off

ssc install asgen 

cd /homes/nber/djsonne/health/surg_conv_fctr

cap log close

log using logs/conv_fctr_impact_spec.log, replace 

local obs_threshold 500 // minimum number of observations required for a speciality 

forvalues yr=1994/1997 {

	use /homes/data/psps/`yr'/psps`yr'.dta, clear
	
	drop if inlist(speccode, "A0", "A1", "A2", "A3", "00")
	drop if inlist(speccode, "A4", "A5", "A6", "A7", "A8")
	
	rename hcpcs hcpcs_cd
	merge m:1 hcpcs_cd using /homes/data/betos/`yr'/betos`yr'.dta //merge with betos codes
	keep if _merge == 3
	drop _merge 
	
	bys speccode: gen obs = _N
	keep if obs >= `obs_threshold' // only keep specialties we have sufficient observations for 
	
	gen grp = substr(betos, 1, 1)
	bys speccode: egen allowed_total = sum(alowchrg)					// Total allowed amounts
	bys speccode: egen allowed_proc_temp = sum(alowchrg) if grp == "P"	// Procedure allowed amounts 
	bys speccode: egen allowed_proc = mean(allowed_proc_temp)
	bys speccode: egen allowed_prim_temp = sum(alowchrg) if grp == "M"	// E & M allowed amounts 
	bys speccode: egen allowed_prim = mean(allowed_prim_temp)
	
	replace allowed_prim = 0 if missing(allowed_prim) // E & M services are not observed for every specialty
	replace allowed_proc = 0 if missing(allowed_proc) //Procedures are not observed for every specialty
	
	gen share_proc = allowed_proc/allowed_total // surgical share
	gen share_prim = allowed_prim/allowed_total // primary care share 
	
	bys speccode: gen counter = _n
	keep if counter == 1
	keep speccode share_proc obs year share_prim
	
	gen surg_cf_chng = -10.43   // surgical conversion factor change 
	gen pr_care_cf_chng = 2.57 	// primary care conversion factor change 
	gen other_cf_chng = 8.39   	// non surgical, non primary care conversion factor change 
	
	
	gen cf_impact = (surg_cf_chng*share_proc + other_cf_chng*(1-share_proc))    // weighted average for non-primary care physicians 
	
	label var share_proc "Specialty specific surgical share `yr'"
	label var share_prim "Specialty specific primary-care share `yr'"
	label var surg_cf_chng "Conversion factor change for surgical services"
	label var pr_care_cf_chng "Conversion factor change for primary-care services"
	label var other_cf_chng "Conversion factor change for non-surgical, non-primary-care services"
	label var cf_impact "Specialty specific impact of the conversion factor changes `yr'"
	label var obs "Observations for the specific specialty `yr'"
	
	tempfile surg_share_`yr'
	save `surg_share_`yr'', replace // save the year-by-year calculations (no primary care adjustment)
		
	replace cf_impact = (surg_cf_chng*share_proc + pr_care_cf_chng*share_prim + other_cf_chng*(1 - share_proc - share_prim)) if inlist(speccode, "01", "08", "11", "37") // weighted average for primary care physicians, i.e. if general practice, family medicine, pediatric medicine, internal medicine if general practice, family medicine, pediatric medicine, internal medicine 
	
	tempfile surg_prim_share_`yr'
	save `surg_prim_share_`yr'', replace // save the year-by-year calculations (with primary care adjustment)
	
	}
	
	
*****************************************************
*create final data file with primary care adjustment*
*****************************************************

use `surg_prim_share_1997', clear
	
forvalues yr = 1994/1996 {

	append using `surg_prim_share_`yr'' // use the year-by-year calculations to create averages over all years 
	
	}
	
bys speccode: egen mean_share_proc = mean(share_proc) //average surgical shares not weighted by observations 
bys speccode: asgen w_mean_share_proc = share_proc, w(obs) // average surgical shares weighted by observations 
bys speccode: egen mean_share_prim = mean(share_prim) //average surgical shares not weighted by observations 
bys speccode: asgen w_mean_share_prim = share_prim, w(obs) // average surgical shares weighted by observations 

drop cf_impact year share_proc share_prim obs

gen mean_cf_impact = (surg_cf_chng*mean_share_proc + other_cf_chng*(1-mean_share_proc)) // weighted average for non-primary care physicians averaged over four years

replace mean_cf_impact = (surg_cf_chng*mean_share_proc + pr_care_cf_chng*mean_share_prim + other_cf_chng*(1-mean_share_proc-mean_share_prim)) if inlist(speccode, "01", "08", "11", "37") // weighted average for primary care physicians, i.e. if general practice, family medicine, pediatric medicine, internal medicine 

	
gen w_mean_cf_impact = (surg_cf_chng*w_mean_share_proc + other_cf_chng*(1-w_mean_share_proc)) // weighted average for non-primary care physicians averaged over four years

replace w_mean_cf_impact = (surg_cf_chng*w_mean_share_proc + pr_care_cf_chng*w_mean_share_prim + other_cf_chng*(1-w_mean_share_proc-w_mean_share_prim)) if inlist(speccode, "01", "08", "11", "37") // weighted average for primary care physicians, i.e. if general practice, family medicine, pediatric medicine, internal medicine 

bys speccode: gen counter = _n
keep if counter == 1 
drop counter
	
label var mean_cf_impact "Specialty specific impact of CF changes averaged over 4 years"
label var w_mean_cf_impact "Specialty specific impact of CF changes averaged over 4 years (weighted by obs)"
label var mean_share_proc "Specialty specific surgical share averaged over 4 years" 
label var w_mean_share_proc "Specialty specific surgical share averaged over 4 years (weighted by obs)" 
label var mean_share_prim "Specialty specific primary-care share averaged over 4 years" 
label var w_mean_share_prim "Specialty specific primary-care share averaged over 4 years (weighted by obs)" 

	
forvalues yr = 1994/1997 {

	merge 1:1 speccode using `surg_prim_share_`yr'', nogen // merge with the year-by-year calculations to create a single data file
	
	rename share_proc share_proc_`yr'
	rename share_prim share_prim_`yr'
	rename cf_impact cf_impact_`yr'
	rename obs obs_`yr'
	drop year
	
	}
	
merge 1:m speccode using CRS_Estimations_CF_Impact.dta
drop if _merge == 2 // for some categories the specialty for the CRS estimations could not be inferred, drop these
drop _merge 

merge 1:1 speccode using specialty_desc.dta
drop if _merge == 2 // we dont need to keep specialties that we dont have estimations for 
drop _merge 
	
label data "Surgical Share and CF Impact with Primary Care Adjustment"
	
save output/surg_prim_share_1994_1997.dta, replace 

	
********************************************************
*create final data file without primary care adjustment*
********************************************************

use `surg_share_1997', clear
	
forvalues yr = 1994/1996 {

	append using `surg_share_`yr'' // use the year-by-year calculations to create averages over all years 
	
	}
	
bys speccode: egen mean_share_proc = mean(share_proc) 		// average surgical shares not weighted by observations 
bys speccode: asgen w_mean_share_proc = share_proc, w(obs)  // average surgical shares weighted by observations 

drop cf_impact year share_proc share_prim obs

gen mean_cf_impact = (surg_cf_chng*mean_share_proc + other_cf_chng*(1-mean_share_proc)) 		// weighted average for non-primary care physicians averaged over four years
gen w_mean_cf_impact = (surg_cf_chng*w_mean_share_proc + other_cf_chng*(1-w_mean_share_proc))   // weighted average for non-primary care physicians averaged over four years


bys speccode: gen counter = _n
keep if counter == 1 
drop counter
	
label var mean_cf_impact "Specialty specific impact of CF changes averaged over 4 years"
label var w_mean_cf_impact "Specialty specific impact of CF changes averaged over 4 years (weighted by obs)"
label var mean_share_proc "Specialty specific surgical share averaged over 4 years" 
label var w_mean_share_proc "Specialty specific surgical share averaged over 4 years (weighted by obs)" 
	
	
forvalues yr = 1994/1997 {

	merge 1:1 speccode using `surg_share_`yr'', nogen // merge with the year-by-year calculations to create a single data file
	
	rename share_proc share_proc_`yr'
	rename cf_impact cf_impact_`yr'
	rename obs obs_`yr'
	drop year share_prim
	
	}
	
merge 1:m speccode using CRS_Estimations_CF_Impact.dta
drop if _merge == 2 // for some categories the specialty for the CRS estimations could not be inferred, drop these
drop _merge 

merge 1:1 speccode using specialty_desc.dta
drop if _merge == 2 // we dont need to keep specialties that we dont have estimations for 
drop _merge 
	
label data "Surgical Share and CF Impact without Primary Care Adjustment"

save output/surg_share_1994_1997.dta, replace 

log close
