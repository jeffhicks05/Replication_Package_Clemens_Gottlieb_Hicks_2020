eststo clear
set more off
local outcomes = "anycert patienthours otherhours totalhours allnewtotal allnewmedicare allnewmedicaid allnewprivate logincome weeksworked"

foreach var of local outcomes {

	
	***********************************
	* Combined Sample Baseline Result *
	***********************************
	
	preserve
	
			sort wave
			egen group = group(wave)
			gen time_practicing = year - yrbgn

			gen interaction = price_change_all*Post/100
		
		if "`var'" =="logincome" | "`var'" == "weeksworked" | | "`var'" == "lnwage" {
			keep if time_prac > 2
			winsor2 logincome wage lnwage, cut(5 95) by(year) replace

			replace Post = (wave >2)
			replace interaction = price_change_all*Post/100

		}
		
		eststo `var'_baseline: reghdfe `var' interaction ib1.wave price_change_all  [pw = $pooled_weight ], cluster(id) absorb(id)

			matrix temp = e(b)
			local coefb = temp[1,1]
			qui su `var' if wave==1 
			estadd scalar MeanDV = r(mean)
			
			if inlist("`var'","logincome","lnwage") {
				estadd scalar elasticity = `coefb' 
			}
			
			else {
				local el = `coefb'/`r(mean)'
				estadd scalar elasticity = `el'
			}	

	restore
	
}



*******************************
* Basline Pooled Diff-in-Diff *	
*******************************

estout totalhours_baseline patienthours_baseline otherhours_baseline allnewtotal_baseline anycert_baseline  ///
	using  $output\new_table1.tex , replace  eqlabels(none) collabels(none) ///
	keep(interaction) ///
	order(interaction) ///
	varlabels(interaction "Price Change $\times$ Post", end("" \addlinespace)) ///
	mlabels(none) ///
	cells("b(star label(Coeff.) fmt(%9.2f))" "ci(par label(SE) fmt(%9.2f))") style(tex) nolegend  /// 
	stats(N MeanDV elasticity, fmt(%9.0fc %9.2fc %9.3fc %9.3fc) labels("N" "Outcome Mean (1996/97)" "Elasticity" )) label  starlevels($stars ) ///
	prehead("\begin{tabular}{lccccc}" "\midrule" ///
	" & Total & Patient & Non-Patient & Taking & Certified \\" ///
	"& Hours & Hours & Hours & New Patients & \\ \midrule") posthead(\midrule) ///
	prefoot(\midrule) postfoot("\midrule" "\end{tabular}" ) type


estout logincome_baseline weeksworked_baseline   ///
	using  $output\new_table2.tex , replace  eqlabels(none) collabels(none) ///
	keep(interaction) ///
	order(interaction) ///
	varlabels(interaction "Price Change $\times$ Post", end("" \addlinespace)) ///
	mlabels("Log Income" "Weeks Worked", span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	cells("b(star label(Coeff.) fmt(%9.2f))" "ci(par label(SE) fmt(%9.2f))") style(tex) nolegend  /// 
	stats(N MeanDV elasticity, fmt(%9.0fc %9.2fc %9.3fc %9.3fc) labels("N" "Outcome Mean (1996/97)" "Elasticity" )) label  starlevels($stars ) ///
	prehead("\begin{tabular}{lcc}" "\midrule") posthead(\midrule) ///
	prefoot(\midrule) postfoot("\midrule" "\end{tabular}" ) type


*******************************
* Differences by Patient Type *
*******************************

estout allnewtotal_baseline allnewmedicare_baseline allnewprivate_baseline allnewmedicaid_baseline ///
	using  $output\tableA0_patienttypec.tex ,   eqlabels(none) collabels(none) replace ///
	keep(interaction) ///
	order(interaction) ///
	varlabels(interaction "Price Change $\times$ Post", end("" \addlinespace) ) ///
	mlabels("New Patients" "New Medicare"  "New Private" "New Medicaid"   ///
		, span prefix(\multicolumn{@span}{c}{) suffix(})) ///
	cells("b(star label(Coeff.) fmt(%9.3f))" "se(par label(SE) fmt(%9.3f))") style(tex) nolegend  /// 
	stats(N MeanDV elasticity, fmt(%9.0fc %9.2fc) labels("N" "Mean of Dep. Var. (1996/97)" "Implied Elasticity")) label  starlevels($stars ) ///
	prehead(" \begin{tabular}{l*{@M}{cc}}" "\midrule") posthead(\midrule) ///
	prefoot(\midrule) postfoot("\midrule" "\end{tabular}"  ) 	type
	
	


