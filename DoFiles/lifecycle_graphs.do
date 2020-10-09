
preserve
	keep if wave==1

	collapse (mean)  weeksworked patienthours otherhours ///
	income totalhours anycert allnewtotal [pw=$pooled_weight], by(agebins)
	
	format anycert %9.2g
	
	drop if mi(agebins)
	
	local scale = 1.2
	
	twoway (scatter patienthours agebins, msymbol(S) msize(medlarge) mcolor(blue) ) , scale(`scale') /*
	*/ legend(off) xtitle(Age, size(medium)) ytitle(Hours, size(medium))  yscale(range(30(5)50)) ylabel(30(5)50, labsize(medium)) ///
		xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace)

	graph export $output\patienthours_lifecycle.pdf	, replace

	twoway (scatter otherhours agebins, msymbol(S) msize(medium) mcolor(blue) ), scale(`scale') /*
	*/ legend(off) xtitle(Age) ytitle(Hours) yscale(range(8(1)13)) ylabel(8(1)13, labsize(medium)) ///
		xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45)) saving(otherhours.gph, replace)

	graph export $output\otherhours_lifecycle.pdf	, replace
		
	twoway (scatter income agebins, msymbol(S) msize(medium) mcolor(blue) ), scale(`scale') /*
	*/ legend(off) xtitle(Age) ytitle("Income")   ///
		xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45)) saving(income.gph, replace) ///
		yscale(range(100(25)250)) ylabel(100(25)250, labsize(medium))
	
	graph export $output\income_lifecycle.pdf	, replace

	twoway (scatter anycert agebins, msymbol(S) msize(medium) mcolor(blue) ) , scale(`scale') /*
	*/ legend(off) xtitle(Age) ytitle(Proportion Certified) yscale(range(.4(.12)1)) ylabel(.4(.12)1, labsize(medium)) ///
		xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45)) saving(anycert.gph, replace)
	
	graph export $output\certification_lifecycle.pdf	, replace
	
	twoway (scatter allnewtotal agebins, msymbol(S) msize(medium) mcolor(blue) ), scale(`scale') /*
	*/ legend(off)  xtitle(Age) ytitle(Taking New Patients) yscale(range(.7(.025).85)) ylabel(.7(.025).85, labsize(medium)) ///
		xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45)) saving(newpatients.gph, replace)

	graph export $output\newpatients_lifecycle.pdf	, replace

	twoway (scatter totalhours agebins, msymbol(S) msize(medlarge) mcolor(blue) ), scale(`scale') legend(off) /*
	*/  xtitle(Age, size(medium)) ytitle(Hours, size(medium))  ylabel(, labsize(medium)) ///
		xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(totalhours.gph, replace)

	graph export $output\totalhours_lifecycle.pdf	, replace

	twoway (scatter weeksworked agebins, msymbol(S) msize(medlarge) mcolor(blue) ), scale(`scale') legend(off) /*
	*/  xtitle(Age, size(medium)) ytitle(Weeks Worked, size(medium))  ylabel(, labsize(medium)) ///
		xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(totalhours.gph, replace)

	graph export $output\weeks_worked_lifecycle.pdf	, replace
	
restore

***********************************
* Lifecycle Graphs by Survey Wave *
***********************************

preserve

	collapse (mean) ownprod ///
	patienthours otherhours income totalhours anycert ///
	allnewtotal ownerstatus salpaid ///
	[pw=$pooled_weight], by(agebins wave)
	
	format anycert %9.2g
	format ownprod %9.2g
	format owner %9.2g
	format salpaid %9.2g
	drop if mi(agebins)
	
	
	twoway (scatter owner agebins if wave==1, msymbol(S) msize(medlarge) mcolor(blue) ) ///
	(scatter owner agebins if wave==2, msymbol(Sh) msize(medlarge) mcolor(green) ) ///
	(scatter owner agebins if wave==3, msymbol(Dh) msize(medlarge) mcolor(red) ) ///
	(scatter owner agebins if wave==4, msymbol(Oh) msize(medlarge) mcolor(prange) ), ///
	 xtitle(Age, size(medium)) ytitle(Proportion with Ownership Stake, size(medium))  yscale(range(.2(.1).9)) ylabel(.2(.1).9, labsize(medium))  ///
	xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace) ///
	legend(pos(6) cols(4) label(1 "1996/1997") label(2 "1998/1999") label(3 "2000/2001") label(4 "2004/2005"))

	graph export $output/owner_lifecycle_bywave.pdf, replace
	
	twoway (scatter salpaid agebins if wave==1, msymbol(S) msize(medlarge) mcolor(blue) ) ///
	(scatter salpaid agebins if wave==2, msymbol(Sh) msize(medlarge) mcolor(green) ) ///
	(scatter salpaid agebins if wave==3, msymbol(Dh) msize(medlarge) mcolor(red) ) ///
	(scatter salpaid agebins if wave==4, msymbol(Oh) msize(medlarge) mcolor(prange) ), ///
	 xtitle(Age, size(medium)) ytitle(Proportion Salaried, size(medium))  yscale(range(.2(.1).9)) ylabel(.2(.1).9, labsize(medium))  ///
	xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace) ///
	legend(pos(6) cols(4) label(1 "1996/1997") label(2 "1998/1999") label(3 "2000/2001") label(4 "2004/2005"))

	graph export $output/salpaid_lifecycle_bywave.pdf, replace
	
	
	twoway (scatter ownprod agebins if wave==1, msymbol(S) msize(medlarge) mcolor(blue) ) ///
	(scatter ownprod agebins if wave==2, msymbol(Sh) msize(medlarge) mcolor(green) ) ///
	(scatter ownprod agebins if wave==3, msymbol(Dh) msize(medlarge) mcolor(red) ) ///
	(scatter ownprod agebins if wave==4, msymbol(Oh) msize(medlarge) mcolor(prange) ), ///
	 xtitle(Age, size(medium)) ytitle(Own-Productivity Affects Comp., size(medium))  yscale(range(.6(.1).9)) ylabel(.6(.1).9, labsize(medium)) ///
	xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace) ///
	legend(pos(6) cols(4) label(1 "1996/1997") label(2 "1998/1999") label(3 "2000/2001") label(4 "2004/2005"))

	graph export $output/ownprod_lifecycle_bywave.pdf, replace
			
	twoway (scatter patienthours agebins if wave==1, msymbol(S) msize(medlarge) mcolor(blue) ) ///
	(scatter patienthours agebins if wave==2, msymbol(Sh) msize(medlarge) mcolor(green) ) ///
	(scatter patienthours agebins if wave==3, msymbol(Dh) msize(medlarge) mcolor(red) ) ///
	(scatter patienthours agebins if wave==4, msymbol(Oh) msize(medlarge) mcolor(prange) ), ///
	 xtitle(Age, size(medium)) ytitle(Hours, size(medium))  yscale(range(30(5)50)) ylabel(30(5)50, labsize(medium)) ///
	xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace) ///
	legend(pos(6) cols(4) label(1 "1996/1997") label(2 "1998/1999") label(3 "2000/2001") label(4 "2004/2005"))

	graph export $output/patienthours_lifecycle_bywave.pdf, replace
	
	twoway (scatter totalhours agebins if wave==1, msymbol(S) msize(medlarge) mcolor(blue) ) ///
	(scatter totalhours agebins if wave==2, msymbol(Sh) msize(medlarge) mcolor(green) ) ///
	(scatter totalhours agebins if wave==3, msymbol(Dh) msize(medlarge) mcolor(red) ) ///
	(scatter totalhours agebins if wave==4, msymbol(Oh) msize(medlarge) mcolor(prange) ), ///
	 xtitle(Age, size(medium)) ytitle(Hours, size(medium)) ylabel(, labsize(medium)) ///
	xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace) ///
	legend(pos(6) cols(4) label(1 "1996/1997") label(2 "1998/1999") label(3 "2000/2001") label(4 "2004/2005"))
	
	graph export $output/totalhours_lifecycle_bywave.pdf, replace

	twoway (scatter otherhours agebins if wave==1, msymbol(S) msize(medlarge) mcolor(blue) ) ///
	(scatter otherhours agebins if wave==2, msymbol(Sh) msize(medlarge) mcolor(green) ) ///
	(scatter otherhours agebins if wave==3, msymbol(Dh) msize(medlarge) mcolor(red) ) ///
	(scatter otherhours agebins if wave==4, msymbol(Oh) msize(medlarge) mcolor(prange) ), ///
	xtitle(Age, size(medium)) ytitle(Hours, size(medium))  yscale(range(5(1)12)) ylabel(5(1)12, labsize(medium))  ///
	xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace) ///
	legend(pos(6) cols(4) label(1 "1996/1997") label(2 "1998/1999") label(3 "2000/2001") label(4 "2004/2005"))
	
	graph export $output/otherhours_lifecycle_bywave.pdf, replace

	
	twoway (scatter anycert agebins if wave==1, msymbol(S) msize(medlarge) mcolor(blue) ) ///
	(scatter anycert agebins if wave==2, msymbol(Sh) msize(medlarge) mcolor(green) ) ///
	(scatter anycert agebins if wave==3, msymbol(Dh) msize(medlarge) mcolor(red) ) ///
	(scatter anycert agebins if wave==4, msymbol(Oh) msize(medlarge) mcolor(prange) ), ///
	 xtitle(Age, size(medium)) ytitle(Proportion Certified, size(medium))  yscale(range(.4(.12)1)) ylabel(.4(.12)1, labsize(medium))  ///
	xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace) ///
	legend(pos(6) cols(4) label(1 "1996/1997") label(2 "1998/1999") label(3 "2000/2001") label(4 "2004/2005"))
	
	graph export $output/anycert_lifecycle_bywave.pdf, replace
	
	twoway (scatter allnewtotal agebins if wave==1, msymbol(S) msize(medlarge) mcolor(blue) ) ///
	(scatter allnewtotal agebins if wave==2, msymbol(Sh) msize(medlarge) mcolor(green) ) ///
	(scatter allnewtotal agebins if wave==3, msymbol(Dh) msize(medlarge) mcolor(red) ) ///
	(scatter allnewtotal agebins if wave==4, msymbol(Oh) msize(medlarge) mcolor(prange) ), ///
	 xtitle(Age, size(medium)) ytitle(Taking New Patients, size(medium))  yscale(range(.7(.025).85)) ylabel(.7(.025).85, labsize(medium)) ///
	xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace) ///
	legend(pos(6) cols(4) label(1 "1996/1997") label(2 "1998/1999") label(3 "2000/2001") label(4 "2004/2005"))
	
	graph export $output/newpatients_lifecycle_bywave.pdf, replace

		
	twoway (scatter income agebins if wave==1, msymbol(S) msize(medlarge) mcolor(blue) ) ///
	(scatter income agebins if wave==2, msymbol(Sh) msize(medlarge) mcolor(green) ) ///
	(scatter income agebins if wave==3, msymbol(Dh) msize(medlarge) mcolor(red) ) ///
	(scatter income agebins if wave==4, msymbol(Oh) msize(medlarge) mcolor(prange) ), ///
	 xtitle(Age, size(medium)) ytitle(Income, size(medium)) yscale(range(100(25)250))  ylabel(100(25)250, labsize(medium)) ///
	xlabel( 29 "29-34" 35 "35-39" 40 "40-44" 45 "45-49" 50 "50-54" 55 "55-59" 60 "60-64" 65 "65-69" 70 "70-85", angle(45) labsize(medium)) saving(patienthours.gph, replace) ///
	legend(pos(6) cols(4) label(1 "1996/1997") label(2 "1998/1999") label(3 "2000/2001") label(4 "2004/2005"))
	
	graph export $output/income_lifecycle_bywave.pdf, replace

restore


