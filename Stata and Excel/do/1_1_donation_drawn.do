*--------------------------------------------------
* Bangladesh 2022 - Relation Values
* 1_1_donation_drawn.do
* Philipps University Marburg
*--------------------------------------------------


*--------------------------------------------------
* Program Setup
*--------------------------------------------------
clear all               
version 16              // Set Version number for backward compatibility
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
For 100 of all participants their decision on how much to donate and how much to keep was actually realized
*/
*--------------------------------------------------

/*
I) Donation decision
*/




*---------------
* 3) Merge with donation data
*---------------
use "$datapath\dhaka_2022_clean1.dta" , clear
merge m:m envelope using "$datapath\dhaka_2022_donation&winners" // actually 1:1 but missing data due to problems above
*drop if _merge == 2
*drop _merge



