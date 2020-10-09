
preserve	
	local list_of_variables = "allnewtotal anycert otherhours totalhours patienthours"
	
	egen speccoden = group(speccode)
	drop speccode
	foreach var of local list_of_variables {
		local l`var' : variable label `var'
	}
	gen one = 1
	collapse (rawsum) count = one (mean) `list_of_variables' price* ///
	(sum) $pooled_weight [pw=$pooled_weight], by(speccode Post)
	
	bys speccode: egen max = min(count)
	
	foreach var of local list_of_variables {
		label var `var' "`l`var''"
	}
	
	sort speccode Post
	xtset speccode Post
		
	foreach var of local list_of_variables {
	
	gen ln`var' = ln(`var')
	gen change`var' = `var' - l.`var'
	
	reg change`var' price_change_all [pw=$pooled_weight], robust
	matrix temp = e(b)
	local slope = temp[1,1]
	
	if "`var'" == "allnewtotal" | "`var'" == "anycert" {
	local slope: di %6.4f `slope'
	}
	else {
	local slope: di %4.2f `slope'
	}
	
	matrix temp = e(V)
	local se = sqrt(temp[1,1])
	if "`var'" == "allnewtotal" | "`var'" == "anycert" {
	local se: di %6.4f `se'
	}
	else {
	local se: di %4.2f `se'
	}
	
	twoway (scatter change`var' price_change_all if max > 50 [pw=$pooled_weight], mcolor(blue) msize(medlarge)) ///
	(lfit change`var' price_change_all [pw=$pooled_weight], lcolor(black) lwidth(medlarge) lpattern(solid)), ///
	xtitle(Percent Change in Medicare Reimbursement) ytitle("  Change in `: variable label `var''") ///
	legend(pos(11) lstyle(solid) ring(0) order(2) label(2 "Slope: `slope', Standard Error: `se' " ) ) xline(0) yline(0)
	
	graph export $output\pricechange_pre_post`var'.pdf, replace
	
}

	* Do Changes in Patient Hours Coincoide with Changes in Non-Patient Hours *
	reg changepatienthours changeotherhours [pw=$pooled_weight], robust
	matrix temp = e(b)
	local slope = temp[1,1]
	local slope: di %4.2f `slope'
	matrix temp = e(V)
	local se = sqrt(temp[1,1])
	local se: di %4.2f `se'
	
	twoway (scatter changepatienthours changeotherhours if max > 50 [pw=$pooled_weight] , mcolor(blue) msize(medlarge)) ///
			(lfit changepatienthours changeotherhours if max > 50 [pw=$pooled_weight], lcolor(black) lwidth(medlarge) lpattern(solid)), ///
			xtitle("Change in Non-Patient Hours") ytitle("Change in Patient Hours") xline(0) yline(0) ///
			legend(pos(7) lstyle(solid) ring(0) order(2) label(2 "Slope: `slope', Standard Error: `se' " ) ) 
	
	graph export $output\patient_versus_other_specialty.pdf, replace

restore
