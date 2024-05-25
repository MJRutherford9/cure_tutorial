***************************************************************************************************************************************************************************
*** This do file creates the 3 datasets used in "Mixture and non-Mixture Cure Models for Health Technology Assessment: What You Need to Know", by Latimer and Rutherford***
*** It then calls other do files to fit the models and produce the plots contained in the paper ***************************************************************************
***************************************************************************************************************************************************************************

**CHANGE WORKING DIRECTORY TO MAIN FOLDER WHERE THE FILES ARE DOWNLOADED FROM GITHUB
cd ".\Files for GitHub"


adopath ++ ".\ado"

*********************************
*** 1. INSTALL REQUIRED FILES ***
*********************************

* To run this do file you will need to install various packages
ssc install stpm2
ssc install rcsgen
ssc install standsurv
* The strsmix command for fitting mixture cure models must be installed in the following way:
findit lambert cure
* then click on the Stata Journal link followed by click to install.

*****************************
*** 2. NOTE ON DATA FILES ***
*****************************

* The datasets created in [3] below are also saved in the "Data" folder in this repository
* The population mortality data (popmort and popmort_SMR25) used to fit cure models in [4]-[9] are saved in the "Data" folder in this repository
* stexpect3, which is required to incorporate background mortality in mixture cure models in [4]-[9] is included in the "ado" folder in this repository

***********************************************************
*** 3. CREATE THE DATASETS FOR THE 3 SCENARIOS ANALYSED ***
***********************************************************

* We use colon cancer registry data
use "https://pclambert.net/data/colon.dta", clear 

* SCENARIO 1: REGIONAL DISEASE WITH LARGE CURE FRACTION
set seed 194540
 
* Assume we don't know the reason for death. In the actual dataset we know if it was cancer-related (coded 1) or not (coded 2), but often we won't know this in a trial, so create a new variable for death combining these.
gen dead = 0 
replace dead = 1 if status ==1 | status==2

* Only keep patients with regional disease
keep if stage==2
* 1,787 patients. To represent trial dataset, aim to keep about 400
keep if runiform()<0.24
* left with 440

stset surv_mm, failure(dead) id(id) scale(12) 
sts graph, risktable

* create an "accurate" age variable, to avoid jagged hazard plots. In reality dob should be used, here we don't have that, so just use a uniform function
gen age_accurate=age+runiform()	

* When we compare models fitted to earlier artificially censored datasets to the later observed data, we will append the artificially censored datasets to the original full dataset, then fit the models to the appended datasets and plot alongside the full data. Here we create 3 versions of the dataset, with 24-month follow-up (dataset==1), 48-month follow-up (dataset==2), and the complete data (dataset==0)
expand 3, gen(dataset)
replace dataset = 2 if dataset==1 & dataset[_n-1]==1 & id==id[_n-1]
sort dataset id
* 0 is the master dataset, 1 is the 24 month dataset, 2 is the 48 month dataset
replace dead = 0 if dead==1 & surv_mm>24 & dataset==1
replace surv_mm = 24 if surv_mm>24 & dataset==1
replace dead = 0 if dead==1 & surv_mm>48 & dataset==2
replace surv_mm = 48 if surv_mm>48 & dataset==2
replace id = _n
save ".\data\combined_dataset_regional.dta", replace

* SCENARIO 2: DISTANT DISEASE WITH SMALL CURE FRACTION
use "https://pclambert.net/data/colon.dta", clear 
set seed 456461

* Assume we don't know the reason for death. In the actual dataset we know if it was cancer-related (coded 1) or not (coded 2), but often we won't know this in a trial, so create a new variable for death combining these.
gen dead = 0 
replace dead = 1 if status ==1 | status==2

* Only keep patients with distant disease
keep if stage==3
* 5,147 patients. To represent trial dataset, aim to keep about 400
keep if runiform()<0.078
* Left with 391

stset surv_mm, failure(dead) id(id) scale(12) 
sts graph, risktable

* Create an "accurate" age variable, to avoid jagged hazard plots. In reality dob should be used, here we don't have that, so just use a uniform function
gen age_accurate=age+runiform()	

* When we compare models fitted to earlier artificially censored datasets to the later observed data, we will append the artificially censored datasets to the original full dataset, then fit the models to the appended datasets and plot alongside the full data. Here we create 3 versions of the dataset, with 24-month follow-up (dataset==1), 48-month follow-up (dataset==2), and the complete data (dataset==0)
expand 3, gen(dataset)
replace dataset = 2 if dataset==1 & dataset[_n-1]==1 & id==id[_n-1]
sort dataset id
* 0 is the master dataset, 1 is the 24 month dataset, 2 is the 48 month dataset
replace dead = 0 if dead==1 & surv_mm>24 & dataset==1
replace surv_mm = 24 if surv_mm>24 & dataset==1
replace dead = 0 if dead==1 & surv_mm>48 & dataset==2
replace surv_mm = 48 if surv_mm>48 & dataset==2
replace id = _n
save ".\data\combined_dataset_distant.dta", replace

*** SCENARIO 3: DISTANT DISEASE WITH NO CURE FRACTION
use "https://pclambert.net/data/colon.dta", clear 
set seed 456461

* Assume we don't know the reason for death. In the actual dataset we know if it was cancer-related (coded 1) or not (coded 2), but often we won't know this in a trial, so create a new variable for death combining these.
gen dead = 0 
replace dead = 1 if status ==1 | status==2

* Only keep patients with distant disease
keep if stage==3
* 5,147 patients. Prefer to have about 400, to be more similar to an RCT arm, and only keep people who lived less than 96 months
keep if runiform()<0.1
drop if surv_mm>96
* Left with 481

stset surv_mm, failure(dead) id(id) scale(12) 
sts graph, risktable

* Create an "accurate" age variable, to avoid jagged hazard plots. In reality dob should be used, here we don't have that, so just use a uniform function
gen age_accurate=age+runiform()	

* When we compare models fitted to earlier artificially censored datasets to the later observed data, we will append the artificially censored datasets to the original full dataset, then fit the models to the appended datasets and plot alongside the full data. Here we create 3 versions of the dataset, with 24-month follow-up (dataset==1), 48-month follow-up (dataset==2), and the complete data (dataset==0)
expand 3, gen(dataset)
replace dataset = 2 if dataset==1 & dataset[_n-1]==1 & id==id[_n-1]
sort dataset id
* 0 is the master dataset, 1 is the 24 month dataset, 2 is the 48 month dataset
replace dead = 0 if dead==1 & surv_mm>24 & dataset==1
replace surv_mm = 24 if surv_mm>24 & dataset==1
replace dead = 0 if dead==1 & surv_mm>48 & dataset==2
replace surv_mm = 48 if surv_mm>48 & dataset==2
replace id = _n
save ".\data\combined_dataset_distant_nocure.dta", replace

*******************************************************
*** 4. FIT MODELS TO SCENARIO 1 DATASET, WITH SMR=1 ***
*******************************************************

* fit models
do ".\code\Regional_analysis_SMR1.do"

* construct plots
do ".\code\Regional_model_plots_SMR1.do"


*********************************************************
*** 5. FIT MODELS TO SCENARIO 1 DATASET, WITH SMR=2.5 ***
*********************************************************

* fit models
do ".\code\Regional_analysis_SMR25.do"

* construct plots
do ".\code\Regional_model_plots_SMR25.do"



*******************************************************
*** 6. FIT MODELS TO SCENARIO 2 DATASET, WITH SMR=1 ***
*******************************************************

* fit models
do ".\code\Distant_analysis_SMR1.do"

* construct plots
do ".\code\Distant_model_plots_SMR1.do"


*********************************************************
*** 7. FIT MODELS TO SCENARIO 2 DATASET, WITH SMR=2.5 ***
*********************************************************

* fit models
do ".\code\Distant_analysis_SMR25.do"

* construct plots
do ".\code\Distant_model_plots_SMR25.do"



*******************************************************
*** 8. FIT MODELS TO SCENARIO 3 DATASET, WITH SMR=1 ***
*******************************************************

* fit models
do ".\code\Distant_nocure_analysis_SMR1.do"

* construct plots
do ".\code\Distant_nocure_model_plots_SMR1.do"

*********************************************************
*** 9. FIT MODELS TO SCENARIO 3 DATASET, WITH SMR=2.5 ***
*********************************************************

* fit models
do ".\code\Distant_nocure_analysis_SMR25.do"

* construct plots
do ".\code\Distant_nocure_model_plots_SMR25.do"




