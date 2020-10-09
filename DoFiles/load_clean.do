*************
* Load Data *
*************

use $data\raw_data_cts\CTS2004And2005, clear
gen wave = 4 
replace physidx = r3phyidx if !mi(r3phyidx)

append using $data\raw_data_cts\CTS2000And2001
replace wave = 3 if wave ==.

replace r2phyidx =0 if mi(r2phyidx)

gsort physidx r2phyidx
by physidx: gen temp = r2phyidx[_N]
replace physidx = temp if temp > 0
drop temp

append using $data\raw_data_cts\CTS1998And1999

replace wave = 2 if wave ==.
replace r1phyidx =0 if mi(r1phyidx)
gsort physidx r1phyidx
by physidx: gen temp = r1phyidx[_N]
replace physidx = temp if temp>0
drop temp

append using $data\raw_data_cts\CTS1996And1997

replace wave=1 if mi(wave)
rename physidx id

label define waves 1 "1996/1997" 2 "1998/1999" 3 "2000/2001" 4 "2004/2005" 5 "2008"
label values wave waves

qui compress, nocoalesce 



* Merge CPI *

preserve
	import excel $data\USinflationIndex.xls, clear firstrow
	drop if mi(wave)
	keep wave cpinormalized
	save $data\USinflationIndex.dta, replace
restore

merge m:1 wave using $data\USinflationIndex.dta, nogen
 
gen weight = 1

gen Post = (wave>1) 


gen year = 1997 if wave==1
replace year = 1999 if wave ==2
replace year = 2001 if wave ==3
replace year = 2005 if wave ==4
gen time = year - 1996

* Generate Age
rename birth birthyear
gen age = year - birthyear
drop if mi(age)

* Sample Cut One *
drop if age>85

* Manual Age Bins
gen agegroup_manual = 1 if age>=60
replace agegroup_manual = 2 if age>=45 & age <60
replace agegroup_manual = 3 if age<45


// age bins for life cycle graphs
egen agebins = cut(age), at(29 35 40 45 50 55 60 65 70 100)


* Other Variables *
replace gender = gender-1
rename grad_yr gradyear

gen time_since_grad = year - gradyear
gen time_since_grad_bins = time_since_grad if time_since <6 
replace time_since_grad_bins = 6 if time_since_grad >=6

gen Surgeon = (specx==5) if !mi(specx) 
rename specx specialty
rename nwspec specialty_detailed

* Hours Variables *
rename hrspat patienthours
rename hrsmed totalhours
gen otherhours = totalhours - patienthours
gen shareofhours = otherhours/totalhours 


* Income and Weeks Worked *
sort id wave
rename incomet income
replace income = income/1000  
replace income = income/cpinormalized
rename wkswrk weeksworked

gen wage = income/weeksworked
gen lnwage = ln(wage)


**** Winsorize ***
winsor2 totalhours patienthours otherhours income wage lnwage, cut(1 99) by(year) replace

gen logincome = ln(income)




* Taking New Patients Variables *
gen allnewmedicare = (nwmcare - 1)/3
gen allnewprivate = (nwpriv -1)/3
gen allnewmedicaid = (nwmcaid-1)/3
gen allnewtotal  = (nwmcare +nwmcaid +nwpriv -3)/9

* Certification Variable *

// Two possible certification variables: (1) bdctps which is certified in primary specialty/subspecialty.
// or 2) bdcert == any certification. If using the former, need to note that it excluded hospitalists 
// in 00/01 and 04/05, which account for 28 observations.

rename bdctps primary_certified 

gen anycert = (bdcert==1)
replace anycert = bdctany if wave==4

* Ownership Variable *
gen ownerstatus = 1 if ownpr ==1 | ownpr ==2
replace ownerstatus = 0 if ownerstatus==.

* Salaray paid *
replace salpaid = 0 if mi(salpaid)

* Own Productivity Affects Compensation *
replace sprod = 1 if mi(sprod) /* Full Owners of Solo practices were not asked this question, but obviously their productivity affects comp*/
rename sprod ownprod
label define sprodlabel 0 "No" 1 "Yes"
label values ownprod sprodlabel


* Merge in Predicted Price Changes Based on PCPS

preserve
	use "C:\Golf\Data\PSPS_prices_march2020.dta", clear
	destring specialty_detailed, replace
	tempfile temp
	save "`temp'"
restore

merge m:1 specialty_detailed using "`temp'", keep(3) nogen keepusing(*mean_cf_impact speccode)

rename specialty_detailed medicare_specialtyn
rename mean_cf_impact price_change_all


*******************
* Label Variables *
*******************

bysort id: gen balance = _N

label variable patienthours "Patient Hours"
label variable otherhours "Non-Patient Hours"
label variable totalhours "Total Hours"
label variable income "Income"
label variable ownerstatus "Full or Partial owner"
label variable allnewtotal "Taking New Patients"
label variable allnewmedicare "Taking New Medicare Patients"
label variable allnewmedicaid "Taking New Medicaid Patients"
label variable allnewprivate "Taking New Private Patients"
label variable weeksworked "Weeks Worked in Past Year"
label variable age "Age"
label variable birth "Birth Year"
label variable balance "Number of Years Respondent Sampled"
label variable gender "Gender (Male 0 Female 1)"
label define agelabels 1 "Old" 2 "Middle-Aged" 3 "Young"
label values agegroup_man agelabels
label define genderlabels 1 "Female" 0 "Male"
label values gender genderlabels
label define surgeonlabel 1 "Surgeon" 0 "Non-Surgeon"
label values Surgeon surgeonlabel
label variable weeksworked "Weeks Worked"
label define wavelabel 1 "1996/1997" 2 "1998/1999" 3 "2000/2001" 4 "2004/2005"
label values wave wavelabel
label variable anycert "Certified"
label variable allnewtotal "Taking New Patients"
label variable medicare_specialty "Specialty"
label variable price_change_all "Price Change (Conversion Factor and RVU)"
label variable salpaid "Salaried"
label variable ownprod "Own-Productivity Affects Compensation"
label variable owner "Full/Partial Owner"
