# cure_tutorial

"Mixture and non-Mixture Cure Models for Health Technology Assessment: What You Need to Know"
Latimer N, Rutherford M
PharmacoEconomics Tutorial Paper, 2024

24th May 2024

This repository contains the following folders:

- ado
- code
- data

- "ado" contains "stexpect3.ado" which is required to incorporate background mortality in mixture cure models

- "code" contains 13 .do files. The "Master.do" file creates the datasets for each of the 3 scenarios analysed, and calls the other .do files to fit the models and construct the graphs. 
  Users should be able to run all of the analyses contained in the tutorial paper simply by running the "Master.do" file.

- "data" contains 3 .dta files for each of the 3 scenarios analysed, and two "popmort" datasets. 
    - The "combined..." datasets contain the datasets generated in part [3] of the "Master.do" file, to which models are subsequently fitted.
      If desired, users do not need to run part [3] of the "Master.do" file, and can instead fit models directly to these "combined..." datasets.
    - The "...models_for_plots" datasets contain the datasets created in parts [4]-[9] of the "Master.do" file, and contain the hazard and survivor functions estimated by each of the cure models.
      If desired, users do not need to run the "fit models" parts of [4]-[9] in the "Master.do" file, and can instead simply run the "constructs plots" code to generate the graphs.
    - "popmort" contains the life tables relevant to the colon cancer registry dataset
    - "popmort_SMR25" contains the life tables relevant to the colon cancer registry dataset with an SMR of 2.5 applied

Please note, this code was written primarily by Nicholas Latimer, with assistance from Mark Rutherford. Any errors (and inefficient code) are due to Nick Latimer!
