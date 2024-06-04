******************************************
* Analyses
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


*--------------------------------------------------
* Directory
*--------------------------------------------------
/*  Please set up your directory here 
global workpath	"C:\Users\________\STATA\DO-Files"
global datapath	"C:\Users\_________\STATA\DTA-Files"
global output	"C:\Users\__________\STATA\Output"
global raw_data	"C:\Users\___________\STATA\XLS-Files"
*/*--------------------------------------------------

*--------------------------------------------------
* Installation
*--------------------------------------------------
ssc install outreg2
ssc install asdoc


*--------------------------------------------------
* Description
*--------------------------------------------------
/*
 I) Descriptive Statistics
 II) Analyses
     Including regression,Correlation, Principal Component Analysis (PCA), Diagnostic/Post-estimation tests
*/
*--------------------------------------------------



/* 
I. Descriptive Statistics 
[Please note that the results will be taken and made into a table using excel]
*/

asdoc sum wtp treatment relational_v1 relational_v2 relational_v3 relational_v4 age female marital edu_yr distance donation, detail save(descriptive.doc) replace
* Please note that these are not conclusive for the descriptive statistics table, and that more are to be added later when variables are created, for example relval , household_income, wtp100 and hypothetical_bias.

/* 
II. Analyses
*/


asdoc reg wtp treatment,r save(Reg1.doc)

reg wtp treatment  relational_v1 relational_v2 relational_v3 relational_v4,r 


	
egen relval_control= mean(relational_v1 + relational_v2 + relational_v3 + relational_v4) if treatment==0 //mean relval for control group
egen relval_treatment= mean(relational_v1 + relational_v2 + relational_v3 + relational_v4) if treatment==1 //mean relval for treatment group
sum relval_control relval_treatment


*** Principal Component Analysis (PCA) ***

pca relational_v1 relational_v2 relational_v3 relational_v4
scree // available in Appendix
predict relval //only one component is retained as eigenvalues ≥ 1 only for one. 
sum relval, detail //For Descriptive Statistic Table
hist relval 



*** mean income levels for each level ***
gen income_level=0
replace income_level=500 if income==1 
replace income_level=2000 if income==2 
replace income_level=4000 if income==3 
replace income_level=7500 if income==4 
replace income_level=12500 if income==5 
replace income_level=17500 if income==6
replace income_level=21000 if income==7

gen household_income=0
replace household_income=500 if income_hh==1 
replace household_income=2000 if income_hh==2 
replace household_income=4000 if income_hh==3 
replace household_income=7500 if income_hh==4 
replace household_income=12500 if income_hh==5 
replace household_income=17500 if income_hh==6
replace household_income=21000 if income_hh==7

sum household_income, detail //For Descriptive Statistic Table

*******  wtp model *******

ttest wtp, by (treatment)

reg wtp treatment,r
eststo a1
reg wtp treatment relval , r
reg wtp treatment female, r 
eststo a2
reg wtp treatment female age , r  
eststo a3
reg wtp treatment female age marital , r 
reg wtp treatment female age marital edu_yr,r
reg wtp treatment female age marital edu_yr income_level, r  
estat vif
reg wtp treatment  female age marital edu_yr household_income, r 
eststo a4
estat vif

pwcorr distance cc_changes hazard_number //distance as a proxy

reg wtp treatment female age marital edu_yr household_income distance, r  //***sig : treatment household_income distance
eststo a5
estat vif
estat ovtest // Ramsey RESET Test
esttab a*

outreg2 [a1 a2 a3 a4 a5] using "output_wtp.doc",addstat("Adjusted R2", e(r2_a)) replace
 
 
 
*** Mann Whitney U-Test to assess potential differences in sociodemographic characteristics between control and treatment group ****
ranksum age , by (treatment) exact
ranksum female , by (treatment) exact 
ranksum marital , by (treatment) exact
ranksum edu_yr , by (treatment) exact
ranksum household_income , by (treatment) exact
ranksum distance , by (treatment) exact


*** Deeper analysis to understand the distance results in relation to wtp ***
gen wtp_cat = .
replace wtp_cat = 1 if wtp == 0
replace wtp_cat = 2 if wtp > 0 & wtp < 60
replace wtp_cat = 3 if wtp >= 60  & wtp < 150
replace wtp_cat = 4 if wtp >= 150

cibar wtp_cat, over1 (treatment)
ttest wtp_cat, by(treatment)


asdoc ologit wtp_cat i.treatment##c.distance female age marital edu_yr household_income,r save(ologit_wtp.doc) replace

asdoc margins, dydx(distance) at(treatment=(0 1)), save(ologit_wtp.doc)

asdoc sum household_income if wtp<60
asdoc sum household_income if wtp>60




*******  donation model *******
ttest donation, by (treatment)

reg donation treatment,r
eststo b1
reg donation treatment relval, r //using relval derived from pca
reg donation treatment female, r 
eststo b2
reg donation treatment female age , r // age and female are sig 
eststo b3
reg donation treatment female age marital , r //female sig
reg donation treatment female age marital edu_yr , r // female and edu sig
reg donation treatment female age marital edu_yr  household_income , r 
eststo b4
reg donation treatment female age marital edu_yr  household_income distance, r //**sig: female edu_yr
eststo b5

estat vif
estat ovtest // Ramsey RESET Test

esttab b*

outreg2 [b1 b2 b3 b4 b5] using "output_donation.doc",addstat("Adjusted R2", e(r2_a)) replace


cibar donation, over(female)
cibar donation, over(edu_yr )
tab donation
hist donation

sum donation if treatment == 0 // to gain insights into donation of the control group
sum donation if treatment == 1 //  to gain insights into donation of the treatment group

/*
***Number 7.6 : Heterogenous effects
egen relval_median= median(relval)

reg wtp treatment relval age female marital edu_yr household_income distance if relval > relval_median, r

reg wtp treatment relval age female marital edu_yr household_income distance if relval < relval_median, r


reg donation treatment relval age female marital edu_yr household_income distance if relval > relval_median,r

reg donation treatment relval age female marital edu_yr household_income distance if relval < relval_median,r


tab wtp
hist wtp
hist wtp if wtp<200



reg wtp income,r 
gen lnincome = log(income_level)

reg wtp lnincome,r
*/


*** Hypothetical bias ***

gen wtp100=wtp
replace wtp100=100 if wtp>=100
sum wtp100, detail //For Descriptive Statistic Table

gen hypothetical_bias = wtp100-donation
sum hypothetical_bias, detail //For Descriptive Statistic Table

asdoc reg hypothetical_bias treatment age female marital edu_yr household_income distance, r save(hypothetical_bias.doc)

reg wtp treatment age female marital edu_yr household_income , r
reg donation treatment age female marital edu_yr household_income , r


hist donation
reg donation treatment age female marital edu_yr household_income if donation>0, r
reg donation treatment age female marital edu_yr household_income, r

*** Hurdle model ***

asdoc churdle linear donation treatment female age marital edu_yr household_income distance, select (female edu_yr household_income distance) ll(0) save(output_hurdle.doc)

reg relval treatment,r
eststo rr1

reg relval treatment female age marital edu_yr  household_income,r
eststo rr2

reg relval treatment female age marital edu_yr  household_income distance,r
eststo rr3

outreg2 [rr1 rr2 rr3] using "output_reg_relval.doc",addstat("Adjusted R2", e(r2_a)) replace


