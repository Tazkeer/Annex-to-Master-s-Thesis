*--------------------------------------------------
* Bangladesh 2022 - Relation Values (Pre-Test)
* 1_0_clean_Pre-Test.do
* Philipps University Marburg
*--------------------------------------------------


*--------------------------------------------------
* Program Setup
*--------------------------------------------------
clear all               
version 14              // Set Version number for backward compatibility
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
*/

*--------------------------------------------------


*--------------------------------------------------
* Description
*--------------------------------------------------
/*
 I) Donation decision 
 II) Survey
     1) Cleaning: labels, renaming of variables
     2) Merge donation decision
	 3) Generating new variables
	 
*/
*--------------------------------------------------

/*
I) Donation decision
*/
import excel "$raw_data\Donation", sheet("Experiment") clear
keep A B
foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
  replace `var'="" if _n==1
  destring `var', replace
}
drop if A == .
rename A envelope
rename B donation
save "$datapath\dhaka_2022_donation.dta" , replace




/*
II) Survey
*/
*Load raw dataset
import excel "$raw_data\hh_survey_BD_2022_translated_-_all_versions_-_English_-_2022-02-11-19-56-45", sheet("hh_survey_BD_2022_translated") clear

drop C E G BF IZ VQ ZZ ABQ AFQ AII AMW APQ ATE // only text-messages to assistants

foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
  replace `var'="" if _n==1
  destring `var', replace
}

dropmiss, force

sort A

drop in 1 // label row

gen pretest = 1









***************************************************
* Cleaning: labels, renaming and generating new variables
***************************************************
*** Rename to lower case
label define yes_no1 0 "No" 1 "Yes", replace
rename IF if2 // variables not allowed name "if"
rename *, lower



*** Rename variables
** Setup

rename a start_date
rename b end_date


label define interviewer1 1 "Tazkeer" 2 "Tamim" 3 "Imran" 4 "Sartaz" 5 "Nibir" 6 "Tasdiq" 7 "Shibly" 8 "Tahmid" 9 "Shafquat" 10 "Assitant 10" 11 "Assitant 11" 12 "Assitant 12"
encode d, generate(interviewer) label(interviewer1)
lab var interviewer "Interviewer"

encode f , generate (date)
encode h, generate(interivew_village ) 

encode j, generate(consent) label(yes_no1)

rename l time_start

rename k treatment
label define t_sc 0 "Control" 1 "Treatment", replace
label values treatment t_sc








*-------
* Module A: Socio-Demographics I
*---------
rename o name

label define female1 0 "Male" 1 "Female", replace
encode p, generate(female) label(female1)

label define marital1 1 "Never married" 2 "Married" 3 "Widowed" 4 "Divorced" 5 "Abandoned / separated" 6 "Other", replace
encode q, generate(marital) label(marital1)

label define hh_decision1 1	"Me" 2 "My spouse" 3 "Me and my spouse" 4 "Someone else" , replace
encode r , gen(hh_decision) label(hh_decision1)
rename s hh_decision_other

rename t age
rename u edu_yr

// Time at place
rename w place_living
lab var place_living "Where do you currently live?"
rename x place_living_other
encode y, gen(living_here_always) label(yes_no1)
rename z living_here_years

// Place before and reasons for moving
rename aa place_before
rename ac m_reason_movein
lab var m_reason_movein "Reason: Family (Moving in with my family)"
rename ad m_reason_hazards
lab var m_reason_hazards "Reason: Too many hazards at old place"
rename ae m_reason_conflict
lab var m_reason_conflict "Reason: Conflict with other people at place"
rename af m_reason_job
lab var m_reason_job "Reason: Better job opportunities in new place"
rename ah m_reason_other
lab var m_reason_other "Reason: Other"
foreach var in m_reason_movein m_reason_hazards m_reason_conflict m_reason_job {
lab val `var' yes_no1 	
}

// Place Home
rename aj home_village
rename ak home_district

// Religion
label define religion1 1 "Muslims" 2 "Hindus" 3	"Buddhists" 4 "Christians" 5 "Aboriginal" 6 "Other"
encode al , generate(religion) label(religion1)
rename am prayer_freq





*-------
* Module B: Climate Change Perception
*---------
label define yes_no_dk1 0 "No" 1 "Yes" 99 "Don't know"
encode ao , gen(cc_changes) lab(yes_no_dk1)
encode ap , gen(cc_move) lab(yes_no_dk1)
encode aq , gen(cc_destiny) lab(yes_no_dk1)
rename as cc_uncertain
rename at cc_agency
rename ax cc_perception1
rename ay cc_perception2
rename az cc_perception3
rename ba cc_perception4
rename bb cc_perception5
rename bc cc_perception6
rename bd cc_perception7
rename be cc_perception8





*-------
* Module C: Relational Value Scenario
*---------
rename bf start_scenario

// Willingness to donate
gen wtp = .
replace ca = "" if ce != . // if wtp > 800
destring ca, replace // destring wtp
replace ca = ce if ce != . // if wtp > 800
destring ca, replace // destring wtp
replace wtp = ca if ca != . // replace by wtp_other
replace cb = "" if ce != . // if wtp > 800
destring cb, replace // destring wtp
replace cb = ce if ce != . // replace by wtp_other
replace wtp = cb if cb != . 
lab var wtp "How much are you willing to donate?"

rename cc end_scenario
drop cd
rename cf wtp_reason
replace wtp_reason = cg if cg != ""
rename ci budget_change

// Values questions
* relational
rename cl relational_v1
rename cm relational_v2
rename cn relational_v3
rename co relational_v4

* intrinsic
rename cp intrinsic_v

* instrumental
rename cq instrumental_v

* order task
rename cs v_importance1
rename ct v_importance2
rename cu v_importance3
rename cv v_importance4

* solutions
rename cx solution1
rename cy solution2
rename cz solution3
rename da solution4














*-------
* Module D: Environmental hazards lived
*---------

// Exposure to hazards
rename dc hazard_number
encode de, gen(house_damaged) lab(yes_no1)
encode df, gen(house_destroyed) lab(yes_no1)
encode dg, gen(injured) lab(yes_no1)
encode dh, gen(injured_others) lab(yes_no1)
encode di, gen(lost_land) lab(yes_no1)
encode dj, gen(lost_livestock) lab(yes_no1)
encode dk, gen(lost_assets) lab(yes_no1)
rename dl rebuild_total_here
encode dm , gen(hazard_move) lab(yes_no1)
encode dn , gen(affected_amphan) lab(yes_no1)

// Who should help?
rename dp help_gov
rename dq help_ngo
rename dr help_rich
rename ds help_relig
rename dt help_community
rename du help_bank
rename dv help_insurance
rename dw help_family
rename dx help_friends
rename dy help_neighbors
rename dz help_none

lab var  help_gov "Government should help"
lab var  help_ngo "NGO should help"
lab var  help_rich "Rich countries who are causing the pollution should help"
lab var  help_relig "Religious Organization should help"
lab var  help_community "My local community should help"
lab var  help_bank "My Bank should help"
lab var  help_insurance "My insurance provider should help"
lab var  help_family "Family members should help"
lab var  help_friends "Friends should help"
lab var  help_neighbors "Neighbors  should help"
lab var  help_none "No one should help"


// Adaptation
encode ea, gen(adaptation) label(yes_no1)

rename ec cc_adapt_house
replace cc_adapt_house = 0 if cc_adapt_house ==.
lab var cc_adapt_house "Reinforced the house"
rename ed cc_adapt_store
replace cc_adapt_store = 0 if cc_adapt_store ==.
lab var cc_adapt_store "Store belongings on elevated level"
rename ee cc_adapt_stilts
replace cc_adapt_stilts = 0 if cc_adapt_stilts ==.
lab var cc_adapt_stilts "Rebuild on stilts"
rename ef cc_adapt_fortify
replace cc_adapt_fortify = 0 if cc_adapt_fortify ==.
lab var cc_adapt_fortify "Fortified the land"
rename eg cc_adapt_other
replace cc_adapt_other = 0 if cc_adapt_other == .
lab var cc_adapt_other "Other measure taken"
rename eh cc_adapt_other_which
lab var cc_adapt_other_which "Type of other measures taken"


// Suggested Adaptation
rename et cc_adapt_suggest1
rename eu cc_adapt_suggest2
rename ev cc_adapt_suggest3
rename ew cc_adapt_suggest4
rename ex cc_adapt_suggest5
rename ey cc_adapt_suggest6
rename ez cc_adapt_suggest7
rename fa cc_adapt_suggest_other

lab var  cc_adapt_suggest1 "Suggest: Build sea walls"
lab var  cc_adapt_suggest2 "Suggest: Plant plants and trees (i.e. mangroves)"
lab var  cc_adapt_suggest3 "Suggest: Throw up sand / stones on the beach"
lab var  cc_adapt_suggest4 "Suggest: Move away"
lab var  cc_adapt_suggest5 "Suggest: Move further into the land"
lab var  cc_adapt_suggest6 "Suggest: Other"
lab var  cc_adapt_suggest7 "Don't know"
lab var  cc_adapt_suggest_other "Suggested: Other"

foreach var in cc_adapt_suggest1 cc_adapt_suggest2 cc_adapt_suggest3 cc_adapt_suggest4 cc_adapt_suggest5 cc_adapt_suggest6 cc_adapt_suggest7 {
	lab val `var' yes_no1
}







*-------
* Module F: Migration
*---------
encode fc, generate(pref_lifestyle)
encode fd, generate(pref_place)
rename fe dhaka_stay_yrs








*-------
* Module G: Norms
*---------
encode ff, generate(norms_believe)
encode fg, generate(norms_visit_home) lab(yes_no1)
rename fh visit_home
rename fj visit_friends
rename fk get_visits






*--------
* Module H: Personal Preferences
*------------
// Agency
rename fm econ_aspiration
rename fn econ_knowledge
rename fo econ_agency1
rename fp econ_agency2
rename fq econ_agency3
rename fr econ_agency7
rename fs econ_agency8
encode ft , gen(poor) lab(yes_no1)

// Place Attachment
rename fw place_attach1
rename fx place_attach2
rename fy place_attach3

// Preferences
rename ga time
lab var time "How willing are you to give up something today in order to benefit more in the future? "
rename gc risk
lab var risk "How willing or unwilling you are to take risks?"
rename ge trust_general
lab var trust_general "Most people can be trusted"
rename gf trust_community 
lab var trust_community "Most people who live in this community can be trusted"
rename gg trust_family
lab var trust_family "I only trust people from my family"
rename gi recip_pos
rename gj recip_neg
rename gk altruism

label define commwork1 1 "Never" 2 "Couple times a year" 3 "Once a month" 4 "Once a week" 5 "Every day"
encode gl , generate(community_work) lab(commwork)
label define commworkpunish1 1 "Very unlikely" 2 "Somewhat unlikely" 3 "Neither likely nor unlikely" 4 "Somewhat likely" 5 "Very likely"
encode gm , generate(community_work_punish) lab(commworkpunish1)




*--------
* Module I: Socio-Demographics
*------------
rename go hh_member
rename gp children


lab define occupation1 1 "Government job" 2 "Non-governmental job" 3 "NGO" 4 "Business" 5 "Self employed (agriculture)" 6 "Self employed (nonagriculture)" 7 "Housewife" 8 "Unemployed" 9 "Other"
encode gq , gen(occupation) label(occupation1)
rename gr occupation_other
encode  gs , gen(occupation_spouse) label(occupation1)
rename gt occupation_spouse_other

rename gv housework_me
rename gw housework_spouse
rename gx housework_mother
rename gy housework_father
rename ha housework_other

lab var housework_me "I do housework"
lab var housework_spouse "My spouse does housework"
lab var housework_mother "My mother/mother in law does housework"
lab var housework_father "My father/father in law does housework"
lab var housework_other "Somebody else does housework"

* Income
lab define income1 1 "Less than 1,000 Taka" 2 "1,000 – 3000 Taka" 3	"3,000 – 5,000 Taka" 4 "5,000 – 10,000 Taka" 5 "10,000 – 15,000 Taka" 6	"15,000 – 20,000 Taka" 7 "More than 20,000 Taka"
encode hb , gen(income) lab(income1)
lab var income "How much do you earn per month?"
encode hc , gen(income_hh) lab(income1)
lab var income_hh "How high is your household income?"

* Eaten too little
lab define low_nutri1 4 "almost every day" 3 "almost every week" 2	"almost every month" 1 "some months but not every month" 0 "never"
encode hd, gen(low_nutri) lab(low_nutri1)

* Money spent
rename he spent_sparetime
lab var spent_sparetime "Taka spent on spare time activities (per week)"
rename hf spent_temptation
lab var spent_temptation "Taka spent on temptation goods (per week)"
rename hg spent_save
lab var spent_save "Taka put aside for later spending (per week)"



* Participate in Associations
encode hh, generate(member_assosi) lab(yes_no1)
rename hj member_neighborhood
rename hk member_district
rename hl member_migrant
rename hm member_livelihood
rename hn member_farmer
rename ho member_formal_political
rename hp member_informal_political
rename hq member_student
rename hr member_women
rename hs member_cultural
rename ht member_sport
label var member_neighborhood "Member in Neighbourhood association"
label var member_district "Member in Local district association"
label var member_migrant "Member in Migrant association"
label var member_livelihood "Member in Cooperative associated with your livelihood"
label var member_farmer "Member in Farmers association"
label var member_formal_political "Member in Formal political association"
label var member_informal_political "Member in Informal political association"
label var member_student "Member in Student association"
label var member_women "Member in Women's association"
label var member_cultural "Member in Cultural association"
label var member_sport "Member in Sport association"

foreach var in member_neighborhood member_district member_migrant member_livelihood member_farmer member_formal_political member_informal_political member_student member_women member_cultural member_sport {
	lab val `var' yes_no1
}
rename hv member_other
label var member_other "Member in other"

rename hw time_end_survey






*--------
* Module J: Donation Experiment
*------------
rename ic envelope
encode id , gen(transfer)
rename ie phone
encode if2 , gen(believe_lottery) lab(yes_no1)
encode ig , gen(donation_done) lab(yes_no1)
encode ih , gen(believe_transfer) lab(yes_no1)
rename ii time_end_experiment 

rename ik comment
lab var comment "Comments"















*---------------
* 2) Generating
*---------------

// Setup variables
* Time
gen time_sum = round((time_end_experiment - time_start) *60*24)
lab var time_sum "Total time with participan (min)"

gen time_scenario = round((end_scenario - start_scenario) *60*24)
lab var time_scenario "Time explaining scenario (until wtp) (min)"

gen time_exp = round((time_end_experiment - time_end_survey) *60*24)
lab var time_exp  "Time in experiment (min)"

rename start_date date_system

* ID
generate id = _n
lab var id "Participant ID"


*---------------
* 3) Adjust mistakes
*---------------

// Wrong envelope number in KoboCollect
replace envelope = . if envelope == 52 & interviewer == 1 & date == 5 // Taz made a mistake in writing down the envelope on the 16th
replace envelope = . if envelope == 50 & interviewer == 4 & date == 4 // Sartaz made a mistake in writing down the envelope on the 15th


// Budget change differently noted down

The question "By how many percent would you want to increase the development spending on environmental and climate change disaster management?" has been noted down differently by different interviewer: Most noted down the budget to which participants would like to change the budget; Sartaz & Taz noted down by how much they would like to change it (i.e. 0 being a budget of 4). Taz accompanied Tahmad and Assistant 10 at the 17.02. and helped them typing; therefore, also here 0 means a budget of 4. From the 18th on all interviewers were advised to note down the final budget (Sartaz missed that point and noted it down as he used to on the 18th still)
*/
replace budget_change = budget_change + 4 if /// Standardize differences between the interviewees) 
budget_change == 0 & (interviewer == 1 | interviewer == 2 | interviewer == 8 | interviewer == 10) & (date == 1 | date == 2 | date == 3 | date == 4 | date == 5 | date == 6)

replace budget_change = budget_change + 4 if /// Sartaz 0-3
budget_change < 4 & interviewer == 4 & (date == 1 | date == 2 | date == 3 | date == 4 | date == 5 | date == 6 | date == 7) 





*---------------
* 3) Merge with donation data
*---------------
merge m:1 envelope using "$datapath\dhaka_2022_donation"
drop if _merge == 2
drop _merge






*-----
* Order
*----
order ///
/*setup*/  date interviewer interivew_village treatment pretest /* id consent time_sum time_scenario time_exp ///
/*A: socioeconomics I*/ name female marital age religion prayer_freq edu_yr hh_decision hh_decision_other place_living place_living_other living_here_always living_here_years place_before m_reason_movein m_reason_hazards m_reason_conflict m_reason_job m_reason_other home_village home_district ///
/*B: CC Perception*/ cc_changes cc_move cc_destiny cc_uncertain cc_agency cc_perception1 cc_perception2 cc_perception3 cc_perception4 cc_perception5 cc_perception6 cc_perception7 cc_perception8 ///
/*C: RV scenario*/ wtp wtp_reason budget_change relational_v1 relational_v2 relational_v3 relational_v4 intrinsic_v instrumental_v v_importance1 v_importance2 v_importance3 v_importance4 solution1 solution2 solution3 solution4 ///
/*E: Exposure*/ hazard_number house_damaged house_destroyed injured injured_others lost_land lost_livestock lost_assets hazard_move affected_amphan adaptation rebuild_total_here help_gov help_ngo help_rich help_relig help_community help_bank help_insurance help_family help_friends help_neighbors help_none adaptation cc_adapt_house cc_adapt_store cc_adapt_stilts cc_adapt_fortify cc_adapt_other cc_adapt_other_which cc_adapt_suggest1 cc_adapt_suggest2 cc_adapt_suggest3 cc_adapt_suggest4 cc_adapt_suggest5 cc_adapt_suggest6 cc_adapt_suggest7 cc_adapt_suggest_other ///
/*F: Migration*/ pref_lifestyle pref_place dhaka_stay_yrs ///
/*G: Norms*/ norms_believe norms_visit_home visit_home visit_friends get_visits ///
/*H: Preferences, attitudes, personality*/ econ_aspiration econ_knowledge econ_agency1 econ_agency2 econ_agency3 econ_agency7 econ_agency8 poor place_attach1 place_attach2 place_attach3 time risk trust_general trust_community trust_family recip_pos recip_neg altruism community_work community_work_punish ///
/*I: Socio-econ*/ hh_member children occupation occupation_other occupation_spouse housework_me housework_spouse housework_mother housework_father housework_other occupation_spouse_other income income_hh low_nutri spent_sparetime spent_temptation spent_save member_assosi member_neighborhood member_district member_migrant member_livelihood member_farmer member_formal_political member_informal_political member_student member_women member_cultural member_sport member_other ///
/*J: Experiment*/ */ envelope donation phone transfer believe_lottery donation_done believe_transfer comment


keep ///
/*setup*/  date interviewer interivew_village treatment pretest id consent time_sum time_scenario time_exp ///
/*A: socioeconomics I*/ name female marital age religion prayer_freq edu_yr hh_decision hh_decision_other place_living place_living_other living_here_always living_here_years place_before m_reason_movein m_reason_hazards m_reason_conflict m_reason_job m_reason_other home_village home_district ///
/*B: CC Perception*/ cc_changes cc_move cc_destiny cc_uncertain cc_agency cc_perception1 cc_perception2 cc_perception3 cc_perception4 cc_perception5 cc_perception6 cc_perception7 cc_perception8 ///
/*C: RV scenario*/ wtp wtp_reason budget_change relational_v1 relational_v2 relational_v3 relational_v4 intrinsic_v instrumental_v v_importance1 v_importance2 v_importance3 v_importance4 solution1 solution2 solution3 solution4 ///
/*E: Exposure*/ hazard_number house_damaged house_destroyed injured injured_others lost_land lost_livestock lost_assets hazard_move affected_amphan adaptation rebuild_total_here help_gov help_ngo help_rich help_relig help_community help_bank help_insurance help_family help_friends help_neighbors help_none adaptation cc_adapt_house cc_adapt_store cc_adapt_stilts cc_adapt_fortify cc_adapt_other cc_adapt_other_which cc_adapt_suggest1 cc_adapt_suggest2 cc_adapt_suggest3 cc_adapt_suggest4 cc_adapt_suggest5 cc_adapt_suggest6 cc_adapt_suggest7 cc_adapt_suggest_other ///
/*F: Migration*/ pref_lifestyle pref_place dhaka_stay_yrs ///
/*G: Norms*/ norms_believe norms_visit_home visit_home visit_friends get_visits ///
/*H: Preferences, attitudes, personality*/ econ_aspiration econ_knowledge econ_agency1 econ_agency2 econ_agency3 econ_agency7 econ_agency8 poor place_attach1 place_attach2 place_attach3 time risk trust_general trust_community trust_family recip_pos recip_neg altruism community_work community_work_punish ///
/*I: Socio-econ*/ hh_member children occupation occupation_other occupation_spouse housework_me housework_spouse housework_mother housework_father housework_other occupation_spouse_other income income_hh low_nutri spent_sparetime spent_temptation spent_save member_assosi member_neighborhood member_district member_migrant member_livelihood member_farmer member_formal_political member_informal_political member_student member_women member_cultural member_sport member_other ///
/*J: Experiment*/ */ envelope phone donation transfer believe_lottery donation_done believe_transfer comment




***Save
save "$datapath\dhaka_2022_pretest.dta" , replace





*       *       *
* Donation Data *
*       *       *
*--------------------------------------------------
* Description
*--------------------------------------------------
/*
For 100 of all participants their decision on how much to donate and how much to keep was actually realized
*/
*--------------------------------------------------


*** Append to dataset from full data-collection
use"$datapath\dhaka_2022_clean1.dta" , clear
gen pretest = 0
append using "$datapath\dhaka_2022_pretest.dta", force
keep date pretest envelope phone donation transfer comment
save "$datapath\dhaka_2022_pretest_test.dta" , replace 

*** Merge with donation data
import excel "$raw_data\Donation&Winner", sheet("Experiment") clear
keep K
foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
  replace `var'="" if _n==1
  destring `var', replace
}
drop if K == .
rename K envelope
gen donation_drawn = 1
save "$datapath\dhaka_2022_donation_winners.dta" , replace

use "$datapath\dhaka_2022_pretest_test.dta" , clear
merge m:m envelope using "$datapath\dhaka_2022_donation_winners" // actually 1:1 but missing data due to problems above ; two draws changed as envelopes were not found [30 & 298]
replace donation_drawn = 0 if donation_drawn == .
drop _merge
sort donation_drawn envelope
order donation_drawn envelope donation transfer phone



*** Export
export excel using "C:\Users\______\XLS-Files\donation_envelope_phone.xlsx", firstrow(variables) replace













