******************************************
* Robustness check 
******************************************

*--------------------------------------------------
* Program Setup
*--------------------------------------------------
clear all               
version 14            // Set Version number for backward compatibility
set more off            
set linesize 80         
macro drop _all        
set matsize 2000
* -------------------------------------------------


/* 

Including relval in the model for wtp 

*/

reg wtp treatment relval female age marital edu_yr household_income distance, r  

eststo rw1

*** Including relval in the model for donation ***

reg donation treatment relval female age marital edu_yr household_income distance, r  

eststo rd1


outreg2 [a5 rw1 b5 rd1] using "output_robust_wtp_donation.doc",addstat("Adjusted R2", e(r2_a)) replace



/* 

Subsample as a Robustness check 

*/

gen rand = runiform()  //Generate a random number for each observation

sort treatment rand   //sort in ascending order
gen id2 = _n if treatment ==0
replace id2 =0 if treatment ==1

gsort -treatment rand // sort in descending order
gen id3 =_n if treatment ==1
replace id3 =0 if treatment ==0

gen id_rand = id2 + id3


drop if id_rand >50

tab treatment

*** Regression with subsample ***

reg wtp treatment female age marital edu_yr  household_income distance, r 
eststo sub_wtp1
outreg2 [a5 sub_wtp1] using "output_robust.doc",addstat("Adjusted R2", e(r2_a)) replace


reg donation treatment female age marital edu_yr  household_income distance, r
eststo sub_don1
outreg2 [a5 sub_don1] using "output_robust.doc",addstat("Adjusted R2", e(r2_a)) replace

outreg2 [a5 sub_wtp1 b5 sub_don1] using "output_robust.doc",addstat("Adjusted R2", e(r2_a)) replace







