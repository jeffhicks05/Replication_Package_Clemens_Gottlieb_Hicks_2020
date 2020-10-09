gen period = 1996 if wave == 1
replace period = 1998 if wave == 2
replace period = 2000 if wave == 3
replace period = 2004 if wave == 4

* Use just those whose first period is in 1996/1997 *

set more off

local vars = "patienthours otherhours totalhours anycert allnewtotal shareofhours"

local controls = "i.age#i.Surgeon"

local oldagecut = 60

local youngagecut = 45

local weight = "$pooled_weight"

foreach var of local vars {

	***************
	* Old Doctors *
	***************
	
	preserve

		keep if id<300000  /* Individuals whose first wave was 96/97 or 97/98 */
					
		gsort id - period
		
		by id: gen final_period = period[1]
		
		gsort id period
		
		by id: gen first_period = period[1]
		
		gen age_in_firstperiod = age if first_period==period
		
		sort id age_in_firstperiod
		
		by id: replace age_in_firstperiod = age_in_firstperiod[1]
		
		keep if age_in_firstperiod > `oldagecut'
		
		gen years_to_attrition = final_period - period
		
		keep if wave==1 | wave ==2 
		
		drop if wave==2 & first_period != 1998
		
		drop if wave==2 & final_period==2004
		
		reg `var' i.years_to_attrition `controls' [pw=`weight']
		
		count 
		
		local N = `r(N)'
		
		parmest , norestore

		keep if parm == "0b.years_to_attrition" | parm == "2.years_to_attrition" | parm == "4.years_to_attrition" | parm == "6.years_to_attrition" | parm == "8.years_to_attrition" 

		gen years_to_attrition = _n
		
		if "`var'" == "lpatienthours" | "`var'" == "patienthours" {
		local title = "Patient Hours"
		}
		if "`var'" == "ltotalhours" | "`var'" == "totalhours" {
		local title = "Total Hours"
		}
		if "`var'" == "lotherhours" | "`var'" == "otherhours" {
		local title = "Non-Patient Hours"
		}
		if "`var'" == "shareofhours" {
		local title = "Non-Patient Hours' Share of Total"
		}
		if "`var'" == "anycert" {
		local title = "Certified"
		}
		if "`var'" == "allnewtotal" {
		local title = "Taking New Patients Index"
		}
		
		graph twoway (scatter estimate years_to_attrition, msymbol(D) msize(large) mcolor(black)) (rcap min95 max95 years_to_attrition, lwidth(medthick) lcolor(blue)), ///
		title("`title': Age > 60", size(medlarge)) xscale(reverse) xtitle("Years to Attrition", size(medlarge)) ytitle("Estimated Coefficient", size(medlarge)) scale(1.3) xlabel(1 "0" 2 "2" 3 "4" 4 "8 or more", labsize(medium))  note("N = `N'") ///
		name(`var'9699, replace) legend(cols(2) pos(6) label(1 "Relative Estimate") label(2 "Confidence Interval")) yline( 0)	ylabel(,labsize(medium))

	restore

	
	**************************
	* Placebo: Young Doctors *
	**************************

	preserve

		keep if id<300000  /* Individuals whose first wave was 96/97 or 97/98 */
		
		sort id period
			
		gsort id - period
		
		by id: gen final_period = period[1]
		
		gsort id period
		
		by id: gen first_period = period[1]
		
		gen age_in_firstperiod = age if first_period==period
		
		sort id age_in_firstperiod
		
		by id: replace age_in_firstperiod = age_in_firstperiod[1]
		
		keep if age_in_firstperiod <50
		
		gen years_to_attrition = final_period - period
		
		keep if wave==1 |wave ==2 
		
		drop if wave==2 & first_period != 1998
		
		drop if wave==2 & final_period==2004
			
		reg `var' i.years_to_attrition `controls' [pw=`weight']
		
		count 
		
		local N = `r(N)'
		
		parmest , norestore
		
		keep if parm == "0b.years_to_attrition" | parm == "2.years_to_attrition" | parm == "4.years_to_attrition" | parm == "6.years_to_attrition" | parm == "8.years_to_attrition" 
		
		gen years_to_attrition = _n
		
		if "`var'" == "lpatienthours" | "`var'" == "patienthours" {
		local title = "Patient Hours"
		}
		if "`var'" == "ltotalhours" | "`var'" == "totalhours" {
		local title = "Total Hours"
		}
		if "`var'" == "lotherhours" | "`var'" == "otherhours" {
		local title = "Non-Patient Hours"
		}
		if "`var'" == "shareofhours" {
		local title = "Non-Patient Hours' Share of Total"
		}
		if "`var'" == "anycert" {
		local title = "Certified"
		}
		if "`var'" == "allnewtotal" {
		local title = "Taking New Patients Index"
		}
		
		graph twoway (scatter estimate years_to_attrition, msymbol(D) msize(large) mcolor(black)) (rcap min95 max95 years_to_attrition, lwidth(medthick) lcolor(blue)), ///
		title("`title': Age < 45", size(medlarge)) xscale(reverse) xtitle("Years to Attrition", size(medlarge)) ytitle("Estimated Coefficient", size(medlarge)) scale(1.3) xlabel(1 "0" 2 "2" 3 "4" 4 "8 or more", labsize(medium))  note("N = `N'") ///
		name(`var'9699_young, replace) legend(cols(2) pos(6) label(1 "Relative Estimate") label(2 "Confidence Interval")) yline( 0 )	ylabel(,labsize(medium))

	restore

}

* LEVELS: Old vs Young Panels: Other Hours and Share *

grc1leg shareofhours9699 shareofhours9699_young, altshrink ycommon name(share9699, replace)

grc1leg otherhours9699 otherhours9699_young, altshrink ycommon name(other9699, replace)

grc1leg other9699 share9699, rows(2) altshrink

graph export $output\otherhours_years_to_attrition_comparison9699levels.pdf, replace

* LEVELS: Old vs Young Panels: Total Hours and Patient Hours *

grc1leg totalhours9699 totalhours9699_young, altshrink ycommon name(total9699, replace)

grc1leg patienthours9699 patienthours9699_young, altshrink ycommon name(patient9699, replace)

grc1leg total9699 patient9699, rows(2) altshrink

graph export $output\patientandtotal_years_to_attrition_comparison9699levels.pdf, replace

* LEVELS: Old vs Young Panels: Investments *

grc1leg anycert9699 anycert9699_young, ycommon altshrink name(cert9699, replace) 

grc1leg allnewtotal9699 allnewtotal9699_young, altshrink ycommon name(newpatient9699, replace) 

grc1leg cert9699 newpatient9699, altshrink rows(2) 

graph export $output\investments_years_to_attrition_comparison9699.pdf, replace

