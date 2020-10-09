
local scale = 1.1 

set more off
*Levels*
foreach yvar in anycert allnewtotal totalhours patienthours otherhours {

preserve 
		sort wave
		egen group = group(wave)

		xtset id group
		tabulate wave, gen(w)
		gen i2 = w2*price_change_all/100
		gen i3 = w3*price_change_all/100
		gen i4 = w4*price_change_all/100
				
		eststo dyn_`yvar': qui reghdfe `yvar' ib1.wave i2 i3 i4 ///
		 price_change_all   [pw = $pooled_weight ], ///
		cluster(id) absorb(id)
		
		parmest, format(estimate %08.2g min95 %08.2g max95 %08.2g) norestore

		if "`yvar'" == "anycert"  local title "Board Certification"
		else if "`yvar'" == "allnewtotal"  local title "Taking New Patients"		
		else if "`yvar'" == "newmedicare" local title "Taking New Medicare Patients"	
		else if "`yvar'" == "newmedicaid" local title "Taking New Medicaid Patients"
		else if "`yvar'" == "newprivate" local title "Taking New Private Patients"
		else if "`yvar'" == "totalhours"  local title "Total Hours"	
		else if "`yvar'" == "patienthours" local title "Patient Care Hours"
		else if "`yvar'" == "otherhours"  local title "Non-Patient Hours"

		**** Make dynamic DD graph
		
		drop dof t p stderr
	
		keep if parm=="i2" | parm=="i3" | parm=="i4" | parm == "2.wave"

		replace parm = "i1" if parm == "2.wave"
		replace estimate = 0 if parm == "i1"
		replace min95 = 0 if parm == "i1"
		replace max95 = 0 if parm == "i1"
		
		gen period = real(substr(parm,2,2))
		
		label var period "Year"

		graph twoway scatter estimate period, msymbol(S) msize(large) mcolor(black) || ///
			rcap min95 max95 period, lwidth(medthick) lcolor(blue)  ///
		 xline(1.8, lpattern(dash) lwidth(medthick)) ///
		 yline(0, lpattern(dash) lwidth(medthick)) ///
			xlabel(1 "96-97" 2 "98-99" 3 "00-01" 4 "04-05"  , labsize(medium))  ///
		 ytitle("Estimated DD Coefficient", size(medium)) ///
		 xtitle(Year, size(medlarge) ) ///
			legend(on pos(6) col(2) size(medium) order(1 "Estimated Effect of Fee Change" 2 "95% Confidence Interval"))  ///
		ylabel(#5, labsize(medium))  scale(`scale')
	
		graph export $output\dyn_`yvar'_cf_and_rvu.pdf, replace

restore

}



* Income and Weeks Worked *
set more off
foreach yvar in logincome weeksworked {

	preserve 
			sort wave
			egen group = group(wave)
			gen time_practicing = year - yrbgn
			keep if time_practicing > 2

			xtset id group
			tabulate wave, gen(w)			

			winsor2 logincome lnwage, cut(5 95) by(year) replace

			gen i1 = w1*price_change_all/100
			gen i3 = w3*price_change_all/100
			gen i4 = w4*price_change_all/100
			
	
			sort id year
								
			replace price_change_all = price_change_all/100
			
			eststo dyn_`yvar': qui reghdfe `yvar' ib2.wave i1 i3 i4  price_change_all ///
			  [pw = $pooled_weight ], ///
			 cluster(id) absorb(id)
			
			parmest, format(estimate %08.2g min95 %08.2g max95 %08.2g) norestore
			
			drop dof t p stderr
			
			keep if inlist(parm,"i1", "i2", "i3", "i4", "2b.wave")
			
			replace parm = "i2" if parm == "2b.wave"
	
			sort parm
			gen period = _n
			
			label var period "Year"

			graph twoway scatter estimate period, msymbol(S) msize(large) mcolor(black) || ///
				rcap min95 max95 period, lwidth(medthick) lcolor(blue)  ///
			 xline(2.5, lpattern(dash) lwidth(medthick)) ///
			 yline(0, lpattern(dash) lwidth(medthick) ) xlabel(1 "95" 2 "97" 3 "99" 4 "03"  , labsize(medium))  ///
			 ytitle("Estimated DD Coefficient", size(medium)) ///
			 xtitle(Year, size(medlarge) ) ///
			legend(on pos(6) col(2) size(medium) order(1 "Estimated Effect of Fee Change" 2 "95% Confidence Interval"))  ///
			ylabel(#5, labsize(medium))  scale(`scale') 
			
			graph export $output\dyn_`yvar'_cf_and_rvu.pdf, replace

	restore

}

