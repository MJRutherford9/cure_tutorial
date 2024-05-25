program define stexpectind
  version 17.0
  syntax newvarlist          using/                           ///
         [if] [in]                                            ///
         ,                                                    ///
         AGEDiag(varname)                                     ///
         DATEDiag(varname)                                    ///
         [                                                    ///  
         id(varname)                                          ///
         PMAge(string)                                        ///
         PMOther(string)                                      ///
         PMRate(string)                                       ///
         PMYear(string)                                       ///
         PMMAXAge(real 99)                                    ///
         PMMAXYear(real 10000)                                ///
         SAVEEXPAND(string)                                   ///
         TIMES(numlist)                                       ///
         TIMEVar(varname)                                     ///
         ]


  marksample touse, novarlist
         
// check only one of times() and timevar() used    
  if "`times'" != "" &  "`timevar'" != "" {
    di as error "Only one of the times() and timevar() options can be used"
    exit 198
  }

// check at least one of times() and timevar() options used  
  if wordcount("`times' `timevar'") ==0 {
    di as error "You must use either the times() and timevar() options can be used"
    exit 198
  }
 
    local Nnewvars = wordcount("`varlist'")
 
  
// Times
  if "`times'" != "" {
    local Ntimes  = wordcount("`times'")
    local maxtime = word("`times'",`Ntimes')
  // Number of newvars much match times
    if `Nnewvars' != `Ntimes' {
      di as error "The number of new variables should match the number of times"
      exit 198
    }
    local timesoption timesoption
  }
  
// 
  if "`timevar'" != "" {
    qui levelsof `timevar' if `timevar'>0 
    local Ntimes `r(r)'
    local times `r(levels)'
    local maxtime = word("`times'",`Ntimes')
    if `Nnewvars' != 1 {
      di as error "you can only specifiy one new variable when using the timevar() option"
    }
    qui count if `timevar' == 0
    if `r(N)'>1 {
      di as err "There is more than one zero in the timevar variable."
      exit 198
    }
    local timevar_has0 = `r(N)'>0
  }

*******************     
// popmort file ///
*******************
  if "`pmage'" == ""  local pmage _age
  if "`pmyear'" == "" local pmyear _year
  if "`pmrate'" == "" local pmrate rate  
  local pmfile `using'
  qui describe using "`pmfile'", varlist short
  local popmortvars `r(varlist)'
  foreach var in `pmage' `pmyear' `pmother' `pmrate' {
    local varinpopmort:list posof "`var'" in popmortvars
    if !`varinpopmort' {
      di "`var' is not in popmort file"
      exit 198
    }
  }  
  

  if "`id'" == "" {
    tempvar id
    gen `id' = _n
  }
  tempname expand
  local Nexpand = ceil(`maxtime')*2 + 1
  tempvar tage tdate agefirst
  gen double `tage' = ceil(`agediag'+1e-12) - `agediag'
  gen double `tdate' = (mdy(1,1,year(`datediag') + 1) - `datediag')/365.24
  gen `agefirst' = (`tage'<=`tdate')

  frame put `id' `agediag' `datediag' `pmother' `tage' `tdate' ///
            `agefirst'  if `touse', into(`expand')

  frame `expand' {
    qui expand `Nexpand'
    bysort `id': gen rownum = _n
    qui bysort `id' (rownum): gen agechange = mod(rownum,2) if `agefirst'
    qui replace agechange = mod(rownum-1,2) if !`agefirst'
    gen yearchange = 1 - agechange
    gen yearfu = floor((rownum-1)/2)

    gen double stop = yearfu + cond(agechange,`tage',`tdate')
    qui bysort `id' (rownum): gen double start = stop[_n-1]
    qui bysort `id' (rownum): replace start = 0 if _n==1
    
    gen risktime = stop - start
    
    qui gen `pmage'  = yearfu + floor(`agediag')
    qui replace `pmage' = `pmage' + yearchange if `agefirst'
    qui replace `pmage' = min(`pmage',`pmmaxage')
    gen `pmyear' = yearfu + year(`datediag')
    qui replace `pmyear' = `pmyear' + agechange if !`agefirst'
    qui replace `pmyear' = min(`pmyear',`pmmaxyear')
   
    qui  merge m:1 `pmage' `pmyear' `pmother' using `pmfile', keepusing(`pmrate') keep(master match)    
    bysort `id' (rownum): gen ch = sum(`pmrate'*risktime)

    
    forvalues i = 1/`Ntimes' {
      tempvar select`i'
      local t = word("`times'",`i')
      qui gen double diff = stop - `t'
      
//      qui bysort `id' (rownum): egen mindiff = min(diff) if diff >=0
//      qui bysort `id' (rownum): gen `select`i'' = float(mindiff)== float(diff)
//      qui gen Sstar`i' = exp(-(ch - `pmrate'*diff)) if `select`i''

      qui replace diff = . if diff<0
      qui bysort `id' (diff): gen Sstar`i' = exp(-(ch - `pmrate'*diff)) if _n==1
      qui bysort `id' (diff): gen `select`i'' = _n==1
      
      tempname Sstar`i'
      qui frame put `id' Sstar`i' if `select`i'', into(`Sstar`i'')
      drop diff 
      cap drop mindiff
    }
    if "`saveexpand'" != "" {
      keep `id' `agediag' `dx' `pmother' start stop `pmage' `pmyear' rate risktime ch Sstar*
      save `saveexpand'
    }
  }   
  if "`timesoption'" != "" {
      forvalues i = 1/`Ntimes' {
        local newvar = word("`varlist'",`i')
        local t = word("`times'",`i')  
        qui frlink 1:1 `id' , frame(`Sstar`i'')
        qui frget `newvar'= Sstar`i', from(`Sstar`i'') 
      }
  }
  if "`timevar'" != "" {
    tempname tt_Sstar
    frame create `tt_Sstar' `timevar' Sstar
    if `timevar_has0' frame post `tt_Sstar' (0) (1)
    forvalues i = 1/`Ntimes' {
      local t = word("`times'",`i')  
      frame `Sstar`i'': summ Sstar`i', meanonly
      frame post `tt_Sstar' (`t') (`r(mean)')
    }   
    qui frlink m:1 `timevar' , frame(`tt_Sstar')
    qui frget `varlist' = Sstar, from(`tt_Sstar') 

    
  }
  
end  



