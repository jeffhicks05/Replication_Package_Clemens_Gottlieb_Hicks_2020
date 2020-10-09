
* Descriptives by Panel Length
bysort balance: egen N = count(id)
replace N = N/balance

eststo clear

estpost tabstat patienthours otherhours totalhours weeksworked anycert allnewtotal ///
	income age gender ownerstatus salpaid ownprod owner N , statistics(mean) columns(statistics)  listwise by(balance) nototal

local tablenotes = " \item Means of the main variables are reported for each set of observations in a given panel length. While the panel is unbalanced, the observables are very similar across panel lengths." 
estout using $output\balance_mean.tex, unstack ///
	varlabels(, end("" \addlinespace)) mgroups(" Number of Times Observed in Panel", pattern(1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span ) ///
	cells(mean(label(Mean) fmt(2 2 2 2 2 2 0 2 2 2 2 2 0)))  replace ///
	prehead(" \begin{tabular}{l*{@E}{c}}" "\midrule") ///
	posthead(\midrule) style(tex) label nonumbers collabels(none) mlabels(none) lz ///
	prefoot(\midrule) postfoot("\midrule" "\end{tabular}"  )  

* Descriptives by Specialty *

format *hours anycert allnewtotal %9.2g

* Income and Certification *

label define temp 1 "Certified" 0 "Not Certified"
label values anycert temp

cibar income, over1(anycert) over2(agegroup_manual) over3(Surgeon) barcolor(ltblue gray) ciopts(lcolor(blue))  ///
	graphopts(ytitle("Average Income 1000s (2001 U.S.)") title("Income by Age and Certification") legend( pos(6) label(1 "Income Among Uncertified" ) label(2 "Income Among Certified")))

graph export $output\income_by_cert.pdf, replace

* Income and Own Prod *

label define temp2 1 "Own-Productivity Affects Compensation" 0 "Own Productivity Does Not Affect Compensation"
label values ownprod temp2

* Practice Type *

label define practicetype 1 "Solo/Two Physician Practice" 2 "Group (3 or more)" 3 "HMO" 4 "Medical School" 5 "Hospital based" 6 "Other"
label values prctype practicetype


label define prtype 1 "Solo Practice" 3 "Group Practice" 7 "Privately-Owned Hospital" 6 " Medical School/Univ" 2 "Two Physician Practice"
label define prtype 4 "Group Model HMO" 13 "Free-Standing Clinic" 5 "Staff Model HMO" 8 "State/local Government Hospital" 9 "State/local Government Clinic" , add
label define prtype 25 "Other" 12 "Integrated Health System" 14 "PPM" 15 "Community Health Center" 19 "Independent Contractor" 10 "State/local Government Other", add
label define prtype 17 "PHO" 21 "Foundation" 16 "MSO" 18 "Locum Tenens" 11 "Other Insurance" 20 "Employer-based Clinic", add

label values allprtp prtype

preserve

	collapse (count) count = id, by(allprtp)

	gen reverse_count = -count

	egen rank = rank(reverse_count), unique

	tempfile counts2

	save "`counts2'"

restore

merge m:1 allprtp using "`counts2'", nogen

* Counts

eststo clear

estpost tabulate allprtp, sort elabels label

local tablenotes = "\item Raw observation counts by reported practice type. If an individual appears in multiple years, with the same practice type they are counted twice."
local title = "Practice Type"
estout using $output\practice_type.tex, 	varlabels(`e(labels)', end("" \addlinespace)) cells(b(label(Count)) ) unstack replace ///
	prehead(" \begin{tabular}{l*{@E}{ccc}}" "\midrule") ///
	posthead(\midrule) style(tex) label  nonumbers mlabel("Count") collabels(none) lz ///
	prefoot(\midrule) postfoot("\midrule" "\end{tabular}"  )  


* Rounding Percentages *

preserve
	
	gen patind = 0 
	gen otherind = 0
	gen totind = 0
	
	local round = "5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100"
	
	foreach num of local round {
	
		replace patind = 1 if patienthours == `num'
		replace patind = . if patienthours ==0
		replace otherind = 1 if otherhours == `num'
		replace otherind = . if otherhours == 0
		replace totind = 1 if totalhours == `num'
		replace totind = . if totalhours == 0
	}

	fcollapse (sum) sumpat = patind sumtot = totind sumother = otherind (count) countpat = patind counttot = totind  countother = otherind
	
	gen freq1 = sumother/countother
	gen freq3 = sumtot / counttot
	gen freq2 = sumpat / countpat
	gen id = _n
	
	reshape long freq, i(id) j(type)
	label define type 1 "Non Patient Hours" 2 "Patient Hours" 3 "Total Hours"
	label values type type
	graph bar freq, over(type) ytitle(% of Responses at a Multiple of Five) bar(1, color(blue)) ylabel(0(.1)1)
	graph export $output/rounding.pdf, replace
restore	
	
