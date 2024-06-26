*** Distant No Cure Analysis with SMR=1 ***

* See "Deriving_distant_dataset.do" for deriving the datasets

* Here fit models to the 24 month data (dataset==1), and then to the 48 month data (dataset==2), and then compare them to the observed complete data (dataset==0)
* All these are with an SMR of 1
use ".\data\combined_dataset_distant_nocure.dta", clear

sort dataset id
rename surv_mm OS_mm

* get background survival curve using complete data, and merge in background expected survival for all patients across all data-cuts
stset OS_mm if dataset==0, failure(dead) id(id) scale(12) 
gen _age = min(floor(age + _t),99) if dataset==0
gen _year = floor(yydx +_t) if dataset==0
stset OS_mm if dataset==1, failure(dead) id(id) scale(12) 
replace _age = min(floor(age + _t),99) if dataset==1
replace _year = floor(yydx +_t) if dataset==1
stset OS_mm if dataset==2, failure(dead) id(id) scale(12) 
replace _age = min(floor(age + _t),99) if dataset==2
replace _year = floor(yydx +_t) if dataset==2

* randomisation date (number)
gen datediag = dx


* first get survival expectations for actual background pop (for comparison in graphs, but use the life tables with SMR applied for models)
stset OS_mm if dataset==0, failure(dead) id(id) scale(12) 
stexpect3 using ".\data\popmort.dta" if dataset==0, agediag(age_accurate) datediag(datediag) pmother(sex) pmage(_age) pmyear(_year) every(0.05) maxt(50) pmmaxyear(1995) pmmaxage(99)
rename t_exp t_exp50_b
rename expsurv expsurv50_b
rename  exphaz exphaz50_b

*** SMR=1 ***

* now merge with life table. 
* below merge gives everyone across all the datasets a matched expected mortality rate
merge m:1 _year sex _age using ".\data\popmort.dta", keep(match master)

* Fit the 24 month models first
* for the 24 month models, run stexpect on the 24 month dataset
stset OS_mm if dataset==1, failure(dead) id(id) scale(12) 
stexpect3 using ".\data\popmort.dta" if dataset==1, agediag(age_accurate) datediag(datediag) pmother(sex) pmage(_age) pmyear(_year) every(0.05) maxt(50) pmmaxyear(1995) pmmaxage(99)
rename t_exp t_exp50_24
rename expsurv expsurv50_24
rename  exphaz exphaz50_24

* Model 1. Mixture cure (log normal) incorporating background hazards, without age in model 
strsmix, link(logistic) distribution(lognormal) bhazard(rate) iter(30)
estimates store strsmix_m1
estat ic
predict S_MC_ln_m1, surv timevar(t_exp50_24)
gen S1_MC_ln_m1 = S_MC_ln_m1*expsurv50_24
predict H_ln_m1, hazard timevar(t_exp50_24)
gen H1_ln_m1 = H_ln_m1 + exphaz50_24
integ S1_MC_ln_m1 t_exp50_24 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_MC_ln_m1 t_exp50_24  if t_exp50_24<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_MC_ln_m1 t_exp50_24  if t_exp50_24<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20mixln_m1 = S1_MC_ln_m1 if t_exp50_24>19.98 & t_exp50_24<20.02
summ Sat20mixln_m1
gen Sat10mixln_m1 = S1_MC_ln_m1 if t_exp50_24>9.98 & t_exp50_24<10.02
summ Sat10mixln_m1
gen Sat5mixln_m1 = S1_MC_ln_m1 if t_exp50_24>4.98 & t_exp50_24<5.02
summ Sat5mixln_m1

predict curemixln_m1, cure
summ curemixln_m1

* Model 2. Mixture cure (Weibull) incorporating background hazards, without age in model  
strsmix, link(logistic) distribution(weibull) bhazard(rate) iter(30)
estimates store strsmix_m2
estat ic
predict S_MC_weib_m2, surv timevar(t_exp50_24)
gen S1_MC_weib_m2 = S_MC_weib_m2*expsurv50_24
predict H_weib_m2, hazard timevar(t_exp50_24)
gen H1_weib_m2 = H_weib_m2 + exphaz50_24
integ S1_MC_weib_m2 t_exp50_24 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_MC_weib_m2 t_exp50_24  if t_exp50_24<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_MC_weib_m2 t_exp50_24  if t_exp50_24<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20mixweib_m2 = S1_MC_weib_m2 if t_exp50_24>19.98 & t_exp50_24<20.02
summ Sat20mixweib_m2
gen Sat10mixweib_m2 = S1_MC_weib_m2 if t_exp50_24>9.98 & t_exp50_24<10.02
summ Sat10mixweib_m2
gen Sat5mixweib_m2 = S1_MC_weib_m2 if t_exp50_24>4.98 & t_exp50_24<5.02
summ Sat5mixweib_m2

predict curemixweib_m2, cure
summ curemixweib_m2

* Model 3. Non-mixture cure (FPM, 3df), SMR=2.5, 5-year boundary knot (will want to try other boundary knots), without age in model

stpm2, df(3) scale(h) bknots(0.01 5) bhazard(rate) cure
estimates store stpm2_m3
estat ic
gen t50=50 in 1
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m3) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))

if _rc==0 {
summ rmst_m3
summ rmst_m3_lci
summ rmst_m3_uci
}			

if _rc!=0 {
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m3) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m3
summ rmst_m3_lci
summ rmst_m3_uci
}
}	
			
range tt 0 50 501     
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m3)
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m3) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m3) split(`=1/12'))       
standsurv if dataset==1, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m3) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m3 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m3 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"	
  
integ surv_m3 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df3_m3 = surv_m3 if tt>19.98 & tt<20.02
summ Sat20df3_m3
gen Sat10df3_m3 = surv_m3 if tt>9.98 & tt<10.02
summ Sat10df3_m3
gen Sat5df3_m3 = surv_m3 if tt>4.98 & tt<5.02
summ Sat5df3_m3

predict curedf3_m3, cure
summ curedf3_m3	  

* Model 4. Non-mixture cure (FPM, 5df), SMR=2.5, 5-year boundary knot (will want to try other boundary knots), without age in model

stpm2, df(5) scale(h) bknots(0.01 5) bhazard(rate) cure
estimates store stpm2_m4
estat ic
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m4) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m4
summ rmst_m4_lci
summ rmst_m4_uci
}			

if _rc!=0 {
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m4) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m4
summ rmst_m4_lci
summ rmst_m4_uci
}
}			
         
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m4)
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m4) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m4) split(`=1/12'))       
standsurv if dataset==1, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m4) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m4 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m4 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"	
  
integ surv_m4 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df5_m4 = surv_m4 if tt>19.98 & tt<20.02
summ Sat20df5_m4
gen Sat10df5_m4 = surv_m4 if tt>9.98 & tt<10.02
summ Sat10df5_m4
gen Sat5df5_m4 = surv_m4 if tt>4.98 & tt<5.02
summ Sat5df5_m4

predict curedf5_m4, cure
summ curedf5_m4	  

* Model 5. Non-mixture cure (FPM, 3df), SMR=2.5, 15-year boundary knot (will want to try other boundary knots), without age in model

stpm2, df(3) scale(h) bknots(0.01 15) bhazard(rate) cure
estimates store stpm2_m5
estat ic
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m5) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m5
summ rmst_m5_lci
summ rmst_m5_uci
}		

if _rc!=0 {
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m5) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m5
summ rmst_m5_lci
summ rmst_m5_uci
}	
}			
         
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m5)
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m5) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m5) split(`=1/12'))       
standsurv if dataset==1, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m5) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m5 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m5 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"	
  
integ surv_m5 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df3_m5 = surv_m5 if tt>19.98 & tt<20.02
summ Sat20df3_m5
gen Sat10df3_m5 = surv_m5 if tt>9.98 & tt<10.02
summ Sat10df3_m5
gen Sat5df3_m5 = surv_m5 if tt>4.98 & tt<5.02
summ Sat5df3_m5

predict curedf3_m5, cure
summ curedf3_m5	  

* Model 6. Non-mixture cure (FPM, 5df), SMR=2.5, 15-year boundary knot (will want to try other boundary knots), without age in model

stpm2, df(5) scale(h) bknots(0.01 15) bhazard(rate) cure
estimates store stpm2_m6
estat ic
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m6) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m6
summ rmst_m6_lci
summ rmst_m6_uci
}				

if _rc!=0 {
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m6) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m6
summ rmst_m6_lci
summ rmst_m6_uci
}
}			
         
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m6)
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m6) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m6) split(`=1/12'))       
standsurv if dataset==1, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m6) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 
  
integ surv_m6 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
  
integ surv_m6 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"	
  
integ surv_m6 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df5_m6 = surv_m6 if tt>19.98 & tt<20.02
summ Sat20df5_m6
gen Sat10df5_m6 = surv_m6 if tt>9.98 & tt<10.02
summ Sat10df5_m6
gen Sat5df5_m6 = surv_m6 if tt>4.98 & tt<5.02
summ Sat5df5_m6

predict curedf5_m6, cure
summ curedf5_m6	  

*** Now above models but better - with age in the models

rcsgen age_accurate if dataset==1, df(4) orthog gen(rcsage) 

* Model 7. Mixture cure (log normal) incorporating background hazards, with age in model 

strsmix rcsage*, link(logistic) distribution(lognormal) bhazard(rate) iter(100) k1(rcsage*) k2(rcsage*)
estimates store strsmix_m7
estat ic

predict curemix_m7, cure
summ curemix_m7

gen t=.
local j=0
gen ssurv=.
gen tplot_m7=.

levelsof id if dataset==1, local(idlevs)

forvalues t=0/501 {
	gen exp_survid_t`t'=.
	gen exp_hazid_t`t'=.
	
}

* this takes quite a long time**
foreach id of local idlevs {
	capture drop t_exp 
	capture drop expsurv 
	capture drop exphaz	
	quietly { 
		stexpect3 using ".\data\popmort.dta" if id==`id' & dataset==1, agediag(age_accurate)  ///
		   datediag(datediag) pmother(sex) pmage(_age)                    ///
		   pmyear(_year) every(0.1) maxt(50)                          ///
		   pmmaxyear(1995) pmmaxage(99)
	
		 forvalues t=0/501 {
			su expsurv if inrange(t_exp*10,`=`t'-0.001',`=`t'+0.001'), meanonly
			replace exp_survid_t`t'=r(mean) if id==`id' & dataset==1
			su exphaz if inrange(t_exp*10,`=`t'-0.001',`=`t'+0.001'), meanonly
			replace exp_hazid_t`t'=r(mean) if id==`id' & dataset==1
		}
	}
}

gen S1_m7=. 
gen H1_m7 =. 

local j=0
forvalues t=0(1)500 {	
	
	local j=`j'+1
	replace t=`t'/10
	
	predict ssurv`t', timevar(t) surv
	gen ssurv_overall`t'= ssurv`t'*exp_survid_t`t'
	su ssurv_overall`t', meanonly
	replace tplot_m7=`t'/10 in `j'
	replace S1_m7=r(mean) in `j'
	
	predict hazard`t', timevar(t) hazard
	gen haz_overall`t'= ssurv_overall`t'*(hazard`t' + exp_hazid_t`t')
	su haz_overall`t'
	local sumh=r(sum)
	su ssurv_overall`t'
	local sums=r(sum)
	replace tplot_m7=`t'/10 in `j'
	replace H1_m7=`sumh'/`sums' in `j'
	drop exp_hazid_t`t' hazard`t' haz_overall`t'
	drop exp_survid_t`t' ssurv_overall`t' ssurv`t'
	
}

integ S1_m7 tplot_m7 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_m7 tplot_m7  if tplot_m7<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_m7 tplot_m7  if tplot_m7<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20mix_m7 = S1_m7 if tplot_m7>19.98 & tplot_m7<20.02
summ Sat20mix_m7
gen Sat10mix_m7 = S1_m7 if tplot_m7>9.98 & tplot_m7<10.02
summ Sat10mix_m7
gen Sat5mix_m7 = S1_m7 if tplot_m7>4.98 & tplot_m7<5.02
summ Sat5mix_m7

capture drop  exp_survid_t* exp_hazid_t*  
capture drop ssurv* hazard* haz_overall* 
capture drop t ssurv*  
capture drop hazard*
capture drop t_exp 
capture drop expsurv exphaz

* Model 8. Mixture cure (Weibull) incorporating background hazards, with age in model  
* Does not converge
strsmix rcsage*, link(logistic) distribution(weibull) bhazard(rate) iter(100) k1(rcsage*) k2(rcsage*)
estimates store strsmix_m8
estat ic

predict curemix_m8, cure
summ curemix_m8

gen t=.
local j=0
gen ssurv=.
gen tplot_m8=.

levelsof id if dataset==1, local(idlevs)

forvalues t=0/501 {
	gen exp_survid_t`t'=.
	gen exp_hazid_t`t'=.
	
}

* this takes quite a long time**
foreach id of local idlevs {
	capture drop t_exp 
	capture drop expsurv 
	capture drop exphaz	
	quietly { 
		stexpect3 using ".\data\popmort.dta" if id==`id' & dataset==1, agediag(age_accurate)  ///
		   datediag(datediag) pmother(sex) pmage(_age)                    ///
		   pmyear(_year) every(0.1) maxt(50)                          ///
		   pmmaxyear(1995) pmmaxage(99)
	
		 forvalues t=0/501 {
			su expsurv if inrange(t_exp*10,`=`t'-0.001',`=`t'+0.001'), meanonly
			replace exp_survid_t`t'=r(mean) if id==`id' & dataset==1
			su exphaz if inrange(t_exp*10,`=`t'-0.001',`=`t'+0.001'), meanonly
			replace exp_hazid_t`t'=r(mean) if id==`id' & dataset==1
		}
	}
}


gen S1_m8=. 
gen H1_m8 =. 

local j=0
forvalues t=0(1)500 {	
	
	local j=`j'+1
	replace t=`t'/10
	
	predict ssurv`t', timevar(t) surv
	gen ssurv_overall`t'= ssurv`t'*exp_survid_t`t'
	su ssurv_overall`t', meanonly
	replace tplot_m8=`t'/10 in `j'
	replace S1_m8=r(mean) in `j'
	
	predict hazard`t', timevar(t) hazard
	gen haz_overall`t'= ssurv_overall`t'*(hazard`t' + exp_hazid_t`t')
	su haz_overall`t'
	local sumh=r(sum)
	su ssurv_overall`t'
	local sums=r(sum)
	replace tplot_m8=`t'/10 in `j'
	replace H1_m8=`sumh'/`sums' in `j'
	drop exp_hazid_t`t' hazard`t' haz_overall`t'
	drop exp_survid_t`t' ssurv_overall`t' ssurv`t'
	
}

integ S1_m8 tplot_m8 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_m8 tplot_m8  if tplot_m8<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_m8 tplot_m8  if tplot_m8<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20mix_m8 = S1_m8 if tplot_m8>19.98 & tplot_m8<20.02
summ Sat20mix_m8
gen Sat10mix_m8 = S1_m8 if tplot_m8>9.98 & tplot_m8<10.02
summ Sat10mix_m8
gen Sat5mix_m8 = S1_m8 if tplot_m8>4.98 & tplot_m8<5.02
summ Sat5mix_m8

capture drop  exp_survid_t* exp_hazid_t*  
capture drop ssurv* hazard* haz_overall* 
capture drop t ssurv*  
capture drop hazard*
capture drop t_exp 
capture drop expsurv exphaz

* Model 9. Non-mixture cure (FPM, 3df), SMR=2.5, 5-year boundary knot (will want to try other boundary knots), with age in model
capture stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(3) scale(h) bknots(0.01 5) bhazard(rate) cure

if _rc==0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(3) scale(h) bknots(0.01 5) bhazard(rate) cure	
}

if _rc!=0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(2) df(3) scale(h) bknots(0.01 5) bhazard(rate) cure	
}

estimates store stpm2_m9
estat ic
* standsurv rmst may not run for this model: max iterations of Dormand Prince method may be exceeded. Can integrate to estimate RMST instead
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m9) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 
			
if _rc==0 {
summ rmst_m9
summ rmst_m9_lci
summ rmst_m9_uci
}			

if _rc!=0 {
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m9) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m9
summ rmst_m9_lci
summ rmst_m9_uci
}
}			
         
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m9)
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m9) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m9) split(`=1/12'))       
standsurv if dataset==1, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m9) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m9 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"	
  
integ surv_m9 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"	
  
integ surv_m9 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df3_m9 = surv_m9 if tt>19.98 & tt<20.02
summ Sat20df3_m9
gen Sat10df3_m9 = surv_m9 if tt>9.98 & tt<10.02
summ Sat10df3_m9
gen Sat5df3_m9 = surv_m9 if tt>4.98 & tt<5.02
summ Sat5df3_m9

predict curedf3_m9, cure
summ curedf3_m9	  

* Model 10. Non-mixture cure (FPM, 5df), SMR=2.5, 5-year boundary knot (will want to try other boundary knots), with age in model
capture stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(5) scale(h) bknots(0.01 5) bhazard(rate) cure
if _rc==0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(5) scale(h) bknots(0.01 5) bhazard(rate) cure
}

if _rc!=0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(2) df(5) scale(h) bknots(0.01 5) bhazard(rate) cure
}

estimates store stpm2_m10
estat ic
* standsurv rmst may not run for this model: max iterations of Dormand Prince method may be exceeded. Can integrate to estimate RMST instead
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m10) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m10
summ rmst_m10_lci
summ rmst_m10_uci
}

if _rc!=0 {
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m10) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m10
summ rmst_m10_lci
summ rmst_m10_uci
}
}			
         
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m10)
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m10) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m10) split(`=1/12'))       
standsurv if dataset==1, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m10) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m10 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"	

integ surv_m10 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"	
  
integ surv_m10 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df5_m10 = surv_m10 if tt>19.98 & tt<20.02
summ Sat20df5_m10
gen Sat10df5_m10 = surv_m10 if tt>9.98 & tt<10.02
summ Sat10df5_m10
gen Sat5df5_m10 = surv_m10 if tt>4.98 & tt<5.02
summ Sat5df5_m10

predict curedf5_m10, cure
summ curedf5_m10	  

* Model 11. Non-mixture cure (FPM, 3df), SMR=2.5, 15-year boundary knot (will want to try other boundary knots), with age in model
capture stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(3) scale(h) bknots(0.01 15) bhazard(rate) cure

if _rc==0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(3) scale(h) bknots(0.01 15) bhazard(rate) cure
}

if _rc!=0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(2) df(3) scale(h) bknots(0.01 15) bhazard(rate) cure
}

estimates store stpm2_m11
estat ic
* standsurv rmst may not run for this model: max iterations of Dormand Prince method may be exceeded. Can integrate to estimate RMST instead
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m11) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m11
summ rmst_m11_lci
summ rmst_m11_uci
}

if _rc!=0 {
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m11) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m11
summ rmst_m11_lci
summ rmst_m11_uci
}
}			
         
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m11)
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m11) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m11) split(`=1/12'))       
standsurv if dataset==1, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m11) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m11 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"	

integ surv_m11 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"	
  
integ surv_m11 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df3_m11 = surv_m11 if tt>19.98 & tt<20.02
summ Sat20df3_m11
gen Sat10df3_m11 = surv_m11 if tt>9.98 & tt<10.02
summ Sat10df3_m11
gen Sat5df3_m11 = surv_m11 if tt>4.98 & tt<5.02
summ Sat5df3_m11

predict curedf3_m11, cure
summ curedf3_m11	  

* Model 12. Non-mixture cure (FPM, 5df), SMR=2.5, 15-year boundary knot (will want to try other boundary knots), with age in model
capture stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(5) scale(h) bknots(0.01 15) bhazard(rate) cure
if _rc==0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(5) scale(h) bknots(0.01 15) bhazard(rate) cure
}

if _rc!=0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(2) df(5) scale(h) bknots(0.01 15) bhazard(rate) cure
}

estimates store stpm2_m12
estat ic
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m12) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m12
summ rmst_m12_lci
summ rmst_m12_uci
}

if _rc!=0 {
capture standsurv if dataset==1, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m12) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m12
summ rmst_m12_lci
summ rmst_m12_uci
}
}			
         
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m12)
standsurv if dataset==1, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m12) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m12) split(`=1/12'))       
standsurv if dataset==1, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m12) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m12 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m12 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"	
  
integ surv_m12 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df5_m12 = surv_m12 if tt>19.98 & tt<20.02
summ Sat20df5_m12
gen Sat10df5_m12 = surv_m12 if tt>9.98 & tt<10.02
summ Sat10df5_m12
gen Sat5df5_m12 = surv_m12 if tt>4.98 & tt<5.02
summ Sat5df5_m12

predict curedf5_m12, cure
summ curedf5_m12	  

* Model 13. Standard FPM incorporating background hazards, without age 
stpm2, scale(h) df(4) bhazard(rate) 
estimates store stpm2_nc_m13
estat ic
predict S_m13, surv timevar(t_exp50_24)
gen S1_m13 = S_m13*expsurv50_24
predict H_m13, hazard timevar(t_exp50_24)
gen H1_m13 = H_m13 + exphaz50_24
integ S1_m13 t_exp50_24 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_m13 t_exp50_24  if t_exp50_24<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_m13 t_exp50_24  if t_exp50_24<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20_m13 = S1_m13 if t_exp50_24>19.98 & t_exp50_24<20.02
summ Sat20_m13
gen Sat10_m13 = S1_m13 if t_exp50_24>9.98 & t_exp50_24<10.02
summ Sat10_m13
gen Sat5_m13 = S1_m13 if t_exp50_24>4.98 & t_exp50_24<5.02
summ Sat5_m13

*********************************************************************************
*** 48-month dataset

* for the 48 month models, run stexpect on the 48 month dataset
stset OS_mm if dataset==2, failure(dead) id(id) scale(12) 
stexpect3 using ".\data\popmort.dta" if dataset==2, agediag(age_accurate) datediag(datediag) pmother(sex) pmage(_age) pmyear(_year) every(0.05) maxt(50) pmmaxyear(1995) pmmaxage(99)
rename t_exp t_exp50_48
rename expsurv expsurv50_48
rename  exphaz exphaz50_48

* Model 14. Mixture cure (log normal) incorporating background hazards, without age in model  
strsmix, link(logistic) distribution(lognormal) bhazard(rate) iter(30)
estimates store strsmix_m14
estat ic
predict S_MC_ln_m14, surv timevar(t_exp50_48)
gen S1_MC_ln_m14 = S_MC_ln_m14*expsurv50_48
predict H_ln_m14, hazard timevar(t_exp50_48)
gen H1_ln_m14 = H_ln_m14 + exphaz50_48
integ S1_MC_ln_m14 t_exp50_48 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_MC_ln_m14 t_exp50_48  if t_exp50_48<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_MC_ln_m14 t_exp50_48  if t_exp50_48<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20mixln_m14 = S1_MC_ln_m14 if t_exp50_48>19.98 & t_exp50_48<20.02
summ Sat20mixln_m14
gen Sat10mixln_m14 = S1_MC_ln_m14 if t_exp50_48>9.98 & t_exp50_48<10.02
summ Sat10mixln_m14
gen Sat5mixln_m14 = S1_MC_ln_m14 if t_exp50_48>4.98 & t_exp50_48<5.02
summ Sat5mixln_m14

predict curemixln_m14, cure
summ curemixln_m14

* Model 15. Mixture cure (Weibull) incorporating background hazards, without age in model  
strsmix, link(logistic) distribution(weibull) bhazard(rate) iter(30)
estimates store strsmix_m15
estat ic
predict S_MC_weib_m15, surv timevar(t_exp50_48)
gen S1_MC_weib_m15 = S_MC_weib_m15*expsurv50_48
predict H_weib_m15, hazard timevar(t_exp50_48)
gen H1_weib_m15 = H_weib_m15 + exphaz50_48
integ S1_MC_weib_m15 t_exp50_48 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_MC_weib_m15 t_exp50_48  if t_exp50_48<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_MC_weib_m15 t_exp50_48  if t_exp50_48<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20mixweib_m15 = S1_MC_weib_m15 if t_exp50_48>19.98 & t_exp50_48<20.02
summ Sat20mixweib_m15
gen Sat10mixweib_m15 = S1_MC_weib_m15 if t_exp50_48>9.98 & t_exp50_48<10.02
summ Sat10mixweib_m15
gen Sat5mixweib_m15 = S1_MC_weib_m15 if t_exp50_48>4.98 & t_exp50_48<5.02
summ Sat5mixweib_m15

predict curemixweib_m15, cure
summ curemixweib_m15

* Model 16. Non-mixture cure (FPM, 3df), SMR=2.5, 5-year boundary knot (will want to try other boundary knots), without age in model
rename tt tt_1
stpm2, df(3) scale(h) bknots(0.01 5) bhazard(rate) cure
estimates store stpm2_m16
estat ic
drop t50
gen t50=50 in 1
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m16) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m16
summ rmst_m16_lci
summ rmst_m16_uci
}

if _rc!=0 {
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m16) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m16
summ rmst_m16_lci
summ rmst_m16_uci
}
}			
         
range tt 0 50 501     
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m16)
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m16) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m16) split(`=1/12'))       
standsurv if dataset==2, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m16) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 
summ rmst_m16
summ rmst_m16_lci
summ rmst_m16_uci

integ surv_m16 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m16 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
  
integ surv_m16 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df3_m16 = surv_m16 if tt>19.98 & tt<20.02
summ Sat20df3_m16
gen Sat10df3_m16 = surv_m16 if tt>9.98 & tt<10.02
summ Sat10df3_m16
gen Sat5df3_m16 = surv_m16 if tt>4.98 & tt<5.02
summ Sat5df3_m16

predict curedf3_m16, cure
summ curedf3_m16	  

* Model 17. Non-mixture cure (FPM, 5df), SMR=2.5, 5-year boundary knot (will want to try other boundary knots), without age in model

stpm2, df(5) scale(h) bknots(0.01 5) bhazard(rate) cure
estimates store stpm2_m17
estat ic
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m17) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m17
summ rmst_m17_lci
summ rmst_m17_uci
}

if _rc!=0 {
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m17) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m17
summ rmst_m17_lci
summ rmst_m17_uci
}
}				
         
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m17)
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m17) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m17) split(`=1/12'))       
standsurv if dataset==2, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m17) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m17 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m17 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
  
integ surv_m17 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df5_m17 = surv_m17 if tt>19.98 & tt<20.02
summ Sat20df5_m17
gen Sat10df5_m17 = surv_m17 if tt>9.98 & tt<10.02
summ Sat10df5_m17
gen Sat5df5_m17 = surv_m17 if tt>4.98 & tt<5.02
summ Sat5df5_m17

predict curedf5_m17, cure
summ curedf5_m17	  

* Model 18. Non-mixture cure (FPM, 3df), SMR=2.5, 15-year boundary knot (will want to try other boundary knots), without age in model

stpm2, df(3) scale(h) bknots(0.01 15) bhazard(rate) cure
estimates store stpm2_m18
estat ic
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m18) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m18
summ rmst_m18_lci
summ rmst_m18_uci
}

if _rc!=0 {
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m18) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m18
summ rmst_m18_lci
summ rmst_m18_uci
}
}				
         
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m18)
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m18) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m18) split(`=1/12'))       
standsurv if dataset==2, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m18) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m18 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m18 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
  
integ surv_m18 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df3_m18 = surv_m18 if tt>19.98 & tt<20.02
summ Sat20df3_m18
gen Sat10df3_m18 = surv_m18 if tt>9.98 & tt<10.02
summ Sat10df3_m18
gen Sat5df3_m18 = surv_m18 if tt>4.98 & tt<5.02
summ Sat5df3_m18

predict curedf3_m18, cure
summ curedf3_m18	  

* Model 19. Non-mixture cure (FPM, 5df), SMR=2.5, 15-year boundary knot (will want to try other boundary knots), without age in model

stpm2, df(5) scale(h) bknots(0.01 15) bhazard(rate) cure
estimates store stpm2_m19
estat ic
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m19) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m19
summ rmst_m19_lci
summ rmst_m19_uci
}

if _rc!=0 {
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m19) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m19
summ rmst_m19_lci
summ rmst_m19_uci
}
}				
         
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m19)
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m19) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m19) split(`=1/12'))       
standsurv if dataset==2, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m19) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m19 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m19 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
  
integ surv_m19 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df5_m19 = surv_m19 if tt>19.98 & tt<20.02
summ Sat20df5_m19
gen Sat10df5_m19 = surv_m19 if tt>9.98 & tt<10.02
summ Sat10df5_m19
gen Sat5df5_m19 = surv_m19 if tt>4.98 & tt<5.02
summ Sat5df5_m19

predict curedf5_m19, cure
summ curedf5_m19	  

*** Now above models but better - with age in the models
drop rcsage*
rcsgen age_accurate if dataset==2, df(4) orthog gen(rcsage) 

* Model 20. Mixture cure (log normal) incorporating background hazards, with age in model 

strsmix rcsage*, link(logistic) distribution(lognormal) bhazard(rate) iter(100) k1(rcsage*) k2(rcsage*)
estimates store strsmix_m20
estat ic

predict curemix_m20, cure
summ curemix_m20

gen t=.
local j=0
gen ssurv=.
gen tplot_m20=.

levelsof id if dataset==2, local(idlevs)

forvalues t=0/501 {
	gen exp_survid_t`t'=.
	gen exp_hazid_t`t'=.
	
}

* this takes quite a long time**
foreach id of local idlevs {
	capture drop t_exp 
	capture drop expsurv 
	capture drop exphaz	
	quietly { 
		stexpect3 using ".\data\popmort.dta" if id==`id' & dataset==2, agediag(age_accurate)  ///
		   datediag(datediag) pmother(sex) pmage(_age)                    ///
		   pmyear(_year) every(0.1) maxt(50)                          ///
		   pmmaxyear(1995) pmmaxage(99)
	
		 forvalues t=0/501 {
			su expsurv if inrange(t_exp*10,`=`t'-0.001',`=`t'+0.001'), meanonly
			replace exp_survid_t`t'=r(mean) if id==`id' & dataset==2
			su exphaz if inrange(t_exp*10,`=`t'-0.001',`=`t'+0.001'), meanonly
			replace exp_hazid_t`t'=r(mean) if id==`id' & dataset==2
		}
	}
}


gen S1_m20=. 
gen H1_m20 =. 

local j=0
forvalues t=0(1)500 {	
	
	local j=`j'+1
	replace t=`t'/10
	
	predict ssurv`t', timevar(t) surv
	gen ssurv_overall`t'= ssurv`t'*exp_survid_t`t'
	su ssurv_overall`t', meanonly
	replace tplot_m20=`t'/10 in `j'
	replace S1_m20=r(mean) in `j'
	
	predict hazard`t', timevar(t) hazard
	gen haz_overall`t'= ssurv_overall`t'*(hazard`t' + exp_hazid_t`t')
	su haz_overall`t'
	local sumh=r(sum)
	su ssurv_overall`t'
	local sums=r(sum)
	replace tplot_m20=`t'/10 in `j'
	replace H1_m20=`sumh'/`sums' in `j'
	drop exp_hazid_t`t' hazard`t' haz_overall`t'
	drop exp_survid_t`t' ssurv_overall`t' ssurv`t'
	
}

integ S1_m20 tplot_m20 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_m20 tplot_m20  if tplot_m20<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_m20 tplot_m20  if tplot_m20<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20mix_m20 = S1_m20 if tplot_m20>19.98 & tplot_m20<20.02
summ Sat20mix_m20
gen Sat10mix_m20 = S1_m20 if tplot_m20>9.98 & tplot_m20<10.02
summ Sat10mix_m20
gen Sat5mix_m20 = S1_m20 if tplot_m20>4.98 & tplot_m20<5.02
summ Sat5mix_m20

capture drop  exp_survid_t* exp_hazid_t*  
capture drop ssurv* hazard* haz_overall* 
capture drop t ssurv*  
capture drop hazard*
capture drop t_exp 
capture drop expsurv exphaz

* Model 21. Mixture cure (Weibull) incorporating background hazards, with age in model  
strsmix rcsage*, link(logistic) distribution(weibull) bhazard(rate) iter(100) k1(rcsage*) k2(rcsage*)
estimates store strsmix_m21
estat ic

predict curemix_m21, cure
summ curemix_m21

gen t=.
local j=0
gen ssurv=.
gen tplot_m21=.

levelsof id if dataset==2, local(idlevs)

forvalues t=0/501 {
	gen exp_survid_t`t'=.
	gen exp_hazid_t`t'=.
	
}

* this takes quite a long time**
foreach id of local idlevs {
	capture drop t_exp 
	capture drop expsurv 
	capture drop exphaz	
	quietly { 
		stexpect3 using ".\data\popmort.dta" if id==`id' & dataset==2, agediag(age_accurate)  ///
		   datediag(datediag) pmother(sex) pmage(_age)                    ///
		   pmyear(_year) every(0.1) maxt(50)                          ///
		   pmmaxyear(1995) pmmaxage(99)
	
		 forvalues t=0/501 {
			su expsurv if inrange(t_exp*10,`=`t'-0.001',`=`t'+0.001'), meanonly
			replace exp_survid_t`t'=r(mean) if id==`id' & dataset==2
			su exphaz if inrange(t_exp*10,`=`t'-0.001',`=`t'+0.001'), meanonly
			replace exp_hazid_t`t'=r(mean) if id==`id' & dataset==2
		}
	}
}

gen S1_m21=. 
gen H1_m21 =. 

local j=0
forvalues t=0(1)500 {	
	
	local j=`j'+1
	replace t=`t'/10
	
	predict ssurv`t', timevar(t) surv
	gen ssurv_overall`t'= ssurv`t'*exp_survid_t`t'
	su ssurv_overall`t', meanonly
	replace tplot_m21=`t'/10 in `j'
	replace S1_m21=r(mean) in `j'
	
	predict hazard`t', timevar(t) hazard
	gen haz_overall`t'= ssurv_overall`t'*(hazard`t' + exp_hazid_t`t')
	su haz_overall`t'
	local sumh=r(sum)
	su ssurv_overall`t'
	local sums=r(sum)
	replace tplot_m21=`t'/10 in `j'
	replace H1_m21=`sumh'/`sums' in `j'
	drop exp_hazid_t`t' hazard`t' haz_overall`t'
	drop exp_survid_t`t' ssurv_overall`t' ssurv`t'
	
}


integ S1_m21 tplot_m21 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_m21 tplot_m21  if tplot_m21<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_m21 tplot_m21  if tplot_m21<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20mix_m21 = S1_m21 if tplot_m21>19.98 & tplot_m21<20.02
summ Sat20mix_m21
gen Sat10mix_m21 = S1_m21 if tplot_m21>9.98 & tplot_m21<10.02
summ Sat10mix_m21
gen Sat5mix_m21 = S1_m21 if tplot_m21>4.98 & tplot_m21<5.02
summ Sat5mix_m21

drop t ssurv  t_exp expsurv exphaz

capture drop  exp_survid_t* exp_hazid_t*  
capture drop ssurv* hazard* haz_overall*
capture drop t ssurv expsurv exphaz

* Model 22. Non-mixture cure (FPM, 3df), SMR=2.5, 5-year boundary knot (will want to try other boundary knots), with age in model
capture stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(3) scale(h) bknots(0.01 5) bhazard(rate) cure

if _rc==0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(3) scale(h) bknots(0.01 5) bhazard(rate) cure
}

if _rc!=0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(2) df(3) scale(h) bknots(0.01 5) bhazard(rate) cure
}

estimates store stpm2_m22
estat ic
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m22) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m22
summ rmst_m22_lci
summ rmst_m22_uci
}

if _rc!=0 {
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m22) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m22
summ rmst_m22_lci
summ rmst_m22_uci
}
}				
         
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m22)
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m22) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m22) split(`=1/12'))       
standsurv if dataset==2, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m22) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m22 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m22 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
  
integ surv_m22 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df3_m22 = surv_m22 if tt>19.98 & tt<20.02
summ Sat20df3_m22
gen Sat10df3_m22 = surv_m22 if tt>9.98 & tt<10.02
summ Sat10df3_m22
gen Sat5df3_m22 = surv_m22 if tt>4.98 & tt<5.02
summ Sat5df3_m22

predict curedf3_m22, cure
summ curedf3_m22	  

* Model 23. Non-mixture cure (FPM, 5df), SMR=2.5, 5-year boundary knot (will want to try other boundary knots), with age in model
capture stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(5) scale(h) bknots(0.01 5) bhazard(rate) cure

if _rc==0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(5) scale(h) bknots(0.01 5) bhazard(rate) cure
}

if _rc!=0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(2) df(5) scale(h) bknots(0.01 5) bhazard(rate) cure
}

estimates store stpm2_m23
estat ic
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m23) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m23
summ rmst_m23_lci
summ rmst_m23_uci
}

if _rc!=0 {
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m23) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m23
summ rmst_m23_lci
summ rmst_m23_uci
}
}				
         
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m23)
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m23) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m23) split(`=1/12'))       
standsurv if dataset==2, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m23) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m23 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m23 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
  
integ surv_m23 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df5_m23 = surv_m23 if tt>19.98 & tt<20.02
summ Sat20df5_m23
gen Sat10df5_m23 = surv_m23 if tt>9.98 & tt<10.02
summ Sat10df5_m23
gen Sat5df5_m23 = surv_m23 if tt>4.98 & tt<5.02
summ Sat5df5_m23

predict curedf5_m23, cure
summ curedf5_m23	  

* Model 24. Non-mixture cure (FPM, 3df), SMR=2.5, 15-year boundary knot (will want to try other boundary knots), with age in model
capture stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(3) scale(h) bknots(0.01 15) bhazard(rate) cure

if _rc==0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(3) scale(h) bknots(0.01 15) bhazard(rate) cure
}

if _rc!=0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(2) df(3) scale(h) bknots(0.01 15) bhazard(rate) cure
}

estimates store stpm2_m24
estat ic
* standsurv rmst may not run for this model: max iterations of Dormand Prince method may be exceeded. Can integrate to estimate RMST instead
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m24) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m24
summ rmst_m24_lci
summ rmst_m24_uci
}

if _rc!=0 {
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m24) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 

if _rc==0 {
summ rmst_m24
summ rmst_m24_lci
summ rmst_m24_uci
}			
}				
         
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m24)
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m24) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m24) split(`=1/12'))       
standsurv if dataset==2, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m24) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m24 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m24 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
  
integ surv_m24 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df3_m24 = surv_m24 if tt>19.98 & tt<20.02
summ Sat20df3_m24
gen Sat10df3_m24 = surv_m24 if tt>9.98 & tt<10.02
summ Sat10df3_m24
gen Sat5df3_m24 = surv_m24 if tt>4.98 & tt<5.02
summ Sat5df3_m24

predict curedf3_m24, cure
summ curedf3_m24	  

* Model 25. Non-mixture cure (FPM, 5df), SMR=2.5, 15-year boundary knot (will want to try other boundary knots), with age in model
capture stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(5) scale(h) bknots(0.01 15) bhazard(rate) cure

if _rc==0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(3) df(5) scale(h) bknots(0.01 15) bhazard(rate) cure
}

if _rc!=0 {
stpm2 rcsage*, tvc(rcsage*) dftvc(2) df(5) scale(h) bknots(0.01 15) bhazard(rate) cure
}	

estimates store stpm2_m25
estat ic
* standsurv rmst may not run for this model: max iterations of Dormand Prince method may be exceeded. Can integrate to estimate RMST instead
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m25) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12'))
			
if _rc==0 {
summ rmst_m25
summ rmst_m25_lci
summ rmst_m25_uci
}

if _rc!=0 {
capture standsurv if dataset==2, rmst ci             ///
           timevar(t50)        ///
           at1(.) atvars(rmst_m25) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) ///
			odeoptions(reltol(1e-2)) 
if _rc==0 {
summ rmst_m25
summ rmst_m25_lci
summ rmst_m25_uci
}
}				
         
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(rel_surv_m25)
standsurv if dataset==2, surv ci             ///
           timevar(tt)        ///
           at1(.) atvars(surv_m25) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.)  expsurvvars(surv_exp_m25) split(`=1/12'))       
standsurv if dataset==2, hazard ci             ///
           timevar(tt)        ///
           at1(.) atvars(haz_m25) ///
            expsurv(using(".\data\popmort.dta")  ///
            agediag(age_accurate) datediag(datediag) ///
            pmother(sex) pmrate(rate) pmage(_age) pmyear(_year) pmmaxage(99) pmmaxyear(2000) ///
            at1(.) split(`=1/12')) 

integ surv_m25 tt 
display "RMST at 50 years: " %5.3f `r(integral)' " years"

integ surv_m25 tt if tt<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
  
integ surv_m25 tt if tt<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"	  
	  
gen Sat20df5_m25 = surv_m25 if tt>19.98 & tt<20.02
summ Sat20df5_m25
gen Sat10df5_m25 = surv_m25 if tt>9.98 & tt<10.02
summ Sat10df5_m25
gen Sat5df5_m25 = surv_m25 if tt>4.98 & tt<5.02
summ Sat5df5_m25

predict curedf5_m25, cure
summ curedf5_m25	  

* Model 26. Standard FPM incorporating background hazards 
stpm2, scale(h) df(4) bhazard(rate) 
estimates store stpm2_nc_m26
estat ic
predict S_m26, surv timevar(t_exp50_24)
gen S1_m26 = S_m26*expsurv50_24
predict H_m26, hazard timevar(t_exp50_24)
gen H1_m26 = H_m26 + exphaz50_24
integ S1_m26 t_exp50_24 
display "RMST at 50 years: " %5.3f `r(integral)' " years"
integ S1_m26 t_exp50_24  if t_exp50_24<=20.02
display "RMST at 20 years: " %5.3f `r(integral)' " years"
integ S1_m26 t_exp50_24  if t_exp50_24<=10.02
display "RMST at 10 years: " %5.3f `r(integral)' " years"
gen Sat20_m26 = S1_m26 if t_exp50_24>19.98 & t_exp50_24<20.02
summ Sat20_m26
gen Sat10_m26 = S1_m26 if t_exp50_24>9.98 & t_exp50_24<10.02
summ Sat10_m26
gen Sat5_m26 = S1_m26 if t_exp50_24>4.98 & t_exp50_24<5.02
summ Sat5_m26

************** Save dataset for curve plots

save ".\data\distant_nocure_models_for_plots_SMR1.dta", replace

* now inspect which models converged
