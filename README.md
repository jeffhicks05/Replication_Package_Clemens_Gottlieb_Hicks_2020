# Replication_Package_Clemens_Gottlieb_Hicks_2020

This repository contains the replication package for:

"How Would Medicare for All Affect Health System Capacity? Evidence from Medicare for Some" Tax Policy & the Economy (2020) Clemens, Gottlieb, and Hicks

Three sources of data used in the paper are publicly-available, and included in the replication package:

The Community Tracking Study Public-Use File (1996 to 2005 waves).
The National Ambulatory Medical Care Survey (2003 to 2006 waves).
One source of data, which is relied on for the majority of the paper's results, is restricted acces:

Physician/Supplier Procedure Summary (PSPS) file: These are available on the NBER internal servers.
The Community Tracking Study Restricted-Use File (1996 to 2005 waves): Interested parties can apply for access to through the contact information here: https://www.icpsr.umich.edu/web/pages/HMCA/CTSform/physician4/intro.html
Do Files:

"namcs_new_small": This constructs Table 3 of the paper from public-use NAMCS and CTS, both of which are included in the replication package for a one-click-run.

"conv_fctr_impact_spec" and "merge_PSPS_with_CTS": Construct imputed price changes caused by the 1997 Medicare conversasion factor for 46 specialty groups. To do so, specialty-level shares of surgical vs non-surgical procedures are estimated from the 1994, 1995, and 1996 PSPS files. These files are only available on NBER servers.

The remaining do files conduct the main analysis on the restricted-use CTS. The master do-file is "final_do_file" which calls the the remaining sub-do files.

The ado files for user-written packages are included, as of the versions we used (reghdfe, winsor2, ftools, gtools).

For (1), interested persons can simply download the repository, change the parent directory global at the top of each do file, then click run.

CrossWalks: We calculate implied price changes for 46 specialty categories from the PSPS public-use files. We merge these into the Community Tracking Study (restricted-used) based on their detailed specialty code of 126 categories. To do so, we manually cross-walked each CTS specialty ("specialty_detailed") to a single PSPS specialty ("medicare_speccode"). The file "new_crosswalk_medicare_cts.xls" shows this crosswalk, along with string labels for each.

Questions about the replication should be forwarded to jeffhicks05@gmail.com.

The full paper will become available here: https://www.journals.uchicago.edu/toc/tpe/current

A working paper version is available here as of October 2020: http://users.nber.org/~jdgottl/ClemensGottliebHicks.pdf
