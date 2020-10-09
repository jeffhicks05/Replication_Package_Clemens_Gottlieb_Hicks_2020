
gl parent = "C:\Users\jeffh\Dropbox\ResearchProjects\HumanCapitalDoctors\golf\Data\"
import excel $parent\crosswalks\new_crosswalk_medicare_cts.xlsx, firstrow clear

rename medicare_speccode speccode

merge m:1 speccode using $parent\PSPS_weights\output\surg_share_1994_1997.dta, keep(1 3)

save $parent\PSPS_weights\PSPS_prices_march2020.dta, replace
