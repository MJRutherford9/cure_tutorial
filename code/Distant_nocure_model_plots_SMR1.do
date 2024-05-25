*** Distant (no cure) Model Plots with SMR=1 ***

* See "Distant_nocure_analysis_SMR1.do" for fitting of models

*** Curves ***

use ".\data\distant_nocure_models_for_plots_SMR1.dta", clear


stset OS_mm if dataset==0, failure(dead) id(id) scale(12)

*** Models 7 and 8 did not converge. Removed below

* Models 1-13, 24-month data, 50y timeframe

sts graph, ci plotopts(lwidth(medium) lpattern(dash))  /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line S1_MC_ln_m1 t_exp50_24, sort lcolor(blue) lwidth(thin)) /// 
									(line S1_MC_weib_m2 t_exp50_24, sort lcolor(orange) lwidth(thin)) /// 
									(line surv_m3 tt_1, sort lcolor(red) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m4 tt_1, sort lcolor(gold) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m5 tt_1, sort lcolor(red) lwidth(thin)) /// 
									(line surv_m6 tt_1, sort lcolor(gold) lwidth(thin)) /// 
									(line surv_m9 tt_1, sort lcolor(lime) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m10 tt_1, sort lcolor(pink) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m11 tt_1, sort lcolor(lime) lwidth(thin)) ///
									(line surv_m12 tt_1, sort lcolor(pink) lwidth(thin)) ///
									(line S1_m13 t_exp50_24, sort lcolor(green) lwidth(thin)) /// 
									(line expsurv50_b t_exp50_b, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Kaplan-Meier" 3 "Mixture cure model (log-normal)" ///
		4 "Mixture cure model (Weibull)" 5 "Non-mixture cure model, df3, 5y BK" 6 "Non-mixture cure model, df5, 5y BK" ///
		7 "Non-mixture cure model, df3, 15y BK" 8 "Non-mixture cure model, df5, 15y BK" ///
		9 "Non-mixture cure model, df3, 5y BK, age" 10 "Non-mixture cure model, df5, 5y BK, age" 11 "Non-mixture cure model, df3, 15y BK, age" ///
		12 "Non-mixture cure model, df5, 15y BK, age" 13 "FPM non-cure, df4" ///
		14 "Expected survival background population") size(vsmall)) xscale(range(0 50)) xlabel(0(5)50)) ///
		legend(pos(2) ring(0) cols(2)) title(, size(zero) nobox) ytitle(Proportion surviving) ytitle(, size(small)) ///
        ylabel(#8, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Distant_nocure_Surv50_SMR1_24m,replace)

sts graph, hazard ci plotopts(lwidth(medium) lpattern(dash)) /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line H1_ln_m1 t_exp50_24, sort lcolor(blue) lwidth(thin)) ///
									(line H1_weib_m2 t_exp50_24, sort lcolor(orange) lwidth(thin)) ///
									(line haz_m3 tt_1, sort lcolor(red) lpattern(shortdash) lwidth(thin)) ///
									(line haz_m4 tt_1, sort lcolor(gold) lpattern(shortdash) lwidth(thin)) ///
									(line haz_m5 tt_1, sort lcolor(red) lwidth(thin)) ///
									(line haz_m6 tt_1, sort lcolor(gold) lwidth(thin)) ///
									(line haz_m9 tt_1, sort lcolor(lime) lpattern(shortdash) lwidth(thin)) ///
									(line haz_m10 tt_1, sort lcolor(pink) lpattern(shortdash) lwidth(thin)) ///
									(line haz_m11 tt_1, sort lcolor(lime) lwidth(thin)) ///
									(line haz_m12 tt_1, sort lcolor(pink) lwidth(thin)) ///
									(line H1_m13 t_exp50_24, sort lcolor(green) lwidth(thin)) ///
									(line exphaz50_b t_exp50_b, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Observed smoothed hazard" 3 "Mixture cure model (log-normal)" ///
		4 "Mixture cure model (Weibull)" 5 "Non-mixture cure model, df3, 5y BK" 6 "Non-mixture cure model, df5, 5y BK" ///
		7 "Non-mixture cure model, df3, 15y BK" 8 "Non-mixture cure model, df5, 15y BK" ///
		9 "Non-mixture cure model, df3, 5y BK, age" 10 "Non-mixture cure model, df5, 5y BK, age" 11 "Non-mixture cure model, df3, 15y BK, age" ///
		12 "Non-mixture cure model, df5, 15y BK, age" 13 "FPM non-cure, df4" ///
		14 "Expected survival background population") size(vsmall)) xscale(range(0 50)) xlabel(0(5)50)) ///
		legend(pos(2) ring(0) cols(2)) title(, size(zero) nobox) ytitle(Hazard) ytitle(, size(small)) ///
        ylabel(#10, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Distant_nocure_Haz50_SMR1_24m,replace)


* Models 1-13, 24-month data, 20y timeframe

sts graph, ci plotopts(lwidth(medium) lpattern(dash))  /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line S1_MC_ln_m1 t_exp50_24 if t_exp50_24<20, sort lcolor(blue) lwidth(thin)) /// 
									(line S1_MC_weib_m2 t_exp50_24 if t_exp50_24<20, sort lcolor(orange) lwidth(thin)) /// 
									(line surv_m3 tt_1 if tt_1<20, sort lcolor(red) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m4 tt_1 if tt_1<20, sort lcolor(gold) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m5 tt_1 if tt_1<20, sort lcolor(red) lwidth(thin)) /// 
									(line surv_m6 tt_1 if tt_1<20, sort lcolor(gold) lwidth(thin)) /// 
									(line surv_m9 tt_1 if tt_1<20, sort lcolor(lime) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m10 tt_1 if tt_1<20, sort lcolor(pink) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m11 tt_1 if tt_1<20, sort lcolor(lime) lwidth(thin)) ///
									(line surv_m12 tt_1 if tt_1<20, sort lcolor(pink) lwidth(thin)) ///
									(line S1_m13 t_exp50_24 if t_exp50_24<20, sort lcolor(green) lwidth(thin)) /// 
									(line expsurv50_b t_exp50_b if t_exp50_b<20, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Kaplan-Meier" 3 "Mixture cure model (log-normal)" ///
		4 "Mixture cure model (Weibull)" 5 "Non-mixture cure model, df3, 5y BK" 6 "Non-mixture cure model, df5, 5y BK" ///
		7 "Non-mixture cure model, df3, 15y BK" 8 "Non-mixture cure model, df5, 15y BK" ///
		9 "Non-mixture cure model, df3, 5y BK, age" 10 "Non-mixture cure model, df5, 5y BK, age" 11 "Non-mixture cure model, df3, 15y BK, age" ///
		12 "Non-mixture cure model, df5, 15y BK, age" 13 "FPM non-cure, df4" ///
		14 "Expected survival background population") size(vsmall)) xscale(range(0 20)) xlabel(0(2)20)) ///
		legend(pos(2) ring(0) cols(2)) title(, size(zero) nobox) ytitle(Proportion surviving) ytitle(, size(small)) ///
        ylabel(#8, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Distant_nocure_Surv20_SMR1_24m,replace)



sts graph, hazard ci plotopts(lwidth(medium) lpattern(dash)) /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line H1_ln_m1 t_exp50_24 if t_exp50_24<20, sort lcolor(blue) lwidth(thin)) ///
									(line H1_weib_m2 t_exp50_24 if t_exp50_24<20, sort lcolor(orange) lwidth(thin)) ///
									(line haz_m3 tt_1 if tt_1<20, sort lcolor(red) lpattern(shortdash) lwidth(thin)) ///
									(line haz_m4 tt_1 if tt_1<20, sort lcolor(gold) lpattern(shortdash) lwidth(thin)) ///
									(line haz_m5 tt_1 if tt_1<20, sort lcolor(red) lwidth(thin)) ///
									(line haz_m6 tt_1 if tt_1<20, sort lcolor(gold) lwidth(thin)) ///
									(line haz_m9 tt_1 if tt_1<20, sort lcolor(lime) lpattern(shortdash) lwidth(thin)) ///
									(line haz_m10 tt_1 if tt_1<20, sort lcolor(pink) lpattern(shortdash) lwidth(thin)) ///
									(line haz_m11 tt_1 if tt_1<20, sort lcolor(lime) lwidth(thin)) ///
									(line haz_m12 tt_1 if tt_1<20, sort lcolor(pink) lwidth(thin)) ///
									(line H1_m13 t_exp50_24 if t_exp50_24<20, sort lcolor(green) lwidth(thin)) ///
									(line exphaz50_b t_exp50_b if t_exp50_b<20, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Observed smoothed hazard" 3 "Mixture cure model (log-normal)" ///
		4 "Mixture cure model (Weibull)" 5 "Non-mixture cure model, df3, 5y BK" 6 "Non-mixture cure model, df5, 5y BK" ///
		7 "Non-mixture cure model, df3, 15y BK" 8 "Non-mixture cure model, df5, 15y BK" ///
		9 "Non-mixture cure model, df3, 5y BK, age" 10 "Non-mixture cure model, df5, 5y BK, age" 11 "Non-mixture cure model, df3, 15y BK, age" ///
		12 "Non-mixture cure model, df5, 15y BK, age" 13 "FPM non-cure, df4" ///
		14 "Expected survival background population") size(vsmall)) xscale(range(0 20)) xlabel(0(2)20)) ///
		legend(pos(2) ring(0) cols(2)) title(, size(zero) nobox) ytitle(Hazard) ytitle(, size(small)) ///
        ylabel(#10, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Distant_nocure_Haz20_SMR1_24m,replace)


* selective plots for paper

sts graph, ci plotopts(lwidth(medium) lpattern(dash))  /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line S1_MC_ln_m1 t_exp50_24 if t_exp50_24<20, sort lcolor(olive) lwidth(thin)) ///
									(line S1_MC_weib_m2 t_exp50_24 if t_exp50_24<20, sort lcolor(magenta) lwidth(thin)) ///
									(line surv_m9 tt_1 if tt_1<20, sort lcolor(orange) lwidth(thin)) /// 
									(line surv_m11 tt_1 if tt_1<20, sort lcolor(red) lwidth(thin)) ///
									(line expsurv50_b t_exp50_b if t_exp50_b<20, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Kaplan-Meier" 3 "Mixture cure model (log-normal)" 4 "Mixture cure model (Weibull)" ///
		5 "Non-mixture cure model, 2 knot, 5y bk, age" 6 "Non-mixture cure model, 2 knot, 15y bk, age" ///
		7 "Expected survival background population") size(vsmall)) xscale(range(0 20)) xlabel(0(2)20)) ///
		legend(pos(2) ring(0) cols(2)) title("", size(zero) nobox) ytitle(Proportion surviving) ytitle(, size(small)) ///
        ylabel(#8, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Dist_nc_Surv20_SMR1_24m_paper,replace)



sts graph, hazard ci plotopts(lwidth(medium) lpattern(dash)) /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line H1_ln_m1 t_exp50_24 if t_exp50_24<20, sort lcolor(olive) lwidth(thin)) ///
									(line H1_weib_m2 t_exp50_24 if t_exp50_24<20, sort lcolor(magenta) lwidth(thin)) ///
									(line haz_m9 tt_1 if tt_1<20, sort lcolor(orange) lwidth(thin)) ///
									(line haz_m11 tt_1 if tt_1<20, sort lcolor(red) lwidth(thin)) ///
									(line exphaz50_b t_exp50_b if t_exp50_b<20, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Observed smoothed hazard" 3 "Mixture cure model (log-normal), age" 4 "Mixture cure model (Weibull), age" ///
		5 "Non-mixture cure model, 2 knot, 5y bk, age" 6 "Non-mixture cure model, 2 knot, 15y bk, age" ///
		7 "Expected survival background population") size(vsmall)) xscale(range(0 20)) xlabel(0(2)20)) ///
		legend(pos(2) ring(0) cols(2)) title("", size(zero) nobox) ytitle(Hazard) ytitle(, size(small)) ///
        ylabel(#10, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 2.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Dist_noc_Haz20_SMR1_24m_paper,replace)


* Models 14-26, 48-month data, 50y timeframe

sts graph, ci plotopts(lwidth(medium) lpattern(dash))  /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line S1_MC_ln_m14 t_exp50_48, sort lcolor(blue) lwidth(thin)) /// 
									(line S1_MC_weib_m15 t_exp50_48, sort lcolor(orange) lwidth(thin)) ///
									(line surv_m16 tt, sort lcolor(red) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m17 tt, sort lcolor(gold) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m18 tt, sort lcolor(red) lwidth(thin)) /// 
									(line surv_m19 tt, sort lcolor(gold) lwidth(thin)) /// 
									(line S1_m20 tplot_m20, sort lcolor(olive) lwidth(thin)) ///
									(line S1_m21 tplot_m21, sort lcolor(magenta) lwidth(thin)) /// 
									(line surv_m22 tt, sort lcolor(lime) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m23 tt, sort lcolor(pink) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m24 tt, sort lcolor(lime) lwidth(thin)) /// 
									(line surv_m25 tt, sort lcolor(pink) lwidth(thin)) ///
									(line S1_m26 t_exp50_48, sort lcolor(green) lwidth(thin)) /// 
									(line expsurv50_b t_exp50_b, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Kaplan-Meier" 3 "Mixture cure model (log-normal)" 4 "Mixture cure model (Weibull)" ///
		5 "Non-mixture cure model, df3, 5y BK" 6 "Non-mixture cure model, df5, 5y BK" ///
		7 "Non-mixture cure model, df3, 15y BK" 8 "Non-mixture cure model, df5, 15y BK" 9 "Mixture cure model (log-normal), age" 10 "Mixture cure model (Weibull), age" ///
		11 "Non-mixture cure model, df3, 5y BK, age" 12 "Non-mixture cure model, df5, 5y BK, age" ///
		13 "Non-mixture cure model, df3, 15y BK, age" 14 "Non-mixture cure model, df5, 15y BK, age" ///
		15 "FPM non-cure, df4" ///
		16 "Expected survival background population") size(vsmall)) xscale(range(0 50)) xlabel(0(5)50)) ///
		legend(pos(2) ring(0) cols(2)) title(, size(zero) nobox) ytitle(Proportion surviving) ytitle(, size(small)) ///
        ylabel(#8, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(D_nc_Surv50_SMR1_48m,replace)



sts graph, hazard ci plotopts(lwidth(medium) lpattern(dash)) /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line H1_ln_m14 t_exp50_48, sort lcolor(blue) lwidth(thin)) ///
									(line H1_weib_m15 t_exp50_48, sort lcolor(orange) lwidth(thin)) ///
									(line haz_m16 tt, sort lcolor(red) lpattern(shortdash) lwidth(thin)) /// 
									(line haz_m17 tt, sort lcolor(gold) lpattern(shortdash) lwidth(thin)) /// 
									(line haz_m18 tt, sort lcolor(red) lwidth(thin)) /// 
									(line haz_m19 tt, sort lcolor(gold) lwidth(thin)) /// 
									(line H1_m20 tplot_m20, sort lcolor(olive) lwidth(thin)) ///
									(line H1_m21 tplot_m21, sort lcolor(magenta) lwidth(thin)) /// 
									(line haz_m22 tt, sort lcolor(lime) lpattern(shortdash) lwidth(thin)) /// 
									(line haz_m23 tt, sort lcolor(pink) lpattern(shortdash) lwidth(thin)) /// 
									(line haz_m24 tt, sort lcolor(lime) lwidth(thin)) /// 
									(line haz_m25 tt, sort lcolor(pink) lwidth(thin)) ///
									(line H1_m26 t_exp50_48, sort lcolor(green) lwidth(thin)) /// 
									(line exphaz50_b t_exp50_b, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Observed smoothed hazard" 3 "Mixture cure model (log-normal)" 4 "Mixture cure model (Weibull)" ///
		5 "Non-mixture cure model, df3, 5y BK" 6 "Non-mixture cure model, df5, 5y BK" ///
		7 "Non-mixture cure model, df3, 15y BK" 8 "Non-mixture cure model, df5, 15y BK" 9 "Mixture cure model (log-normal), age" 10 "Mixture cure model (Weibull), age" ///
		11 "Non-mixture cure model, df3, 5y BK, age" 12 "Non-mixture cure model, df5, 5y BK, age" ///
		13 "Non-mixture cure model, df3, 15y BK, age" 14 "Non-mixture cure model, df5, 15y BK, age" ///
		15 "FPM non-cure, df4" ///
		16 "Expected survival background population") size(vsmall)) xscale(range(0 50)) xlabel(0(5)50)) ///
		legend(pos(2) ring(0) cols(2)) title(, size(zero) nobox) ytitle(Hazard) ytitle(, size(small)) ///
        ylabel(#10, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Distant_nocure_Haz50_SMR1_48m,replace)

* Models 14-26, 48-month data, 20y timeframe

sts graph, ci plotopts(lwidth(medium) lpattern(dash))  /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line S1_MC_ln_m14 t_exp50_48 if t_exp50_48<20, sort lcolor(blue) lwidth(thin)) ///
									(line S1_MC_weib_m15 t_exp50_48 if t_exp50_48<20, sort lcolor(orange) lwidth(thin)) /// 
									(line surv_m16 tt if tt<20, sort lcolor(red) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m17 tt if tt<20, sort lcolor(gold) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m18 tt if tt<20, sort lcolor(red) lwidth(thin)) /// 
									(line surv_m19 tt if tt<20, sort lcolor(gold) lwidth(thin)) /// 
									(line S1_m20 tplot_m20 if tplot_m20<20, sort lcolor(olive) lwidth(thin)) ///
									(line S1_m21 tplot_m21 if tplot_m21<20, sort lcolor(magenta) lwidth(thin)) /// 
									(line surv_m22 tt if tt<20, sort lcolor(lime) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m23 tt if tt<20, sort lcolor(pink) lpattern(shortdash) lwidth(thin)) /// 
									(line surv_m24 tt if tt<20, sort lcolor(lime) lwidth(thin)) /// 
									(line surv_m25 tt if tt<20, sort lcolor(pink) lwidth(thin)) ///
									(line S1_m26 t_exp50_48 if t_exp50_48<20, sort lcolor(green) lwidth(thin)) /// 
									(line expsurv50_b t_exp50_b if t_exp50_b<20, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Kaplan-Meier" 3 "Mixture cure model (log-normal)" 4 "Mixture cure model (Weibull)" ///
		5 "Non-mixture cure model, df3, 5y BK" 6 "Non-mixture cure model, df5, 5y BK" ///
		7 "Non-mixture cure model, df3, 15y BK" 8 "Non-mixture cure model, df5, 15y BK" 9 "Mixture cure model (log-normal), age" 10 "Mixture cure model (Weibull), age" ///
		11 "Non-mixture cure model, df3, 5y BK, age" 12 "Non-mixture cure model, df5, 5y BK, age" ///
		13 "Non-mixture cure model, df3, 15y BK, age" 14 "Non-mixture cure model, df5, 15y BK, age" ///
		15 "FPM non-cure, df4" ///
		16 "Expected survival background population") size(vsmall)) xscale(range(0 20)) xlabel(0(2)20)) ///
		legend(pos(2) ring(0) cols(2)) title(, size(zero) nobox) ytitle(Proportion surviving) ytitle(, size(small)) ///
        ylabel(#8, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Distant_nocure_Surv20_SMR1_48m,replace)


sts graph, hazard ci plotopts(lwidth(medium) lpattern(dash)) /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line H1_ln_m14 t_exp50_48 if t_exp50_48<20, sort lcolor(blue) lwidth(thin)) ///
									(line H1_weib_m15 t_exp50_48 if t_exp50_48<20, sort lcolor(orange) lwidth(thin)) ///
									(line haz_m16 tt if tt<20, sort lcolor(red) lpattern(shortdash) lwidth(thin)) /// 
									(line haz_m17 tt if tt<20, sort lcolor(gold) lpattern(shortdash) lwidth(thin)) /// 
									(line haz_m18 tt if tt<20, sort lcolor(red) lwidth(thin)) /// 
									(line haz_m19 tt if tt<20, sort lcolor(gold) lwidth(thin)) /// 
									(line H1_m20 tplot_m20 if tplot_m20<20, sort lcolor(olive) lwidth(thin)) ///
									(line H1_m21 tplot_m21 if tplot_m21<20, sort lcolor(magenta) lwidth(thin)) /// 
									(line haz_m22 tt if tt<20, sort lcolor(lime) lpattern(shortdash) lwidth(thin)) /// 
									(line haz_m23 tt if tt<20, sort lcolor(pink) lpattern(shortdash) lwidth(thin)) /// 
									(line haz_m24 tt if tt<20, sort lcolor(lime) lwidth(thin)) /// 
									(line haz_m25 tt if tt<20, sort lcolor(pink) lwidth(thin)) ///
									(line H1_m26 t_exp50_48 if t_exp50_48<20, sort lcolor(green) lwidth(thin)) /// 
									(line exphaz50_b t_exp50_b if t_exp50_b<20, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Observed smoothed hazard" 3 "Mixture cure model (log-normal)" 4 "Mixture cure model (Weibull)" ///
		5 "Non-mixture cure model, df3, 5y BK" 6 "Non-mixture cure model, df5, 5y BK" ///
		7 "Non-mixture cure model, df3, 15y BK" 8 "Non-mixture cure model, df5, 15y BK" 9 "Mixture cure model (log-normal), age" 10 "Mixture cure model (Weibull), age" ///
		11 "Non-mixture cure model, df3, 5y BK, age" 12 "Non-mixture cure model, df5, 5y BK, age" ///
		13 "Non-mixture cure model, df3, 15y BK, age" 14 "Non-mixture cure model, df5, 15y BK, age" ///
		15 "FPM non-cure, df4" ///
		16 "Expected survival background population") size(vsmall)) xscale(range(0 20)) xlabel(0(2)20)) ///
		legend(pos(2) ring(0) cols(2)) title(, size(zero) nobox) ytitle(Hazard) ytitle(, size(small)) ///
        ylabel(#10, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Distant_nocure_Haz20_SMR1_48m,replace)



* selective plots for paper

sts graph, ci plotopts(lwidth(medium) lpattern(dash))  /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line S1_m20 tplot_m20 if tplot_m20<20, sort lcolor(olive) lwidth(thin)) ///
									(line S1_m21 tplot_m21 if tplot_m21<20, sort lcolor(magenta) lwidth(thin)) ///
									(line surv_m22 tt_1 if tt_1<20, sort lcolor(orange) lwidth(thin)) /// 
									(line surv_m24 tt_1 if tt_1<20, sort lcolor(red) lwidth(thin)) ///
									(line expsurv50_b t_exp50_b if t_exp50_b<20, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Kaplan-Meier" 3 "Mixture cure model (log-normal), age" 4 "Mixture cure model (Weibull), age" ///
		5 "Non-mixture cure model, 2 knot, 5y bk, age" 6 "Non-mixture cure model, 2 knot, 15y bk, age" ///
		7 "Expected survival background population") size(vsmall)) xscale(range(0 20)) xlabel(0(2)20)) ///
		legend(pos(2) ring(0) cols(2)) title("", size(zero) nobox) ytitle(Proportion surviving) ytitle(, size(small)) ///
        ylabel(#8, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 1.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(D_nc_Surv20_SMR1_48m_paper,replace)



sts graph, hazard ci plotopts(lwidth(medium) lpattern(dash)) /// 
									ciopts(recast(rarea) fcolor(midblue%40) fintensity(40) lcolor(none%0)) ///
									addplot((line H1_m20 tplot_m20 if tplot_m20<20, sort lcolor(olive) lwidth(thin)) ///
									(line H1_m21 tplot_m21 if tplot_m21<20, sort lcolor(magenta) lwidth(thin)) ///
									(line haz_m22 tt_1 if tt_1<20, sort lcolor(orange) lwidth(thin)) ///
									(line haz_m24 tt_1 if tt_1<20, sort lcolor(red) lwidth(thin)) ///
									(line exphaz50_b t_exp50_b if t_exp50_b<20, sort lpattern(dot) lcolor(black)), below ///
									legend(order(2 "Observed smoothed hazard" 3 "Mixture cure model (log-normal), age" 4 "Mixture cure model (Weibull), age" ///
		5 "Non-mixture cure model, 2 knot, 5y bk, age" 6 "Non-mixture cure model, 2 knot, 15y bk, age" ///
		7 "Expected survival background population") size(vsmall)) xscale(range(0 20)) xlabel(0(2)20)) ///
		legend(pos(2) ring(0) cols(2)) title("", size(zero) nobox) ytitle(Hazard) ytitle(, size(small)) ///
        ylabel(#10, labsize(small) angle(horizontal) format(%9.2f) nogrid) yscale(range(0 2.0)) ///
		xtitle(Time since randomisation (years)) xtitle(, size(small)) xlabel(, labsize(small)) /// 
        graphregion(color(white)) plotregion(fcolor(white)) name(Di_nc_Haz20_SMR1_48m_paper,replace)




