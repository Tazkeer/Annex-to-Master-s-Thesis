*--------------------------------------------------
*  Relation Values
* 1_0_clean.do
* Author: Tazkeer Azeez Chaudhuri
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
*/*--------------------------------------------------

/*Tazkeer(Laptop)
global workpath(do) "F:\Philipps University of Marburg\Semester 6_Thesis\New Topic\STATA\TAZ\Do Files"
global datapath (dta) "F:\Philipps University of Marburg\Semester 6_Thesis\New Topic\STATA\TAZ\DATA Files"
global output     "F:\Philipps University of Marburg\Semester 6_Thesis\New Topic\STATA\TAZ\Output_Taz"
global raw_data   "F:\Philipps University of Marburg\Semester 6_Thesis\New Topic\STATA\XLS-Files"
*/

*--------------------------------------------------
* Description
*--------------------------------------------------
/*
 I) Donation decision 
 II) Survey
     1) Cleaning: labels, renaming of variables
     2) Generating new variables
	 3) Adjusting Mistakes
	 4) Merge donation decision
	 5) Merge distance
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
import excel "$raw_data\Survey_Dhaka_2022_-_all_versions_-_English_-_2022-02-21-15-09-20", sheet("Survey Dhaka 2022") clear



drop C E G BG // only text-messages to assistants

foreach var of varlist * {
  label variable `var' "`=`var'[1]'"
  replace `var'="" if _n==1
  destring `var', replace
}

dropmiss, force

sort A

drop in 1 // label row









***************************************************
* Cleaning: labels, renaming and generating new variables
***************************************************
*** Rename to lower case
label define yes_no1 0 "No" 1 "Yes", replace
encode IF , gen(donation_done) lab(yes_no1) // variables are not allowed to be named 'if'
drop IF
rename IN submission // variables not allowed to be named 'in'
rename *, lower



*** Rename variables
** Setup

rename a start_date
rename b end_date


label define interviewer1 1 "Tazkeer" 2 "Tamim" 3 "Imran" 4 "Sartaz" 5 "Nibir" 6 "Tasdiq" 7 "Shibly" 8 "Tahmid" 9 "Shafquat" 10 "Assitant 10" 11 "Assitant 11" 12 "Assitant 12"
encode d, generate(interviewer) label(interviewer1)
lab var interviewer "Interviewer"

encode f , generate (date)
encode h, generate(place) 

encode j, generate(consent) label(yes_no1)

rename k time_start
drop m

rename l treatment
label define t_sc 0 "Control" 1 "Treatment", replace
label values treatment t_sc




*-------
* Module A: Socio-Demographics I
*---------
rename o name

label define female1 0 "Male" 1 "Female", replace
encode p, generate(female) label(female1)

label define marital1 1 "Never married" 2 "Currently married" 3 "Widowed" 4 "Divorced" 5 "Abandoned / Separated" 6 "Other", replace
encode q, generate(marital) label(marital1)

label define hh_decision1 1	"Me" 2 "My spouse" 3 "Me and my spouse" 4 "Someone else" , replace
encode r , gen(hh_decision) label(hh_decision1)
rename s hh_decision_other

rename t age
rename u edu_yr
replace edu_yr=0 if edu_yr==. //System glitch turned the 0s into "."

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

//Generating village and district with the purpose of Homogenization

gen home_vil_dist =home_village + " " + home_district
gen vil_dist= "abcd"

label variable home_vil_dist "Village and district as surveyed"
label variable vil_dist "Standardized village and district"

replace vil_dist ="Panchagarh Panchagarh" if home_vil_dist =="Hatuari Ponchogor "
replace vil_dist ="Kafuria Natore" if home_vil_dist =="Matiyapara Ponchogor"
replace vil_dist ="Mogalbachha Kurigram" if home_vil_dist =="Kurigram Rongpur"
replace vil_dist ="Gauripur Paurashava Mymensingh" if home_vil_dist =="Kolakuta Mymensing "
replace vil_dist ="Mogalbachha Kurigram" if home_vil_dist =="Kurigram Rongpur"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Mymenshing"
replace vil_dist ="Puran Bharenga Pabna" if home_vil_dist =="Joynogor/Bera thana Pabna"
replace vil_dist ="Tarash Sirajganj" if home_vil_dist =="Batgari Shirajgonj"
replace vil_dist ="Latifpur Rangpur" if home_vil_dist =="Keshobpur Rongpur"
replace vil_dist ="Mogalbachha Kurigram" if home_vil_dist =="Kurigram Rongpur"
replace vil_dist ="Thetroy Kurigram" if home_vil_dist =="Dorikishor Kurigram"
replace vil_dist ="Egarasindur Kishoreganj" if home_vil_dist =="Boro khalpar Kishorgangh"
replace vil_dist ="Ramganj Bhola" if home_vil_dist =="Kaligangh Bhola"
replace vil_dist ="North Char Bangshi Lakshmipur" if home_vil_dist =="Charpakkhi Lakhipur"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Bogali Jamalpur"
replace vil_dist ="Bonar Para Gaibandha" if home_vil_dist =="Munshipara Gaibandha"
replace vil_dist ="Ballamjhar Gaibandha" if home_vil_dist =="Bolomjhara Gaibandha"
replace vil_dist ="Sariakandi Bogra" if home_vil_dist =="Shariyakandi  Bogura"
replace vil_dist ="Nandail Mymensingh" if home_vil_dist =="Nandail Maymansingh"
replace vil_dist ="Pabnapur Gaibandha" if home_vil_dist =="Rajnogor Gaibandha "
replace vil_dist ="Manohardi Paurashava Narsingdi" if home_vil_dist =="Jamalpur,monohorde Norshinde"
replace vil_dist ="Tongi Paurashava Gazipur" if home_vil_dist =="Tongi Gazipur"
replace vil_dist ="Lohajang Teotia Munshiganj" if home_vil_dist =="Lohuzong ,kolma Munshigonj"
replace vil_dist ="Jugli Mymensingh" if home_vil_dist =="Jugli Noyapara Mymensing"
replace vil_dist ="Nalitabari Sherpur" if home_vil_dist =="Nalitabari Sharpur"
replace vil_dist ="Kishoregari Gaibandha" if home_vil_dist =="Bisnopur Gaibandah "
replace vil_dist ="Jogania Sherpur" if home_vil_dist =="Bhatigangpar Sherpur"
replace vil_dist ="Laksam Comilla" if home_vil_dist =="Ashamta/laksham Comilla"
replace vil_dist ="Islampur Jamalpur" if home_vil_dist =="Islampur Jamalpur"
replace vil_dist ="Mymensingh Paurashava Mymensingh" if home_vil_dist =="Shommogonjo Mymensing"
replace vil_dist ="Sherpur Paurashava Sherpur" if home_vil_dist =="Boddarbazar Sherpur"
replace vil_dist ="Ganda Netrakona" if home_vil_dist =="Bodgachiya gandha Mymensing"
replace vil_dist ="Sutar Para Kishoreganj" if home_vil_dist =="Attapara Kishorganj"
replace vil_dist ="Ballamjhar Gaibandha" if home_vil_dist =="Bolomjhar Gaibandha"
replace vil_dist ="Nalitabari Sherpur" if home_vil_dist =="Tinaripara Sherpur"
replace vil_dist ="Belkuchi Sirajganj" if home_vil_dist =="Bilkuchi Shirajganj "
replace vil_dist ="Manikdaha Faridpur" if home_vil_dist =="Union manikda Foridpur"
replace vil_dist ="Bali Para Mymensingh" if home_vil_dist =="Balipara Maymansingh"
replace vil_dist ="Sherpur Paurashava Sherpur" if home_vil_dist =="Nuknankuran bhagisakur Sherpur"
replace vil_dist ="Nakla Paurashava Sherpur" if home_vil_dist =="Nokla thana Maymansingh"
replace vil_dist ="Islampur Jamalpur" if home_vil_dist =="Islam pur Jamalpur"
replace vil_dist ="Sikdar Mallik Pirojpur" if home_vil_dist =="Piruzpur Borishal"
replace vil_dist ="Sherpur Paurashava Sherpur" if home_vil_dist =="Degolde mulapara Sharpur"
replace vil_dist ="Churain Dhaka" if home_vil_dist =="Dokhi churain, nawabgonj Dhaka"
replace vil_dist ="Ghazir Khamar Sherpur" if home_vil_dist =="Urfa,thana- nokkla Sharpur"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Moymonshing"
replace vil_dist ="Muktagachha Paurashava Mymensingh" if home_vil_dist =="Muktagasa Moymonshing"
replace vil_dist ="Phulpur Mymensingh" if home_vil_dist =="Fhulpur Moymonshing"
replace vil_dist ="Balia Mymensingh" if home_vil_dist =="Borilla Mymensing"
replace vil_dist ="Nagarkanda Paurashava Faridpur" if home_vil_dist =="Nogorkanda Faridpur"
replace vil_dist ="Palashtali Narsingdi" if home_vil_dist =="Polashthana Narshindi"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensing"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Sholiyakhanda Jamalpur"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensing"
replace vil_dist ="Balia Mymensingh" if home_vil_dist =="Borilla Mymensing"
replace vil_dist ="Sarishabari Paurashava Jamalpur" if home_vil_dist =="Shunakata Jamalpur"
replace vil_dist ="Nandail Mymensingh" if home_vil_dist =="Nandathana Mymensing"
replace vil_dist ="Mendipur Netrakona" if home_vil_dist =="Medni Nettrokona City"
replace vil_dist ="Munshiganj Paurashava Munshiganj" if home_vil_dist =="Fultola Munshigangh"
replace vil_dist ="Damudya Paurashava Shariatpur" if home_vil_dist =="Damudda Shariyatpur"
replace vil_dist ="Fulbaria Mymensingh" if home_vil_dist =="Fulbari Mymensingh"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensingh"
replace vil_dist ="Pinjuri Gopalganj" if home_vil_dist =="Pinjuri Gopalgangh"
replace vil_dist ="Faridpur Paurashava Faridpur" if home_vil_dist =="Batigopaldi Faridpur"
replace vil_dist ="Barudia Kishoreganj" if home_vil_dist =="Boroitola Kishorgangh"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensingh"
replace vil_dist ="Phulpur Mymensingh" if home_vil_dist =="Fulpur Mymensingh"
replace vil_dist ="Mogalhat Lalmonirhat" if home_vil_dist =="Lalmonir Haat Rangpur "
replace vil_dist ="Kumarghata Mymensingh" if home_vil_dist =="Kumarghati Mymensing"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mayomonshig"
replace vil_dist ="Jatrapur Kurigram" if home_vil_dist =="Jamalpur Kurigram"
replace vil_dist ="Muksudpur Paurashava Gopalganj" if home_vil_dist =="Mukshedpur Gopalganj"
replace vil_dist ="Ward No-10 (part) Rajshahi" if home_vil_dist =="Rajshahi Rajshahi"
replace vil_dist ="Chandrakona Sherpur" if home_vil_dist =="Chorpara Sherpur"
replace vil_dist ="Thakurakona Netrakona" if home_vil_dist =="Salipura Netrokona"
replace vil_dist ="Phulpur Mymensingh" if home_vil_dist =="Polpur thana Maymansingh"
replace vil_dist ="Katiadi Kishoreganj" if home_vil_dist =="Kotiyadi Kishorgonj"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Halowaghat Maymansingh"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Halowaghat Maymansingh"
replace vil_dist ="Phulpur Mymensingh" if home_vil_dist =="Hurfur thana Maymansingh"
replace vil_dist ="Islampur Jamalpur" if home_vil_dist =="Islampur Jamalpur"
replace vil_dist ="Mehendiganj Barisal" if home_vil_dist =="Mehendiganj thana, shonapur Barishal"
replace vil_dist ="Kagapasha Habiganj" if home_vil_dist =="Bagju Baniachong sylhet"
replace vil_dist ="Netrokona Paurashava Netrakona" if home_vil_dist =="Kotebnogor Netrokona"
replace vil_dist ="Chapai Nababganj Paurashava Nawabganj" if home_vil_dist =="Chapainababganj Chapainababganj"
replace vil_dist ="Kanthaltali Barguna" if home_vil_dist =="Kathaltoli Borguna"
replace vil_dist ="Netrokona Paurashava Netrakona" if home_vil_dist =="Netrokona Mymensing"
replace vil_dist ="Barudia Kishoreganj" if home_vil_dist =="Boroitola  Keshorgonj"
replace vil_dist ="Kanchikata Narsingdi" if home_vil_dist =="Kacharikandi Narshingdi"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Jamalpur Jamalpur"
replace vil_dist ="Mymensingh Paurashava Mymensingh" if home_vil_dist =="Bhatipura Mymensingh"
replace vil_dist ="Nazirpur Netrakona" if home_vil_dist =="Namasirpur Mymensingh "
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Jamalpur Jamalpur"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Pushtafi Jamalpur"
replace vil_dist ="Kuliar Char Paurashava Kishoreganj" if home_vil_dist =="Khiraiso Kishorgonge"
replace vil_dist ="Barhatta Netrakona" if home_vil_dist =="Barhatta  Netrokona"
replace vil_dist ="Char Putimari Jamalpur" if home_vil_dist =="Sorpotimari Jamalpur"
replace vil_dist ="Damiha Kishoreganj" if home_vil_dist =="Damiha Kishorgonge"
replace vil_dist ="Islampur Jamalpur" if home_vil_dist =="Chandanpur Jamalpur"
replace vil_dist ="Jugli Mymensingh" if home_vil_dist =="Jugli noya para Mymensingh "
replace vil_dist ="Char Sherpur Sherpur" if home_vil_dist =="Aontopara Sherpur"
replace vil_dist ="Phulpur Mymensingh" if home_vil_dist =="Fulpur  Mymensingh "
replace vil_dist ="Kanchikata Narsingdi" if home_vil_dist =="Kacharikandhi Norshindhi"
replace vil_dist ="Barabari Lalmonirhat" if home_vil_dist =="Borokomla Bari Lalmonir Haat"
replace vil_dist ="Alipura Narsingdi" if home_vil_dist =="Laipura Norshindhi"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensingh"
replace vil_dist ="Banshchara Jamalpur" if home_vil_dist =="Benechor Jamalpur"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensingh"
replace vil_dist ="Phulpur Mymensingh" if home_vil_dist =="Fulpur thana Mymenshing"
replace vil_dist ="Phulpur Mymensingh" if home_vil_dist =="Fulpur Mymensingh"
replace vil_dist ="Baira (kewatkhali) Mymensingh" if home_vil_dist =="Jayra Mymensingh"
replace vil_dist ="Netrokona Paurashava Netrakona" if home_vil_dist =="Retrokona Maymansingh"
replace vil_dist ="Tarail Sachail Kishoreganj" if home_vil_dist =="Tana tarail Kishorgonj"
replace vil_dist ="Katiadi Kishoreganj" if home_vil_dist =="Koittadir Kishorgonj"
replace vil_dist ="Sherpur Paurashava Sherpur" if home_vil_dist =="Sherpur Sherpur"
replace vil_dist ="Niamati Barisal" if home_vil_dist =="Bakergonj , nemoti Borishal"
replace vil_dist ="Naogaon Paurashava Naogaon" if home_vil_dist =="Nouga Rajshahi bibhag, nouga"
replace vil_dist ="Uttar Khan Dhaka" if home_vil_dist =="Pakuria Dhaka"
replace vil_dist ="Tarail Sachail Kishoreganj" if home_vil_dist =="Dola tawra Keshorgonj"
replace vil_dist ="Tarail Sachail Kishoreganj" if home_vil_dist =="Darail Keshorgonj"
replace vil_dist ="Islampur Jamalpur" if home_vil_dist =="Islampur Jamalpur"
replace vil_dist ="Mahmudpur Jamalpur" if home_vil_dist =="Kagikatha Jamalpur"
replace vil_dist ="Nalitabari Sherpur" if home_vil_dist =="Kowkori,naktabari Sharpur"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Bolzana, haluaghat Moymonshing"
replace vil_dist ="Pabnapur Gaibandha" if home_vil_dist =="Rajnogor  gaibandah"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Moymonshing"
replace vil_dist ="Gaffargaon Mymensingh" if home_vil_dist =="Kalebari Moymonshing"
replace vil_dist ="Khagdahar Mymensingh" if home_vil_dist =="Kurepara Moymonshing"
replace vil_dist ="Char Shibpur Bhola" if home_vil_dist =="Chotolokkipur Barisal "
replace vil_dist ="Kakilakura Sherpur" if home_vil_dist =="Polashtola Mymensing"
replace vil_dist ="Mogalbachha Kurigram" if home_vil_dist =="Kurigram Rangpur"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensing"
replace vil_dist ="Nandail Mymensingh" if home_vil_dist =="Nandathana Mymensing"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Chandrapur Jamalpur"
replace vil_dist ="Chauganga Kishoreganj" if home_vil_dist =="Chilakhara Kishorganj"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensing"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Pehaschar Jamalpur"
replace vil_dist ="Nikli Kishoreganj" if home_vil_dist =="Chiknochun notun bazar Kishorgonge "
replace vil_dist ="Mirukhali Pirojpur" if home_vil_dist =="Mirukhali Borishal"
replace vil_dist ="Krishnapur Netrakona" if home_vil_dist =="Tutia Netrokona"
replace vil_dist ="Baliatali Patuakhali" if home_vil_dist =="Balihari Borishal"
replace vil_dist ="Netrokona Paurashava Netrakona" if home_vil_dist =="Netrokona Mymensingh "
replace vil_dist ="Ward No-10 (part) Rajshahi" if home_vil_dist =="Rajshahi Rajshahi"
replace vil_dist ="Sherpur Paurashava Sherpur" if home_vil_dist =="Tawakuri Sherpur"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensing"
replace vil_dist ="Mogalbachha Kurigram" if home_vil_dist =="Kurigram Rangpur"
replace vil_dist ="Phulpur Mymensingh" if home_vil_dist =="Fulpur Mymensing"
replace vil_dist ="Kishoreganj Paurashava Kishoreganj" if home_vil_dist =="Haatrapara Kishorganj"
replace vil_dist ="Aslampur Bhola" if home_vil_dist =="Aslampur Bhola "
replace vil_dist ="Mogalbachha Kurigram" if home_vil_dist =="Kurigram Rongpur"
replace vil_dist ="Nalitabari Sherpur" if home_vil_dist =="Naktabari Moymonshing"
replace vil_dist ="Baushi Netrakona" if home_vil_dist =="Baulle Netrokona"
replace vil_dist ="Madan Netrakona" if home_vil_dist =="Moydam Moymonshing"
replace vil_dist ="Baushi Netrakona" if home_vil_dist =="Boulle Netrokona"
replace vil_dist ="Islampur Jamalpur" if home_vil_dist =="Islampur Jamalpur"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Pasarsor Jamalpur"
replace vil_dist ="Sherpur Mymensingh" if home_vil_dist =="Sharpur Moymonshing"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Moymonshing"
replace vil_dist ="Teligati Netrakona" if home_vil_dist =="Tangra Natrokona"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Mymenshing"
replace vil_dist ="Mahera Tangail" if home_vil_dist =="Mohela Tangail"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Mymenshing"
replace vil_dist ="Banshchara Jamalpur" if home_vil_dist =="Benwarsor Jamalpur"
replace vil_dist ="Alfadanga Faridpur" if home_vil_dist =="Alfa danga Faridpur"
replace vil_dist ="Jaria Netrakona" if home_vil_dist =="Jaria Netrokona jela"
replace vil_dist ="Jaria Netrakona" if home_vil_dist =="Jariya Netrokona"
replace vil_dist ="Netrokona Paurashava Netrakona" if home_vil_dist =="Netrokona Mymenshing"
replace vil_dist ="Purbadhala Paurashava Netrakona" if home_vil_dist =="Bhatikura Maymansingh"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Mymenshing "
replace vil_dist ="Ganeshpur Naogaon" if home_vil_dist =="gopalpur , mandanouga Nouga"
replace vil_dist ="Char Gopalpur Barisal" if home_vil_dist =="Nouga , gopalpur , mandanouga Borishal"
replace vil_dist ="Netrokona Paurashava Netrakona" if home_vil_dist =="Tutiya Nettrokona"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensingh"
replace vil_dist ="Mirukhali Pirojpur" if home_vil_dist =="Nirufhali Pirizpur"
replace vil_dist ="Netrokona Paurashava Netrakona" if home_vil_dist =="Upla Nettrokona"
replace vil_dist ="Baribari Kishoreganj" if home_vil_dist =="Bikrampur Kishorgangh"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Maddhopara Jamalpur"
replace vil_dist ="Char Jabbar Noakhali" if home_vil_dist =="Uttor chormati Noakhali"
replace vil_dist ="Kishoreganj Paurashava Kishoreganj" if home_vil_dist =="Bairhari Kishorgangh"
replace vil_dist ="Ganeshpur Naogaon" if home_vil_dist =="Gopalpur Nouga"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Halua ghat Mymensingh"
replace vil_dist ="Dhanshail Sherpur" if home_vil_dist =="Dhanshail  Sherpur"
replace vil_dist ="Dhurail Mymensingh" if home_vil_dist =="Chor group pur Mymensingh "
replace vil_dist ="Kaliara Gabragat Netrakona" if home_vil_dist =="Shutanal dighirpar Mymensingh "
replace vil_dist ="Kishoreganj Paurashava Kishoreganj" if home_vil_dist =="Shodor Kishorgonge "
replace vil_dist ="Kaunia Bala Para Rangpur" if home_vil_dist =="Jenepara Rongpur"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Sontia Putol Jamalpur"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensingh"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensingh"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensingh"
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Bolokpur Jamalpur"
replace vil_dist ="Purba Austagram Kishoreganj" if home_vil_dist =="Ashutia Para Kishorgangh"
replace vil_dist ="Banagram Kishoreganj" if home_vil_dist =="Kazirgao Kishorgangh"
replace vil_dist ="Barguna Barguna" if home_vil_dist =="Borguna Barishal"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Mymenshing"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Mymenshing"
replace vil_dist ="Kishoreganj Paurashava Kishoreganj" if home_vil_dist =="Kishoreganj Mymenshing"
replace vil_dist ="Kishoreganj Paurashava Kishoreganj" if home_vil_dist =="Shodorthana Kishoreganj"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Halowaghat Maymansingh"
replace vil_dist ="Sreebardi Sherpur" if home_vil_dist =="Sherpur sirbodi thana Sherpur"
replace vil_dist ="Kishoreganj Paurashava Kishoreganj" if home_vil_dist =="Gosiyata Kishorgonj"
replace vil_dist ="Katiadi Kishoreganj" if home_vil_dist =="Bonomgram Kishorgonj"
replace vil_dist ="Brahmanbaria Paurashava Brahamanbaria" if home_vil_dist =="Gajaria Brammonbaria "
replace vil_dist ="Islampur Jamalpur" if home_vil_dist =="Islampur  Jamalpur "
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Korikandah  Moymonshing "
replace vil_dist ="Ramgopalpur Mymensingh" if home_vil_dist =="Butia para Moymonshing "
replace vil_dist ="Banagram Kishoreganj" if home_vil_dist =="Kagergaw Keshorgonj"
replace vil_dist ="Kishoreganj Paurashava Kishoreganj" if home_vil_dist =="Shodor Keshorgonj"
replace vil_dist ="Kishoreganj Paurashava Kishoreganj" if home_vil_dist =="Shodor thana Keshorgonj "
replace vil_dist ="Tarail Sachail Kishoreganj" if home_vil_dist =="Tarail,shimulhate Keshorgonj "
replace vil_dist ="Banagram Kishoreganj" if home_vil_dist =="Kajar gaw Keshorgonj "
replace vil_dist ="Fatullah (part) Narayanganj" if home_vil_dist =="Fotullah  Narayanganj"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensing"
replace vil_dist ="Terokhada Khulna" if home_vil_dist =="Terokhada Khulna"
replace vil_dist ="Karihata Gazipur" if home_vil_dist =="Kapashia Gazipur"
replace vil_dist ="Kakilakura Sherpur" if home_vil_dist =="Hurikahuniya Sherpur"
replace vil_dist ="Banagram Kishoreganj" if home_vil_dist =="Burgaon  Kishorganj"
replace vil_dist ="Tarakanda Mymensingh" if home_vil_dist =="Tarail Mymensing"
replace vil_dist ="Hasail Banari Munshiganj" if home_vil_dist =="Hashail Munshigonge"
replace vil_dist ="Dhurail Mymensingh" if home_vil_dist =="Burup pur Mymensingh"
replace vil_dist ="Dhurail Mymensingh" if home_vil_dist =="Mokamia Mymensingh "
replace vil_dist ="Char Shibpur Bhola" if home_vil_dist =="Shibpur Bhola"
replace vil_dist ="Melandaha Paurashava Jamalpur" if home_vil_dist =="Melandor Jamalpur"
replace vil_dist ="Patgram Lalmonirhat" if home_vil_dist =="Tista Rangpur"
replace vil_dist ="Itakhola Nilphamari" if home_vil_dist =="Etakhola Nilfamari"
replace vil_dist ="Chehelgazi Dinajpur" if home_vil_dist =="Hatirshal Dinajpur"
replace vil_dist ="Morrelganj Bagerhat" if home_vil_dist =="Morolgangh, Bagerhat Khulna"
replace vil_dist ="Kunder Char Shariatpur" if home_vil_dist =="Kalu bepari gram Shariyatpur"
replace vil_dist ="Burunga Sylhet" if home_vil_dist =="Dawanfur Bazar Sylhet"
replace vil_dist ="Shailkupa Paurashava Jhenaidah" if home_vil_dist =="Shekpara Khulna"
replace vil_dist ="Mogalbachha Kurigram" if home_vil_dist =="Kurigram Rangpur"
replace vil_dist ="Nabiganj Habiganj" if home_vil_dist =="Nobigangh Sylhet"
replace vil_dist ="Joypurhat Paurashava Joypurhat" if home_vil_dist =="Jaipurhaat Bogura"
replace vil_dist ="Belkuchi Sirajganj" if home_vil_dist =="Belkuchi Shirajgangh"
replace vil_dist ="Bhairab Paurashava Kishoreganj" if home_vil_dist =="Kishorgonj Bhojrob"
replace vil_dist ="Islampur Jamalpur" if home_vil_dist =="Islampur thana Jamalpur"
replace vil_dist ="Mathbari Jhalokati" if home_vil_dist =="Modbari thana Borishal"
replace vil_dist ="Begumganj Noakhali" if home_vil_dist =="Begomgonjon Noakhali"
replace vil_dist ="Tarail Sachail Kishoreganj" if home_vil_dist =="Tarail Kishorgonj"
replace vil_dist ="Boalmari Faridpur" if home_vil_dist =="Buwalmari Faridpur"
replace vil_dist ="Burichang Comilla" if home_vil_dist =="Bhurichong thana Kumilla"
replace vil_dist ="Burichang Comilla" if home_vil_dist =="Burijon thana Kumilla"
replace vil_dist ="Kaimari Nilphamari" if home_vil_dist =="Holdhaka  Nelfamare"
replace vil_dist ="Pathardubi Kurigram" if home_vil_dist =="Pathirdupe Kurigram "
replace vil_dist ="Rasul Pur Bhola" if home_vil_dist =="Rosulpur Vulla "
replace vil_dist ="Purbadhala Netrakona" if home_vil_dist =="Purvhodhola Netrokona "
replace vil_dist ="Pathardubi Kurigram" if home_vil_dist =="Pthorduki Kurigram "
replace vil_dist ="Sarikal Barisal" if home_vil_dist =="Shultane Boreshal"
replace vil_dist ="Bapta Bhola" if home_vil_dist =="Shamandar Vulla "
replace vil_dist ="Illisha Bhola" if home_vil_dist =="Vhula ilisha Vhula "
replace vil_dist ="Paltapur Dinajpur" if home_vil_dist =="Bergonj  Denzpur "
replace vil_dist ="Banari Para Barisal" if home_vil_dist =="Banerpara  Boreshal "
replace vil_dist ="Galachipa Patuakhali" if home_vil_dist =="Rattandi Putuakhali "
replace vil_dist ="Madaripur Paurashava Madaripur" if home_vil_dist =="Madaripur shadar Madaripur "
replace vil_dist ="Hatiya Paurashava Noakhali" if home_vil_dist =="Hatia Noakhali "
replace vil_dist ="Kaimari Nilphamari" if home_vil_dist =="Joldhaka Nilfamari"
replace vil_dist ="Kunder Char Shariatpur" if home_vil_dist =="Kunderchar Shoriyotpur"
replace vil_dist ="Sakhipur Shariatpur" if home_vil_dist =="Char Shoriyotpur"
replace vil_dist ="Ruhea Thakurgaon" if home_vil_dist =="Shingpara  Thakurgaon"
replace vil_dist ="Kakilakura Sherpur" if home_vil_dist =="Shoagipur Mymensing"
replace vil_dist ="Biral Dinajpur" if home_vil_dist =="KanchanNodi Dinajpur"
replace vil_dist ="Chandrakona Sherpur" if home_vil_dist =="Chokkariya  Sherpur"
replace vil_dist ="Dhurail Mymensingh" if home_vil_dist =="Charrooppur Mymensing"
replace vil_dist ="Kiratan Kishoreganj" if home_vil_dist =="Kiraton Kishorganj"
replace vil_dist ="Barguna Barguna" if home_vil_dist =="Borguna Barisal"
replace vil_dist ="Bhairab Paurashava Kishoreganj" if home_vil_dist =="Bhoirob Kishorganj"
replace vil_dist ="Panchagarh Panchagarh" if home_vil_dist =="Paikarpara Panchagarh"
replace vil_dist ="Dhurail Mymensingh" if home_vil_dist =="Dubahora Mymenshing"
replace vil_dist ="Rani Pukur Rangpur" if home_vil_dist =="Bhoktipur, rani pukur Rangpur"
replace vil_dist ="Mirzapur Tangail" if home_vil_dist =="Mirjapur Tangail"
replace vil_dist ="Nagarpur Tangail" if home_vil_dist =="Nagorpur Tangail"
replace vil_dist ="Raihanpur Barguna" if home_vil_dist =="Raihanpur Borguna"
replace vil_dist ="Chehelgazi Dinajpur" if home_vil_dist =="Jharbari,angoli para Dinajpur"
replace vil_dist ="Rajnagar Sherpur" if home_vil_dist =="Ramnogor  Haluaghat moymonshing "
replace vil_dist ="Dhurail Mymensingh" if home_vil_dist =="Durail, haluaghat  Moymonshing "
replace vil_dist ="Bogra Paurashava Bogra" if home_vil_dist =="Bagarsor Bogura"
replace vil_dist ="Nandail Mymensingh" if home_vil_dist =="Nandail thana Moymonshing "
replace vil_dist ="Jamalpur Paurashava Jamalpur" if home_vil_dist =="Gobinropur Jamalpur "
replace vil_dist ="Korsha Kariail Kishoreganj" if home_vil_dist =="Shawra Kishorganj "
replace vil_dist ="Chuadanga Paurashava Chuadanga" if home_vil_dist =="Bucitola Chuadnga "
replace vil_dist ="Panchagarh Panchagarh" if home_vil_dist =="Ponchogor ,fulbari Ponchogor"
replace vil_dist ="Manikchhari Khagrachhari" if home_vil_dist =="Manikchor Khagrachori"
replace vil_dist ="Kishoreganj Paurashava Kishoreganj" if home_vil_dist =="Jhaluapara Kishorgangh"
replace vil_dist ="Marichpura Sherpur" if home_vil_dist =="Morispuran Maulobipara Sherpur"
replace vil_dist ="Korsha Kariail Kishoreganj" if home_vil_dist =="Kolishakhali Kishorgangh"
replace vil_dist ="Fulbaria Mymensingh" if home_vil_dist =="Fulbari Mymensingh"
replace vil_dist ="Godagari Paurashava Rajshahi" if home_vil_dist =="Shahed Bazar Rajshahi"
replace vil_dist ="Purbadhala Netrakona" if home_vil_dist =="Purbo dhola thana Netrokona , maymansingh"
replace vil_dist ="Begumganj Noakhali" if home_vil_dist =="Begomgonj Noakhali"
replace vil_dist ="Kumar Para Gaibandha" if home_vil_dist =="Kumargari Gaibandha"
replace vil_dist ="Dhamrai Dhaka" if home_vil_dist =="Dhamrai Dhaka "
replace vil_dist ="Gazipur Paurashava Gazipur" if home_vil_dist =="Boardbazar Gazipur"
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat Mymenshing "
replace vil_dist ="Mehendiganj Barisal" if home_vil_dist =="Mehendigonj thana Barishal "
replace vil_dist ="Maghi Magura" if home_vil_dist =="Mogi union Magura"
replace vil_dist ="Manikganj Paurashava Manikganj" if home_vil_dist =="Shingai Manikgonj"
replace vil_dist ="Rajnagar Sherpur" if home_vil_dist =="Poshchim ramnogor  Moymonshing "
replace vil_dist ="Osmanganj Bhola" if home_vil_dist =="Chorpashor Vulla "
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluaghat  Moymonshing "
replace vil_dist ="Haluaghat Mymensingh" if home_vil_dist =="Haluwaghat Mymensingh"
replace vil_dist ="Badiakhali Gaibandha" if home_vil_dist =="Baidakhali Gaibandha"
replace vil_dist ="Bhanga Paurashava Faridpur" if home_vil_dist =="Bhagga Faridpur"




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
replace cs= "b) regardless of its potential use to us people" if cs =="b) its potential use to us people"
replace ct= "b) regardless of its potential use to us people" if ct =="b) its potential use to us people"
replace cu= "b) regardless of its potential use to us people" if cu =="b) its potential use to us people"
replace cv= "b) regardless of its potential use to us people" if cv =="b) its potential use to us people"

label define ranking 1 "a) clean air and water" 2"b) regardless of its potential use to us people" 3"c) strongly connected with our people’s culture" 4"d) Responsibility for it and active effort into conservation"


encode cs ,gen(v_importance1) label(ranking)
encode ct ,gen(v_importance2) label(ranking)
encode cu ,gen(v_importance3) label(ranking)
encode cv ,gen(v_importance4) label(ranking)





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

// Reasons for not haven taken adaptation measures yet
rename ej cc_not_adapt_already_protec
rename ek cc_not_adapt_not_severe
rename el cc_not_adapt_no_resource
rename em cc_not_adapt_dont_know_how
rename en cc_not_adapt_move_when_bad
rename eo cc_not_adapt_move_anyway
rename ep cc_not_adapt_never_thought
rename er cc_not_adapt_other

lab var  cc_not_adapt_already_protec "Reason no adaptation: House/Land already well protected"
lab var  cc_not_adapt_not_severe "Reason no adaptation: Not necessary as environmental hazards won't be severe"
lab var  cc_not_adapt_no_resource "Reason no adaptation: No resources available"
lab var  cc_not_adapt_dont_know_how "Reason no adaptation: Don't know how to protect"
lab var  cc_not_adapt_move_when_bad "Reason no adaptation: Will move away when it gets too bad"
lab var  cc_not_adapt_move_anyway "Reason no adaptation: Other"
lab var  cc_not_adapt_never_thought "Don't know"
lab var  cc_not_adapt_other "Reason no adaptation: Other"

foreach var in cc_not_adapt_already_protec cc_not_adapt_not_severe cc_not_adapt_no_resource cc_not_adapt_dont_know_how cc_not_adapt_move_when_bad cc_not_adapt_move_anyway cc_not_adapt_never_thought  {
	lab val `var' yes_no1
}


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
rename ib envelope
encode ic , gen(transfer)
rename id phone
encode ie , gen(believe_lottery) lab(yes_no1)
encode ig , gen(believe_transfer) lab(yes_no1)
rename ih time_end_experiment 

rename ij comment
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
* 3) Adjusting mistakes
*---------------

// Wrong envelope number in KoboCollect
replace envelope = . if envelope == 52 & interviewer == 1 & date == 5 // Taz made a mistake in writing down the envelope on the 16th
replace envelope = . if envelope == 50 & interviewer == 4 & date == 4 // Sartaz made a mistake in writing down the envelope on the 15th


// Budget change differently noted down
/*
The question "By how many percent would you want to increase the development spending on environmental and climate change disaster management?" has been noted down differently by different interviewer: Most noted down the budget to which participants would like to change the budget; Sartaz & Taz noted down by how much they would like to change it (i.e. 0 being a budget of 4). Taz accompanied Tahmad and Assistant 10 at the 17.02. and helped them typing; therefore, also here 0 means a budget of 4. From the 18th on all interviewers were advised to note down the final budget (Sartaz missed that point and noted it down as he used to on the 18th still)
*/
replace budget_change = budget_change + 4 if /// Taz and Tamim, Tahmid, Assistant 10 when Taz helped) 
budget_change == 0 & (interviewer == 1 | interviewer == 2 | interviewer == 8 | interviewer == 10) & (date == 1 | date == 2 | date == 3 | date == 4 | date == 5 | date == 6)

replace budget_change = budget_change + 4 if /// Sartaz 0-3
budget_change < 4 & interviewer == 4 & (date == 1 | date == 2 | date == 3 | date == 4 | date == 5 | date == 6 | date == 7) 


*---------------
* 4) Merge with donation data
*---------------
merge m:1 envelope using "F:\Philipps University of Marburg\Semester 6_Thesis\New Topic\STATA\DTA-Files/dhaka_2022_donation" // actually 1:1 but missing data due to problems above
drop if _merge == 2
drop if _merge == 1 //????????
drop _merge



*---------------
* 5) Merge with distance data
*---------------
 merge m:m vil_dist using "F:\Philipps University of Marburg\Semester 6_Thesis\New Topic\STATA\DTA-Files\distance.dta" //merge the distance data file to the main survey data (many to many) using vil_dist as the key. 
 



*------------
* Order
*------------
order ///
/*setup*/ id date date_system interviewer place treatment consent time_sum time_scenario time_exp ///
/*A: socioeconomics I*/ name female marital age religion prayer_freq edu_yr hh_decision hh_decision_other place_living place_living_other living_here_always living_here_years place_before m_reason_movein m_reason_hazards m_reason_conflict m_reason_job m_reason_other home_village home_district home_vil_dist vil_dist distance ///
/*B: CC Perception*/ cc_changes cc_move cc_destiny cc_uncertain cc_agency cc_perception1 cc_perception2 cc_perception3 cc_perception4 cc_perception5 cc_perception6 cc_perception7 cc_perception8 ///
/*C: RV scenario*/ wtp wtp_reason budget_change relational_v1 relational_v2 relational_v3 relational_v4 intrinsic_v instrumental_v v_importance1 v_importance2 v_importance3 v_importance4 solution1 solution2 solution3 solution4 ///
/*E: Exposure*/ hazard_number house_damaged house_destroyed injured injured_others lost_land lost_livestock lost_assets hazard_move affected_amphan adaptation rebuild_total_here help_gov help_ngo help_rich help_relig help_community help_bank help_insurance help_family help_friends help_neighbors help_none adaptation cc_adapt_house cc_adapt_store cc_adapt_stilts cc_adapt_fortify cc_adapt_other cc_adapt_other_which cc_not_adapt_already_protec cc_not_adapt_not_severe cc_not_adapt_no_resource cc_not_adapt_dont_know_how cc_not_adapt_move_when_bad cc_not_adapt_move_anyway cc_not_adapt_never_thought cc_not_adapt_other cc_adapt_suggest1 cc_adapt_suggest2 cc_adapt_suggest3 cc_adapt_suggest4 cc_adapt_suggest5 cc_adapt_suggest6 cc_adapt_suggest7 cc_adapt_suggest_other ///
/*F: Migration*/ pref_lifestyle pref_place dhaka_stay_yrs ///
/*G: Norms*/ norms_believe norms_visit_home visit_home visit_friends get_visits ///
/*H: Preferences, attitudes, personality*/ econ_aspiration econ_knowledge econ_agency1 econ_agency2 econ_agency3 econ_agency7 econ_agency8 poor place_attach1 place_attach2 place_attach3 time risk trust_general trust_community trust_family recip_pos recip_neg altruism community_work community_work_punish ///
/*I: Socio-econ*/ hh_member children occupation occupation_other occupation_spouse housework_me housework_spouse housework_mother housework_father housework_other occupation_spouse_other income income_hh low_nutri spent_sparetime spent_temptation spent_save member_assosi member_neighborhood member_district member_migrant member_livelihood member_farmer member_formal_political member_informal_political member_student member_women member_cultural member_sport member_other ///
/*J: Experiment*/ envelope donation phone transfer believe_lottery donation_done believe_transfer comment



keep ///
/*setup*/ id date date_system interviewer place treatment consent time_sum time_scenario time_exp ///
/*A: socioeconomics I*/ name female marital age religion prayer_freq edu_yr hh_decision hh_decision_other place_living place_living_other living_here_always living_here_years place_before m_reason_movein m_reason_hazards m_reason_conflict m_reason_job m_reason_other home_village home_district home_vil_dist vil_dist distance ///
/*B: CC Perception*/ cc_changes cc_move cc_destiny cc_uncertain cc_agency cc_perception1 cc_perception2 cc_perception3 cc_perception4 cc_perception5 cc_perception6 cc_perception7 cc_perception8 ///
/*C: RV scenario*/ wtp wtp_reason budget_change relational_v1 relational_v2 relational_v3 relational_v4 intrinsic_v instrumental_v v_importance1 v_importance2 v_importance3 v_importance4 solution1 solution2 solution3 solution4 ///
/*E: Exposure*/ hazard_number house_damaged house_destroyed injured injured_others lost_land lost_livestock lost_assets hazard_move affected_amphan adaptation rebuild_total_here help_gov help_ngo help_rich help_relig help_community help_bank help_insurance help_family help_friends help_neighbors help_none adaptation cc_adapt_house cc_adapt_store cc_adapt_stilts cc_adapt_fortify cc_adapt_other cc_adapt_other_which cc_not_adapt_already_protec cc_not_adapt_not_severe cc_not_adapt_no_resource cc_not_adapt_dont_know_how cc_not_adapt_move_when_bad cc_not_adapt_move_anyway cc_not_adapt_never_thought cc_not_adapt_other cc_adapt_suggest1 cc_adapt_suggest2 cc_adapt_suggest3 cc_adapt_suggest4 cc_adapt_suggest5 cc_adapt_suggest6 cc_adapt_suggest7 cc_adapt_suggest_other ///
/*F: Migration*/ pref_lifestyle pref_place dhaka_stay_yrs ///
/*G: Norms*/ norms_believe norms_visit_home visit_home visit_friends get_visits ///
/*H: Preferences, attitudes, personality*/ econ_aspiration econ_knowledge econ_agency1 econ_agency2 econ_agency3 econ_agency7 econ_agency8 poor place_attach1 place_attach2 place_attach3 time risk trust_general trust_community trust_family recip_pos recip_neg altruism community_work community_work_punish ///
/*I: Socio-econ*/ hh_member children occupation occupation_other occupation_spouse housework_me housework_spouse housework_mother housework_father housework_other occupation_spouse_other income income_hh low_nutri spent_sparetime spent_temptation spent_save member_assosi member_neighborhood member_district member_migrant member_livelihood member_farmer member_formal_political member_informal_political member_student member_women member_cultural member_sport member_other ///
/*J: Experiment*/ envelope donation phone transfer believe_lottery donation_done believe_transfer comment








***Save
save "$datapath\dhaka_2022_clean_Tazkeer_Azeez_Chaudhuri.dta" , replace



















