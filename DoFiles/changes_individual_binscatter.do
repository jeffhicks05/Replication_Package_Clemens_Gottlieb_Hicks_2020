	
preserve
		
	collapse (mean) otherhours patienthours, by(Post id)
	
	xtset id Post
	

	reshape wide otherhours patienthours, i(id) j(Post)
	
	gen change_patient = patienthours1 - patienthours0
	gen change_nonpatient = otherhours1 - otherhours0
	
	egen bins = cut(change_nonpatient), group(20)
	
	collapse (mean) change*, by(bins)
	
	twoway (scatter change_patient change_nonpatient, mcolor(blue)) ///
		(lfit change_patient change_nonpatient, lcolor(black)), ///
		xtitle(Change in Non-Patient Hours) ///
		ytitle(Change in Patient Hours) legend(off)
	graph export $output/patient_versus_other_individual_binscatter.pdf, replace
	
restore	
	
	
	
